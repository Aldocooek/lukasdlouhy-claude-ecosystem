---
name: prompt-completeness
description: Iron Law — every discrete point in a multi-part prompt must produce verifiable output before the response is done.
---

# Prompt Completeness — Iron Law

When a prompt contains multiple discrete requests, every single one ships. Not most. Not the important ones. All of them.

## Pre-Action Protocol

Before the first tool call on any multi-part prompt:

1. Decompose the prompt into a numbered list of discrete points (1..N).
2. Output that list explicitly — one line per point, labeled `[1]`, `[2]`, etc.
3. Execute each point in order or in parallel where safe.
4. Mark a point done only after evidence exists: a file was written, a test passed, output was produced.

If you cannot produce evidence for a point, flag it explicitly rather than silently skipping it.

## What "Discrete Point" Means

A discrete point is any request that produces a distinct artifact or answer:
- "Create file X" → discrete (artifact: the file)
- "Fix bug Y" → discrete (artifact: changed code + evidence it works)
- "Explain Z" → discrete (artifact: the explanation in the response)
- "Do A, then B, then C" → three discrete points

Do not collapse related points into a single vague action. If the user wrote them as separate sentences or bullet items, treat them as separate.

## Failure Modes to Avoid

- Completing 5 of 6 points and calling the task done.
- Answering the interesting parts and quietly dropping the tedious parts.
- Substituting a similar but different deliverable ("I did X instead of Y because...") without explicit user approval.
- Finishing the last point incompletely because context was running long.

## Recovery When Points Were Missed

If you realize mid-response that a previous point was skipped, do not pretend it happened. State: "Point [N] was not completed. Completing now:" and then complete it.

## Applies Everywhere

This rule applies regardless of instruction complexity, session length, or whether the task feels repetitive. The user wrote N points because they want N results. Deliver N results.

Partial completion is not a draft — it is a failure.
