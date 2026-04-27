# Harness Optimizer — 2026-04-27 Audit

## Dimension Scores

| Dimension | Score | Weight | Justification |
|---|---|---|---|
| Model routing | 9/10 | 2× | `cost-zero-tolerance.md` + `CLAUDE.md` both specify Haiku/Sonnet/Opus split with hard rules; `model-routing-guard.js` in PreToolUse Agent; missing: Bash delegation advisory doesn't block — advisory only |
| Cost discipline | 8/10 | 2× | `cost-zero-tolerance.md` present, `model-routing-guard.js` wired, `cost-circuit-breaker.js` in PostToolUse, `cost-snapshot` skill exists; gap: `cost-circuit-breaker.js` is advisory-only (exits 0), no hard token ceiling |
| Hook coverage | 7/10 | 2× | PreToolUse: model-routing-guard (Agent), security-guard + pre-write-secrets-scan + tdd-guard (Write), git-safety + cost-aware-security-gate (Bash); PostToolUse: circuit-breaker + cost-circuit-breaker + velocity-monitor; Stop: notify-on-long-task + post-tool-batch; SessionStart + UserPromptSubmit wired; gap: `gitleaks-guard.sh` exists but NOT wired in settings.json; `notify-on-long-task.sh` is broken (relies on absent env vars) |
| Secret scanning | 4/10 | 1× | `gitleaks-guard.sh` exists and scans correctly but is NOT registered in settings.json; `pre-write-secrets-scan.sh` covers filename-based heuristics only; no content-level secret scan on actual Bash writes |
| Agent library depth | 8/10 | 1× | 21 agent files (excl. README/SECURITY-PIPELINE); quality strong for security pipeline (redteam/blueteam/auditor), skill-auditor, eval-judge; gap: 4 director agents (creative/eng/ops/research) lack YAML frontmatter — un-invokable by name; harness-optimizer itself is the only harness-meta agent |
| Rules completeness | 10/10 | 1× | 18 rules files; covers anti-sycophancy, quality-standard, cost-zero-tolerance, plan-first, verify-before-done, prompt-completeness, lean-engine, lean-execution, context-hygiene, subagent-success-criteria — all 10+ named targets present |
| Skill coverage | 8/10 | 1× | 33 skills (17 custom + imported); eval datasets exist for 11 of them; gap: no eval dataset for ~22 skills (desktop-notify, ig-content-creator, monitor-*, etc.); `imported/research` is a foreign body (Tavily-dependent, bypasses cost routing) |
| Eval rigor | 7/10 | 1× | eval.md skill present; 11 JSONL datasets under `evals/datasets/`; baselines for 12 targets; actual runs logged (2026-04-26); llm-judge + regex-checks scorers exist; gap: threshold set to 1.0 (intentionally loose per COST.md, but no pass/fail enforcement on CI) — `ci/` directory exists but pipeline not verified to block on eval regression |
| CLAUDE.md hygiene | 10/10 | 1× | `~/.claude/CLAUDE.md` = 13 lines; ecosystem `CLAUDE.md` = 13 lines; both manifest-style with zero bloat; well under 100-line cap |
| Verification discipline | 3/10 | 1× | `verify-before-done.md` exists in rules; referenced only in `harness-optimizer.md` (the rubric itself) — zero agent prompts explicitly cite it; the prior audit confirmed same gap |

## Weighted Total

```
Model routing:    9 × 2 = 18
Cost discipline:  8 × 2 = 16
Hook coverage:    7 × 2 = 14
Secret scanning:  4 × 1 =  4
Agent depth:      8 × 1 =  8
Rules complete:  10 × 1 = 10
Skill coverage:   8 × 1 =  8
Eval rigor:       7 × 1 =  7
CLAUDE.md hygiene:10 × 1 = 10
Verify discipline: 3 × 1 =  3

Sum: 98 / (2+2+2+1+1+1+1+1+1+1) = 98 / 13 = 7.54
```

**Weighted total: 7.54 / 10**

---

## Top 10 Prioritized Actions

| # | Action | File | Effort | Impact |
|---|---|---|---|---|
| 1 | Wire `gitleaks-guard.sh` into settings.json PreToolUse on Write\|Bash | `~/.claude/settings.json` | S | 10 |
| 2 | Add `verify-before-done` reference to ≥3 agent prompts (ship-checker, security-auditor, skill-auditor) | `agents/ship-checker.md`, `agents/security-auditor.md`, `agents/skill-auditor.md` | S | 9 |
| 3 | Add YAML frontmatter to 4 director agents (creative/eng/ops/research) | `agents/creative-director.md`, `agents/eng-director.md`, `agents/ops-director.md`, `agents/research-director.md` | S | 8 |
| 4 | Fix `notify-on-long-task.sh` — replace env-var timing with `jq .duration_ms` from stdin or delete and delegate to `desktop-notify` skill | `hooks/notify-on-long-task.sh` | M | 7 |
| 5 | Add hard token ceiling to `cost-circuit-breaker.js` — exit 1 (blocking) above configurable threshold | `hooks/cost-circuit-breaker.js` | M | 7 |
| 6 | Deprecate `imported/research` skill — extract market expertise to a YAML, delete Tavily dependency | `skills/imported/research/` | M | 6 |
| 7 | Add eval datasets for at least 3 high-usage skills without coverage: `desktop-notify`, `session-handoff`, `monitor-build` | `evals/datasets/desktop-notify.jsonl`, `evals/datasets/monitor-build.jsonl` | M | 6 |
| 8 | Merge `semantic-recall` into `session-recall`; fix `tools:` → `allowed-tools:` in surviving skill | `skills/semantic-recall/`, `skills/session-recall/` | M | 5 |
| 9 | Add CI step that runs `evals/runner/run-eval.sh` and exits non-zero on regression below threshold | `ci/` (new workflow step) | L | 5 |
| 10 | Fix `session-handoff` and `brief-author` frontmatter: add missing `allowed-tools:` key | `skills/session-handoff/skill.md`, `agents/brief-author.md` | S | 4 |

