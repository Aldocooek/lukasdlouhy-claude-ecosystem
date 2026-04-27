# Eval Results: First Run

**Date:** 2026-04-26  
**Run ID:** 2026-04-26-first-run  
**Judge Model:** Haiku  
**Executor Model:** Sonnet  
**Timestamp:** 2026-04-26T14:59:36Z

---

## Summary

| Target | N | Avg Score | Pass Rate | Verdict |
|--------|---|-----------|-----------|---------|
| copy-strategist | 3 | 9.0 | 11/12 | PASS |
| lean-refactor | 3 | 8.67 | 14/15 | PASS (pending fix) |
| **Overall** | **6** | **8.83** | **25/27** | **PASS** |

---

## Per-Target Detail

### copy-strategist

Dataset: `evals/datasets/copywriting.jsonl`

| Case | Score | Criteria | Notes |
|------|-------|----------|-------|
| copy-001 | 10 | 4/4 | Perfect execution. Headline + body copy aligned with brief. |
| copy-002 | 7 | 3/4 | Headline rubric mismatched to ad-body task. Rubric error, not skill fault. |
| copy-003 | 10 | 4/4 | Strong persona discipline. Call-to-action conversion-optimized. |

**Strength:** Consistent persona application, conversion-focused structure.

### lean-refactor

Dataset: `evals/datasets/lean-refactor.jsonl`

| Case | Score | Criteria | Notes |
|------|-------|----------|-------|
| lean-001 | 10 | 5/5 | Python refactor. Clean idiomatic reduction. |
| lean-002 | 10 | 5/5 | JavaScript refactor. Effective compaction without readability loss. |
| lean-003 | 6 | 4/5 | Go refactor. scanErr fold conflicts with idiomatic explicit error handling. Language-idiom issue. |

**Weakness:** Over-applies compaction patterns to Go-idiomatic error handling. Requires language-aware guards.

---

## Aggregate Metrics

- **Overall Average:** 8.83 / 10
- **Overall Pass Rate:** 25/27 criteria (92.6%)
- **Top Strength:** copy-strategist persona discipline; lean-refactor systematic Python/JS coverage
- **Top Weakness:** lean-refactor error-handling over-compaction in Go; copy-002 dataset rubric mismatch
- **Regression Risk:** HIGH on lean-refactor for Go/Rust if prompt tightens without language-idiom awareness

---

## Action Items (From JSON)

1. **Fix lean-refactor SKILL.md:** Add explicit per-language idiom guards
   - Go: prefer explicit error handling (no folding scanErr patterns)
   - Rust: ? operator preferred over error wrapping
   - Python/JS: safe to apply compaction liberally

2. **Fix evals/datasets/copywriting.jsonl copy-002:** Replace 'headline ≤8 words' rubric with 'ad body ≤125 chars' (task-appropriate)

3. **Promote run as baseline:** Once fixes applied, lock 2026-04-26-first-run as official baseline for both skills

---

## Next Eval Cadence

- **Per-skill:** Run on every meaningful change to skill prompts or datasets
- **Full suite:** Weekly (every Monday 02:00 UTC) to catch regressions
- **Before release:** Always run full suite before tagging version
- **Monitoring:** Integrate regression alerts into dashboard (delta < -0.5 triggers warning)

Estimated cost: USD 2.40/week (6 cases × 2 models × 10 runs/week ≈ 50K tokens Sonnet).
