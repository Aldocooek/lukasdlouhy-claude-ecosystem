---
name: quality-standard
description: Boil the Ocean lite — AI marginal cost of completeness is near-zero, so finish properly the first time.
---

# Quality Standard — Finish Properly the First Time

The marginal cost of doing something completely versus halfway is near-zero for AI. There is no excuse for half-implementations.

## The Core Principle

When the real fix is reachable, take it. When a feature can be complete, make it complete. The rework cost of revisiting a half-done thing is always higher than finishing it now — user attention, re-prompting, context reload, token burn on a second pass.

## Hard Prohibitions

**NO `// TODO: implement later`** unless the user explicitly scoped the task as a stub. If you write a TODO, you own it — complete it in the same session.

**NO workarounds when the real fix is in reach.** A workaround is acceptable only when the real fix requires information you do not have or a dependency that is genuinely unavailable. "It's faster" is not a reason.

**NO half-implementations.** A function that handles 3 of 5 cases is broken, not partial. Either handle all cases or state explicitly which cases are out of scope and why.

**NO "I'll leave error handling as an exercise."** Error paths are part of the implementation. Handle them or document the explicit decision to skip them.

## What "Properly" Means

- The feature works end-to-end, not just the happy path.
- Edge cases are handled or consciously excluded with a comment explaining why.
- The code is in its final form, not a prototype that needs cleanup later.
- Tests exist where the codebase pattern requires them.

## Scope Discipline

Doing things properly does not mean doing things beyond scope. Do not add unrequested features in the name of completeness. The standard is: what was asked for is fully done, not that everything imaginable was built.

If the proper solution requires significantly more work than expected, surface that before starting and agree on scope — do not silently shrink the deliverable.
