---
name: ultraplan
description: Assume-failure-first planning with adversarial review — produces a hardened implementation plan by stress-testing assumptions before a single line of code is written
version: 1.0.0
last-updated: 2026-04-27
trigger: /ultraplan <task description>
model: sonnet
---
<!-- Adapted from adamkropacek/claude-ecosystem-adam -->

# Skill: ultraplan

## Purpose

Produce a battle-hardened implementation plan by first assuming the naive approach will fail, then stress-testing it adversarially, and only then writing the final plan. Prevents the most common failure mode: starting to code before the problem is fully understood.

## Trigger

```
/ultraplan <task description>
```

## Execution Protocol

### Phase 1: Decompose (2 min budget)

List every discrete sub-task required to complete the task. Number them 1..N. For each:
- State what artifact it produces (file, endpoint, migration, test, etc.)
- State its dependency on other sub-tasks (none | depends on #N)

Do not write code. Do not open files. Just decompose.

### Phase 2: Assume failure (adversarial review)

For each sub-task from Phase 1, ask: **"What is the most likely way this step fails?"**

Common failure categories to check:
- **Dependency not available** — library version mismatch, API rate limit, missing env var
- **Scope creep** — step touches more files/surfaces than expected
- **Data shape mismatch** — assumed schema doesn't match actual data
- **Test coverage gap** — no way to verify the step worked
- **Rollback impossible** — migration or side-effect is irreversible
- **Parallelism hazard** — two sub-tasks modify the same resource

For each failure identified: name the failure + proposed mitigation (1 sentence each).

### Phase 3: Revised plan

Rewrite the sub-task list incorporating the mitigations from Phase 2. For each step add:
- **Pre-condition:** what must be true before starting
- **Verification:** how we know it worked (test command, browser check, diff review)
- **Rollback:** how to undo if it fails

### Phase 4: Adversarial challenge

Play devil's advocate on the revised plan. Ask:
1. Is the total scope larger than the user's actual intent? (Scope guard)
2. Is there a simpler implementation that achieves the same outcome? (Simplicity check)
3. Are any steps redundant given what already exists in the codebase? (DRY check)
4. Does the plan respect the `plan-first.md` and `quality-standard.md` rules? (Rules check)

Document answers. Adjust plan if any answer reveals a problem.

### Phase 5: Final plan output

Produce the final plan as:

```
## Goal
[one sentence]

## Sub-tasks
[numbered list with pre-condition, action, verification, rollback]

## Risk Register
[table: risk | likelihood | mitigation]

## Verification Gate
[how to confirm the whole plan succeeded end-to-end]

## Out of Scope
[explicit list of things NOT being done, to prevent scope drift]
```

Keep total output under 800 words. If task is trivial (single-file fix, obvious rename), skip to Phase 5 directly and note "low-complexity — phases 1–4 abbreviated."

## Stop Conditions

- Do not start implementing. This skill produces a plan only.
- After outputting the final plan, ask: "Approve to proceed?" and wait for confirmation before any file edits.
- If the adversarial review in Phase 4 reveals the task is actually 3× larger than stated, surface this before producing a plan and ask the user to re-scope.
