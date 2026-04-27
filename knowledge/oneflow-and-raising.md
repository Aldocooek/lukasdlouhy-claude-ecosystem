# OneFlow & Capital Raising — Reference Knowledge

<!-- Compiled from public artifacts in filipdopita-tech/claude-ecosystem-setup. Reference material — adapt before production use. -->

## What OneFlow Is

OneFlow (oneflow.cz) is a Czech fintech operated by Filip Dopita, specialising in corporate bond emissions (dluhopisy) and investor acquisition. The business sits at the intersection of two flows: helping Czech SMB issuers raise capital via bond emissions, and sourcing sophisticated retail and HNWI investors to absorb those emissions. OneFlow is not a licensed CNB entity (no bank/AIFM/ECSP licence) — it operates as an investment intermediary (zprostředkovatel investic) with AML obligations. Production scale confirmed in 2026: 5 live outreach domains, a LinkedIn + WhatsApp + cold-email pipeline, 10,067 firms processed through the data-enrichment engine, and 503 outreach-ready leads from a single enrichment run. The AI stack runs on a Flash VPS with Gemini 2.5 Flash as primary worker for DD and a Claude Sonnet fallback for high-stakes synthesis, all orchestrated via a custom Chain-of-Agents conductor.

Target audience: Czech HNWI (10M+ CZK portfolio, 35–60, founders/doctors/lawyers) as primary; sophisticated retail (500K+ CZK) as secondary; founders seeking to run their own bond emission as tertiary.

## Czech Regulatory Context

**Bond law — Zákon č. 190/2004 Sb.:** Any Czech s.r.o. can issue bonds without a CNB licence. Minimum required document is the emisní podmínky (issuance terms), covering: nominal value, yield (coupon or discount), maturity date, issuer IČO/address, subordination status (yes/no), and ISIN if seeking a regulated market listing.

**Prospectus exemptions — EU Regulation 2017/1129 (implemented in CZ):** No prospectus required if:
- Total emission < 1M EUR in any 12-month window, OR
- Max 149 investors (private placement / "qualifying investors" rule), OR
- Minimum denomination ≥ 100,000 EUR per bond (institutional), OR
- Offered exclusively to professional clients (MiFID II definition).

Combining two exemption grounds requires legal sign-off. CNB monitors emissions even when no prospectus is required.

**ECSP — EU Regulation 2020/1503 (effective CZ: 10 November 2023):** Crowdfunding service providers offering investment products online to the public above 5M EUR in 12 months require a CNB-issued ECSP licence. OneFlow's current structure (direct intermediary, not a public online platform) sits below this threshold, but the assessment is flagged [ASSUMED — verify with counsel].

**AML — Zákon č. 253/2008 Sb.:** OneFlow as a financial services intermediary is considered an obligated entity. Requirements:
- KYC at investor onboarding: ID document, proof of address (≤3 months old), source of funds declaration.
- PEP screening (WorldCheck / Dow Jones Risk / CNB list) at onboarding and on significant profile changes.
- Transaction monitoring: flag anything above 10,000 EUR.
- Suspicious activity reports to FIU (Financial Intelligence Unit, Ministry of Finance).
- 10-year append-only document retention.
- ČNB + ÚOOÚ 72-hour breach notification obligation.
- Professional investor qualification: 2 of 3 criteria — portfolio >500K EUR, ≥10 trades/quarter for 4 quarters, or 1+ year relevant finance employment. Opt-up form (escritura de calificación) required.

**ZPKT — Zákon č. 256/2004 Sb. (MiFID II implementation):** Investment intermediaries may need CNB registration. Obligations include best execution, suitability assessment, and fee/conflict-of-interest disclosure. [ASSUMED — OneFlow must confirm whether its activity triggers registration.]

**Red-flag rule (regulatory):** Guaranteed yield in any marketing material is illegal. Spread >500 bps above risk-free rate is a distress signal. Offers above the 149-investor or 1M EUR thresholds without a prospectus are an immediate stop — flag to Filip.

## Due Diligence Framework

OneFlow runs two complementary DD workflows:

**`/dd-emitent`** — for any named issuer. Pulls live data from Justice.cz (OR, insolvency), ARES (IČO, company record), ISIR (isir.justice.cz for insolvence check), and ČNB JERRS (emitter registry). Runs adversarial self-review after drafting.

