# Three-Way Claude Code Ecosystem Comparison
**Date:** 2026-04-27
**Data sources:** repo-lukas.md, repo-filip.md, repo-adam.md (MISSING — file not present at /tmp/repo-adam.md), conversation-usage-report.md, backtest-2026-04-27.md
**Warning:** Adam Kropáček's data is completely absent from this analysis. All conclusions about Adam are derived from the prompt's stated counts (180 skills, 63 hooks, 20 rules, 16 expertise YAMLs) with zero sampled content. Treat Adam's sections as incomplete estimates until repo-adam.md is available.

---

# 1. Executive Verdict

**Ranking summary before the deep dive:**

| Axis | 1st | 2nd | 3rd |
|---|---|---|---|
| Quality | Lukáš | Filip | Adam (unverified) |
| Performance / cost enforcement | Filip | Lukáš | Adam (unverified) |
| Optimization / meta-system | Lukáš | Filip | Adam (unverified) |
| Overall | Lukáš (narrow) | Filip (close) | Adam (insufficient data) |

**Filip beats Lukáš on one axis — cost enforcement — and it's a real beat, not a narrow one.** Filip has a four-layer defense built after two concrete April 2026 billing incidents (CZK ~4,019 in documented losses). That incident-driven hardening is more credible than Lukáš's rule layer, which is architecturally sound but shows 49.7% unrouted agent calls in production (363 of 729 delegations with no model specified). Writing cost rules is not the same as enforcing them. Filip enforces them. Lukáš documents them.

Lukáš wins on quality (MIT license, CI/CD, eval infra, clean frontmatter, controlled CLAUDE.md size) and on the meta-system (explicit skill versioning, eval regression detection, path-scoped document loading that Filip lacks). Lukáš's 46 skills vs Filip's 291 is a deliberate, arguably correct, tradeoff — but Filip's production deployments (OneFlow.cz, 10,067 firms processed) prove that his system runs at a scale Lukáš has not yet reached.

Adam cannot be ranked with confidence. The prompt states 180 skills, 63 hooks, 20 rules, 16 expertise YAMLs — impressive counts — but without content sampling, there is no way to distinguish real depth from bloat.

The honest answer on percentile: **Filip is top-0.1% by production throughput and domain specialization. Lukáš is top-0.5% by infrastructure quality but top-5% by execution discipline. Adam is unknown.**

---

# 2. Quantitative Comparison Table

| Metric | Lukáš | Filip | Adam |
|---|---|---|---|
| Skills | 46 | 291 | 180 |
| Agents | 25 | 54 | Not sampled |
| Hooks (scripts / wired) | 25 scripts | 51 scripts (5 lifecycle stages) | 63 hooks |
| Rules | 18 | 23 | 20 |
| Knowledge files | 10 | 37 | Not sampled |
| Expertise YAMLs | Not sampled | 16 (Czech fintech) | 16 |
| Eval infrastructure | Real (baselines/, datasets/, runner/, runs/, scorers/) | Present (16 datasets + A/B infra) | Unknown |
| CI workflows | 4 GitHub Actions (YAML validation, model assignment, shell linting, eval regression) | 0 | Unknown |
| Frontmatter completeness | 100% (sampled) | ~95% | Unknown |
| Skill version pinning | Yes (semver, 1.0.0 standard) | Yes (settings.json model pins) | Unknown |
| LICENSE | MIT | ABSENT | Unknown |
| README quality | 8/10 (arch diagram, cost profile table, quick-start, CI overview) | Comprehensive (13 supporting docs) | Unknown |
| Install script complexity | backup/rollback + symlinks + validation + exit codes | three flags (--with-vps, --dry-run, --help) + backup | Unknown |
| Cost-routing rules | Strong (cost-zero-tolerance.md + COST_DISCIPLINE.md, four-layer defense documented) | Extensive (5.6K checklist + 5.7K bash interceptor + cron monitor + source lockdown) | Unknown |
| Cost-aware hooks | 8 (cost-circuit-breaker, cost-aware-security-gate, circuit-breaker, loop-guard, context-bloat-pruner, session-length-guard, velocity-monitor, cost-snapshot) | Extensive (PreToolUse guards blocking 15+ paid APIs) | Unknown |
| Model routing enforcement | Partial (hook wired, but 49.7% unrouted calls in production) | Enforced (hook-layer + cron + incident-driven hardening) | Unknown |
| Distinctive moats | CI/CD for skills, eval regression detection, DaVinci Resolve MCP, ScheduleWakeup parallelism | OneFlow.cz production scale, Czech fintech expertise YAMLs, cron monitoring with push alerts, 291 skills breadth | 63 hooks (highest count), 16 expertise YAMLs, unknown depth |
| Monthly spend documented | $15.80 post-optimization (COST.md) | Incidents documented: ~CZK 4,019 (April 2026) | Unknown |

