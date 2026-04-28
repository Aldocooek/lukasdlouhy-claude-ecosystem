---
name: ads-meta
description: Meta (Facebook + Instagram) ads strategy, campaign structure, creative requirements, audience targeting, and optimization. Covers CBO/ABO, creative specs, kill rules, scaling rules, iOS 14.5 implications, and Czech-market CPM benchmarks.
allowed-tools: Read, Write, WebFetch, WebSearch, Bash
last-updated: 2026-04-27
version: 1.0.0
---

# Meta Ads Agent

Expert-level Meta (Facebook + Instagram) advertising strategy and execution.

## Triggers
"Meta ads", "Facebook ads", "Instagram ads", "Reels ads", "Stories ads", "FB campaign", "Meta campaign", "advantage+", "CBO", "ABO"

---

## 1. Account Structure

### CBO vs ABO
**CBO (Campaign Budget Optimization):** Budget set at campaign level; Meta distributes across ad sets dynamically.
- Use when: 3+ proven ad sets, trust Meta's allocation, scaling past €1K/day
- Advantage: Algorithm finds efficient allocations; reduces manual management
- Risk: One ad set can cannibalize budget from others; Meta favors broad audiences over niche ones

**ABO (Ad Set Budget Optimization):** Budget set at ad set level; full manual control.
- Use when: Testing phase (need controlled spend per ad set), launching new audiences, retargeting (must protect budget)
- Advantage: Precise control; essential for protecting retarget budgets from getting merged with cold traffic
- Structure: ABO for testing → CBO for scaling proven ad sets

### 3-2-2 Method (Andrew Foxwell)
Campaign → 3 ad sets (audience variations) → 2 creatives per ad set → test
After 7-14 days: identify winning ad set + creative combination, consolidate, scale in CBO.

### Campaign Naming Convention (Adam Kropáček)
```
[Platform]_[Objective]_[Audience]_[Offer]_[YYYY-MM-DD]
Example: META_CONV_ColdBroad_FreeGuide_2026-04-27
```

### Learning Phase
- Meta's algorithm requires 50 optimization events per ad set per week to exit learning phase
- During learning: CPAs are volatile; do not make structural changes
- Learning reset triggers: budget change >20%, audience change, creative change, bid change
- If stuck in "Learning Limited" after 7 days: consolidate ad sets or broaden audience

---

## 2. Audience Strategy

### Cold Traffic Audience Ladder
| Tier | Type | Size (CZ market est.) | Use case |
|------|------|----------------------|----------|
| 1% LAL | 1% Lookalike from customer list | 20-50K | Most similar to existing buyers |
| 1-3% LAL | Broader lookalike | 50-150K | Scale when 1% saturates |
| 3-5% LAL | Wide lookalike | 150-300K | Top of funnel reach |
| Broad | No targeting, let Meta optimize | All of CZ | Advantage+ audience; often outperforms manually stacked |
| Interest stacking | Layered interest targeting | Varies | Use when no customer list available for LAL |

### Advantage+ Audiences (2024+ Meta direction)
Meta's AI-driven targeting. Provide creative signals, let Meta find who converts.
- Often outperforms manual interest stacking for cold traffic on established accounts
- Requires 30+ conversions/month for Meta's model to be effective
- Keep broad targeting checked; Meta uses it as signal, not constraint

