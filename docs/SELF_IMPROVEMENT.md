# Self-Improvement Loop Architecture

## Overview

The self-improvement loop is a closed-cycle system that audits the Claude Code
ecosystem weekly, identifies degraded or unused components, and optionally opens
PRs to fix the highest-priority issues. Human review is required before any
change merges.

## Components

| File | Role |
|------|------|
| `agents/skill-auditor.md` | Core audit agent (Sonnet) |
| `commands/audit-self.md` | `/audit-self` slash command |
| `scripts/usage-stats.sh` | Invocation count parser |
| `routines/weekly-audit.yaml` | Cron schedule definition |

## Closed Loop

```
Monday 09:00 CET
       |
       v
[weekly-audit routine fires]
       |
       v
usage-stats.sh          — parse 30/7/1d invocation counts
       |
       v
skill-auditor agent     — read all skills/agents/hooks/commands
       |                   (optionally fetch docs.claude.com once)
       |                   grade A-F, recommend keep/refactor/deprecate
       v
audits/<date>-all.md    — saved report
       |
       v
/audit-self --apply     — if P1 issues with grade C/D exist:
       |                   open up to 3 refactor PRs via gh
       |                   skip deprecation (human must confirm)
       v
GitHub PRs              — require human review + merge
       |
       v
Human reviews           — approve, reject, or request changes
       |
       v
[merged improvements feed back into next audit cycle]
```

## Grading System

| Grade | Meaning | Action |
|-------|---------|--------|
| A | Current, used, well-defined | Keep |
| B | Minor gaps | Keep, low-priority fix |
| C | Stale patterns or vague spec | Refactor (auto-PR eligible) |
| D | Redundant, broken, or unused 30d+ | Refactor or deprecate |
| F | Deprecated API, broken, delete candidate | Deprecate (human only) |

## Risk Controls

These controls are non-negotiable and enforced by the audit command:

1. **Never auto-merge.** All PRs are opened as drafts or regular PRs, not
   auto-merged under any circumstance.

2. **Max 3 PRs per weekly run.** Prevents flooding the repo with low-quality
   automated changes.

3. **Never delete user content.** Session archives, memory files, CLAUDE.md,
   and project memories are on the never-touch list. The agent will refuse
   instructions to modify these.

4. **Deprecations require human confirmation.** Grade-D/F components are
   flagged in the report but the `--apply` mode only acts on `refactor`
   actions. Deletions are never automated.

5. **Backup before edit.** Any file modified by `--apply` is first backed up
   as `<filename>.bak-YYYYMMDD`. Backups accumulate in the same directory.

6. **One external fetch per audit.** The skill-auditor may fetch
   `https://docs.claude.com/release-notes` exactly once per run to check for
   deprecated patterns. No other external calls.

## Operating the Loop

### First setup

```bash
# Make scripts executable
chmod +x ~/Desktop/lukasdlouhy-claude-ecosystem/scripts/usage-stats.sh

# Ensure audits directory exists
mkdir -p ~/Desktop/lukasdlouhy-claude-ecosystem/audits

# Manual first run (recommended before scheduling)
/audit-self all
```

### Activate the weekly schedule

Use the `/schedule` skill to register `routines/weekly-audit.yaml`:

```
/schedule create routines/weekly-audit.yaml
```

Or use CronCreate directly with the prompt from that YAML file.

### Manual runs

```
/audit-self all           # full audit, no PRs
/audit-self skills        # skills only
/audit-self --apply       # read latest report, open PRs for P1 refactors
```

### Review audit history

```bash
ls -la ~/Desktop/lukasdlouhy-claude-ecosystem/audits/
```

## Expected Output Volume

- Typical audit: 5-15 minutes of agent time on Sonnet.
- Report length: 200-600 lines.
- PRs per week: 0-3 (most weeks: 0-1).
- Token cost per audit: ~15,000-40,000 tokens on Sonnet.

## Drift Detection

The auditor checks for:
- Frontmatter fields that no longer match the current schema (e.g., renamed
  `tools` field, changed `model` enum values).
- Triggers that reference commands no longer in the Claude Code CLI.
- Skills that duplicate functionality (high overlap in description + triggers).
- Hooks registered for tool names that have been renamed or removed.

Update the auditor's grading rubric in `agents/skill-auditor.md` when the
Claude Code platform makes breaking changes.