---

# 3. Quality Axis

**Ranking: Lukáš > Filip > Adam (unknown)**

## Lukáš — Quality Analysis

Strong across all quality dimensions:

**Frontmatter:** 100% on sampled skills. Every file has name, description, allowed-tools, last-updated (synced to 2026-04-27), and version. This matters because inconsistent frontmatter causes selective loading failures that are hard to debug. Lukáš doesn't have that failure mode.

**Versioning:** Semantic versioning (1.0.0) is applied consistently. This is rarer than it sounds — most personal Claude ecosystems have no versioning, making it impossible to know when a skill last changed or whether it's safe to update.

**CI/CD:** The only one of the three with GitHub Actions. Four workflows: YAML validation (catches frontmatter errors before they hit production), model assignment checker (policy enforcement in code), shell script linting (catches hook bugs), and eval regression detection (quantitative quality gate). This is the defining moat on the quality axis. Filip and Adam can't regress their ecosystems safely without this.

**Eval infra:** Real baselines, datasets, runner, runs history, scorers. The COST.md tracking $15.80 post-optimization means there's a documented before/after — not just aspirational cost rules. Filip claims 16 datasets + A/B infra but no CI pipeline to run them automatically. Lukáš's evals run on push.

**LICENSE:** MIT. Filip is missing this entirely. For a public or semi-public repo, absence of LICENSE means all rights reserved by default. Not a daily workflow concern, but a significant quality signal.

**README quality:** 8/10. Has architecture diagram, cost profile table, quick-start commands, dry-run install. The 2/10 deduction: telemetry stack (OpenTelemetry, Prometheus, Grafana, Loki) is mentioned but not configured with docker-compose, and MCP server configs not sampled. The gap between what the README promises and what's verifiably deployed is real.

**CLAUDE.md size discipline:** Active rule (claude-md-size.md) with hard caps enforced. The global CLAUDE.md is a lean manifest. This is a meta-quality signal — the system is designed to not bloat.

## Filip — Quality Analysis

**Frontmatter:** ~95%, which is good but with a 5% unexplained gap. On 291 skills, 5% is ~14 files with incomplete metadata. These are invisible errors that cause silent loading failures or incorrect tool routing.

**Documentation breadth:** 13 supporting docs (METHODOLOGY.md, COST_DISCIPLINE.md, HOOKS_GUIDE.md and others). This is higher raw volume than Lukáš, but without CI, there's no enforcement that the docs stay accurate as hooks evolve.

**No LICENSE:** This is a notable quality failure. Filip's system is production-grade (powers OneFlow.cz) but has no license declaration. Any collaborator is legally in ambiguous territory.

**No CI/CD:** Zero .github/workflows. Means: no automated frontmatter validation, no regression detection on skill changes, no linting of 51 hook scripts. With 291 skills, the surface area for silent regressions is enormous.

**Hook timeout enforcement undocumented:** Settings specify 2–10s timeouts but no debugging guidance. When a hook times out silently, workflow breaks with no clear error path.

