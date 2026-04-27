---
name: session-handoff
description: Use when the context window is getting full, a session is ending, or before running /clear. Produces a structured handoff document covering current state, decisions made, open questions, next actions, and critical file paths — optimized for paste-back after /clear.
allowed-tools: [Read, Bash]
---

# Session Handoff

Produce a handoff document that survives a /clear. Optimized for paste-back as first message in a new session.

## When to trigger

- Context window is visibly large (many tool calls, long conversation)
- About to run /clear or start fresh
- Handing off to a different model or agent
- End of work session, work continues later
- After a major decision point — capture before moving on

## Step 1 — Reconstruct current state

Scan the conversation for:
- The original goal / task description
- What has been completed (committed code, files written, configs changed)
- What is partially done (in-progress, untested, draft)
- What has not been started yet

State each item in past/present tense precisely:
- "Wrote X, committed as [hash]" — not "fixed X"
- "Updated Y but not yet tested" — not "done with Y"
- "Z is planned but not started" — not "need to do Z"

## Step 2 — Extract decisions made

List every non-trivial decision from this session:

```
DECISIONS
D1: {what was decided} — Reason: {why} — Alternative rejected: {what and why}
D2: ...
```

Include: architecture choices, library selections, API design, config values chosen, scope cuts.
Exclude: trivial implementation details that don't affect future work.

## Step 3 — List open questions

Any unresolved ambiguity that will matter for continuing work:

```
OPEN QUESTIONS
Q1: {question} — Blocking: {yes/no} — Context: {why it matters}
Q2: ...
```

## Step 4 — Next actions

Concrete, ordered list of what to do next:

```
NEXT ACTIONS
N1: {specific action} — File: {path if applicable} — Depends on: {Q# if blocked}
N2: ...
```

Each action must be specific enough to execute without re-reading the conversation.

## Step 5 — Critical file paths

List every file that was read, written, or is relevant to continuing work:

```
CRITICAL FILES
- {absolute path} — {one-line description of its role}
```

Include: config files, source files being edited, output files produced, files that were read for context.

## Step 6 — Assemble the handoff doc

Output as a single fenced block, ready to paste as the first message in a new session:

```
---
HANDOFF — {date} {time}
SESSION GOAL: {original task in one sentence}
---

COMPLETED
- {item}

IN PROGRESS
- {item} — status: {what's done, what's not}

DECISIONS
D1: ...

OPEN QUESTIONS
Q1: ...

NEXT ACTIONS
N1: ...
N2: ...

CRITICAL FILES
- {path} — {description}

CONTEXT TO RESTORE
{Any non-obvious context a fresh Claude needs to not re-derive: constraints, tone, user preferences for this project, model routing decisions, etc.}
---
```

## Quality check

Before outputting:
- [ ] Every in-progress item has a clear status (not just "in progress")
- [ ] Every next action is specific enough to act on immediately
- [ ] File paths are absolute, not relative
- [ ] No decisions are implied — all are explicit
- [ ] "Context to restore" section covers anything the user would otherwise have to re-explain
