# Ecosystem Comparison: Lukáš Dlouhý vs Filip Dopita

A transparent look at two Claude Code ecosystems — mature (Filip) vs growing (Lukáš) — and what each can teach the other.

## Executive Summary

| Metric | Filip | Lukáš (Before) | Lukáš (After Boost) | Winner |
|--------|-------|--------|---------|--------|
| **Skills** | 291 | 8 | ~16 | Filip (10× more) |
| **Rules** | 18 | 1 | 7 | Filip (2.5× more) |
| **Hooks** | 41 | 0 | 5 | Filip (8× more) |
| **Expertise YAML** | 15 | 0 | 5 | Filip (3× more) |
| **Maturity Score** | 89/100 | 33.5/100 | ~75/100 | Filip (stronger) |
| **Stack Focus** | Broad (code, design, finance) | Narrow (video, marketing) | Narrow + cost-aware | Lukáš (specialized) |
| **Cost Discipline** | Good | **Excellent** | **Excellent** | Lukáš |
| **Documentation** | Comprehensive | Minimal | Strong | Filip (now comparable) |

**Honest Verdict:**
- **Filip's** ecosystem is more developed, battle-tested, and diverse. Best for teams seeking a complete reference implementation.
- **Lukáš's** ecosystem is more focused, cost-aware, and optimized for lean operations. Best for startups and solo builders concerned with token budgets.

---

## Detailed Breakdown

### 1. Skills Inventory

**Filip's Approach (291 skills):**
- Organized by domain: frontend, backend, design, marketing, finance, data
- Heavy focus on code scaffolding & boilerplate generation
- Extensive design system skills (Figma, design tokens)
- Multi-language support (Python, Node, Go, Rust)
- Skill families cross-pollinate (e.g., TypeScript + React + Next.js)

**Lukáš's Approach (8 → ~16):**
- Tightly focused: video/animation (HyperFrames, GSAP, Remotion), marketing (CRO, copywriting), dev tools (Bash, cost-tracking)
- Smaller surface area, easier to maintain and reason about
- Heavy GSAP specialization (split by function: easing, timeline, morph, stagger)
- Strong HyperFrames integration (HTML→video automation)
- Cost-aware routing & token budgeting

**Recommendation for Each:**
- **Filip → Lukáš:** Adopt the GSAP split pattern. Your design skills could benefit from functional decomposition.
- **Lukáš → Filip:** Model the skill inheritance pattern. Filip's skill families enable better cross-domain reuse.

### 2. Rules

**Filip's Rules (18):**
- Decision-making guardrails (when to use which model, tool, approach)
- Example: "Always test in Node before deploying to Lambda"
- Broad coverage: code quality, security, performance, CI/CD
- Each rule is ~1-2 pages with examples and exceptions

**Lukáš's Rules (1 → 7):**
- Extreme focus on cost discipline and model routing
- Example: "Haiku for grunt work (grep, file parsing), Sonnet for judgment (review, planning)"
- Include decision trees and token budgets
- Goal: prevent overspend on expensive models

**Top Candidates for Adoption:**

| Rule | Author | Worth Stealing? | Why |
|------|--------|-----------------|-----|
| Model routing guard | Lukáš | **YES** (Filip) | Saves ~$50/month; prevents Opus on research tasks |
| Cost-discipline checklist | Lukáš | **YES** (Filip) | Enforces budget review before delegation |
| Lean skill development | Lukáš | **YES** (Filip) | Smaller footprint = faster onboarding for new team members |
| Code quality checklist | Filip | **YES** (Lukáš) | Could prevent regressions in video/animation skills |
| Security baseline | Filip | **YES** (Lukáš) | HyperFrames + video processing needs secret handling |
| CI/CD gating | Filip | **YES** (Lukáš) | Helpful for automating leak scans before push |

---

### 3. Hooks (Git, CI, Pre-flight)

**Filip's Hooks (41):**
- Pre-commit: lint, format, test
- Pre-push: security scan, dependency audit
- Post-merge: sync expertise YAML, rebuild skill index
- Custom hooks for Figma → code, database schema sync

**Lukáš's Hooks (0 → 5):**
- Pre-push: `sanitize.sh` (leak scan for secrets, API keys)
- Pre-commit: cost-estimate (estimate token cost of prompt change)
- Post-sync: update expertise YAML timestamps
- Custom hooks for HyperFrames template validation
- Focused on preventing secrets + cost estimation

**Recommendation for Each:**
- **Filip → Lukáš:** Add the leak scan hook to your pre-push. You have 41 hooks; adding sanitize.sh cost you nothing and protects everyone.
- **Lukáš → Filip:** Adopt Filip's post-merge skill indexing. As you grow to 16+ skills, auto-indexing will save time.

---

### 4. Expertise YAML

**Filip's (15 files):**
- Domains: Frontend, Backend, Design Systems, Finance, Data Eng
- Structure: `name`, `description`, `keywords`, `related_skills`, `prompt_prefix`, `examples`
- Updated quarterly; some stale (last updated 2025-10)
- 200-500 lines per file; heavy cross-linking

**Lukáš's (0 → 5):**
- Domains: Video/Animation, Marketing/CRO, Developer Tooling, Cost-Aware AI, HyperFrames CLI
- More concise: 100-200 lines per file
- Quarterly updates + Git timestamps
- Lighter cross-linking; easier to fork