**`/dd-pipeline`** — for PDF prospectuses of any length. Sends the PDF to the Flash VPS Chain-of-Agents conductor (Gemini 2.5 Flash workers + optional Claude Sonnet manager synthesis). Processes 100-page prospectus in 2–4 min, 500-page in 5–10 min, at zero marginal cost (Max subscription + Flash VPS).

**6-Dimension Scoring Matrix** (both workflows output an A–F composite):

| Dimension | Weight | What is scored |
|---|---|---|
| Financial health | 25% | DSCR, LTV, cash flow stability, 3-year revenue trend |
| Legal clarity | 20% | ISIR clean, no active zástavy/liens, no court proceedings, prospectus status |
| Business model | 20% | Revenue diversification, customer concentration, EBITDA margin vs sector |
| Team | 15% | Track record, references, UBO verification, no PEP/sanction matches |
| Collateral | 15% | Real asset value (conservative, not issuer-stated), pledge position, liquidity |
| Market risk | 5% | Sector cyclicality, macro context |

**Grade thresholds:** A = 90+, B = 75–89, C = 60–74, D = 45–59, F = <45. F = recommend rejection.

**Numeric standards enforced in every report:**
- DSCR: X.XX (2 decimal places). Benchmark: <1.2 = risk; <1.0 = immediate concern.
- LTV: XX.X%. Benchmark: >75% = warning. Conservative valuation (never issuer self-stated).
- Yield: always p.a. — never total return without explicit time axis.
- Maturity: exact date, not relative ("in 3 years").

**Automatic red-flag stops:** Emission above exemption threshold without prospectus; >149 retail investors without prospectus; guaranteed yield in marketing; cross-border offer without MiFID passport; Ponzi pattern indicators (new investor inflows fund existing payouts).

## Investor Outreach Methodology

**Signal-based, not quota-based.** Outreach is triggered by evidence of intent, not send-volume targets.

**Signal tiers:**
- Tier 1 (Active Buying): pricing page visit, teaser download, yield calculator use, direct DM/comment, referral from existing investor.
- Tier 2 (Event-Based): new IČO registration, founder exit, M&A completion, LinkedIn post mentioning investing.
- Tier 3 (Behavioral): repeated OneFlow content engagement (saves, views), LinkedIn activity around bonds/finance.

**Channels and benchmarks:**

| Channel | Volume/day | Sequence | Benchmark reply rate |
|---|---|---|---|
| LinkedIn Voyager | 30 connections | Connect → thanks → value×2 → meeting ask | 5–8% |
| Cold email | 50/domain | 5 emails over D+0/3/7/14/21 | 2–4%; target >15% personalized |
| WhatsApp | Variable | Signal-based, short | 26.2% reply on 2026-04-22 Steakhouse campaign |
| Warm intro | As available | No sequence needed | 40–60% |

**5-Email sequence structure:**
1. Day 0: Personalized first line + value stat + teaser + soft CTA (reply question, no link in email 1).
2. Day 3: Subject "Re: [previous]" + new angle, 80 words max.
3. Day 7: Case study or social proof number + medium CTA.
4. Day 14: Single direct question, no pitch, 60 words max.
5. Day 21: "Leaving you alone" breakup, door left open, 50 words max.

**Cialdini integration:**
- Reciprocity: Email 1 always gives (free DD, market report, data) — asks nothing.
- Social proof: "3 emissions, 47M CZK, 0 defaults" — specific numbers, never identifiable clients without consent.
- Scarcity: Only real allocation limits or real deadlines. Never fake urgency — CNB monitors.
- Authority: CNB registration, track record, third-party audit.

**Banned phrases (CZ):** "dovoluji si", "rád bych", "pokud byste měl chvilku", "mám pro vás exkluzivní nabídku", generic templates, multi-paragraph walls. Sign as "Dopita" or "Filip Dopita, OneFlow" — never "s pozdravem".

**Max email length:** 100 words (mobile-first). Max WhatsApp: 80 words. Every message ends with a CTA or clear next step, never a summary.

**Deliverability hard rules:**
- Bounce rate >4% → HALT.
- Spam rate >0.3% → HALT.
- Never send from a domain in Proofpoint PDR blocklist.
- 21-day warmup before full volume. Max 50 emails/domain/day during warmup.
- A/B/C domain rotation: A = high-priority, B = test sequences, C = warmup only.

## Pitch Deck / Investment Memo Structure

*OneFlow uses this for both pitching its own service to founders (fundraising clients) and for materials it helps issuers produce.*

**Stage-appropriate slide counts:** Pre-seed/Seed: 8–14 slides. Series A: 14–18. Series B: 16–20.

