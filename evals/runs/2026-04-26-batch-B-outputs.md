=== EVAL 1: ship-checker ===

=== CASE ship-001 ===

VERDICT: NO-GO

FINDINGS:

1. [SECRETS — CRITICAL] .env.production committed to public GitHub repo — contains STRIPE_SECRET_KEY and DATABASE_URL. Immediate revocation of both secrets required before any other action. This is an automatic NO-GO. Rotate the Stripe key and cycle the database credentials now; assume both are compromised.

2. [BROKEN LINK] /pricing page — href="/prcing" (typo). Navigation link resolves to a non-existent route. Users attempting to reach pricing will hit a 404.

3. [A11Y] /features — three <img> tags missing alt= attribute. All three are an automatic NO-GO per accessibility checklist. Each image must receive a descriptive alt or alt="" if decorative.

4. [RUNTIME ERROR] Contact form — success handler throws TypeError: Cannot read property 'email' of undefined (console-visible). Form appears to submit but the success path is broken. This is user-visible failure, not a cosmetic issue.

CLEARED:
- Mobile viewport meta tag present
- Favicon set
- robots.txt exists
- No additional credential patterns detected beyond .env.production finding

RESOLUTION REQUIRED BEFORE SHIP:
- Finding 1 (credentials leak) is non-negotiable. Revoke, rotate, remove from git history, add .env.production to .gitignore.
- Findings 3 (alt attributes) and the absence of a meta title/description check — confirm meta title and description are present on all pages; not enough information was provided to clear this.

---

=== CASE ship-002 ===

VERDICT: NO-GO

FINDINGS:

1. [COPY — AUTOMATIC NO-GO] Product description on Deluxe SKU contains placeholder text '[INSERT BENEFITS HERE]'. User-visible placeholder copy is an automatic NO-GO. This text must be replaced with final copy before launch.

2. [COPY] Order confirmation email references old brand name 'Halo Goods'. Company rebranded to 'Soleil' 3 months ago. Every customer touchpoint must reflect the current brand name. Flag for legal/brand review.

3. [A11Y] 'Add to Cart' button on mobile has an effective tap target of approximately 28x28px, partially obscured by sticky cookie banner. WCAG 2.5.5 recommends a minimum 44x44px touch target. Users on mobile will miss or misfire the primary conversion action. Automatic accessibility blocker.

4. [TRUST / UX] Checkout page SSL padlock icon removed from custom theme. HTTPS is active but the visual trust signal is absent. Users may abandon checkout due to perceived security concern. Flag for immediate theme restore.

CLEARED:
- Sitemap submitted
- Google Analytics firing
- Meta descriptions present

NOTE: Did not find evidence of secrets, localhost URLs, lorem ipsum, or missing robots.txt within the provided scope. SSL padlock removal is a UX/trust issue, not a protocol failure — HTTPS itself is intact.


=== EVAL 2: brief-author ===

=== CASE brief-001 ===

Before I can produce a complete brief, I need to resolve the single most critical gap: I do not know what this product is or what it does. Every other field — goal, audience pain state, conversion action, tone — depends on this. Please tell me:

**What is the product? What does it do, and what problem does it solve for the buyer?**

Once I have that, I can draft the full brief. In the meantime, here is what I can fill and what remains blocked:

---

BRIEF
=====
Type: landing page
Date authored: 2026-04-26
Author: agent — brief-author

1. GOAL
   [NEEDS CONFIRMATION — product is unknown; cannot state a measurable goal without knowing what action the page must drive and for what offering]

2. AUDIENCE
   Primary: busy professionals
   Role: [NEEDS CONFIRMATION — "busy professionals" spans every industry and seniority level; need job title, company size, and pain state to write to a real person]
   Belief before: [NEEDS CONFIRMATION — depends on product]
   Desired belief/action after: [NEEDS CONFIRMATION — no conversion goal stated]

3. SUCCESS METRIC
   [NEEDS CONFIRMATION — no conversion goal, no baseline, no threshold stated; "convert well" is not a metric]