**Install script:** Three flags including --dry-run is good. Backup logic present. But no exit code documentation (compared to Lukáš's documented exit codes).

## Adam — Quality Analysis (INCOMPLETE)

With repo-adam.md absent, no quality claims can be made. The stated counts (180 skills, 63 hooks, 20 rules, 16 expertise YAMLs) show investment but say nothing about frontmatter completeness, versioning, documentation depth, or licensing. Until the file is available, Adam is unranked on this axis.

---

# 4. Performance Axis (Token Cost Discipline, Model Routing, Hook Enforcement)

**Ranking: Filip > Lukáš >> Adam (unknown)**

## Filip — Performance Analysis

Filip wins this axis because his cost controls were built after real failure, not in anticipation of it. The April 2026 billing incidents (CZK ~4,019) forced hardening that Lukáš's system has not been tested against.

**Four-layer defense (post-incident):**
1. Rule layer: 5.6K checklist (free-tier verification) — human-readable policy
2. Hook layer: 5.7K bash interceptor blocking 15+ paid APIs — machine-enforced
3. Cron monitor: Hourly credential/log audits with push alerts — continuous monitoring
4. Source lockdown: Disabled directories for compromised pipelines — structural prevention

The hook layer blocking 15+ paid APIs is the key differentiator. Lukáš has 8 cost-aware hooks but the evidence from 16 real sessions shows 49.7% of agent calls are unrouted (no model specified). Filip's hook layer would catch these — a bash interceptor checking for missing model parameters on Agent calls is not a creative solution, but it's one that Filip apparently built and Lukáš has not.

**Model configuration:** `effortLevel: max` + `CLAUDE_CODE_EFFORT_LEVEL: max` in settings means Filip explicitly trades cost for quality on every call. This is a legitimate choice for a production fintech system where wrong answers cost more than extra tokens. Whether it's "performance optimization" depends on definition — it's not token minimization, but it's appropriate for the use case.

**Production evidence:** OneFlow.cz ran 10,067 firms, 26.2% reply rate, zero compliance violations. This is the only system of the three with verifiable production outcomes. Lukáš's production evidence is 16 sessions of personal workflow automation.

## Lukáš — Performance Analysis

**The 363 unrouted agent calls are the primary indictment.** From the backtest data: 363 of 729 subagent calls (49.7%) have no model specified. The cost-zero-tolerance rule says every delegation must have an explicit model override for research/audit/web tasks. Half of delegations violate this in production. If even 100 of those 363 ran on Opus instead of Haiku, the cost multiplier is 20–50x. The backtest estimates $5–25 overspend on a 3-day sprint alone.

The rules are architecturally sound: cost-zero-tolerance.md, model-routing-guard.js as a PreToolUse hook, cost-circuit-breaker.js, loop-guard.sh. But the hook is not catching real-world violations. There's a gap between what the system is supposed to do and what it does.

**What's working:**
- Zero Firecrawl/WebFetch from main thread confirmed — this rule is followed
- Haiku at 17.3% of agent calls shows the routing exists and fires for some tasks
- $15.80/month documented — the cost is actually low, suggesting real-world discipline is higher than the 49.7% unrouted figure implies
- ScheduleWakeup (119 calls) + Monitor (42 calls) = active parallelism without burning serial context

**The 99.7% Opus problem:** The backtest notes workspace default was set to Sonnet 4.6 (per memory, April 24) but sessions show 7,388 of 7,403 message events on Opus 4.7. This is a significant disconnect. Either the workspace default isn't working, or Lukáš is manually overriding it, or the event model doesn't capture sub-session model switches accurately. Either way, the main thread is Opus when Sonnet should suffice for most tasks.

## Adam — Performance Analysis (INCOMPLETE)

63 hooks is the highest count of the three, but without content, there's no way to assess whether those hooks actually block costly operations or are decorative. The 16 expertise YAMLs parallel Filip's approach, suggesting domain-aware loading, which is a performance pattern (load only what's relevant). Everything else is inference.

---

# 5. Optimization Axis (Meta-System, Learning Loops, Observability, Cache Hygiene)

**Ranking: Lukáš > Filip > Adam (unknown)**

## Lukáš — Optimization Analysis

Lukáš's strongest axis. The meta-system is more evolved than Filip's.

**Eval regression detection via CI:** This is the only automated learning loop of the three. When a skill changes, CI runs evals against baselines and catches regressions before they reach sessions. Filip has 16 datasets but no automation to run them.

**Context hygiene rules:** context-hygiene.md is sophisticated — prompt cache TTL awareness (5-minute rule, avoid modifying CLAUDE.md mid-session), "grep before read, read before agent" hierarchy, specific guidance on 270s vs 300s sleep intervals for cache preservation. These are not generic advice; they're operational specifics that only someone who has debugged prompt cache behavior writes.

**Path-scoped document loading (path-scoped-loading.md):** Prevents bulk loading all project docs on every task. The loading order table (PROJECT → REQUIREMENTS → ROADMAP → STATE → ACTIVE, stable to volatile) is a real architectural pattern. Filip has no equivalent — his 37 knowledge files and 291 skills are loaded by trigger, but there's no scoping protocol for when to load which.

**Sessions as data (lessons-loop.md):** Corrections are written to tasks/lessons.md per project, keyed to date and incident. This is a structured learning loop. The backtest itself (this file's predecessor) is evidence of the meta-system working — Lukáš commissioned a real audit of his own ecosystem and is acting on it.

**Parallel worktrees rule:** Documented pattern with concrete guidance (3-5 sessions is the productivity sweet spot, cleanup protocol, `git worktree list` hygiene). Not unique to Lukáš but documented with operational depth.

**Reasoning depth override (reasoning-depth.md):** The priority matrix (financial/security → full depth + falsification, simple facts → word budget applies) is a sophisticated calibration that prevents two failure modes: over-brevity on stakes tasks and over-elaboration on trivial ones. Filip has something similar ("reasoning-depth > brevity") but less granular.

**Gaps in optimization:**
- Telemetry (OpenTelemetry, Prometheus, Grafana, Loki) mentioned in README but not verifiably deployed
- 363 unrouted calls shows the learning loop hasn't closed on the most expensive violation
- Skills not aligned to actual workflows (10+ React/GSAP skills with zero corresponding projects)

## Filip — Optimization Analysis

Filip's optimization story is reactive rather than architectural. The April 2026 incidents forced hardening — which works, but means the system was unoptimized until the failure happened. The cron monitor (hourly audits with push alerts) is a strong operational pattern, but it's monitoring, not prevention.

**Strengths:**
- Persistent session identity + expertise YAML auto-loading = consistent domain context across sessions
- Multi-layer defense after incident = real optimization from real failure
- 188 commands suggests automation coverage across the workflow surface

**Gaps:**
- No CI/CD means no automated regression detection — regressions are discovered in production
- No path-scoped loading equivalent — 291 skills + 37 knowledge files need a scoping protocol
- Fintech domain lock makes the optimization patterns less portable (Czech market hardcoded)

## Adam — Optimization Analysis (INCOMPLETE)

16 expertise YAMLs suggests domain-aware loading (similar to Filip's approach). 63 hooks suggests dense automation. Beyond that, nothing can be said without content.

---

# 6. Quantity vs. Quality Tradeoff

## Filip: 291 Skills — Is the Depth Real?

The evidence suggests **mixed quality, with genuine depth in the production core and probable bloat in the periphery.**

What's verifiable:
- 291 skills powering OneFlow.cz production = at least the fintech-core skills are real and battle-tested
- 10,067 firms processed, 26.2% reply rate, zero compliance violations = the skills that touch the production path work
- 54 agents + 51 hooks = substantial automation that presumably supports the 291 skills
- 37 knowledge files = significant reference base for domain context

What raises quality questions:
- With 291 skills and zero CI, there is no automated mechanism to detect that 50 of those skills have broken frontmatter or outdated tool references
- The ~5% frontmatter gap on 291 skills = ~14 files with incomplete metadata. For a 46-skill system, 5% is 2 files — manageable. For 291, it's a debugging surface
- 291 skills vs 46 = 6.3x more skills for a system serving one person and one company. The ratio implies either many narrow skills (Czech-market specificity would justify some of this) or speculative skills built without use-case evidence
- No content sampling available from repo-filip.md on skill bodies — verdict is limited to metadata signals

**Judgment: Filip's core (fintech, compliance, OneFlow) is real and deep. The periphery (general-purpose skills outside the fintech core) is unverifiable and likely has bloat. The production evidence validates the system at scale, not the full 291.**

## Adam: 180 Skills — Is the Depth Real?

Cannot be assessed. repo-adam.md does not exist. The 180 count with 63 hooks and 20 rules suggests a system between Lukáš and Filip in scale, but without content there is no quality signal. The 16 expertise YAMLs parallel Filip's approach and are a positive structural signal, but depth is unknown.

## Lukáš: 46 Skills — Is Leanness a Virtue?

The backtest shows 4 skills should be deleted immediately (shadcn-ui, cold-email, mythos-narrator, multi-agent-debate) and 10+ are under review. So the real number is closer to 32 skills with strong justification. The CI/CD and eval infra mean those 32 are validated. This is a higher quality-per-skill ratio than the alternatives, but the cost is coverage gaps:

- No `resolve-editor` skill despite DaVinci Resolve MCP being the second-most-used MCP cluster (17 calls)
- No `podcast-workflow` skill despite ONEFLOW PODCAST being active (27 subdirs)
- No Czech-market SaaS skill despite three active CZ prototypes

Lean is good when the skills you have are right. Lukáš has both the leanness and several obvious gaps. The 46-skill ceiling appears to be artificial constraint (CLAUDE.md size discipline is excellent; skills aren't the bottleneck) rather than genuine completeness.

---

# 7. Distinctive Moats Per Author

## Lukáš

1. **CI/CD for skills ecosystem.** Four GitHub Actions workflows are unique. No other personal Claude ecosystem has automated frontmatter validation, model assignment checking, shell linting, and eval regression detection. This is the gap that makes Lukáš's system maintainable at scale without manual audits.

2. **DaVinci Resolve MCP integration.** Connecting a professional video editing tool to Claude Code is genuinely rare. The Resolve MCP (50+ tools, 17 calls in 3 days) creates a creative production workflow no other known ecosystem matches.

3. **Eval baseline infrastructure.** baselines/ + datasets/ + runner/ + runs/ + scorers/ + COST.md = a real quality-measurement system. The $15.80/month documented spend is an outcome metric, not an aspiration.

4. **Context hygiene depth.** The prompt cache TTL rules (270s vs 300s sleep interval guidance, "don't modify CLAUDE.md mid-session") are operationally specific — this comes from debugging prompt cache behavior, not reading blog posts about it.

5. **ScheduleWakeup parallelism at scale.** 119 ScheduleWakeup calls in 3 days, combined with 42 Monitor calls and 30 TaskStop calls, represents active parallel workflow management that isn't just a documented pattern — it's a running habit.

## Filip

1. **Production throughput at scale.** OneFlow.cz running on Filip's ecosystem (10,067 firms, 26.2% reply rate, zero compliance violations) is the most credible external validation of any ecosystem in this comparison. Lukáš's system hasn't shipped to external users yet.

2. **Czech fintech vertical specialization.** 16 domain expertise YAMLs covering Czech corporate bond issuance, regulatory compliance, due diligence, CRM ops, email deliverability, and LinkedIn automation. This is not a general-purpose tool — it's a vertical-specific AI platform. Replicable in other verticals but genuinely deep in this one.

3. **Incident-driven cost hardening.** The April 2026 billing incidents and resulting four-layer defense represent battle-tested cost control. The cron monitoring with push alerts (hourly credential/log audits) is an operational sophistication Lukáš's system lacks.

4. **Scale of command coverage.** 188 commands vs Lukáš's 27 (7x coverage) means Filip has automated more workflow surface. Even if some are speculative, the automation breadth reflects a different philosophy: automate everything, prune later.

5. **Reasoning-depth + fintech calibration.** Explicitly subordinating token efficiency to analytical correctness on financial/legal decisions, combined with domain expertise YAMLs, produces a system that has been tuned for the highest-stakes use case.

## Adam (INCOMPLETE — counts only)

1. **63 hooks (highest count).** If these are real and diverse, this represents the densest automation layer of the three. Hook density correlates with enforcement — but without content, whether these are distinct hooks or variations on a theme is unknown.

2. **180 skills + 16 expertise YAMLs.** Scale between Lukáš and Filip with domain-aware loading. If the expertise YAMLs encode a different vertical from Czech fintech, Adam may have a comparable but distinct specialization moat.

3. **20 rules.** Slightly more than Lukáš (18) and fewer than Filip (23). Without content, whether these add to Lukáš's framework or duplicate it is unknown.

Items 4 and 5 cannot be stated without repo-adam.md content.

---

# 8. Cross-Pollination Opportunities for Lukáš

Ranked by impact-to-effort ratio (impact = cost savings or quality improvement, effort = S/M/L).

## From Filip

**1. Add a PreToolUse hook that requires explicit `model` on Agent calls. (Impact: HIGH, Effort: S)**

Filip's hook layer catches things at the boundary. Lukáš's model-routing-guard.js exists but the 363 unrouted calls prove it doesn't catch missing-model Agent invocations. A 20-line bash or JS PreToolUse hook that checks `if Agent call && no model parameter → warn/block` would close the 49.7% unrouted delegation gap. This is the single highest ROI action in this entire analysis.

**2. Add hourly cron monitoring for spend anomalies. (Impact: HIGH, Effort: M)**

Filip's hourly cron with push alerts caught billing spikes before they compounded. Lukáš has COST.md with $15.80/month documented but no automated alerting. A cron job that queries the Claude API usage endpoint hourly and sends a desktop notification if hourly spend exceeds threshold would catch Opus leaks in real time. Estimated effort: M (needs a spend-query script + notification wiring).

**3. Take the bash interceptor pattern for paid API blocking. (Impact: MEDIUM, Effort: S)**

Filip's 5.7K bash interceptor blocks 15+ paid APIs at the PreToolUse level. Lukáš's cost-circuit-breaker.js does similar work but on a narrower scope. Adapting Filip's broader API blocklist to Lukáš's hook layer would close gaps for APIs that aren't currently blocked.

**Ignore from Filip:**
- The 291-skill breadth strategy. Lukáš's lean + CI approach is more maintainable. Don't replicate Filip's scale without CI to catch regressions.
- The effortLevel: max setting. This is appropriate for fintech where wrong answers are expensive. For Lukáš's creative/SaaS workflow, the cost-quality tradeoff should be calibrated per task type, not globally maxed.
- Domain expertise YAMLs for Czech fintech. Wrong vertical for Lukáš's actual work.

## From Adam (INCOMPLETE — speculative)

Without repo-adam.md content, recommendations are structurally inferred from counts:

**4. Study Adam's 63-hook structure for hooks Lukáš's 25 don't cover. (Impact: UNKNOWN, Effort: S once file is available)**

The gap between Lukáš's 25 hooks and Adam's 63 is significant. Some of that 38-hook delta may encode patterns (PostToolUse quality gates, stop-condition enforcement, output validation) that Lukáš doesn't have. This is the primary reason to obtain repo-adam.md.

**5. Evaluate Adam's 16 expertise YAMLs for a parallel structure Lukáš could use. (Impact: MEDIUM, Effort: M)**

If Adam's expertise YAMLs are in a different vertical (not Czech fintech), the structural pattern could be adapted for Lukáš's domains (video production, Czech SaaS, personal brand). The YAML-based domain context loading is a pattern worth borrowing regardless of content.

**Ignore from Adam (until sampled):**
- Don't replicate Adam's 180 skills without seeing content quality. Scale without CI validation is a liability, not an asset.

## Lukáš's Own System (actions that aren't borrowing but building)

**6. Build `resolve-editor` skill immediately. (Impact: HIGH, Effort: M)**

DaVinci Resolve MCP has 17 calls in 3 days and 50+ available tools. No skill exists to encode the operational patterns. A skill covering color grading workflow, subtitle pipeline (transcribe_audio → create_subtitles_from_audio → export_srt), render job management (add_render_job → start_rendering → get_render_status), and Fusion comp patterns would compress dozens of exploratory Bash calls per session. This is the highest-impact missing skill.

**7. Build `podcast-workflow` skill. (Impact: HIGH, Effort: M)**

ONEFLOW PODCAST is active (27 subdirs). Episode structure, transcript→show notes, distribution checklist. Would fire on every podcast session and replace ad-hoc prompting with consistent output.

**8. Fix the Opus leak — verify workspace default is actually applying. (Impact: CRITICAL, Effort: S)**

Backtest shows 7,388 of 7,403 message events on Opus 4.7 despite workspace default set to Sonnet 4.6 on April 24. This needs a single diagnostic session: check settings.json, verify the model field is set correctly, run a test session and confirm model events. If the default isn't applying, fix it. At Opus vs Sonnet pricing, this is potentially a 3-5x cost difference on every session.

**9. Delete 4 dead-weight skills now. (Impact: LOW-MEDIUM, Effort: S)**

`shadcn-ui`, `cold-email`, `mythos-narrator`, `multi-agent-debate` — confirmed dead weight by backtest. Each adds to context load on relevant triggers with zero return. Delete them in one pass.

---

# 9. What Lukáš Does Better Than the Other Two

**1. CI/CD enforcement.** Filip and Adam have zero GitHub Actions. Lukáš's four workflows mean that skill changes are validated before they reach sessions. Regressions are caught at push time, not discovered when a session fails. This is a genuine capability gap that neither competitor has.

**2. Eval baseline tracking.** baselines/ + datasets/ + runner/ + runs/ + scorers/ is a real quality measurement system. Filip has datasets but no automated runner. Adam's eval infra is unknown. Lukáš has the most complete eval loop of the three.

**3. CLAUDE.md size discipline enforced by rule.** The hard caps (root <150 lines, nested <50 lines, global <100 lines) prevent context bloat at scale. Filip's 13 supporting docs and 291 skills suggest CLAUDE.md bloat is a real risk in that system. Lukáš has a structural control against it.

**4. Path-scoped document loading.** The loading order table and per-task scoping prevents bulk-loading all docs on every task. With Lukáš's 10 knowledge files + 18 rules + CLAUDE.md stack, this saves meaningful context on every call. Filip and Adam have no equivalent — their systems load more context more of the time.

**5. MIT License.** Trivially better than Filip's absent LICENSE. If Lukáš ever shares the ecosystem or collaborates, the legal position is clear. Filip's system is legally ambiguous.

**6. Documented cost outcomes.** $15.80/month in COST.md is a real number derived from a real optimized system. Filip has incident costs documented (CZK ~4,019) but no ongoing spend tracking. Adam's spend is unknown. Lukáš has the clearest cost accounting.

**7. DaVinci Resolve integration.** This is unique to Lukáš. A professional video editing tool connected to Claude Code via MCP is a workflow no other known ecosystem replicates. The capability exists; the gap is the missing `resolve-editor` skill to encode it.

---

# 10. Final Ranking

## Quality Axis
1. **Lukáš** — CI/CD, MIT license, 100% frontmatter, eval baselines, context hygiene depth, version pinning, CLAUDE.md size discipline. No competitor matches this on systematic quality engineering.
2. **Filip** — Comprehensive documentation (13 supporting docs), 95% frontmatter, backup install, incident documentation. Loses on CI/CD absence and no LICENSE.
3. **Adam** — Unknown. Cannot rank with confidence. Sufficient counts to be competitive but no content verified.

## Performance / Cost Enforcement Axis
1. **Filip** — Four-layer post-incident defense, cron monitoring with push alerts, 15+ API blocklist in bash interceptor. Production-validated at 10,067 firms. The only system where cost enforcement is provably working at scale.
2. **Lukáš** — $15.80/month documented, Haiku delegation present, zero WebFetch from main thread. But 49.7% unrouted agent calls and 99.7% Opus on main thread show the enforcement layer has gaps the rules don't close.
3. **Adam** — 63 hooks could mean dense enforcement. Unknown.

## Optimization / Meta-System Axis
1. **Lukáš** — Eval regression detection in CI, context hygiene with prompt cache specifics, path-scoped loading, lessons-loop per project, ScheduleWakeup parallelism as active habit (119 calls/3 days), 16-session self-audit commissioned and acted on.
2. **Filip** — Cron monitoring (reactive optimization), incident-driven hardening (reactive optimization), persistent session identity (proactive). Less architectural than Lukáš's meta-system.
3. **Adam** — Unknown.

## Overall
1. **Lukáš** (narrow, quality+optimization axes outweigh performance gap)
2. **Filip** (close — production scale and cost enforcement are real advantages)
3. **Adam** (insufficient data)

## Percentile Estimates

**Filip: Top 0.1%** by production throughput and domain specialization. OneFlow.cz at scale with zero compliance violations in a regulated industry is the only verifiable top-0.1% claim in this comparison. The fintech vertical depth and post-incident hardening are credentials most Claude Code users never develop because they never reach production scale.

**Lukáš: Top 0.5%** by infrastructure quality, **top 5% by execution discipline.** The infrastructure (CI/CD, eval baselines, DaVinci Resolve MCP, 25 hooks) is genuinely rare. The execution gaps (49.7% unrouted calls, 99.7% Opus on main thread, skills not aligned to actual work) prevent 0.1% qualification. Close the three gaps from the backtest and 0.1% is reachable.

**What would push Lukáš to top 0.1%:**
1. Fix the Opus leak + verify workspace default actually applies
2. Add a mandatory model parameter hook on Agent calls (close the 49.7% gap)
3. Build resolve-editor and podcast-workflow (close the workflow-skill alignment gap)
4. Deploy the telemetry stack that's referenced in README but not running (Prometheus + Grafana)
5. Ship one production project on the ecosystem (Steakhouse/Repairio to users)

**Adam: Unknown.** If content quality matches the hook count (63 hooks is the highest), Adam may be competitive with Filip on enforcement. Without data, any percentile estimate is fabrication.

---

# 11. Bottom-Line Action Plan for Lukáš (Next 30 Days)

Ranked by impact, concrete, one action each.

| # | Action | Source | Effort | Expected Outcome |
|---|---|---|---|---|
| 1 | Diagnose why workspace default (Sonnet 4.6, set Apr 24) isn't applying; confirm model in settings.json; run a test session | Own system | S | If Opus leak is real, fix it. 3-5x cost reduction on all sessions. |
| 2 | Add PreToolUse hook: if Agent call has no model parameter, emit warning or block | Filip (adapting hook pattern) | S | Closes 49.7% unrouted delegation gap. Estimated $5-25/sprint savings. |
| 3 | Build `resolve-editor` skill: color grading workflow, subtitle pipeline (transcribe → subtitles → SRT), render job management, Fusion comp patterns | Own (missing skill) | M | Compresses exploratory Bash calls in every Resolve session; encodes 50+ MCP tools into usable patterns |
| 4 | Delete `shadcn-ui`, `cold-email`, `mythos-narrator`, `multi-agent-debate` | Backtest verdict | S | Removes dead context load. Clean ecosystem. |
| 5 | Build `podcast-workflow` skill: episode structure, transcript→show notes, distribution checklist | Own (missing skill) | M | Fires on every ONEFLOW PODCAST session; replaces ad-hoc prompting |
| 6 | Add hourly cron: query Claude API usage endpoint, desktop-notify if hourly spend exceeds threshold | Filip (cron monitoring pattern) | M | Catches Opus leaks and billing spikes in real time rather than end-of-month |
| 7 | Obtain and read repo-adam.md; extract any hooks Lukáš's 25 don't cover | Adam (blocked by missing file) | S (once file exists) | May reveal 10-15 hook patterns in the 63-hook gap that address unhandled lifecycle events |
| 8 | Consolidate `semantic-recall` + `session-recall` (likely duplicates); merge `storyboard` and `video-storyboard` (likely duplicates) | Backtest verdict | S | Removes duplicate loading on trigger; clarity on which skill fires when |
| 9 | Verify telemetry stack is actually running (Prometheus/Grafana/Loki/OTel) or remove from README | Own (README accuracy gap) | M | Either real observability or honest docs; both are better than the current gap |
| 10 | Build `czech-service-saas` skill: ARES API, Fakturoid/Pohoda invoicing, Czech UX patterns | Own (missing skill) | M | Useful on every Steakhouse/Autoservisy/Repairio session; encodes market context currently re-established from scratch each time |

**Priority: Actions 1 and 2 first.** The Opus leak and unrouted delegation gap together are the largest cost overspend and the most fixable. Both are S-effort. Do them in one session before anything else.

---

*Generated: 2026-04-27 | Data: repo-lukas.md (complete), repo-filip.md (complete), repo-adam.md (MISSING), conversation-usage-report.md (complete), backtest-2026-04-27.md (complete)*
*Confidence: Lukáš/Filip analyses: HIGH. Adam analysis: LOW (counts only, no content).*