**Standard Pre-Seed/Seed sequence (8-slide minimum — Intercom model):**
Cover → Problem (YC P.A.I.N. — specific, quantified) → Solution (symmetric: 3 problems = 3 solutions) → Traction (numbers as early as possible) → Why Now (tech/regulatory/behavioural shift — Sequoia required slide) → Market (TAM top-down + SAM bottom-up: "0.4% TAM = €200M ARR" frame) → Competition (quadrant or attribute grid; never "no competitors") → Ask (amount + 3-line breakdown + milestone it unlocks + runway).

**Narrative arc (6-part):**
SHIFT → ENEMY → BREAKTHROUGH → PROOF → EXPANSION → CALL.

**Emotional vs. rational balance:**
- Slides 1–3: Win emotionally (conviction, vision, fear of missing out).
- Slides 4–12: Win rationally (unit economics, market size, defensible moat).
- Slides 13+: Re-activate emotion (team story, vision statement).

**Copywriting rules:**
- Headlines: 5–10 words, complete thought. Traction slide example: "$3.2M ARR — 3× YoY".
- Numbers: $15M not $15,000,000; 3.2× not 320% growth; 3.4% not 0.034 churn.
- Bullets: verb-first ("Uzavřeli", not "Systém umožňuje"), parallel structure, quantified.
- Text density: live deck max 10–15 words/slide; leave-behind max 75 words/slide; max 3 bullets (absolute cap 5).
- Banned: "innovative", "revolutionary", "seamless", "best-in-class", "passionate", "leverage" as verb.

