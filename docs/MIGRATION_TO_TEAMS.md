# Migration to Agent Teams

When to migrate, when not to, and what the before/after looks like for the
creative-director workflow.

---

## The honest summary

Agent Teams is a real, distinct primitive — not a renamed version of parallel Agent
dispatch. The key difference is peer-to-peer communication: teammates can message each
other directly, self-claim from a shared task list, and challenge each other's conclusions
without routing everything through the lead.

It is also experimental, opt-in, and token-expensive. Migration is not universally
beneficial. This guide covers the exact scenarios where it adds value and the ones where
it does not.

---

## What changes structurally

### Before: Agent-tool dispatch (creative-director)

```
creative-director session
  Context window: accumulates all specialist output
  │
  ├── [single context window throughout]
  │
  ├── Agent call → brief-author        (runs, returns text into director context)
  │       ↓ brief-author output lands in creative-director's context
  ├── Agent call → video-director      (runs, returns text into director context)
  ├── Agent call → copy-strategist     (runs, returns text into director context)
  └── Agent call → perf-auditor        (runs, returns text into director context)
        ↓
  creative-director synthesizes all four outputs from its own context
```

Communication pattern: hub-and-spoke. All specialist output routes through the director.
Specialists cannot see each other's work or respond to it.

### After: Agent Teams dispatch (creative-director as lead)

```
creative-director session (lead)
  Context window: spawn prompts + teammate completion notifications only
  │
  ├── Shared task list: ~/.claude/tasks/{team-name}/
  │     Task 1: brief (pending → in-progress → complete)
  │     Task 2: video (blocked until task 1 complete → in-progress → complete)
  │     Task 3: copy  (blocked until task 1 complete → in-progress → complete)
  │     Task 4: perf  (pending → in-progress → complete, independent)
  │
  ├── Teammate: brief-author       [own context window]
  │       ↓ completes task 1, unblocks tasks 2 and 3
  ├── Teammate: video-director     [own context window]
  │       ↓ sends message directly to copy-strategist: "hook tone is X"
  ├── Teammate: copy-strategist    [own context window]
  │       ↓ responds to video-director message, aligns CTAs to hook tone
  └── Teammate: perf-auditor       [own context window, independent]
        ↓
  lead receives completion notifications, synthesizes final campaign package
```

Communication pattern: peer-to-peer + lead coordination. Specialists can message each
other without lead relay. Lead context window does not accumulate raw specialist output.

---

## Side-by-side comparison

| Property | Before (Agent-tool) | After (Agent Teams) |
|---|---|---|
| Specialist output in lead context | Yes — all of it | No — completion notifications only |
| Specialist-to-specialist comms | Not possible | Direct messaging |
| Task coordination | Manual by director | Shared task list, self-claiming |
| Tone alignment (copy + video) | Director relays | copy-strategist messages video-director |
| Session resumption | Works normally | Experimental — /resume does not restore teammates |
| Requires opt-in flag | No | Yes — CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 |
| Min Claude Code version | Any | v2.1.32+ |
| Token cost per campaign | Director context fills | Each teammate context is separate |
| Token cost direction | One large window | Multiple smaller windows |

On token cost: the comparison is not straightforward. Agent Teams avoids accumulating
specialist output in the director's context, but each teammate is a full Claude instance
with its own context window. For a 4-specialist campaign:
- Agent-tool: 1 director window grows with each specialist output
- Agent Teams: 4+ independent windows, each smaller, plus coordination overhead

In practice, Agent Teams can be cheaper on long campaigns where accumulated specialist
output would bloat the director's context significantly. For short campaigns, Agent-tool
dispatch is likely cheaper. There is no universal winner — profile your actual campaigns.

---

## The one workflow where Agent Teams adds clear value

**Tone alignment between video-director and copy-strategist.**

In the Agent-tool model, the director passes copy to video-director as context, or vice
versa, but the specialists cannot respond to each other's in-progress work. The director
plays telephone between them.

In Agent Teams, copy-strategist can message video-director directly:
```
"Your hook establishes an emotional tone — I'm going to match the headline rhythm
to your opening beat. Before I finalize, does the scene table have a text overlay
slot I should leave room for?"
```

video-director responds directly:
```
"Yes — scene 2 has a 3-second overlay window. Keep headline under 7 words."
```

This exchange requires no lead relay. The final campaign package has tighter cross-surface
coherence than what the director alone could produce by passing outputs back and forth.

---

## Cost comparison — worked example

Campaign: full product launch, Instagram Reels + landing page copy + perf audit.

| Step | Agent-tool cost | Agent Teams cost |
|---|---|---|
| brief-author run | ~15K tokens in director context | ~15K tokens in teammate context |
| video-director run | +~30K tokens in director context | ~30K tokens in teammate context |
| copy-strategist run | +~25K tokens in director context | ~25K tokens in teammate context |
| perf-auditor run | +~8K tokens in director context | ~8K tokens in teammate context |
| Director synthesis | Runs with ~78K context | Runs with ~5K context (notifications only) |
| Tone alignment round-trips | +~6K tokens in director context | ~2K tokens in teammate mailbox |
| **Total estimate** | ~122K tokens in one window | ~85K tokens across 4 windows + overhead |

These are rough estimates. The key driver is that the director's synthesis step is
dramatically cheaper in Agent Teams because it does not hold the full specialist output
in its context window.

---

## When NOT to migrate

**Single-domain tasks.** If you only need video scripts, call video-director directly.
No director, no team. This applies regardless of whether Agent Teams is available.

**Sequential pipelines.** If workstreams must run in strict order with no parallelism
(brief → video → copy, each gating the next), Agent-tool dispatch handles this with wave
dispatch. Agent Teams adds coordination overhead without benefit.

**Automated/scheduled runs.** The `/resume` command does not restore in-process teammates.
If your workflow runs unattended or needs session resumption, stay on Agent-tool dispatch.

**Small campaigns (1–2 specialists).** The Agent Teams overhead (shared task list setup,
spawn prompts, mailbox initialization) is not justified for a brief + copy run. Two Agent
calls is faster and cheaper.

**Environments without the flag.** If `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is not set,
use Agent-tool dispatch. Do not block a campaign on an experimental feature.

**When token budget is the primary constraint.** Agent Teams is not guaranteed to be
cheaper for all campaign sizes. If you are cost-optimizing aggressively, measure your
specific workflow before committing.

---

## Migration checklist

Before enabling Agent Teams for a director:

- [ ] Claude Code version >= 2.1.32 (`claude --version`)
- [ ] `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json or shell
- [ ] Agent definitions are subagent files that teammates can reference by name
- [ ] Campaign has 3+ independent workstreams that benefit from peer communication
- [ ] Session resumption is not required for this workflow
- [ ] Tested fallback path: if teammate spawn fails, does the director fall back cleanly?

---

## Rollback

If Agent Teams causes issues, remove `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` from
settings.json and the feature reverts entirely. All existing directors continue to work
on Agent-tool dispatch. No other changes are required.

The Step 0 block added to creative-director.md explicitly checks for the flag and falls
back to Agent-tool dispatch if it is absent. The fallback path is identical to the
pre-migration behavior.

---

See also:
- `agents/TEAMS.md` — full architecture doc
- `agents/creative-director.md` — updated with Step 0 detection branch
- `agents/team-coordinator.md` — meta-agent for cross-director orchestration
- `commands/team.md` — `/team` slash command with automatic dispatch routing
