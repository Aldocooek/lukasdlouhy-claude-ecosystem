# MYTHOS — What This Ecosystem Is and Why It Exists

Read this first. It is 90 seconds. After it, you will know whether this repo is worth your time.

---

## What This Is

A working Claude Code ecosystem for a creator, marketer, and video operator. Not a tutorial. Not a starter template. Not a proof of concept. A live system, running in production on real work — HTML-to-video pipelines, Instagram content operations, CRO landing page audits, marketing funnel work — exposed publicly so others can see inside and cherry-pick what fits.

The core config lives in `~/.claude/`. This repo is a sanitized mirror of that, versioned and published for peer inspection and selective adoption.

---

## What It Optimizes For

**Signal-to-noise.** Rules are short and specific. Skills do one thing. No padding, no aspirational comments. If a file in this repo cannot justify its existence in a sentence, it gets deleted.

**Cost discipline.** Token cost is tracked per session, audited weekly, and defended with four independent layers. This is not a "we care about efficiency" statement — it is an architecture decision with hooks that block violations at runtime. See `COST_DISCIPLINE.md`.

**Surgical scope.** Do what was asked, report what was done, stop. No unrequested additions, no half-implementations. `rules/quality-standard.md` and `rules/prompt-completeness.md` enforce this.

**Anti-sycophancy.** The model should say what is true, not what is agreeable. `rules/anti-sycophancy.md` names this explicitly and lists the banned opener patterns.

---

## What This Is Not

**Not exhaustive.** Filip Dopita's ecosystem has 291 skills. This one has ~30, by deliberate choice. Fewer skills means easier maintenance, faster onboarding, and a smaller surface for things to go wrong. Coverage is traded for precision.

**Not Czech-localized.** Everything is in English. The target audience is any builder in this domain — video, marketing, lean AI ops — not a Czech-speaking subset of it. Fork it into your language if needed.

**Not enterprise SaaS infrastructure.** No Statsig, no Datadog by default, no company-wide SSO, no approval workflows. This is a solo and small-team tool. The telemetry stack (OpenTelemetry/Prometheus/Grafana) is optional and self-hosted — you can run it with `docker compose up` or skip it entirely.

**Not a framework.** There is no install command that wires everything together and abstracts away the internals. You read the files, you understand what they do, you copy what you want. That is the protocol.

---

## Architecture in 1 Minute

```
~/.claude/
  rules/          Text-level behavioral constraints. Loaded every session.
  hooks/          Shell/JS scripts wired to harness events (PreToolUse, PostToolUse, etc.).
                  These execute at the system level — not by the model, by the harness.
  skills/         Invocable workflows (/cost-snapshot, /retro, /gsap-timeline-design, ...).
  agents/         Specialized subagent configurations for swarm patterns.
  commands/       Slash command definitions (/swarm, /eval-status).
  expertise/      Domain YAML configs for Instagram, TikTok, YouTube, brand voice.
  memory/         Persistent memory templates that survive session boundaries.
```

The rules and hooks are always-on. Skills are invoked on demand. Agents are spawned when a task warrants parallel execution. The whole thing runs inside the Claude Code harness — no external process manager required.

---

## The 4-Layer Cost Defense

Text rules tell the model what to do. Hooks enforce it mechanically. Skills audit it on demand. Governance reviews the gaps.

Each layer is independently necessary because each layer has a different failure mode. The full breakdown, with the incidents that motivated each layer, is in `COST_DISCIPLINE.md`.

Short version: if you only read one cost-related file in this repo, make it `rules/cost-zero-tolerance.md`. If you want to understand why that rule exists and what happens when it is violated, read `COST_DISCIPLINE.md`.

---

## The 5 Pillars

The reasoning methodology behind every rule and skill in this ecosystem:

1. **Falsification-first thinking** — find evidence against the hypothesis before claiming it is correct.
2. **Calibrated confidence** — express certainty, likelihood, guesses, and ignorance as distinct states.
3. **Cost-aware delegation** — every tool call and subagent spawn has a routing decision; route it correctly.
4. **Surgical scope** — do exactly what was asked, surface expansions before doing them.
5. **Verification before claim** — evidence that a thing works, not just that it was written.

Full treatment of each pillar, with examples and anti-patterns, is in `METHODOLOGY.md`.

---

## How to Fork and Adapt

**Reusable as-is:**
- `rules/cost-zero-tolerance.md` — works for any Claude Code setup, any domain.
- `rules/anti-sycophancy.md`, `rules/quality-standard.md`, `rules/prompt-completeness.md` — domain-agnostic.
- `hooks/model-routing-guard.js`, `hooks/gitleaks-guard.sh` — plug in after reviewing for your key patterns.
- `skills/cost-snapshot`, `skills/retro` — work against any transcript directory.

**Needs personalization:**
- `expertise/` YAML files — brand voice, platform configs. Replace with your own context.
- `skills/ig-content-creator`, `skills/gsap-timeline-design`, `skills/hyperframes-debug` — tightly coupled to the creator/video stack. Useful only if you work in that domain.
- `~/.claude/CLAUDE.md` — the model routing rules reference this repo's structure. Update paths if yours differs.

**Gut entirely:**
- `telemetry/` — optional observability stack. Keep it if you want Grafana dashboards. Skip it if local session cost estimates are enough.
- `agents/SWARM_PATTERNS.md` — useful only if you run multi-agent pipelines. Not a dependency for anything else.
- Domain-specific skills not relevant to your work — delete them. A skill you do not use is a maintenance burden and a context token.

---

## Maintainer

Lukáš Dlouhý — [dlouhyphoto@gmail.com](mailto:dlouhyphoto@gmail.com)

License: MIT. Copy, fork, adapt. Attribution appreciated, not required.

Peer ecosystem for comparison: Filip Dopita — see `COMPARISON.md`.