**Common failure modes:** Cherry-picked retention cohorts (a16z red flag #1); deck numbers that don't match financials; weak Ask ("We'd love to discuss further" vs. "$80M CZK — would you lead or co-lead?"); LinkedIn-style error of listing multiple revenue streams instead of one primary.

**Investor update format (Visible.vc standard):**
1. Highlights (3–5 specific wins with numbers)
2. Lowlights (2–3 things not working + what's being done)
3. Metrics (4–6 KPIs, never change the definitions)
4. Team updates
5. Ask (1–2 specific requests, e.g. "intro to [named person] at [named firm]")
Send Wednesday or Thursday. Never Monday or Friday.

**Data room structure (prepare before fundraise starts):**
01_Overview / 02_Financials (24-month P&L + cap table) / 03_Metrics (KPI dashboard + cohort analysis) / 04_Product / 05_Legal / 06_Team (on request).

## Brand Voice & Style (OneFlow)

**Language:** Czech (cs-CZ) for all investor-facing content. English for Dubai/international pipeline.

**Voice principles:**
- Direct, confident, no apologies. Maximum 2 sentences per idea.
- Active verbs ("nasadil", not "byl nasazen").
- Numbers instead of adjectives ("49,215 Kč", not "slušná mzda").
- No hedging: eliminate "možná", "potenciálně", "určitě", "snad".
- No exclamation marks.
- Every message ends with action (CTA), not a period.
- Formal address (vykání) with new contacts.
- Signature: "Dopita" (short) or "Dopita / OneFlow" (standard). Never "s pozdravem".
- Max 2 emoji per message.

**Visual system — monochrome only:**
- Primary: #000000 (black headings/CTA text), #1A1A1A (fills), #555555 (secondary text).
- Light surfaces: #F2F0ED bg (warm off-white, premium paper), #E5E3E0 borders, #C8C4BF accent.
- Dark surfaces: #0A0A0C bg.
- No gold, no orange, no saturated hues — ever.
- Font: Inter Tight only. No exceptions, no mixing.
- Alternating dark/light surface rhythm per section.
- Post formats: 1080×1350 (IG carousel/static), 1080×1920 (Reel/Story), 1200×628 (LinkedIn).

**Content pillars (Instagram/LinkedIn):** Investment 30%, Fundraising BTS 25%, CZ Market 20%, Personal/Filip 15%, AI/Tech 10%. Metric priority: saves > shares > comments > profile visits > reach.

**Banned words (CZ):** inovativní, revoluční, komplexní řešení, win-win, synergie, paradigma, disruptivní, "v dnešní době" → "teď", "závěrem lze konstatovat", "dovoluji si", "s pozdravem" → "Dopita", Furthermore, Moreover, em dash.

**AI-robot patterns to remove:** Lists of exactly 5 or 10 bullet points, uniform sentence length throughout, excessive em-dash use.

## Operational Patterns

OneFlow's Claude Code ecosystem is organised around composable skill/agent chains:

- **`/dd-emitent`** → auto-triggers `/evalopt` (quality audit) → optional `/deset` (10/10 polish). Any DD that scores below a set threshold on auto-eval gets flagged before delivery.
- **`/dd-pipeline`** handles PDF prospectuses via SSH to Flash VPS conductor. Zero marginal cost (Gemini 2.5 Flash on VPS, Max subscription for Claude synthesis).
- **`outbound-strategist` agent** reads `expertise-sales-psychology.md`, `filip-style-clone.md`, and `cz-market-data.md` at boot before generating any outreach.
- **Email deliverability guard**: pre-send check is a mandatory gate (Proofpoint PDR, SPF/DKIM/DMARC, bounce rate, spam rate). Any check failure = HALT, escalate to Filip.
- **Data enrichment pipeline**: ARES (free baseline, 100% CZ coverage) → Apollo (~70% hit rate on 50+ employee SMB) → Hunter.io fallback → SMTP verify gate. Supplemented by ISIR, CUZK (cadastre), Justice.cz (court), Veřejný rejstřík (UBO/liens).
- **GHL CRM**: GoHighLevel via API v1+v2. Tag taxonomy by lifecycle stage, source channel, vertical. Custom fields for IČO, DIČ, právní forma. Webhook handlers for inbound replies. Production: 110+ Dubai LinkedIn leads in pipeline.
- **LinkedIn Voyager**: Playwright session refresh, 4-variant A/B message testing, Czech/English language detection, daily humanized cadence limits.
- **Knowledge routing**: keyword-triggered CARL activation pattern loads only the relevant expertise YAML for each task type, keeping context lean.

## Key Heuristics + Quotable Rules

1. **OneFlow reputation > yield.** One bad emitter = reputational catastrophe. DSCR <1.2 or LTV >75% = reject, regardless of yield.
2. **Never verify DSCR from the emitter's projections.** Use actual cash flow numbers. Projections are marketing.
3. **ISIR check is non-negotiable.** One skipped insolvency check can cost six figures.
4. **Guaranteed yield in marketing = illegal.** Spot it, stop it, flag it immediately.
5. **Under 1M EUR and under 149 investors = no prospectus needed.** Combine both exemptions only with legal sign-off.
6. **Email 1 always gives, never asks.** Reciprocity is the opener.
7. **Fake scarcity is forbidden.** CNB monitors. Only use real allocation limits or real deadlines.
8. **100-word cap on cold emails.** Mobile-first. One CTA per message, one question or one imperative.
9. **Numbers beat adjectives.** "3 emissions, 47M CZK, 0 defaults" > "impressive track record".
10. **Signal-based outreach, not quota-based.** Reply rate targets: >15% cold email, >5% meeting booking from cold.
11. **Domain warmup is 21 days minimum.** No full-volume send before that. A/B/C domain rotation is mandatory.
12. **Pitch deck: numbers ≠ deck numbers → deal killer.** Sync deck and data room before investor sharing.
13. **"Nemáme konkurenci" on a competition slide = instant credibility loss.** Always show a quadrant or grid.
14. **Investor updates: change the metric definitions = kill trust.** Pick 4–6 KPIs and never redefine them.
15. **The Ask slide must be specific:** amount + breakdown + milestone it unlocks + runway. "We'd love to discuss further" is not an ask.
16. **Post-send check is not optional.** Proofpoint PDR block = zero emails from that IP until cleared.
17. **All regulatory [ASSUMED] flags require legal verification before investor-facing use.**
18. **DD adversarial self-review is mandatory.** After drafting, ask: "What did I miss? Where was I too optimistic? Would I invest my own money?"

## Sources

All content compiled from the following raw files in `filipdopita-tech/claude-ecosystem-setup` (main branch):

- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/SPECIALIZATION.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/expertise/czech-regulatory.yaml`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/expertise/investor-outreach.yaml`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/expertise/oneflow-brand.yaml`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/rules/oneflow-all.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/rules/domains/cold-email.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/rules/domains/investment.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/knowledge/pitch-deck-factory.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/agents/outbound-strategist.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/skills/dd-pipeline/SKILL.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/skills/dd-emitent/SKILL.md`
- `https://raw.githubusercontent.com/filipdopita-tech/claude-ecosystem-setup/main/skills/investment-memo/SKILL.md`

Directory listing only (not fetched for content): `expertise/` README, `knowledge/` directory, `rules/` directory, `agents/` directory, `skills/` directory.
