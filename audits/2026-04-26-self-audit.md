# Self-Audit 2026-04-26

## Overall Grade: C

## Summary

The ecosystem is structurally coherent — the three-tier agent hierarchy is well-designed, security pipeline is solid, rules are sharp and non-redundant, and expertise YAMLs are genuinely useful. However, several high-visibility issues drag the grade down: four director agents lack YAML frontmatter (making them un-invokable via the Agent tool as named agents), model version references are locked on `claude-sonnet-4-5` / `claude-haiku-4-5` across agents, evals runner, and CI configs (current workspace default is Sonnet 4.6), all 13 hooks are unregistered in `settings.json.template`, two recall skills are near-duplicates, and the `imported/research` skill is a foreign body (Tavily-dependent, CZ/SK-market-specific, no integration with the ecosystem's model routing rules). Usage stats are unavailable, so zero-usage candidates cannot be confirmed statistically. No components are outright broken or contradictory, but the outstanding issues are worth a focused cleanup sprint.

---

## Top 10 Improvements (prioritized)

1. **Four director agents missing YAML frontmatter** (`creative-director`, `eng-director`, `ops-director`, `research-director`) — **refactor**. These files use prose `## Metadata` blocks instead of YAML front matter. The Agent tool matches agents by `name:` in frontmatter; without it these agents cannot be reliably addressed by name. Add `---\nname: creative-director\ndescription: ...\nmodel: sonnet\ntools: [...]\n---` to each.

2. **Model version drift — claude-sonnet/haiku-4-5 hardcoded throughout** — **refactor**. All four director agents, the evals runner (`evals/runner/run-eval.sh`, `evals/scorers/llm-judge.sh`), and all CI workflows/configs hardcode `claude-sonnet-4-5` and `claude-haiku-4-5`. Workspace default was updated to Sonnet 4.6 on 2026-04-24. Update all model strings to `claude-sonnet-4-6` / `claude-haiku-4-6` or use symbolic defaults.

3. **Hooks are unregistered** — **refactor**. `settings.json.template` contains only `effortLevel` and `additionalDirectories`. None of the 13 hooks in `hooks/` are wired up. The hooks directory is dead weight until registered. Add a proper `hooks` block to `settings.json.template` mapping each hook to its trigger type (`PreToolUse`, `PostToolUse`, `Stop`, `UserPromptSubmit`, `SessionStart`).

4. **`semantic-recall` and `session-recall` are near-duplicates** — **merge**. Both skills search `~/.claude/sessions-archive/`, return top-3 hits, and have nearly overlapping trigger phrases. `semantic-recall` adds Voyage embeddings as optional upgrade path; `session-recall` is keyword/grep only. Merge into a single `session-recall` skill with a "semantic upgrade" section. Deprecate `semantic-recall`.

5. **`semantic-recall` uses wrong frontmatter key** — **refactor**. Uses `tools:` instead of `allowed-tools:`. Claude Code skill frontmatter requires `allowed-tools`. This may cause the tool permission check to be skipped silently.

6. **`imported/research` is a foreign body** — **deprecate or isolate**. This skill depends on a Tavily MCP server, an external OAuth flow, and a `./scripts/research.sh` that isn't in the ecosystem's `scripts/` dir. It bypasses the ecosystem's own model routing rules (cost-aware-research / cost-zero-tolerance). The description has a trailing space and the skill body includes CZ/SK market tips that belong in an expertise YAML, not skill logic. Either extract a proper `research.yaml` expertise file and delete this skill, or quarantine it with a clear `# EXTERNAL DEPENDENCY` header.

7. **Four director agents lack a `description:` with "Use when..." trigger language** — **refactor** (partially overlaps with #1). Even after adding frontmatter, the descriptions are prose-narrative, not trigger-optimized. Model routing and Agent tool invocations benefit from crisp "Use when X not Y" framing. Rewrite to match the pattern used by `skill-auditor`, `brief-author`, and `eval-judge`.

8. **`notify-on-long-task.sh` hook relies on non-standard env vars** — **refactor**. Uses `TURN_START_TIME` and `TURN_END_TIME` which are not exposed by the Claude Code SDK Stop hook payload (which provides `transcript_path` via stdin JSON, not env vars). The hook silently exits if these vars are absent — currently always. Replace timing logic with a `jq` parse of the stdin payload's `duration_ms` field if available, or remove the hook and replace with the `desktop-notify` skill.

9. **`gsap-timeline-design` skill overlaps with `imported/gsap-*` skills** — **keep both but add cross-references**. These serve different purposes: imported GSAP skills are reference docs for GSAP API; `gsap-timeline-design` is an opinionated planning workflow. However, the custom skill duplicates GSAP API examples already in the imported skills. Slim `gsap-timeline-design` to planning logic only; add `See also: imported/gsap-scrolltrigger` cross-reference.

10. **8 commands lack YAML frontmatter** (`audit-self`, `compact-strategic`, `clear-task`, `cost`, `eval-status`, `memory-index`, `experiment`, `swarm`) — **refactor**. Commands without frontmatter cannot expose `allowed-tools`, `description`, or `argument-hint` to the harness. Add minimal frontmatter blocks to each.

---

## Per-Category Findings

### Skills (25 total: 17 custom + 8 imported)

- **`semantic-recall`**: uses `tools:` instead of `allowed-tools:` — schema drift. B → refactor.
- **`session-recall`**: well-structured, good trigger phrases, proper `allowed-tools`. A.
- **`semantic-recall` vs `session-recall`**: see Redundancies section. One should be merged/deprecated.
- **`cost-aware-research`**: strong description with clear "Use when" and cost enforcement rationale. A.
- **`cost-snapshot`**: solid, distinct from cost-aware-research (estimation vs routing). A.
- **`video-storyboard`**: description is good, but `allowed-tools: [Read]` is too restrictive for a skill that may need to write output. B.
- **`session-handoff`**: well-defined trigger, no `allowed-tools` listed at all — missing key. B.
- **`gsap-timeline-design`**: overlaps with imported GSAP skills (see #9). B.
- **`hyperframes-debug`**: clean, tight scope, solid phase structure. A.
- **`lean-refactor`**, **`marketing-funnel-audit`**, **`prompt-decompose`**: all well-formed with strong trigger language. A.
- **`desktop-notify`**: functional but description mixes trigger phrases ("Triggers on notify when done") into narrative rather than clean trigger syntax. B.
- **`competitor-screenshot`**: description mixes triggers into prose. B.
- **`imported/research`**: foreign body — see issue #6. D.
- **`imported/copywriting`**, **`imported/gsap-*`**, **`imported/hyperframes*`**, **`imported/marketing-psychology`**: all well-formed with clear `name`, `description`, triggers. A/B range.

### Agents (14 agents, excluding README/HIERARCHY/SECURITY-PIPELINE/SWARM_PATTERNS docs)

Actual agent count: 10 (`brief-author`, `copy-strategist`, `creative-director`, `eng-director`, `eval-judge`, `experiment-analyst`, `ops-director`, `perf-auditor`, `research-director`, `security-auditor`, `security-blueteam`, `security-redteam`, `ship-checker`, `skill-auditor`, `video-director`) — 15 agent files.

- **Four director agents** (`creative-director`, `eng-director`, `ops-director`, `research-director`): no YAML frontmatter, stale model versions. D.
- **`eval-judge`**, **`security-auditor`**, **`security-blueteam`**, **`security-redteam`**, **`ship-checker`**, **`skill-auditor`**: all have proper frontmatter, sharp descriptions, correct model assignments. A.
- **`brief-author`**: uses `tools:` not `allowed-tools:` (same schema inconsistency as semantic-recall). B.
- **`copy-strategist`**: uses `tools:` not `allowed-tools:`. B.
- **`perf-auditor`**: uses `tools:` not `allowed-tools:`. B.
- **`video-director`**: uses `tools:` not `allowed-tools:`. B.
- **`experiment-analyst`**: uses `model: claude-sonnet-4-6` (correct). But description lacks "Use when" trigger opener — just jumps to purpose. B.
- **`eval-judge`**: `model: haiku` — uses symbolic not full model ID. Acceptable shorthand but inconsistent with ecosystem convention. B.

### Commands (19 commands, excluding README)

- **8 commands without frontmatter** (`audit-self`, `compact-strategic`, `clear-task`, `cost`, `eval-status`, `memory-index`, `experiment`, `swarm`): C.
- **`archive`**, **`retro`**, **`ship`**, **`storyboard`**, **`sync-state`**, **`competitor-snapshot`**, **`content-batch`**, **`eval`**, **`render`**, **`brief`**, **`audit-page`**: have frontmatter. A/B range.
- **`audit-self`**: well-written command with apply mode — just needs frontmatter. B.
- **`swarm`**: substantial content, no frontmatter, no `allowed-tools`. C.
- **`compact-strategic`**: no frontmatter, logic is good. B.

### Hooks (13 hooks: 11 bash + 2 JS)

- **None are registered in `settings.json.template`**. This is the highest-severity structural gap in the hooks category. All hooks are dead until wired up. D for registration state; individual hook quality varies.
- **`notify-on-long-task.sh`**: relies on `TURN_START_TIME`/`TURN_END_TIME` env vars not provided by Claude Code SDK. Silently no-ops on every run. D.
- **`git-safety.sh`**: blocks destructive git ops. Correct hook type (PreToolUse). Would be A if registered.
- **`security-guard.sh`**, **`pre-write-secrets-scan.sh`**: both scan for secrets on write. Partial overlap — `security-guard.sh` blocks (exit 2), `pre-write-secrets-scan.sh` is advisory (exit 0). Intentional layered defense, acceptable.
- **`cost-circuit-breaker.js`**, **`circuit-breaker.sh`**: two separate circuit breakers. `cost-circuit-breaker.js` tracks token costs; `circuit-breaker.sh` tracks consecutive tool failures. Distinct enough to keep both.
- **`velocity-monitor.sh`**: good idea, correct PostToolUse hook type. B.
- **`model-routing-guard.js`**: advisory only, correct PreToolUse on Agent calls. A when registered.
- **`hook-profile-loader.sh`**: SessionStart profile switching — clever but writes to a file that other hooks must explicitly read. Low adoption risk. B.
- **`auto-index-on-archive.sh`**: triggers off bash command containing "session-archive" — fragile string match. B.

### Rules (7 rules)

- All 7 rules have proper frontmatter with `name` and `description`.
- **`anti-sycophancy`**, **`quality-standard`**, **`prompt-completeness`**, **`lean-engine`**, **`cost-zero-tolerance`**, **`context-hygiene`**: sharp, actionable, non-redundant. A.
- **`path-scoped-loading`**: missing `name:` in frontmatter (has `---` delimiter but no `name` field in the displayed head). Check and add. B.

### Expertise (10 YAMLs)

- All 10 have `domain`, `keywords`, `last_updated`, `confidence` fields. Well-structured.
- **`brand-voice-system`**, **`campaign-planning`**, **`marketing-cro`**, **`gsap-patterns`**, **`hyperframes-domain`**: high quality, specific signal. A.
- **`instagram-algorithm-2026`**, **`tiktok-distribution-2026`**, **`youtube-shorts-strategy`**: time-sensitive data (algorithm weights from Q1 2026). Add `review_by: 2026-10-01` field to flag for staleness check. B.
- **`claude-code-cost-ops`**: prices marked `approximate` — correct, but no link to canonical source. Add `source_url: https://anthropic.com/pricing`. B.
- No missing expertise domains detected for active skills.

---

## Redundancies Detected

- **`semantic-recall` vs `session-recall`**: Both search the same archive directory, both return top-3 hits, overlapping trigger phrases ("what was decided about", "recall context"). `semantic-recall` adds Voyage embedding support but is otherwise a strict subset of `session-recall` functionality. **Recommend: merge into `session-recall` with an optional semantic-search code path. Deprecate `semantic-recall`.**

- **`pre-write-secrets-scan.sh` vs `security-guard.sh`**: Both fire on Write tool use, both scan for secrets. `security-guard.sh` blocks (exit 2); `pre-write-secrets-scan.sh` is advisory (exit 0). This is intentional defense-in-depth layering — **keep both**, but document the layering rationale in a comment at the top of each file.

- **`gsap-timeline-design` skill vs `imported/gsap-scrolltrigger` + `imported/gsap-core`**: Partial overlap in GSAP API examples. `gsap-timeline-design` is a planning workflow skill; the imported GSAP skills are reference docs. **Keep both**, but trim duplicate API examples from `gsap-timeline-design`.

- **`cost-aware-research` (skill) vs `cost-zero-tolerance` (rule)**: Both enforce model routing / cost discipline. They are layered by design — the rule is declarative, the skill is procedural (decision tree for what to delegate). **Keep both** — they operate at different abstraction levels.

---

## Frontmatter Quality

### Files with wrong frontmatter key (`tools:` instead of `allowed-tools:`)
- `agents/brief-author.md`
- `agents/copy-strategist.md`
- `agents/perf-auditor.md`
- `agents/video-director.md`
- `skills/semantic-recall/SKILL.md`

### Files with no YAML frontmatter at all
- `agents/creative-director.md`
- `agents/eng-director.md`
- `agents/ops-director.md`
- `agents/research-director.md`
- `commands/audit-self.md`
- `commands/compact-strategic.md`
- `commands/clear-task.md`
- `commands/cost.md`
- `commands/eval-status.md`
- `commands/memory-index.md`
- `commands/experiment.md`
- `commands/swarm.md`

### Files missing trigger keywords in description (vague or narrative-only)
- `agents/creative-director.md` — "Use for end-to-end creative campaign orchestration" is reasonable but buried in prose body, not frontmatter
- `agents/eng-director.md` — same issue
- `agents/research-director.md` — same issue
- `agents/ops-director.md` — same issue
- `agents/experiment-analyst.md` — description starts with purpose but lacks "Use when..." opener
- `skills/desktop-notify/SKILL.md` — description mixes trigger triggers into narrative prose
- `skills/competitor-screenshot/SKILL.md` — same pattern

---

## Missing Pieces

- **Hook registration**: `settings.json.template` needs a complete `hooks` block wiring all 13 hooks to their correct event types. Without it the entire `hooks/` directory has zero effect.
- **`path-scoped-loading` rule**: possibly missing `name:` frontmatter field — verify and add.
- **`session-handoff` skill**: missing `allowed-tools` key in frontmatter entirely.
- **Director agent frontmatter**: four agents need YAML frontmatter to be callable by name via the Agent tool.
- **Model version update**: no single source of truth for current default model strings — a `defaults.yaml` or env-var convention would prevent future drift across agents, evals, and CI.
- **`imported/research` integration gap**: if Tavily-based research is genuinely needed, it should delegate through `cost-aware-research` patterns rather than bypassing routing rules. A proper integration wrapper is missing.

---

## Files Recommended for Deprecation

- `skills/semantic-recall/SKILL.md`: merge into `session-recall`. The Voyage semantic search capability should be a code path within `session-recall`, not a separate skill with overlapping triggers.
- `hooks/notify-on-long-task.sh`: broken — relies on `TURN_START_TIME`/`TURN_END_TIME` env vars that the Claude Code SDK Stop hook does not provide. Either fix to read `duration_ms` from stdin JSON payload (if available) or replace with the `desktop-notify` skill invocation pattern.

---

## Files Recommended for Merge

- `skills/semantic-recall/` → merge into `skills/session-recall/SKILL.md` as an optional semantic search code path gated on `VOYAGE_API_KEY`. Update `session-recall` trigger list to absorb `semantic-recall`'s triggers.

---

*Usage stats unavailable (scripts/usage-stats.sh returned no output). Zero-usage candidates cannot be confirmed statistically. Grades reflect structural analysis only.*
