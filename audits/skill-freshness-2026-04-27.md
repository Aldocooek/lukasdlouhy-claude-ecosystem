# Skill Freshness Audit — 2026-04-27

**Audited:** 2026-04-27
**Auditor:** skill-freshness-check v1.0.0
**Scope:** skills/* + skills/imported/* (39 skills total)

---

## Summary

| Metric | Count |
|---|---|
| Total skills audited | 39 |
| FRESH (< 180 days) | 39 |
| STALE (180–364 days) | 0 |
| ROTTING (365+ days) | 0 |
| Missing last-updated | 0 |

**Note:** All 39 skills were created/last-committed 2026-04-27 (repo initial release). `last-updated` was added in this session. All skills start at 0 days old. The next meaningful freshness check should run in ~180 days (2026-10-24).

---

## Full Skill Table

| Skill | last-updated | Age (days) | Status | Suggested Action |
|---|---|---|---|---|
| brand-dna-extractor | 2026-04-27 | 0 | FRESH | No action |
| clarity-heatmaps | 2026-04-27 | 0 | FRESH | No action |
| competitor-screenshot | 2026-04-27 | 0 | FRESH | No action |
| computer-use-qa | 2026-04-27 | 0 | FRESH | No action |
| cost-aware-research | 2026-04-27 | 0 | FRESH | No action |
| cost-snapshot | 2026-04-27 | 0 | FRESH | No action |
| desktop-notify | 2026-04-27 | 0 | FRESH | No action |
| gsap-timeline-design | 2026-04-27 | 0 | FRESH | No action |
| hyperframes-debug | 2026-04-27 | 0 | FRESH | No action |
| ig-content-creator | 2026-04-27 | 0 | FRESH | No action |
| instagram-analyzer | 2026-04-27 | 0 | FRESH | No action |
| landing-patterns-2026 | 2026-04-27 | 0 | FRESH | No action |
| lean-refactor | 2026-04-27 | 0 | FRESH | No action |
| marketing-funnel-audit | 2026-04-27 | 0 | FRESH | No action |
| meta-ads-api | 2026-04-27 | 0 | FRESH | No action |
| monitor-build | 2026-04-27 | 0 | FRESH | No action |
| monitor-deploy | 2026-04-27 | 0 | FRESH | No action |
| monitor-render | 2026-04-27 | 0 | FRESH | No action |
| motion-react | 2026-04-27 | 0 | FRESH | No action |
| multi-agent-debate | 2026-04-27 | 0 | FRESH | No action |
| mythos-narrator | 2026-04-27 | 0 | FRESH | No action |
| playwright-content-qa | 2026-04-27 | 0 | FRESH | No action |
| posthog-analytics | 2026-04-27 | 0 | FRESH | No action |
| prompt-decompose | 2026-04-27 | 0 | FRESH | No action |
| remotion-best-practices | 2026-04-27 | 0 | FRESH | No action |
| rum-monitoring | 2026-04-27 | 0 | FRESH | No action |
| semantic-recall | 2026-04-27 | 0 | FRESH | No action |
| session-handoff | 2026-04-27 | 0 | FRESH | No action |
| session-recall | 2026-04-27 | 0 | FRESH | No action |
| shadcn-ui | 2026-04-27 | 0 | FRESH | No action |
| video-storyboard | 2026-04-27 | 0 | FRESH | No action |
| imported/copywriting | 2026-04-27 | 0 | FRESH | No action |
| imported/gsap-core | 2026-04-27 | 0 | FRESH | No action |
| imported/gsap-react | 2026-04-27 | 0 | FRESH | No action |
| imported/gsap-scrolltrigger | 2026-04-27 | 0 | FRESH | No action |
| imported/hyperframes-cli | 2026-04-27 | 0 | FRESH | No action |
| imported/hyperframes | 2026-04-27 | 0 | FRESH | No action |
| imported/marketing-psychology | 2026-04-27 | 0 | FRESH | No action |
| imported/research | 2026-04-27 | 0 | FRESH | No action |

---

## Tool Version Flags (requires manual check)

These skills embed tool-specific patterns that drift with upstream releases. Flag for manual version cross-check at next STALE threshold (2026-10-24):

| Skill | Tool | Check command |
|---|---|---|
| shadcn-ui | shadcn/ui | `npm info shadcn-ui version` |
| motion-react | motion/react | `npm info motion version` |
| gsap-timeline-design | GSAP | gsap.com/docs — check for v4+ breaking changes |
| imported/gsap-* | GSAP | same as above |
| remotion-best-practices | Remotion | `npm info remotion version` |
| meta-ads-api | Meta Graph API v21 | developers.facebook.com/docs/graph-api/changelog |
| posthog-analytics | PostHog | posthog.com/docs/changelog |
| rum-monitoring | Vercel Speed Insights | vercel.com/docs/speed-insights |

---

## Top 5 "Oldest" Skills

All skills tied at 0 days. The 5 most functionally complex (highest drift risk by domain velocity):

1. **meta-ads-api** — Meta Graph API versions rotate every 6–12 months
2. **shadcn-ui** — shadcn releases are frequent; component APIs change
3. **motion-react** — motion/react had v10→v11 breaking changes in 2025
4. **remotion-best-practices** — Remotion releases ~monthly
5. **imported/gsap-core** — GSAP v4 released 2024; check if skill covers v4 APIs

---

## Recommendations

1. **Set calendar reminder for 2026-10-24** — re-run this audit at the 180-day mark. The first real STALE flags will appear then.
2. **Bump `last-updated` + `version` on every content edit** — this is now enforced by frontmatter presence; honor it on future edits.
3. **meta-ads-api deserves a v-check now** — Meta Graph API v21 deprecation window runs through mid-2026. Confirm the skill targets the current stable version.
4. **imported/* skills** — these were cherry-picked from a peer repo. Track upstream if the source repo is active; they may diverge faster than first-party skills.

---

*Next audit due: 2026-10-24. Run `/skill-freshness-check` to regenerate.*
