# Power User Patterns

Advanced techniques for Claude Code automation and efficiency.

## 1. Bash Dynamic Injection

Use backtick syntax to inject bash command output directly into skills or commands.

**Syntax:** `` !`command` ``

**Examples:**

Inject current directory:
```
/analyze-codebase !`pwd`
```

Inject git branch:
```
/format-commit-msg "Feature for !`git branch --show-current`"
```

Inject timestamp:
```
/log-event "Deploy at !`date +%Y-%m-%d_%H:%M:%S`"
```

Inject file list:
```
/review-files !`ls -1 src/*.ts`
```

**How it works:** Claude Code expands `` !`...` `` before passing to skill/command handler.

---

## 2. File Reference in Slash Commands

Inline file content into slash commands using `@` syntax.

**Syntax:** `/command @filename.md [args]`

**Examples:**

Pass config file to init command:
```
/init @CLAUDE.md
```

Pass PR template to create:
```
/create-pr @templates/pr-template.md
```

Pass test plan:
```
/run-tests @QA_PLAN.md
```

**How it works:** Claude Code reads file, inlines content as string argument.

---

## 3. $ARGUMENTS Substitution

Reference slash command arguments in nested commands.

**Example skill definition:**
```
/build-video [--format FORMAT] [--output PATH]
# Internally calls:
# /generate-thumbnail --format=$FORMAT --path=$OUTPUT/thumb.jpg
```

**Use case:** Pass user arguments down to sub-commands without re-prompting.

---

## 4. Path-Scoped Rules via Glob Patterns

Load rules based on file path using glob matching.

**Example `.claude/settings.json`:**
```json
{
  "rules": [
    {
      "glob": "src/**/*.tsx",
      "allowedTools": ["playwright-qa-cli", "update-config"],
      "maxTokens": 50000
    },
    {
      "glob": "scripts/**/*.sh",
      "allowedTools": ["bash", "read"],
      "runInBackground": true
    }
  ]
}
```

**Behavior:** When editing `src/components/Button.tsx`, only playwright-qa and update-config are allowed. When in scripts/ dir, Bash runs in background by default.

**Reference:** See `rules/path-scoped-loading.md` for full spec.

---

## 5. Hook Profile Environment Variable

Control automation depth via `HOOK_PROFILE` env var.

**Profiles:**

- `off` — No hooks, no auto-behaviors
- `minimal` — Only critical hooks (pre-commit security checks)
- `standard` — Default: pre-commit, post-deploy, pre-push hooks
- `strict` — All hooks + cost alerts, approval gates, slow-but-safe compaction

**Usage:**
```bash
export HOOK_PROFILE=minimal
claude-code start  # Runs with minimal hooks only

HOOK_PROFILE=strict npx claude-code  # One-shot with strict mode
```

**Examples by profile:**
- `minimal`: Skip test hooks, run linter only
- `standard`: Run linter + tests + pre-commit checks
- `strict`: Same + rate-limit cost, require approval for deployment, auto-compact at 50 msgs

---

## 6. Subagent Isolation with Worktree

Spawn isolated subagent in a clean worktree for risky operations.

**Usage:**
```
Start a new subagent:
  with "code-review": Use worktree for analysis
  model: "sonnet"
  
Subagent runs:
  /worktree create feature-review
  # Cloned repo in isolated state
  # No side effects on main working tree
  # Auto-cleaned on exit
```

**When to use:** Security audits, destructive refactors, testing format changes.

---

## 7. Subagent run_in_background with Status Polling

Long-running tasks execute in background; main session continues.

**Example:**
```
You: Deploy to production
Claude: Spawning background agent for deploy...
  Agent ID: bg-deploy-2026-04-26-14-32
  Status: Running
  Check status: /status bg-deploy-2026-04-26-14-32

You: [continue working on next task]

[Background agent finishes 20 min later]
Notification: Deploy succeeded. 42 commits, 8min build time.
```

**In settings.json:**
```json
{
  "commands": {
    "/deploy": {
      "runInBackground": true,
      "notifyOnCompletion": true
    }
  }
}
```

---

## 8. Output Style Stacking

Layer output formatting for readability.

**Example:**
```json
{
  "outputStyle": {
    "format": "markdown",
    "theme": "dark",
    "section_separator": "---",
    "code_block_lang": "typescript",
    "callout_prefix": "TIP:",
    "max_line_length": 88
  }
}
```

**Result:** Code blocks auto-highlight as TypeScript, callouts prefixed with "TIP:", markdown renders with dark theme.

---

## Real-World Example: Automated Video Render + Notify

Combine patterns 1, 3, 5, and 7:

```
/render-video \
  --input=!`find . -name "*.h264" | head -1` \
  --format=$FORMAT \
  --notify-channel=@slack-channel.txt

# Internally:
# 1. Expands !`find...` to actual file
# 2. Passes $FORMAT from user args
# 3. Reads Slack channel from file (@slack-channel.txt)
# 4. Runs in background (HOOK_PROFILE=standard)
# 5. Notifies on completion
```

**Cost:** Standard profile keeps token usage low (subagent on Haiku), background execution frees main session.
