# Conditional Hooks in Claude Code

## What syntax is actually supported

Claude Code supports a native `if` field on every hook handler object. It uses **permission rule syntax**: `ToolName(glob-pattern)`.

```json
{
  "type": "command",
  "if": "Edit(*.ts)",
  "command": "/path/to/hook.sh"
}
```

### Rules

- Only evaluated on tool events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`. On `SessionStart`, `Stop`, etc., hooks with `if` **never run**.
- Pattern is a glob matched against the tool's primary argument (file path for Write/Edit, command string for Bash).
- Bash matching strips leading `VAR=value` assignments. Hooks with `if: "Bash(git push *)"` fire even if prefixed with env vars.
- If the Bash command is too complex to parse, the hook **always runs** (safe default).
- `if: "Bash|Edit"` (combining tool names in `if`) is **not valid**. Use separate handler entries per tool.
- The `matcher` on the outer group still gates first — `if` is a second-level filter within the matched group.

### Execution flow

```
Event fires
  → matcher checks tool name (regex, on the group)
    → if matches (or omitted): evaluate if condition on each handler
      → if condition matches (or omitted): spawn hook
```

## MCP result-size override

**Not supported.** As of 2026-04, there is no `maxResultSize`, `outputSize`, or per-tool limit field in the Claude Code settings schema (`https://json.schemastore.org/claude-code-settings.json`). MCP result sizes cannot be capped from `settings.json`. Options if needed:

- Configure limits at the MCP server definition level in `.mcp.json`
- Use a PostToolUse hook to truncate/summarize large MCP responses
- Raise with Anthropic — the setting does not exist yet

## Hooks using conditional `if` and why

### tdd-guard (PreToolUse Write|Edit|MultiEdit)

Without `if`, tdd-guard spawned a process for every file write — including `.md`, `.yaml`, `.json`, config files, and test files themselves. The hook already filtered by extension internally, but the process spawn still cost ~10–30ms and a subprocess slot per call.

With `if`, the hook only spawns for files where TDD applies:

```json
{ "type": "command", "if": "Write(*.ts)", "command": "...tdd-guard.sh" },
{ "type": "command", "if": "Write(*.tsx)", "command": "...tdd-guard.sh" },
{ "type": "command", "if": "Write(*.js)", "command": "...tdd-guard.sh" },
{ "type": "command", "if": "Write(*.jsx)", "command": "...tdd-guard.sh" },
{ "type": "command", "if": "Write(*.py)", "command": "...tdd-guard.sh" },
{ "type": "command", "if": "Edit(*.ts)", "command": "...tdd-guard.sh" },
... (same for tsx/js/jsx/py for Edit and MultiEdit)
```

Because `if` can't combine tools (`Write|Edit` is invalid in the `if` field), separate entries are required per tool × extension combination. This is verbose but correct.

**Estimated saving**: tdd-guard previously fired on every Write/Edit/MultiEdit. In a typical session ~60–70% of file writes are `.md`, `.json`, `.sh`, `.yaml` — none of which benefit from TDD checks. Removing those spawns saves roughly 60–70% of tdd-guard process invocations.

### auto-formatter (PostToolUse Write|Edit|MultiEdit)

The formatter only acts on `.md` and `.json`. Previously it spawned on every Write/Edit/MultiEdit and exited early after reading stdin and checking the extension. With `if`, it only spawns for those two extensions:

```json
{ "type": "command", "if": "Write(*.md)", "command": "...auto-formatter.sh" },
{ "type": "command", "if": "Write(*.json)", "command": "...auto-formatter.sh" },
{ "type": "command", "if": "Edit(*.md)", "command": "...auto-formatter.sh" },
{ "type": "command", "if": "Edit(*.json)", "command": "...auto-formatter.sh" }
```

Note: `MultiEdit` is not included because `auto-formatter.sh` reads a single `tool_input.file_path` — MultiEdit edits multiple files per call and its schema differs. The formatter would silently no-op on MultiEdit anyway.

**Estimated saving**: ~80–90% of auto-formatter spawns eliminated (most writes are `.ts`, `.tsx`, `.sh` etc., not `.md`/`.json`).

### security-guard (PreToolUse Write|Edit|MultiEdit)

Always-on — no `if` condition applied. Security scanning should run on every file write regardless of extension. The internal script handles `.gitignore`-style pattern exclusions if needed.

### Hooks without `if` (correct as-is)

| Hook | Reason |
|------|--------|
| `security-guard.sh` | Must run on all writes — no safe subset |
| `pre-write-secrets-scan.sh` | Must run on all writes |
| `git-safety.sh` | Bash matcher already scopes it; `if` would add complexity for minimal gain |
| `cost-aware-security-gate.sh` | Advisory only, already on Bash matcher |
| `model-routing-guard.js` | Agent matcher already scopes it |
| `velocity-monitor.sh` | Must fire on all tool use |
| `circuit-breaker.sh` | Must fire on all tool use |
| `cost-circuit-breaker.js` | Must fire on all tool use |
| `session-counter.sh` | UserPromptSubmit — `if` not evaluated on non-tool events |
| `hook-profile-loader.sh` | SessionStart — `if` not evaluated on non-tool events |
| `post-tool-batch.sh` | Stop — `if` not evaluated on non-tool events |
| `notify-on-long-task.sh` | Stop — `if` not evaluated on non-tool events |

## Validation

```bash
python3 -c "import json; json.load(open('/Users/lukasdlouhy/.claude/settings.json')); print('valid')"
```