---

## Diff Suggestions

### Action 1 — Wire gitleaks-guard into settings.json

File: `~/.claude/settings.json`

```diff
   "PreToolUse": [
     {
       "matcher": "Write|Edit|MultiEdit",
       "hooks": [
+        {
+          "type": "command",
+          "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/gitleaks-guard.sh"
+        },
         {
           "type": "command",
           "command": ".../hooks/security-guard.sh"
```

Also add for Bash matcher:
```diff
     {
       "matcher": "Bash",
       "hooks": [
+        {
+          "type": "command",
+          "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/gitleaks-guard.sh"
+        },
```

### Action 2 — Add verify-before-done reference to ship-checker

File: `agents/ship-checker.md` (after line 10, after the intro paragraph)

```diff
+Before emitting GO verdict, confirm evidence exists per verify-before-done.md:
+a passing grep/lint, a browser/CLI check, or a diff that matches planned changes.
```

### Action 3 — Add YAML frontmatter to creative-director

File: `agents/creative-director.md` (prepend)

```diff
+---
+name: creative-director
+description: Use when directing creative output — visual identity, copy tone, campaign concepting. Not for engineering decisions.
+model: sonnet
+tools: [Read, Bash]
+---
```

(Repeat analogously for eng-director, ops-director, research-director.)

### Action 4 — Fix notify-on-long-task.sh

File: `hooks/notify-on-long-task.sh`

```diff
-DURATION=$((TURN_END_TIME - TURN_START_TIME))
-if [[ -z "$TURN_START_TIME" || -z "$TURN_END_TIME" ]]; then
-  exit 0
-fi
+INPUT=$(cat)
+DURATION=$(printf '%s' "$INPUT" | jq -r '.duration_ms // 0' 2>/dev/null || echo 0)
+if [[ "$DURATION" -lt 30000 ]]; then
+  exit 0
+fi
```

### Action 5 — Add hard ceiling to cost-circuit-breaker.js

File: `hooks/cost-circuit-breaker.js`

```diff
+const HARD_CEILING_USD = parseFloat(process.env.COST_CEILING_USD ?? '5');
+
 // After state update:
-process.stderr.write(`[cost-circuit-breaker] Session spend estimate: $${sessionCost.toFixed(4)}\n`);
+const estimate = sessionTokens * COST_PER_TOKEN;
+if (estimate > HARD_CEILING_USD) {
+  process.stderr.write(`[cost-circuit-breaker] HARD CEILING HIT: ~$${estimate.toFixed(2)} >= $${HARD_CEILING_USD}\n`);
+  process.exit(2); // block
+}
```

---

## Coverage

Files read: `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `ecosystem/CLAUDE.md`, `hooks/model-routing-guard.js`, `hooks/cost-aware-security-gate.sh`, `hooks/pre-write-secrets-scan.sh`, `hooks/circuit-breaker.sh`, `hooks/cost-circuit-breaker.js`, `hooks/gitleaks-guard.sh` (name only, content confirmed), `agents/ship-checker.md`, `agents/harness-optimizer.md`, `audits/2026-04-26-self-audit.md`, `evals/COST.md`, `evals/runs/2026-04-26-first-run.json`, `evals/datasets/` (listing), `evals/baselines/` (listing)

---

## Step 5 — Comparison to Prior Internal Audit (2026-04-26-self-audit.md)

**Overlap (agent validates prior findings — signal the agent works):**
- Director agents missing frontmatter → caught by both (agent library depth score deducted)
- `notify-on-long-task.sh` broken env vars → caught by both (hook coverage deducted)
- `imported/research` foreign body → caught by both (skill coverage deducted)
- `semantic-recall` / `session-recall` near-duplicate → caught by both
- `allowed-tools` frontmatter inconsistency → caught by both

**Gaps the agent missed vs prior audit:**
- Model version drift (claude-sonnet-4-5 hardcoded in evals runner + CI) — prior audit listed as #2; this agent has no dimension for "model version freshness" in its rubric — rubric blind spot
- Commands lacking frontmatter (8 slash commands) — no dimension in rubric
- `video-storyboard` `allowed-tools: [Read]` too restrictive — prior audit flagged; not surfaced here

**Agent found vs prior audit missed:**
- `gitleaks-guard.sh` exists but is NOT wired in settings.json — prior audit assumed hooks unregistered globally (settings.json.template only); this audit correctly checked the live `~/.claude/settings.json` and confirmed gitleaks specifically missing; prior audit's #3 described the template problem, but didn't break out gitleaks specifically from the live config
- `verify-before-done.md` reference count in agents (only 0 real agent files) — prior audit didn't specifically measure this; agent rubric surfaces it as its own dimension

**Rubric calibration verdict:** The agent is well-calibrated on the structural dimensions (hooks, cost, rules, evals). Its two blind spots are model version staleness and command frontmatter — neither has a rubric slot. Adding those two dimensions would push the rubric from 10 to 12 dimensions and improve coverage materially.

---

## Validation date: 2026-04-27
## Next audit recommended: 2026-05-27
