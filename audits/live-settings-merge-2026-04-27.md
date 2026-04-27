# Live Settings Merge — 2026-04-27

## Before Merge

**Top-level keys (4):** `effortLevel`, `permissions`, `statusLine`, `hooks`

**Hook event coverage:** SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop

**Hook command count: 13**
- SessionStart: hook-profile-loader.sh
- UserPromptSubmit: session-counter.sh
- PreToolUse/Write|Edit|MultiEdit: security-guard.sh, pre-write-secrets-scan.sh, tdd-guard.sh ×15 (per-extension `if` conditions)
- PreToolUse/Bash: git-safety.sh, cost-aware-security-gate.sh
- PreToolUse/Agent: model-routing-guard.js
- PostToolUse/.*: velocity-monitor.sh, circuit-breaker.sh, cost-circuit-breaker.js
- PostToolUse/Write|Edit|MultiEdit: auto-formatter.sh ×4 (per-extension)
- Stop: post-tool-batch.sh, notify-on-long-task.sh

**Missing vs template:** prompt-completeness-inject.sh, quality-gate-inject.sh, session-length-guard.sh, context-bloat-pruner.sh, auto-index-on-archive.sh, autonomy-guard.sh

## After Merge

**Top-level keys (4):** `effortLevel`, `permissions`, `statusLine`, `hooks` — unchanged

**Hook event coverage:** SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop — unchanged

**Hook command count: 19** (+6)

## Hooks Added

| Hook | Event | Matcher |
|------|-------|---------|
| `prompt-completeness-inject.sh` | UserPromptSubmit | (global) |
| `quality-gate-inject.sh` | UserPromptSubmit | (global) |
| `session-length-guard.sh` | UserPromptSubmit | (global) |
| `autonomy-guard.sh` | PreToolUse | AskUserQuestion |
| `auto-index-on-archive.sh` | PostToolUse | Bash |
| `context-bloat-pruner.sh` | PostToolUse | Read\|Bash\|WebFetch |

## User Customizations Preserved

- `statusLine` key (live-only, not in template) — preserved verbatim
- `permissions.additionalDirectories` — live had extra entry (`lukasdlouhy-claude-ecosystem`), preserved
- Per-extension `if` conditions on `tdd-guard.sh` — live's finer-grained wiring kept over template's coarser version
- `node` prefix on JS hooks (`model-routing-guard.js`, `cost-circuit-breaker.js`) — live style kept

## Backup Location

`/Users/lukasdlouhy/.claude/settings.json.backup-2026-04-27`

## Smoke Test

**Hooks tested:** `session-counter.sh` (UserPromptSubmit) and `session-length-guard.sh` (UserPromptSubmit)
**Input:** synthetic JSON payloads via stdin
**Result:** Both exited 0, no stderr output — PASS

## Notes

- `gitleaks-guard.sh` intentionally NOT wired (template notes it requires the `gitleaks` binary; constraint says do not add hooks that point to non-ecosystem paths — but here it exists in hooks/. Left unwired to match template's `_optional_hooks_note` intent: wire only if binary is installed).
- All 22 template hook entries (across 5 event types) are now represented in live settings.