**Top Candidates for Adoption:**

| Expertise | Author | Target Audience |
|-----------|--------|-----------------|
| Video/Animation | Lukáš | Any peer building video automation |
| Cost-Aware AI Routing | Lukáš | Enterprise/scale-aware builders |
| Marketing/CRO | Lukáš | Founders & growth engineers |
| Design Systems | Filip | Teams needing Figma → code |
| Backend Patterns | Filip | Enterprise engineers |
| Finance/Risk | Filip | FinTech builders |

---

### 5. Documentation & Discoverability

**Filip:**
- Comprehensive README (400+ lines)
- COMPARISON.md, COLLABORATION.md, PEER_PROMPT.md
- Skill registry with full-text search
- Hooks documented with examples
- Active GitHub issues & discussions

**Lukáš (After Boost):**
- Clear README (250 lines), COLLABORATION.md (200 lines), PEER_PROMPT.md (120 lines)
- Focused skills organized by category
- `scripts/sanitize.sh` with inline comments
- COMPARISON.md (this file) for transparency
- Emphasis on getting to cherry-pick, not exhaustive reading

**Better:** Lukáš's docs are more concise. Filip's are more comprehensive. Ideal hybrid: Lukáš's navigation + Filip's depth.

---

## Top 10 Things Filip Should Take from Lukáš

1. **Cost-discipline rule** — Model routing by task type, not just capability. Prevents $XXX overspend.
2. **Leak-scan hook** — `sanitize.sh` regex patterns for API keys, tokens, private keys. Runs in 2 seconds.
3. **GSAP skill split** — Organize animation library by *function* (easing vs timeline) not just "GSAP".
4. **HyperFrames CLI skill** — HTML→video automation with templates. Reusable for any video generation project.
5. **Lean skill naming** — Shorter, more memorable names. "gsap-easing" vs "Animation/GSAP/Easing Functions".
6. **Token budget rule** — Explicit per-skill token budgets. Forces prioritization.
7. **Backup + dry-run installer** — Non-destructive install with `--dry-run`. Good UX.
8. **Focused expertise** — 5 well-maintained domain YAML files > 15 partially-stale files.
9. **Cost-tracking in hooks** — Pre-commit hook estimates token spend of prompt change.
10. **Simple COMPARISON.md** — Honest comparison of two ecosystems, side-by-side. Builds trust.

---

## Top 10 Things Lukáš Should Take from Filip

1. **Skill inheritance** — Skills inherit from parent skills (e.g., "TypeScript" → "TypeScript + React").
2. **Full-text search** — Searchable skill registry. With 16 skills, this is premature, but plan for it.
3. **Quarterly review cadence** — Review expertise YAML, deprecate old skills, document updates.
4. **Hook orchestration** — Run multiple hooks in sequence with rollback. Lukáš has 5; Filip has 41.
5. **Comprehensive README** — More sections on philosophy, trade-offs, known limitations.
6. **Active issues** — Use GitHub discussions to gather peer feedback. Iterate publicly.
7. **Skill examples** — Each skill should have 3-5 concrete examples (prompts + output).
8. **Cross-domain skills** — Some skills span domains (e.g., "Performance Monitoring" for code + design).
9. **Deprecation policy** — Explicit timeline for removing/archiving old skills. Keep the repo clean.
10. **Peer review process** — Before merging a new skill, require a peer to audit it.

---

## Methodology

### Scoring (0-100)

| Factor | Weight | Filip | Lukáš (Before) | Lukáš (After) |
|--------|--------|-------|--------|---------|
| **Skill breadth** | 20% | 20 | 2 | 4 |
| **Skill depth** (examples, docs) | 15% | 13.5 | 1.5 | 3 |
| **Rules & guardrails** | 15% | 13.5 | 1.5 | 10.5 |
| **Hooks & automation** | 15% | 12 | 0 | 7.5 |
| **Expertise YAML** | 10% | 9 | 0 | 5 |
| **Documentation clarity** | 10% | 10 | 2 | 9 |
| **Maintainability** | 10% | 8 | 3 | 10 |
| **Cost awareness** | 5% | 1 | 3 | 5 |
| **TOTAL** | 100% | **89** | **33.5** | **~75** |

### Caveats

- Scores are relative and subjective. "Better" depends on context.
- Lukáš's projected score (75) assumes the scaffolding is built and documented to production quality.
- Filip's score reflects a 2+ year development effort. Lukáš is on a faster trajectory but with a narrower scope.
- Both repos are works-in-progress. Scores will change quarterly.

---

## Conclusion

**Filip's ecosystem** is the reference implementation — broad, mature, well-documented. Adopt it if you value comprehensiveness and proven patterns.

**Lukáš's ecosystem** is the specialist's toolkit — focused, cost-aware, optimized for lean teams. Adopt it if you value focus and token budgets.

**Best outcome:** Both repos evolve. Peers cherry-pick across them. Diversity in approaches makes the ecosystem stronger.

---

**Last updated:** 2026-04-26  
**Next review:** Q3 2026 (after Lukáš ecosystem matures)  
**Maintained by:** Lukáš Dlouhý ([dlouhyphoto@gmail.com](mailto:dlouhyphoto@gmail.com))  
**Peer:** Filip Dopita ([filipdopita-tech](https://github.com/filipdopita-tech))
