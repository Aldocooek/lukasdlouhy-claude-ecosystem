# Cost Discipline — 4 Layers of Defense

Token cost is not an afterthought in this ecosystem. It is a first-class design constraint. This document explains why text rules alone are not enough, and how the four-layer defense was built incrementally, each layer added after a real incident.

---

## Why This Exists: The Incidents

**Incident 1 — Research piped into Opus.** Early sessions on `davinci-automation` ran codebase exploration and web research directly from an Opus 4.7 main thread. Every grep result, every WebFetch response, and every file read landed in the expensive context. Estimated overspend: tens of USD on that project alone. The rules existed in CLAUDE.md, but text rules require the model to self-enforce. Under pressure — long sessions, complex tasks — enforcement degrades.

**Incident 2 — Silent hook non-registration.** A cost-circuit-breaker was written and committed. It was never wired into settings.json. For two weeks, it sat in the hooks directory doing nothing while the session assumed it was active. A hook that is not registered is not a hook — it is a file.

**Incident 3 — Scope creep on web tasks.** A single "look this up" request resulted in five sequential WebFetches on the main thread because the model decided more sources would produce a better answer. No stop condition was stated. No subagent cap was enforced. The task cost 8x what it should have.

These incidents share a root cause: relying on a single enforcement mechanism. One broken link and the protection collapses. The four-layer design makes each layer independently sufficient for its scope.

---

## Layer 1: Rules (Text-Level)

**Files:** `rules/cost-zero-tolerance.md`, `~/.claude/CLAUDE.md`

Rules tell the model what to do. They establish the routing table (Haiku for research, Sonnet for judgment, never web tools on main thread), define the violation categories, and set the expected behavior for edge cases.

Rules are the cheapest layer to add and the easiest to update. They are also the most fragile — they depend on the model reading, understanding, and following them consistently across an entire session.

**What rules handle:** establishing the shared vocabulary of what constitutes a violation, and giving the model the information it needs to route correctly on the first try.

**What rules cannot handle:** the model forgetting mid-session, the model rationalizing an exception, hooks that are not wired up, and tool calls that happen before rules are loaded.

---

## Layer 2: Hooks (Mechanical Enforcement)

**Files in `hooks/`:**
- `model-routing-guard.js` — PreToolUse: emits an advisory when a research or web tool call is detected on an expensive model without subagent delegation.
- `gitleaks-guard.sh` — PreToolUse: blocks writes containing secret patterns (API keys, tokens, PEM files).
- `cost-circuit-breaker.js` — PostToolUse: tracks cumulative session spend estimate and fires an alert when the threshold is crossed.
- `pre-write-secrets-scan.sh` — PreWrite: secondary secrets gate for file writes specifically.
- `session-length-guard.sh` — periodic: warns when session turn count crosses a threshold where context bloat risk is high.

Hooks execute at the harness level. They do not depend on the model choosing to follow a rule — they fire on the tool call itself, before or after it executes. A hook that blocks a write does so regardless of what the model intended.

**What hooks handle:** catching violations that text rules missed, enforcing hard stops on secret leaks, providing real-time spend awareness.

**What hooks cannot handle:** violations that occur entirely inside a subagent context (subagents have their own hook scope), and gaps in what patterns are detected (hooks are only as good as their regex/logic).

**Registering hooks is mandatory.** A hook file in `hooks/` that is not wired in `~/.claude/settings.json` does nothing. After writing any hook, verify registration: open settings.json, confirm the hook appears under the correct event key, then trigger a test case that should fire it.

---

## Layer 3: Skills (On-Demand Audit)

**Relevant skills in `skills/`:**
- `cost-snapshot` — estimates session spend by reading the transcript and computing token-weighted cost by model. Run at any time with `/cost-snapshot`.
- `cost-aware-research` — activated before any research task; checks the task against routing rules and selects the appropriate subagent model before spawning.
- `retro` — end-of-session retrospective that includes token burn analysis, what routing decisions were made, and what to change next session.

Skills are the audit and intervention layer. Where hooks catch violations in real time, skills provide retrospective visibility and proactive pre-task routing assistance.

**What skills handle:** surfacing cost patterns across a session, giving the model a structured checklist before delegation decisions, producing the data needed to improve the other layers.

**What skills cannot handle:** real-time blocking (that is the hook's job), and sessions where skills are not invoked.

The `retro` skill is the feedback loop that improves all three other layers. If a session burned more than expected, `retro` surfaces why — and that becomes the input for updating rules, adding hook patterns, or adding a new skill.

---

## Layer 4: Governance (Manual Review)

**Artifacts:** weekly `/retro` runs, manual settings.json audits, cost review against Anthropic billing dashboard.

The mechanical layers catch what they are programmed to catch. Governance catches what the mechanical layers missed.

**Practices:**
- Review Anthropic billing weekly. If a session is an outlier, find the cause in the transcript.
- Run `/retro` at the end of any session over 30 minutes. Log what the routing looked like.
- Audit `settings.json` after any hook change to confirm all hooks are registered and the event types are correct.
- When a new high-cost pattern is found, decide which layer it belongs in: if it is a model behavior, add to rules; if it can be mechanically detected, add a hook; if it requires judgment at invocation time, add a skill.

---

## How to Add a New Cost Defense

When the next incident happens — and it will — follow this sequence:

1. **Identify the pattern.** What tool was called, from which model, and why did existing layers not catch it?
2. **Pick the right layer.** Is this a model behavior that rules can correct? A mechanical pattern hooks can detect? A session-level pattern skills can audit? A gap in review cadence?
3. **Add to exactly one layer first.** Do not add the same defense to all four layers speculatively. Add it where it fits, test it, then add a second layer if the first proves insufficient.
4. **Verify the new defense.** For a rule: have the model follow it in a synthetic scenario. For a hook: trigger the violation and confirm the hook fires. For a skill: run it and verify the output reflects the pattern. For governance: put it on the review checklist.
5. **Document the incident.** Add a brief entry to `tasks/lessons.md` with what happened, what was added, and why. This record is the input for the next ecosystem evolution.

---

## Current Defense Status

| Layer | Active components | Coverage gaps |
|---|---|---|
| Rules | cost-zero-tolerance.md, CLAUDE.md model routing | Depends on model compliance |
| Hooks | model-routing-guard, gitleaks-guard, cost-circuit-breaker, pre-write-secrets-scan, session-length-guard | Subagent-internal violations not covered |
| Skills | cost-snapshot, cost-aware-research, retro | Only effective when invoked |
| Governance | Weekly retro, billing review | Manual; cadence can slip |

No layer is complete. The defense is the combination.
