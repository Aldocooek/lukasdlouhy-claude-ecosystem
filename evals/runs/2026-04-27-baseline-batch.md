# Baseline Batch Run — 2026-04-27

All 10 placeholder baselines replaced with real measured numbers.
Model under test: `claude-haiku-4-5`. Judge: `claude-haiku-4-5`. Threshold: ≥6 = pass.

---

## Results (sorted by mean score, ascending)

| Dataset | Cases | Mean Score | Pass Count | Pass Rate | Run ID |
|---|---|---|---|---|---|
| storyboard | 10 | 2.80/10 | 1/10 | 10% | 2026-04-27T120544Z-storyboard |
| perf-auditor | 6 | 3.83/10 | 3/6 | 50% | 2026-04-27T112928Z-perf-auditor |
| brief-author | 6 | 4.00/10 | 1/6 | 17% | 2026-04-27T112353Z-brief-author |
| security-redteam | 8 | 5.25/10 | 3/8 | 38% | 2026-04-27T120527Z-security-redteam |
| ship-checker | 6 | 5.50/10 | 4/6 | 67% | 2026-04-27T113457Z-ship-checker |
| copywriting | 10 | 5.90/10 | 5/10 | 50% | 2026-04-27T120540Z-copywriting |
| video-storyboard | 8 | 6.00/10 | 5/8 | 63% | 2026-04-27T120532Z-video-storyboard |
| prompt-decompose | 8 | 6.00/10 | 5/8 | 63% | 2026-04-27T115700Z-prompt-decompose |
| lean-refactor | 8 | 6.25/10 | 7/8 | 88% | 2026-04-27T110217Z-lean-refactor |
| session-handoff | 5 | 7.20/10 | 5/5 | 100% | 2026-04-27T111844Z-session-handoff |
| marketing-funnel-audit | 8 | 7.25/10 | 8/8 | 100% | 2026-04-27T114852Z-marketing-funnel-audit |

---

## Datasets Skipped

None — all 11 datasets had ≤10 cases. All were run.

Note: `lean-refactor` was already a real baseline from a prior session; it was re-confirmed but not overwritten.

---

## Cost Estimate

- Total cases: 85 (across 11 datasets, including lean-refactor)
- New cases run today: 77 (excluding lean-refactor's 8)
- Model calls: 77 (test) + 77 (judge) = 154 Haiku calls
- Estimate: ~154 × $0.003 = **~$0.46** (well under $3.00 cap)

---

## Worst Performer: `storyboard` — 2.80/10, 10% pass rate

The `/storyboard` command skill outputs permission requests and planning summaries instead of delivering the actual storyboard artifact. 8 of 10 cases received 0–4/10 because the model asked for write-file approval rather than rendering the storyboard inline. This is a skill invocation mode mismatch — the skill is designed for interactive Claude Code use (where it can write files), but the eval harness runs it headless with `claude -p` where tool calls fail silently. **Investigate:** the skill SKILL.md likely unconditionally attempts to write a file rather than outputting markdown to stdout when no filesystem is available.

## Second Worst: `brief-author` — 4.00/10, 17% pass rate

The agent correctly identifies critical blockers but fails to deliver the required structured template format in 5 of 6 cases. Pattern: the agent writes conversational elicitation responses instead of the labeled template artifact the rubric requires. The AGENT.md definition likely under-specifies the required output format.

## Third Worst: `perf-auditor` — 3.83/10, 50% pass rate

3 of 6 cases scored 1–2/10 because the agent requested source code files instead of auditing from the metrics already provided in the prompt. Root cause: the agent's default behavior is to ask for more context before diagnosing — appropriate in real sessions but failing in eval where all context is embedded in the input.

## Best Performers

- `marketing-funnel-audit`: 7.25/10, 100% pass rate — consistent across all 8 cases
- `session-handoff`: 7.20/10, 100% pass rate — all 5 cases passed, including one 8/10

---

## Runner Bugs Found

**1. `bc` parse error on transient judge failure (non-fatal if retried).**
First run of `marketing-funnel-audit` failed mid-run at case 5 with "Parse error: bad expression" from `bc`. Cause: the LLM judge returned a malformed score (likely empty string or newline) for that case, and `TOTAL_SCORE + <empty>` is invalid in `bc`. The `set -euo pipefail` caused script abort before the run file was written. Fix applied: simply re-ran the dataset; the second run completed cleanly. The runner should sanitize `CASE_SCORE` to a numeric default (e.g., `CASE_SCORE="${CASE_SCORE//[^0-9.]/}"`) before passing to `bc`. Not patched here — documenting for follow-up.

---

## Baseline Files Updated

All 10 placeholder baselines updated in `evals/baselines/`:
`brief-author`, `copywriting`, `marketing-funnel-audit`, `perf-auditor`, `prompt-decompose`, `security-redteam`, `session-handoff`, `ship-checker`, `storyboard`, `video-storyboard`