### Exclusion Layers (apply always)
- Existing customers: exclude by customer list (email/phone upload)
- Recent converters: exclude 7-14 day conversion window
- <10-second bouncers: exclude page engagement <10s (prevents wasted impressions)
- Retarget audiences: exclude from cold campaigns (don't let cold CPM hit warm traffic)

### Retargeting Windows (Adam Kropáček)
| Audience | Stage | Window | Bid approach |
|----------|-------|--------|-------------|
| Video viewers (25%) | TOFU | 30-90 days | Lower bid OK |
| Blog readers | TOFU | 30-90 days | Lower bid OK |
| Product page visitors | MOFU | 14-30 days | Standard |
| Pricing page visitors | MOFU | 7-14 days | Increase bid |
| Cart abandoners | BOFU | 1-7 days | Max bid; high-value |
| Lead form abandoners | BOFU | 1-7 days | Max bid |
| Exclude: recent purchasers | — | 14 days | Excluded |

---

## 3. Creative Requirements — Placement Specs

### Aspect Ratios
| Placement | Ratio | Resolution | Max duration |
|-----------|-------|------------|--------------|
| Feed (FB + IG) | 1:1 or 4:5 | 1080x1080 / 1080x1350 | 60 seconds |
| Reels | 9:16 | 1080x1920 | 90 seconds |
| Stories | 9:16 | 1080x1920 | 15 seconds |
| In-stream video | 16:9 | 1920x1080 | 5-15 seconds |
| Right column (desktop) | 1:1 | 1200x1200 | Static only |
| Collection | Square | 1:1 | — |

**Best practice:** Always produce 9:16 master. Crop to 1:1 and 4:5 from safe zone (center of frame).

### Video File Requirements
- Format: MP4 or MOV
- Codec: H.264
- Audio: AAC, 128kbps+
- Max file size: 4GB
- Safe zone: Keep text/faces within center 80% of frame (edges masked on some placements)

### Hook Mechanics — First 3 Seconds
- 85% of Meta video is consumed with sound off → text overlay on frame 1 is mandatory
- 0-3 seconds determines scroll or watch (Meta internal data)
- Target: 50%+ still watching at 3 seconds (hook-to-view ratio)
- Text placement: top-left or center-top; avoid bottom 15% (hidden by UI elements)
- Frame 1 must include: a face OR a product in use OR a bold text statement

### Retention Cliffs
| Completion | Signal | Action |
|------------|--------|--------|
| 25% | First quality filter | Track; anything below 25% avg = weak hook |
| 50% | Message-market fit | Strong engagement; optimize this creative |
| 75% | High intent | Retarget this audience immediately |
| 95% | Hot audience | Retarget with direct offer / scarcity close |

---

## 4. Hook Patterns Proven on Meta

### 1. Founder-to-Camera (Authentic Confession)
Setup: Informal setting, direct eye contact, first 2 words establish stakes.
Example: "We lost €40,000 on Meta ads before I figured this out. Here's what we changed."
Why: Authenticity signals override polished production in Meta feed context. UGC-style outperforms studio 60% of the time for cold traffic.

### 2. Dramatic Stat Drop (Pattern Interrupt)
Setup: Bold text on minimal background, contrasting color scheme.
Example: "4.8x ROAS. 30 days. €0 to €45K. Here's the structure." [black text, white background]
Why: Data-first hooks for business-aware audiences signal time value; no story needed.

### 3. Problem-Pain Loop
Setup: Describe the exact pain point in the first 2 seconds, pause.
Example: "You've tried Meta ads. Spent €5K. Got nothing back. Sound familiar?"
Why: Recognition drives attention. If it describes their experience, they're watching.

### 4. Contrarian Claim
Example: "Stop split-testing your Facebook copy. It's not the copy that's killing you."
Why: Takes opposite position to conventional wisdom; cognitive dissonance drives watch time.

### 5. Urgency Command + Specificity
Example: "Offer closes Sunday midnight — €2,400 off. Here's exactly what's included."
Why: Real urgency + specific price creates click pressure. Vague urgency is ignored.

### 6. Transformation Bridge
Example: "January: €8K spend, 0.9x ROAS. March: same budget, 3.8x ROAS. One structural change."
Why: Credible transformation narrative with specific numbers. Before/after creates aspiration.

### 7. Social Proof Lead
Example: "174 brands use this system. Average ROAS increased 2.1x in the first 60 days."
Why: Volume + specificity creates instant credibility. Specificity ("174" vs "hundreds") is crucial.

### 8. Curiosity Gap with Partial Reveal
Example: "There's one Meta setting that 90% of advertisers have never touched. It controls who sees your ad first."
Why: Information gap theory (Loewenstein) — partial reveal compels resolution. Mechanism withheld.

---

## 5. Numerical Thresholds — Meta Kill Rules

### CTR
- Target: >1.5% link CTR (cold traffic)
- Acceptable: 0.8-1.5%
- Kill signal: <0.8% link CTR after 500+ impressions
- CPC kill rule: >2x category benchmark after 100+ clicks

### CPM Benchmarks
| Market | Cold CPM range | Warm/Retarget CPM |
|--------|---------------|-------------------|
| Czech Republic | €5-15 | €8-20 |
| Slovak Republic | €4-12 | €7-15 |
| Germany | €8-25 | €12-30 |
| United States | $15-40 | $25-60 |
| United Kingdom | £8-20 | £12-25 |

CPM spikes indicate: audience saturation, increased competition (seasonal), learning phase instability, or low relevance score.

### ROAS Targets
| Audience temperature | Target ROAS | Kill below |
|---------------------|-------------|------------|
| Cold (prospecting) | 2.5x | 1.5x at 7 days |
| Warm (engaged) | 5x | 3x |
| Hot (retarget BOFU) | 10x | 4x |
| SaaS (LTV/CAC) | 3:1 LTV/CAC | 2:1 |

Break-even ROAS formula: 1 ÷ Gross Margin. 50% margin → break-even at 2x. Run nothing below break-even past week 1.

### Kill Decision Tree
1. **<48 hours:** Do not kill. Learning phase data is unreliable.
2. **Day 3-7, €50-100 spent, zero conversions:** Kill creative. Test new hook.
3. **Day 7, CTR <0.8%:** Kill ad set or refresh creative.
4. **Day 14, ROAS <1.5x cold:** Kill campaign, audit landing page, rebuild angle.
5. **CPC >2x benchmark consistently:** Landing page CRO issue OR creative relevance issue. Check both before killing.

### Scaling Rules
- Maximum budget increase: 20-30% per day (Adam Kropáček rule: never exceed 30% at once)
- Preferred scaling method: Horizontal duplication (new ad set with same creative + audience) > vertical budget increase
- Vertical scale: budget doubling resets learning phase on that ad set
- Duplicate winning ad set: new ad set ID = fresh learning, same audiences — allows scale without disruption

---

## 6. Pixel & CAPI Setup Checklist

### Pixel Setup (mandatory)
- [ ] Meta Pixel installed on ALL pages (including confirmation page)
- [ ] Standard events firing: PageView, ViewContent, AddToCart, InitiateCheckout, Purchase
- [ ] Purchase event includes: value, currency, content_id
- [ ] Conversion test: verify via Events Manager → Test Events tab
- [ ] Deduplication: set event_id on both browser pixel and CAPI to prevent double-counting

### Conversions API (CAPI) — Required Post-iOS 14.5
- CAPI sends server-side conversion data directly to Meta, bypassing browser-level tracking loss
- Match rate target: >70% (events matched to Meta users)
- Required parameters for high match rate: email (hashed), phone (hashed), fbc (click ID), fbp (browser ID), client_user_agent, client_ip_address
- Event deduplication: include event_id on both browser and server events; Meta deduplicates by event_id
- Implementation options: Meta's native CAPI, partner integration (Shopify, WooCommerce), Gateway (hosted solution)

### UTM Parameters (mandatory for attribution)
```
utm_source=facebook
utm_medium=paid
utm_campaign={{campaign.name}}
utm_content={{adset.name}}
utm_term={{ad.name}}
```

---

## 7. iOS 14.5 / SKAdNetwork Implications

### What Changed (April 2021, still relevant 2026)
- Users must opt-in to tracking (ATT prompt). Typical opt-in rate: 20-40%.
- Meta lost visibility into ~60-70% of iOS conversions.
- Reporting delay: up to 3-day reporting window for iOS.
- Attribution window reduced: default changed from 28-day click to 7-day click + 1-day view.

### Mitigation
1. **CAPI is non-negotiable.** Server-side events recover 40-60% of lost signal.
2. **Aggregated Event Measurement (AEM):** Verify your domain in Meta Business Manager. Configure up to 8 conversion events in priority order.
3. **Attribution window:** Use 7-day click, 1-day view for accurate comparison. 28-day window shows legacy data only.
4. **Over-reporting on Android, under-reporting on iOS:** True blended ROAS is usually higher than Meta reports.
5. **Model-based conversions:** Meta uses statistical modeling to fill gaps. Results = real + modeled; accept the uncertainty.

---

## 8. Meta Policy Traps — Most Common Rejection Reasons

### Ad Disapproval Triggers
1. **Before-and-after claims** in images: explicit before/after showing body transformation = policy violation
2. **Personal attributes targeting implication:** Copy that implies targeting by health condition ("If you have diabetes..."), financial status ("Are you struggling with debt?"), or political views
3. **Shocking or sensational imagery:** Excessive violence, strong negative emotions in hero image
4. **Misleading claims:** Guaranteed results without qualification ("Guaranteed to make €10K in 30 days")
5. **Prohibited industries:** Payday loans, multi-level marketing (without explicit approval), tobacco, weapons

### Special Ad Categories (must declare, limits targeting)
- Housing, employment, credit, social issues/elections/politics
- When declared: cannot use age, gender, ZIP code targeting — only location, broad interest
- Financial products: MAY require special ad category if offering credit/insurance

### The "20% Text Rule" — DEPRECATED
Meta removed the 20% text rule for images in 2021. Images with heavy text are still allowed but may receive lower delivery. Best practice: keep text overlay under 30% of image area for optimal delivery.

### Account Health
- Two ad disapprovals = "Ad Limit" on account
- 5+ disapprovals = account review, potential restriction
- Always appeal rejections with specific reasoning; generic appeals fail
- Appeal via the Ad Account Quality page, not Business Support

---

## 9. Optimization Flowchart

**ROAS too low → Diagnose in order:**
1. Is conversion tracking firing correctly? (Check Events Manager, verify Purchase event)
2. Is the landing page load time <3 seconds? (High bounce kills ROAS regardless of ad quality)
3. Is the audience warm enough for the offer presented? (Cold traffic → cold offer; warm traffic → hot offer)
4. Is the hook driving 50%+ 3-second views? (If not, the audience never sees the offer)
5. Is the CTA aligned with the next logical step? (Don't ask for purchase from unaware audience)

**CTR low → Creative resonance problem:**
- Hook failing → test 4 new hooks on same concept (keep body identical)
- Audience mismatch → check audience insights for age/gender skew vs. ICP
- Ad fatigue → check frequency; if >4x cold, kill and refresh

**CPM rising → Supply or relevance issue:**
- Audience too narrow → expand targeting or use Advantage+
- Seasonal competition → expect +20-40% CPM during Q4, holidays
- Low relevance → improve creative match to audience; Meta rewards relevance with lower CPMs

---

## 10. Bidding Phase Progression (Adam — paid-ads)

Sequential phases tied to conversion volume — never skip phases:

| Phase | Trigger | Bid Strategy | Purpose |
|-------|---------|-------------|---------|
| Phase 1 — Initial | Account launch | Manual CPC or cost caps | Gather baseline data; no algorithmic signal yet |
| Phase 2 — Accumulation | 0–50 conversions | Stay manual; optimize creatives + audiences | Build statistical base; premature automation kills accounts |
| Phase 3 — Automation | 50+ conversions/month | Switch to automated (Advantage+ or target CPA/ROAS) | Algorithm has enough signal; anchored to historical performance |
| Phase 4 — Refinement | Post-automation | Monitor, adjust targets incrementally (±10–15%) | Fine-tune; stay within ±20–30% budget changes to avoid learning reset |

**Never switch bid strategies during peak-traffic windows** (Q4, holidays) — learning phase reset during peak = wasted budget.

## 11. Ad Creative Hook Angles — 8 Core Patterns (Adam — ad-creative)

| Angle | Template | Example |
|-------|----------|---------|
| **Pain Point** | "Stop [pain]" or "[Action] without [friction]" | "Stop wasting time on manual reports" |
| **Outcome** | "Achieve [result] in [timeframe]" | "Ship code 3× faster in 14 days" |
| **Social Proof** | "Join [number]+ [audience] who..." | "Join 10,000+ teams using..." |
| **Curiosity** | "The [descriptor] secret [audience] use" | "The one Meta setting top brands never share" |
| **Comparison** | "Unlike [competitor], we [benefit]" | "We offer what agencies don't" |
| **Urgency** | "Limited: get [offer] [constraint]" | "First 500 signups get free access" |
| **Identity** | "Built for [specific role/segment]" | "Made for growth marketers only" |
| **Contrarian** | "Why [common practice] doesn't work" | "Manual creative testing costs more than it earns" |

Generation workflow: define 3–5 distinct angles → generate variations per angle (word choice, tone, structure) → validate against character limits → analyze top performers → extend winners + test 1–2 unexplored angles.

## 12. Ad Fatigue Thresholds & Frequency Management (Adam — paid-ads)

| Retargeting Stage | Audience Window | Frequency Cap | Action at Breach |
|-------------------|-----------------|---------------|-----------------|
| Hot retargeting | 1–7 days | 4–7× daily acceptable | Test new creative angle; do not kill — high-value audience |
| Warm retargeting | 7–30 days | 3–5× per week | Rotate creative; refresh hook |
| Cold retargeting | 30–90 days | 1–2× per week | Kill and rebuild if CTR falling |
| Cold prospecting | N/A | Optimal 2–4× total | Kill or refresh at 5×+ cold |

**Fatigue diagnostic:** frequency 3.5×+ on cold audiences → CPM rises, CTR falls (diminishing returns begin). At 5×+ cold: kill or refresh creative immediately.

**Learning phase discipline:** Never make structural changes (budget >20%, audience, creative, bid) during learning phase. Each change resets the 50-conversion clock.

## 13. Czech-Specific Considerations

- Financial ads: ČNB compliance mandatory; risk disclaimer required for investment products
- Consumer protection: ZoOR §2 — no misleading claims, no fake urgency
- Language: Vykání in all ad copy targeting adults unless brand explicitly uses tykání for Gen Z
- Payment methods in ad creative: Czech market responds to local payment method imagery (Česká spořitelna, Komercní banka logos as trust signals)
- Carousel and collection ads: Czech e-commerce responds well to price-point clarity; show CZK price in ad copy
- Peak season: Czech e-commerce peaks Nov-Dec (Christmas), Valentine's Day, summer (June-July for outdoor/lifestyle)

---

## 14. Lookalike Audience Seed Quality (Adam — paid-ads)

Build lookalikes **from best customers by lifetime value, NOT by volume**. Seeding with a large list of low-intent customers dilutes the model — Meta's LAL algorithm mirrors the seed quality directly.

Seed hierarchy (best to worst):
1. Top-LTV customers (purchasers with highest lifetime spend)
2. Repeat purchasers
3. Qualified leads (not all leads)
4. All purchasers
5. All website visitors (weakest — do not use as primary seed)

**Exclusion rules (apply every campaign):**
- Existing customers — exclude unless upsell-focused
- Recent converters — 7–14 day lookback exclusion window
- Bounced visitors — <10 seconds on-site
- Irrelevant page visitors — careers, support, about sections
