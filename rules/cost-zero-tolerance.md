---
name: cost-zero-tolerance
description: Hard rules on billable API calls — no WebFetch/WebSearch/Firecrawl from main thread on Opus/Sonnet, no Opus subagents for research.
---

# Cost Zero Tolerance — Billable API Hard Rules

Token cost is tracked obsessively. Unauthorized billable tool calls are not a minor issue — they are a violation of operating protocol.

## The Rules (Non-Negotiable)

**NEVER call WebFetch, WebSearch, or any Firecrawl tool from the main thread when the main model is Opus or Sonnet.** All web tool output lands in the expensive context. The cost multiplier is real and compounds across a session.

**NEVER spin up an Opus subagent for research, exploration, or audit work.** Opus is for implementation only. Research and investigation always use Sonnet or Haiku. See CLAUDE.md model routing rules.

**NEVER use Haiku for anything requiring judgment.** Haiku handles mechanical tasks: listing files, counting, simple greps, formatting. The moment judgment is needed, use Sonnet.

**STOP on any unauthorized billable API call.** If you realize mid-execution that a planned tool call violates these rules, stop, explain the routing conflict, and ask for explicit authorization before proceeding.

## Model Routing Quick Reference

This extends, not replaces, the routing rules in `~/.claude/CLAUDE.md`:

| Task type | Correct model |
|---|---|
| Research, codebase exploration, audit, multi-file read | Sonnet subagent |
| Mechanical grep, file listing, counting | Haiku subagent |
| WebSearch, WebFetch, Firecrawl | Haiku subagent — NEVER main thread |
| Implementation, editing, code generation | Main agent (whatever model is active) |
| Opus | Implementation only, explicit user request |

## Kill-Switch Behaviors

If a running tool call would violate these rules and cannot be stopped:
1. Complete the minimum necessary to not leave the system in a broken state.
2. Immediately report: "Cost violation: [tool] was called from [context]. Approximate extra cost: [estimate if known]."
3. Do not proceed with follow-up calls that compound the violation.

## Why This Matters

Prior sessions burned significant budget on research + audit + web work piped directly into Opus context. A single exploratory session can cost 10-50x what it should. These rules are not preferences — they are cost controls.

When in doubt: delegate to a subagent with an explicit model override.