4. DELIVERABLES
   One landing page, mobile-responsive
   [NEEDS CONFIRMATION — copy only, or design + dev? Who owns each? What tech stack/CMS?]

5. DEADLINE
   Hard deadline (cannot move): [NEEDS CONFIRMATION — "end of month" — which month, which year? Is that copy-complete, design-complete, or live in production?]
   Soft deadline (preferred): [NEEDS CONFIRMATION]
   Review cycles expected: [NEEDS CONFIRMATION]

6. CONSTRAINTS
   Budget: described as "flexible" — [NEEDS CONFIRMATION — "flexible" is not a budget; what is the actual ceiling?]
   Brand/legal guardrails: [NEEDS CONFIRMATION]
   Technical constraints: mobile support confirmed
   Things explicitly off the table: [NEEDS CONFIRMATION]

7. CONTEXT & BACKGROUND
   [NEEDS CONFIRMATION — is there an existing page being replaced? A competitor benchmark? Prior attempts?]
   Why now: [NEEDS CONFIRMATION]

8. TONE & REFERENCE
   Visual direction: clean, modern (stakeholder's words)
   Reference examples: [NEEDS CONFIRMATION — "clean and modern" describes half the internet; need 3 URLs or descriptions of work that hits the right tone]
   Must NOT feel like: [NEEDS CONFIRMATION]

9. OPEN QUESTIONS
   - What is the product and what does it do? (BLOCKING — nothing else can be written without this)
   - What is the single conversion action? (signup, demo request, purchase, email capture?)
   - Who specifically is the audience? (industry, seniority, company size, pain state)
   - What does "end of month" mean exactly, and at what stage of completion?
   - What is the actual budget ceiling?
   - Is there a page being replaced, or is this net-new?

10. APPROVER
    [NEEDS CONFIRMATION — stakeholder is unnamed; need name and role of final sign-off]

---

=== CASE brief-002 ===

Enough to produce a near-complete brief with two targeted open questions flagged. Here it is:

---

BRIEF
=====
Type: ad campaign
Date authored: 2026-04-26
Author: agent — brief-author

1. GOAL
   Reactivate existing SaaS customers who have not purchased or engaged in 90+ days, driving them back to active status by August 15.
   [NEEDS CONFIRMATION — see Open Questions: "active status" must be defined as a specific action: login, purchase, renewal, or upgrade]

2. AUDIENCE
   Who: existing customers of the SaaS tool, lapsed 90+ days with no purchase activity
   Belief before: product may no longer be relevant to them, or they have drifted to a competitor or no-tool workflow
   Desired action after: re-engage — return to the product and take the defined reactivation action (see Q1)
   [NEEDS CONFIRMATION — audience targeting parameters for paid channels: are these addressable by email CRM export, or will paid channels require lookalike/custom audience upload?]

3. SUCCESS METRIC
   [NEEDS CONFIRMATION — BLOCKING: reactivation rate is undefined. What KPI constitutes a successful reactivation? Suggested candidates: % of lapsed segment completing a login, a purchase, or a renewal within 30 days of campaign touch. Need a number and a timeframe.]

4. DELIVERABLES
   Channels: social (platform(s) TBC) + email
   Brand assets: provided (existing)
   [NEEDS CONFIRMATION — exact creative deliverables: number of email variants, social ad formats and dimensions, copy variants required for A/B testing, platform selection (Meta? LinkedIn? Both?)]

5. DEADLINE
   Hard deadline (cannot move): August 15
   Soft deadline (preferred): [NEEDS CONFIRMATION]
   Review cycles expected: described as "fast" — [NEEDS CONFIRMATION — fast is not a cycle count; how many rounds, and what is the turnaround expectation per round?]
   Legal review: required for any creative containing a discount offer

6. CONSTRAINTS
   Budget: $40,000 total
   Brand/legal guardrails: legal team must review all discount offer creative before it runs
   Technical constraints: [NEEDS CONFIRMATION — ESP/sending platform for email? Ad account access? Any suppression list requirements?]
   Things explicitly off the table: [NEEDS CONFIRMATION]

7. CONTEXT & BACKGROUND
   Product: SaaS tool (category and specific functionality not provided)
   Existing assets: brand assets confirmed available
   Prior reactivation attempts: [NEEDS CONFIRMATION — has this segment been contacted before? What happened?]
   Why now: Q3 campaign cycle; 90-day lapse window suggests a defined churn risk threshold

8. TONE & REFERENCE
   [NEEDS CONFIRMATION — no tone direction given. Need 3 examples of campaigns or creative that hit the right register for this brand and audience. What must this NOT feel like?]

9. OPEN QUESTIONS
   Q1: What defines a successful reactivation? (BLOCKING for success metric — login, purchase, renewal, or something else?) What is the target rate or volume?
   Q2: Is a discount offer planned, or is the legal-review constraint purely contingent? This affects creative strategy significantly — a discount-led reactivation versus a value-reminder approach are different campaigns.
   Q3: Which social platforms? (Meta, LinkedIn, other?) Platform selection drives format requirements and audience targeting approach.
   Q4: How many email variants and social creative variants are required? Are A/B tests planned?
   Q5: What SaaS product is this, and what is the primary value proposition to re-surface to lapsed users?

10. APPROVER
    [NEEDS CONFIRMATION — "approvals will be fast this time" implies a known approver; need name and role for sign-off chain]

Type-specific additions (ad campaign):
- Channel mix: social + email (platforms TBC)
- Spend range: $40,000 total (split across channels TBC)
- Audience targeting parameters: existing customer list, lapsed 90+ days — [NEEDS CONFIRMATION on upload/targeting method per channel]
- Creative variants required: [NEEDS CONFIRMATION — number of A/B tests not specified]

---


=== EVAL 3: session-handoff ===

=== CASE handoff-001 ===

```
---
HANDOFF — 2026-04-26
SESSION GOAL: Migrate auth flow from NextAuth default handler to a custom JWT-based handler at /api/v2/auth with org-scoped claims support.
---

COMPLETED
- Wrote new JWT auth config at src/lib/auth.ts
- Wrote new custom handler at src/app/api/v2/auth/route.ts
- Updated middleware.ts matcher to route to new handler
- Validated that JWT strategy is functional (database session path not taken)

IN PROGRESS
- Legacy handler at /api/auth/[...nextauth] still exists — not removed or redirected. Risk: conflicting auth paths in production. Status: intentionally deferred, not yet addressed.

DECISIONS
D1: Moved auth entrypoint from /api/auth/[...nextauth] to /api/v2/auth (custom handler) — Reason: NextAuth's session callback cannot be extended to include org-scoped claims without forking the library — Alternative rejected: forking NextAuth (maintenance burden, upgrade risk)
D2: JWT strategy chosen over database sessions — Reason: avoids a sessions table migration — Alternative rejected: database sessions (would require schema migration, added latency)

OPEN QUESTIONS
Q1: How to handle token refresh for long-lived CLI sessions? — Blocking: yes, for CLI auth path — Context: JWTs have a fixed expiry; CLI sessions can run for hours/days; no refresh strategy was designed or implemented. Needs decision before CLI auth is shipped.

NEXT ACTIONS
N1: Decide token refresh strategy for CLI sessions — File: src/lib/auth.ts — Depends on: Q1
N2: Remove or redirect legacy /api/auth/[...nextauth] handler to prevent auth path confusion — File: src/app/api/auth/[...nextauth]/route.ts (or equivalent NextAuth default path) — Depends on: nothing blocking, safe to do once N1 is decided to avoid double-migration
N3: Test new handler end-to-end: org-scoped claims present in JWT payload, middleware matcher routing correctly, sessions invalidate on token expiry

CRITICAL FILES
- src/lib/auth.ts — new JWT auth configuration; org-scoped claims logic lives here
- src/app/api/v2/auth/route.ts — new custom auth handler; replaces NextAuth default
- middleware.ts — updated matcher; routes requests to new /api/v2/auth path
- (legacy, risk) src/app/api/auth/[...nextauth]/route.ts (or pages/api/auth/[...nextauth].ts) — old NextAuth handler, still live, not yet removed

CONTEXT TO RESTORE
The org-scoped claims requirement is the root reason for this entire migration — any solution that cannot attach org context to the token is off the table. JWT strategy was chosen specifically to avoid a sessions table migration; do not revisit database sessions unless the migration cost is re-evaluated. The CLI token refresh question (Q1) is the only unresolved architectural decision and it is blocking CLI auth shipment. The legacy /api/auth path being live is a known risk, not an oversight — it was left because the new path was not fully validated at session end.
---
```

---

=== CASE handoff-002 ===

```
---
HANDOFF — 2026-04-26
SESSION GOAL: Fix CLS (Cumulative Layout Shift) regression on the product page caused by a Suspense boundary resolving after above-fold paint.
---

COMPLETED
- Root cause identified: <Suspense> boundary wrapping review carousel resolves after above-fold content paints, causing a 140px layout shift
- Fix applied: added min-height placeholder to Suspense fallback in components/ReviewCarousel.tsx
- Desktop CLS improved: 0.31 → 0.04 (passes Core Web Vitals threshold)

IN PROGRESS
- Mobile CLS still failing: 0.18 (threshold is 0.1) — Status: fix is applied but incomplete; the min-height is hardcoded in px and the carousel height is dynamic on mobile, so the placeholder does not adequately reserve space

DECISIONS
D1: Added min-height placeholder to Suspense fallback as the fix approach — Reason: simplest intervention to reserve space before carousel loads — Alternative rejected: none formally; approach was chosen as first attempt and works on desktop
D2: Mobile fix approach deferred — Reason: two competing options identified (ResizeObserver + localStorage hint vs. taller fixed fallback); decision requires design input — Alternative rejected: neither option was ruled out; both are still on the table

OPEN QUESTIONS
Q1: Mobile carousel height fix approach — Blocking: yes, mobile CLS remains at 0.18 — Context: Option A: use ResizeObserver to measure carousel height on first load, store in localStorage as a hint for subsequent visits. Option B: hardcode a taller fixed fallback that covers the mobile carousel height. Design input required before proceeding — carousel height is a design decision.

NEXT ACTIONS
N1: Get design input on mobile carousel height (or confirmation that Option A/B is acceptable) — File: components/ReviewCarousel.tsx — Depends on: Q1
N2: Implement chosen mobile fix in Suspense fallback — File: components/ReviewCarousel.tsx — Depends on: Q1 resolved
N3: Run Lighthouse CI after mobile fix to confirm CLS ≤ 0.1 on mobile — File: scripts/lighthouse-ci.ts — Depends on: N2 complete
N4: Verify desktop CLS has not regressed after mobile fix — File: scripts/lighthouse-ci.ts — Depends on: N2 complete

CRITICAL FILES
- components/ReviewCarousel.tsx — Suspense fallback with min-height placeholder; this is where the mobile fix must be applied
- app/product/[slug]/page.tsx — product page where the ReviewCarousel is rendered; Suspense boundary lives here or in the carousel component itself
- scripts/lighthouse-ci.ts — Lighthouse test script used to measure CLS before and after fix; re-run after any change

CONTEXT TO RESTORE
The CLS issue is specifically caused by the Suspense boundary resolving late — not by image loading, font loading, or any other common CLS source. Desktop is fixed and should not be touched. The mobile problem is purely that we don't know the carousel's height at SSR time on mobile. The ResizeObserver/localStorage approach would be progressive (first visit still shifts, subsequent visits don't); the fixed-height approach would fix all visits but could look wrong if the carousel height changes. Neither decision should be made without design sign-off on carousel height expectations.
---
```
