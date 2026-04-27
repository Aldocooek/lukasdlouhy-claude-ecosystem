# First Real Eval Run — 2026-04-27

## What ran

- Dataset: `evals/datasets/lean-refactor.jsonl` (8 cases)
- Target skill: `lean-refactor`
- Model under test: `claude-haiku-4-5`
- Judge: `claude-haiku-4-5` (default)
- Run ID: `2026-04-27T110217Z-lean-refactor`

## Results

| Metric | Value |
|---|---|
| Mean score | 6.25 / 10 |
| Pass rate (≥6) | 87.5% (7/8) |
| Failed cases | lean-006 (Ruby, score 4) |

## What worked

Runner executed cleanly end-to-end. All 8 cases invoked, judged, and written to JSON. Dry-run mode works for iteration without spend. Judge produced coherent per-criterion reasoning.

## What broke + fixes applied

**Bug 1 — `run-eval.sh` line 241**: `bc` does not support ternary `? :` syntax. `PASS_RATE` calculation crashed with `parse error: bad character '?'`, causing runner to exit 2 on every dry-run.
Fix: replaced ternary with bash `if/else` block.

**Bug 2 — `run-eval.sh` line 301**: `pass_rate_pct` jq formula used pre-computed `CASE_COUNT` arithmetic inline in jq; fragile coupling to `bc` float output. Fixed by passing `$PASS_RATE` as a pre-computed `--argjson` arg.

Both fixes in `/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/evals/runner/run-eval.sh`.

## Cost actually spent

Unknown exactly — `claude -p` uses account session auth, not a metered API key. 16 Haiku calls total (8 skill invocations + 8 judge invocations). At Haiku pricing (~$0.001 per call at typical prompt sizes), estimated < $0.05.

## Skill findings

- lean-006 (Ruby): skill misses nil-check idiom and string interpolation pattern. Needs Ruby-specific examples added.
- lean-003 (Go): skill argues against err/scanErr rename, contradicting the rubric. The `pending_fix_action` in the old baseline was correct — language-idiom guards needed.
- lean-004 (Python class): misses mutable instance state → local variable refactor pattern.

## Recommendations for next runs

1. Fix `lean-refactor` SKILL.md with Ruby nil-check and string interpolation examples before next run.
2. Add Go per-language idiom guards (err shadowing).
3. Run with `--baseline evals/baselines/lean-refactor-baseline.json` to catch regressions going forward.
4. Consider `--judge sonnet` for borderline WARN cases to reduce judge noise.
