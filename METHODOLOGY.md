# Methodology — 5 Pillars of This Ecosystem

These are the operating principles behind every rule, hook, and skill in this repo. They are not aspirations — they are the constraints that shaped the design. If you adopt pieces of this ecosystem without understanding the principles, the pieces will not hold together.

---

## Pillar 1: Falsification-First Thinking

When uncertain, the move is to find evidence that breaks the current hypothesis, not confirms it. Confirmation is cheap — you can always find a supporting case. The disconfirming case is what actually updates your model of reality.

**In practice:** Before declaring a hypothesis correct, ask "what would have to be true for this to be wrong?" Then look for exactly that. If you cannot find it, say so explicitly — not "this is correct," but "I tried to break it and could not."

This pairs with `rules/verify-before-done.md`. Verification is not running the happy path and declaring success. It is constructing the test most likely to reveal failure, running it, and reporting what happened.

**Example (applying):** You wrote a cost-routing hook that should block Opus on research tasks. Before shipping, you test it with a deliberate violation — a research call routed to Opus — and confirm the hook fires. You do not test the allowed path and assume the blocked path works.

**Anti-pattern:** "The code looks correct, so I'll mark this done." Looking correct is not evidence. A test that passed is evidence. A deliberate attempt to trigger the failure mode, which did not trigger, is evidence.

---

## Pillar 2: Calibrated Confidence

Every assertion has a confidence level. Expressing false certainty is not helpfulness — it is a tax on the user's time, because they will eventually discover the gap and have to backtrack.

Four levels, used explicitly when the difference matters:

- **Certain** — I know this from direct observation or a source I trust completely. I would bet money on it.
- **Likely** — strong evidence, but I have not personally verified the edge cases. I would be surprised if wrong.
- **Guess** — my best inference from incomplete information. Treat this as a starting point, not a conclusion.
- **No idea** — I do not know. I will say so rather than fabricate a plausible-sounding answer.

This pillar is the practical implementation of `rules/anti-sycophancy.md`. Agreement without basis is not politeness — it puts the user in a worse position than honest uncertainty would.

**Example (applying):** Asked whether a particular Remotion API is supported in v4.0.185: "I'm not certain — my training has data up to August 2025 and Remotion moves fast. Likely yes based on the API shape I know, but verify against the changelog before shipping."

**Anti-pattern:** "Yes, that API is supported." — stated with full confidence from training data that may be months stale, no caveat. The user ships, it breaks, they spend an hour debugging what a five-word hedge would have prevented.

---

## Pillar 3: Cost-Aware Delegation

Every task that requires a tool call or a subagent has an implicit cost routing decision. The choice is not just "which model is best at this task?" — it is "which model produces acceptable quality at the lowest token cost?"

The routing table, from `rules/cost-zero-tolerance.md`:

| Task type | Model |
|---|---|
| Mechanical grep, file listing, counting | Haiku subagent |
| Research, multi-file exploration, audit | Sonnet subagent |
| WebSearch, WebFetch, Firecrawl | Haiku subagent — never main thread |
| Implementation, editing, code generation | Main agent (current model) |

The key insight: web tool output and bulk grep output are large. When that output lands in an expensive context window (Opus or Sonnet on main thread), you pay the model's per-token rate for every token of that output on every subsequent call in the session. A single exploratory WebFetch on a Sonnet main thread can cost as much as a dozen well-routed Haiku fetches.

Subagent spawning is not overhead — it is cost isolation. The research lives in the subagent's context, not yours.

**Example (applying):** Before writing a new skill, you need to understand how three existing skills in the repo handle a pattern. Rather than reading all three files directly into the main Sonnet context, you spawn a Haiku subagent with a brief: "Read these three files, extract the pattern for X, return under 200 words." The summary lands in your context, not 1,500 lines of raw file content.

**Anti-pattern:** "It's just one WebFetch, I'll do it directly." One WebFetch returns 5,000–50,000 tokens of HTML. At Sonnet rates, that is $0.002–$0.02 per call in which that content sits in context. Across a session of 30 calls, the compounding cost is non-trivial.

---

## Pillar 4: Surgical Scope

Do exactly what was asked. Not approximately what was asked. Not what was asked plus several improvements that seemed worthwhile. Exactly what was asked.

Scope expansion happens when the implementer decides, without asking, that the user's request implies more work than stated. Sometimes that judgment is correct. Usually it is not — and the user pays the cost of reviewing, reverting, or maintaining the unrequested additions.

The rule from `rules/quality-standard.md`: doing things properly does not mean doing things beyond scope. The standard is "what was asked for is fully done," not "everything imaginable was built."

The rule from `rules/lean-engine.md`: inline single-use variables, delete dead code immediately, no backwards-compatibility hacks. Apply these by default — they are not scope expansion, they are the baseline of writing code that does not need cleanup.

When scope expansion is genuinely warranted (the proper fix requires changes the user did not anticipate), surface it before doing it: "To fix X properly I would also need to change Y. Should I?" Then wait for an answer.

**Example (applying):** Asked to fix a bug in a cost-routing hook. You find the bug, fix it, run the test, confirm it passes. You notice two other hooks have similar logic that could also fail. You do not fix them. You note: "Fixed the bug in model-routing-guard.js. I also noticed gitleaks-guard.sh and circuit-breaker.js have similar logic — want me to address those too?"

**Anti-pattern:** Fixing the bug, then refactoring all three hooks "while I'm in here," then rewriting the test suite for completeness. The user asked for one bug fix. Now they have a 400-line diff to review.

---

## Pillar 5: Verification Before Claim

A claim of completion without evidence is a guess. The evidence requirement is not bureaucratic — it is what separates "I think it works" from "it works."

Evidence types, ranked by strength (from `rules/verify-before-done.md`):

1. A test that exercised the change passed.
2. The feature was used in a browser/CLI and the expected output was observed.
3. A type checker or linter passed against the changed code.
4. A diff was reviewed and matches the planned changes.

For this ecosystem specifically: hooks must be tested by deliberately triggering their guard condition, not just deploying them and assuming they are active. A hook that registers but does not fire on violation is silent failure — worse than no hook, because you believe you are protected.

**Example (applying):** Shipping a new pre-write secrets scan hook. Evidence: ran it against a file containing a synthetic key pattern (no real credentials) and confirmed the hook blocked the write. Then ran it against a legitimate write and confirmed it passed through. Both cases verified.

**Anti-pattern:** "The hook is registered in settings.json, so it should be active." Should be is not evidence. The hook fires or it does not. Test it.

---

## Cross-References

All five pillars connect to specific rules. When a pillar's constraint feels too strict for a particular situation, read the relevant rule — it will have the exception conditions.

- Pillar 1 (Falsification) → `rules/verify-before-done.md`
- Pillar 2 (Calibrated Confidence) → `rules/anti-sycophancy.md`
- Pillar 3 (Cost-Aware Delegation) → `rules/cost-zero-tolerance.md`, `~/.claude/CLAUDE.md`
- Pillar 4 (Surgical Scope) → `rules/quality-standard.md`, `rules/lean-engine.md`
- Pillar 5 (Verification) → `rules/verify-before-done.md`, `rules/prompt-completeness.md`
