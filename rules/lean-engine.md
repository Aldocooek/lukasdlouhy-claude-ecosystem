---
name: lean-engine
description: Code compaction patterns — write lean code by default, no WHAT comments, no dead weight.
---

# Lean Engine — Default Code Compaction Patterns

Write code the way Lukáš would refactor it anyway. Don't produce a first draft that needs cleaning.

## No WHAT Comments

Comments explain WHY, never WHAT. The code already says what it does.

```js
// BAD — describes the code
// Loop through items and add to total
let total = items.reduce((sum, item) => sum + item.price, 0)

// GOOD — explains a non-obvious decision
// prices are in cents to avoid float rounding in downstream billing
let total = items.reduce((sum, item) => sum + item.price, 0)
```

If a line needs a WHAT comment to be understood, the line should be rewritten, not commented.

## Inline Single-Use Variables

Do not name a variable that is used exactly once immediately after assignment.

```js
// BAD
const isEligible = user.age >= 18 && user.verified
if (isEligible) { ... }

// GOOD — unless the condition is complex enough to warrant naming
if (user.age >= 18 && user.verified) { ... }
```

Exception: name the variable if the expression is complex, or if naming it materially aids debugging (e.g., it will appear in a stack trace or log).

## Optional Chaining Over Null Guards

```js
// BAD
const name = user && user.profile && user.profile.name

// GOOD
const name = user?.profile?.name
```

Same applies to nullish coalescing:

```js
// BAD
const label = item.label !== null && item.label !== undefined ? item.label : 'default'

// GOOD
const label = item.label ?? 'default'
```

## Delete Unused Code Immediately

Do not leave commented-out code blocks "in case we need them later." That is what git is for.

```js
// BAD — dead weight
// const oldHandler = (e) => { ... }
const handler = (e) => { ... }
```

If code is disabled for a legitimate temporary reason, add a comment with a concrete condition for its removal: `// re-enable after migration to v2 API`.

## No Backwards-Compat Hacks

Do not write code that handles both old and new behavior "for safety" unless there is an explicit migration window with a known end date. Compat shims accumulate and never get removed.

```js
// BAD — the old shape is gone, stop checking for it
const id = item.id ?? item.legacy_id ?? item._id

// GOOD — if old shapes are truly dead
const id = item.id
```

If backwards compat is genuinely required, isolate it in one place with a dated comment and remove it when the condition is met.

## GSAP / Animation Specifics

Prefer tween chaining over storing intermediate tween references when the reference is not reused. Avoid allocating new objects inside `onUpdate` callbacks — cache outside.
