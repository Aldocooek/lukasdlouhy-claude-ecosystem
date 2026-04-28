---
name: ads-google
description: Google Ads strategy and execution — Search, Display, YouTube, Performance Max, and Demand Gen. Covers campaign type selection, Quality Score, bidding strategies, negative keyword hygiene, RSA structure, and conversion tracking.
allowed-tools: Read, Write, WebFetch, WebSearch, Bash
last-updated: 2026-04-27
version: 1.0.0
---

# Google Ads Agent

Expert-level Google Ads strategy across all campaign types.

## Triggers
"Google Ads", "Google ads", "Search ads", "PMax", "Performance Max", "YouTube ads", "Display campaign", "Google campaign", "RSA", "Smart Shopping", "Demand Gen", "Discovery ads"

---

## 1. Campaign Types — Decision Tree

### Which Campaign Type to Use

```
Is the audience actively searching for your product/service?
├─ YES → Search campaign (highest intent, lowest funnel)
│
Is it visual / e-commerce product catalog?
├─ YES → Performance Max (Shopping feed + all placements)
│         → or Standard Shopping (more control)
│
Is the goal brand awareness / reaching new audiences visually?
├─ YES → Demand Gen (YouTube, Discover, Gmail, Maps)
│         → was "Discovery" campaign, rebranded 2023
│
Is it a YouTube video ad specifically?
├─ YES → Video campaign (in-stream, in-feed, bumper)
│
Remarketing / staying top-of-mind for warm audiences?
└─ YES → Display campaign (GDN) with audience lists
```

### Campaign Type Strengths
| Type | Best for | Avoid for |
|------|---------|-----------|
| Search | Bottom-funnel; purchase intent keywords | Awareness; broad brand discovery |
| Performance Max | E-commerce with product feed; max reach | Products without clear Google Shopping feed |
| Video / YouTube | Brand building; demonstration products | Direct response on small budgets |
| Demand Gen | Social-native audiences; visual products | Performance marketing without creative |
| Display | Retargeting; awareness sequencing | Cold traffic without audience signals |
| Standard Shopping | E-com brands needing bid control per product | Brands without product feed optimization |

---

## 2. Search Campaigns — Core Mechanics

### Keyword Match Types (2026 behavior)
Match type hierarchy (precision to volume):
1. **Exact [keyword]:** Only triggers for that query (and very close variants). Lowest volume, highest intent.
2. **Phrase "keyword":** Triggers for queries containing the phrase in order. Medium precision.
3. **Broad +audience:** Triggers for related queries; Google uses audience signals and landing page context to decide relevance.

**2026 reality:** Broad match + Smart Bidding + strong audience signals often outperforms exact match stacking for established accounts. For new accounts: start exact/phrase to control spend; graduate to broad with tCPA once 50+ conversions/month.

**Funnel: Exact for proven high-performers → Phrase for expansion → Broad with tCPA/tROAS for discovery.**

### Quality Score (QS) — 1-10 Score
Three factors (Google's transparency):
1. **Expected CTR** (based on historical CTR for your keyword + match type)
2. **Ad Relevance** (how closely the ad matches the query intent)
3. **Landing Page Experience** (load time, mobile-friendliness, content relevance, low bounce)

**QS effect on CPC:**
- QS 10: CPC reduction up to 50%
- QS 7-9: Below average CPC
- QS 5-6: Average
- QS 4 and below: Above average CPC; ad shows less frequently
- Target: QS ≥7 on core keywords; ≥8 on brand terms

**Improving QS:**
- CTR: Tighter ad groups (1-3 closely related keywords per ad group — SKAG or close SKAG)
- Ad relevance: Include keyword in headline 1 and description
- Landing page: Match search query intent to page content. Slow page (>3s) = "Poor" landing page experience automatically

### Bidding Strategy Progression (Adam Kropáček framework)
```
Stage 1 (0-30 conversions/month): Manual CPC or Maximize Clicks
   → Purpose: data collection, avoid burning budget on smart bidding with no signal

Stage 2 (30-50 conversions/month): Target CPA or Maximize Conversions
   → Algorithm has enough signal; automated bidding starts outperforming manual

Stage 3 (50+ conversions/month): Target ROAS or Maximize Conversion Value
   → Full automation with value-based optimization; best for e-commerce

Brand campaigns: Target Impression Share (90%+ IS target) or Max Clicks with bid cap
```

**Never switch bid strategies during high-traffic periods (holidays, peak season).** Learning phase reset during peak = wasted budget.

### RSA (Responsive Search Ad) Structure
- 15 headlines (30 characters each) — Google tests combinations
- 4 descriptions (90 characters each)
- Asset performance grades: Best → Good → Low → Learning
- Rules:
  1. Every headline must stand alone AND in combination with any 2 other headlines
  2. Include primary keyword in at least 2 headlines
  3. Include CTA in at least 1 headline
  4. Include key benefit/differentiator in descriptions
  5. Do NOT pin headlines unless brand/legal requirement — pinning kills machine learning
  6. Include at least 3 "Best" or "Good" rated assets before scaling; low-performing assets pulled automatically but still hurt

**RSA Example (SaaS — lead gen):**
```
Headlines:
1. Save 4 Hours/Week on Reporting
2. [Keyword Insertion: {KeyWord: Marketing Analytics}]
3. Try Free for 14 Days — No Card
4. Trusted by 12,400+ Marketing Teams
5. Real-Time Dashboard in 2 Minutes
6. Cut Reporting Time by 75%
7. See Why Teams Switch to Us
8. Connect All Your Ad Accounts

Descriptions:
1. Stop exporting spreadsheets. Connect your ad accounts, CRM, and
   analytics in one live dashboard. Setup takes under 5 minutes.
2. 4.8/5 from 1,200 reviews. Join teams saving 4+ hours weekly on
   performance reporting. Free trial, no credit card.
```

### Negative Keyword Hygiene
- Must-have negative lists (apply at account level):
  - Brand competitor names (unless running competitor campaigns)
  - "Free," "jobs," "careers," "salary," "Wikipedia," "Reddit"
  - Irrelevant geographies
  - Irrelevant product categories

- Campaign-level negatives:
  - Add after reviewing Search Terms report weekly
  - Any query converting zero after 2x target CPA spend → add as negative
  - Cross-campaign negatives: exclude brand terms from non-brand campaigns; exclude non-brand from brand campaigns

- Negative keyword types: use exact negatives sparingly; phrase negatives cover more ground

### CTR Benchmarks (Search)
| Campaign type | Good CTR | Acceptable | Kill signal |
|---------------|----------|------------|-------------|
| Brand | >8% | 5-8% | <3% |
| Non-brand, high intent | >3% | 2-3% | <1% |
| Non-brand, informational | >2% | 1-2% | <0.5% |

CTR below floor = ad relevance issue OR wrong keyword match type. Check: is the query matching the right intent?

---

## 3. Performance Max

### What PMax Does
Runs across all Google inventory simultaneously: Search, Shopping, Display, YouTube, Discover, Gmail, Maps.
Uses Google's ML to find conversion opportunities across all placements with one campaign.

### Asset Groups — Structure for Success
- Each asset group = one product category or audience theme. Do NOT blend brand + generic terms.
- Separate asset groups for: brand-related, non-brand top products, non-brand categories
- Brand vs. non-brand blending: PMax cannibalizes brand traffic (cheap) and inflates reported ROAS without earning non-brand conversions. Separate or exclude brand terms.

**PMax Asset Checklist per group:**
- [ ] 15 images (product, lifestyle, logos)
- [ ] 5 videos (if none supplied, Google auto-generates — quality is poor; always supply)
- [ ] 5 headlines (30 char)
- [ ] 5 long headlines (90 char)
- [ ] 4 descriptions (60-90 char)
- [ ] Business name, logo, URL

### Audience Signals (feed to PMax)
Audience signals are starting hints, not targeting locks. PMax uses them to seed learning, then expands.
Priority signals to add:
1. Customer match list (existing customers/emails)
2. Website visitors (remarketing tags)
3. In-market audiences most relevant to product category
4. Custom audiences based on search terms or URLs

### Product Feed Quality (Shopping component)
- Title: [Brand] + [Product type] + [Key attribute] + [Size/Color/Model]
  Example: "Nike Air Max 2026 Running Shoes — Men's Size 42 — White/Black"
- Description: Top 150 characters = most important (truncated below)
- GTIN / MPN: Required for all products with one; better match rate, lower CPC
- Images: White background for apparel, lifestyle for home goods
- Price: Must match landing page exactly; mismatch = disapproval

### PMax Kill / Optimization Signals
- Low performance for 2+ weeks after 50+ conversions: check asset group structure; likely blending conflicting themes
- "Search themes" (2024 feature): add keyword themes to guide intent; use for niche products Google doesn't understand
- Placement exclusions: apply brand safety exclusions (parked domains, gambling, sensitive content) at account level

---

## 4. YouTube Ads

### Format Decision
| Format | Skip? | Length | Best for |
|--------|-------|--------|---------|
| In-stream skippable | Yes (5s) | 15s-3min | Brand awareness, direct response |
| In-stream non-skippable | No | 15-20s | Guaranteed message delivery |
| Bumper | No | 6s | Frequency / reminder |
| In-feed (discovery) | N/A | Any | Organic-style discovery |
| Outstream | Yes (immediate) | — | Mobile web reach |

### Hook — 5 Seconds Before Skip
The entire game for in-stream skippable is the first 5 seconds.
- Must create a reason not to skip: unresolved question, surprising visual, promise of specific value
- Viewer decision: Is this worth 15-120 more seconds of my time?
- Use the curiosity-gap or transformation hook patterns
- Do not front-load branding in seconds 1-5: show it after second 5 (brand recognition happens; skips happen if brand-first)

### YouTube Hook Examples
- "I'm going to show you a €0 to €45K/month Meta strategy in the next 90 seconds. Stay with me."
- "Most people running Google ads are wasting 40% of their budget on this one thing. Let me show you."
- "Before you skip this: you're losing money every day you run search ads without this one setting."

### Retention Curves
- For skippable in-stream: 30% retention at the 30-second mark = strong
- If <15% retention at 30s = hook isn't holding; rebuild first 10 seconds
- Watch time is the primary YouTube algorithm signal; longer-watch ads get cheaper CPVs

### Bidding for YouTube
- Awareness: CPM bidding (maximize reach per €)
- Consideration: CPV (cost per view — maximize 30s views)
- Direct response: Target CPA (requires 50+ conversions/week on YouTube specifically)

---

## 5. Display Campaigns

### Smart Display vs Standard
- **Smart Display:** Google manages targeting + creative assembly. Requires images + logos + headlines; Google tests combinations.
  - Use: established accounts, retargeting scale, when you don't want to manage placements
- **Standard Display:** Manual audience + placement control.
  - Use: specific audience lists, brand-safe placement targeting, competitive exclusions

### Must-Have Placement Exclusions (apply at account level)
- Parked domains
- Error pages
- App categories: casual games, children's apps (low intent)
- Mobile app (ALL) exclusion for B2B — in-app display traffic = accidental clicks, not conversions
- Check Placement Report monthly and manually exclude bottom-quartile sites

### Audience Strategy for Display
Priority audiences:
1. Customer match (highest value)
2. Website retargeting (14-day, 30-day, 90-day segments)
3. Similar audiences to converters
4. In-market audiences (Google's intent signals)
5. Custom intent (users who searched specific keywords)

Do NOT run display to "all adults 18-65" cold — CTR <0.1%, CPMs wasted. Always use audience + demographic layering.

---

## 6. Conversion Tracking

### GA4 + Google Ads Integration (mandatory)
- [ ] GA4 linked to Google Ads account
- [ ] Primary conversion: Purchase / Lead (from GA4 goal import OR native Google Ads tag)
- [ ] Secondary conversions: Add to cart, Begin checkout, Phone call (for optimization insight, not bidding)
- [ ] Verify: every conversion event firing once per actual conversion (no double-counting from page refresh)

### Enhanced Conversions
Sends hashed customer data (email, phone, name, address) alongside conversion events to improve match rates.
- Required for accurate measurement post-iOS 14+ / cookie deprecation
- Implementation: tag-based (Google Tag Manager) or API-based
- Improves attribution by matching offline signals to Google profiles

### Offline Conversion Import
For B2B with long sales cycles: import CRM deal stages as offline conversions.
- Mark a qualified lead at €100 value; closed deal at €5,000 value
- Google optimizes toward the signals that predict downstream revenue, not just form fills
- Use Google Ads Conversion Import API or Zapier/CRM connector

### Attribution Models (2026 Google position)
- Data-driven attribution (DDA): default and recommended — uses ML across all touchpoints
- Last-click: only for very simple single-step funnels; penalizes upper-funnel
- Linear, time-decay: legacy; generally inferior to DDA
- DDA requires 300+ conversions in 30 days; otherwise defaults to last-click

---

## 7. Kill Rules by Campaign Type

### Search
- Ad group: <0.5% CTR after 500 impressions AND 2x target CPA spend without conversion → pause
- Keyword: >2x target CPA with 0 conversions → add as negative or pause
- Campaign: 14 days, tCPA >150% of target → audit audience, match types, landing page

### Performance Max
- Week 1-2: Do not make structural changes (learning phase)
- Week 3+: No improvement and spend exceeding target CPA by >50% → restructure asset groups or split campaign
- Check Search Terms report (partial visibility) for irrelevant traffic → add negatives

### YouTube
- CPV >€0.15 (in-stream) with no view-through conversions → hook failure; rebuild first 5s
- Campaign: 30 days, no conversions, budget >€500 → video is not converting; test new angle

### Display
- Placement: >100 clicks, zero conversions → add to placement exclusion list
- Creative: >10K impressions, CTR <0.05% → replace creative
- Audience: 30 days, >2x target CPA → restrict or remove audience

---

## 8. Smart Bidding Learning Phase — 50-Conversion Rule (Adam — paid-ads)

The 50-conversion threshold is the hard prerequisite for reliable automated bidding — applies to both tCPA and tROAS:

- **Below 50 conv/month:** Smart Bidding has insufficient signal. tCPA targets will oscillate; algorithm makes random-walk decisions. Stay on Manual CPC or Maximize Clicks.
- **At 50 conv/month:** Switch to Target CPA or Maximize Conversions. Anchor initial tCPA target at 10–20% above historical actual CPA (give the algorithm room).
- **At 100+ conv/month:** Graduate to Target ROAS or Maximize Conversion Value for value-based optimization.
- **Per campaign, not account:** A campaign needs its own 50 conversions — account-level volume doesn't substitute.

**Learning phase protection:** After switching bid strategy, the algorithm enters a learning period (typically 7–14 days). Do NOT change bids, budgets (>20%), or audience during this window. Changes reset learning.

**Budget scaling rule (Adam — paid-ads):** Increase budget maximum 20–30% at a time; wait 3–5 days between changes to allow convergence. Never double a budget at once — it resets learning and the algorithm overspends in a volatile window.

## 9. Value-Based Bidding Architecture (Adam — paid-ads)

Use value-based bidding (Maximize Conversion Value / tROAS) when conversions have different revenue values:

**Setup requirements:**
- Conversion actions must pass a `value` parameter (purchase value, lead score, LTV estimate)
- For B2B with long cycles: use proxy values (qualified lead = €100, SQLed lead = €500, closed = €5,000) and import via Offline Conversion Import
- Google optimizes toward the signals that predict downstream revenue, not just form fills

**Customer Match as primary audience signal:**
1. Upload first-party customer list (email hashes) as Customer Match
2. Set bid adjustments or use as Smart Bidding signal
3. For tROAS: Customer Match lists of high-LTV customers steer the algorithm toward similar users

**Value-based signal hierarchy for PMax (priority order):**
1. Customer Match (existing high-LTV buyers)
2. Website converters with value data (remarketing + purchase value)
3. In-market audiences (Google's intent modeling)
4. Custom audiences (keyword or URL based)

## 10. Audience Architecture — Search + PMax (Adam — paid-ads)

### Search Campaigns: Audience Layering (Observation mode first)
- Add all relevant audiences in **Observation** mode first — collects bid modifier data without restricting reach
- After 30+ days: identify which audiences convert at lower CPA → apply positive bid adjustments (10–30%)
- Typical high-value segments: Customer Match, In-market (your category), Remarketing (14-day website visitors)

### PMax: Audience Signals as Seeds, Not Constraints
PMax uses audience signals as starting hints — it expands beyond them. Feed the highest-quality signals:
1. Customer Match list (existing purchasers / emails)
2. Website remarketing tag audiences (all visitors, converters separated)
3. In-market audiences matching your product category
4. Custom intent audiences based on high-converting search terms

**Brand term cannibalization:** PMax will absorb cheap brand traffic and inflate reported ROAS without earning non-brand conversions. Add brand terms as campaign-level negative keywords in PMax, or run a separate brand Search campaign with explicit brand keyword protection.

## 11. Negative Keyword Sculpting — PMax + Search Cross-Campaign (Adam — paid-ads)

### PMax Negative Keywords (limited but critical)
- PMax does not support standard negative keyword lists — use account-level negative keyword lists (Shared Library)
- Apply immediately: competitor brand names (unless running competitor campaigns), irrelevant product categories, job/career terms, "free" + category
- Search Themes (2024 feature): add keyword themes to guide intent for niche products; functions as positive signal, not negatives

### Search Cross-Campaign Sculpting
- **Brand vs Non-Brand isolation:** Brand terms as exact negatives on non-brand campaigns; non-brand as negative phrase on brand campaigns
- **Zero-conversion queries:** Any search term spending 2× target CPA with zero conversions → add as exact negative
- **Cannibalization audit:** Check Search Terms report weekly; queries appearing in both brand and non-brand = add as exact negative on non-brand
- **Match type negative hierarchy:** Phrase negatives cover more surface area than exact negatives — use phrase for category-level exclusions, exact for specific high-value query protection

## 12. Czech / CZ Market Notes (original section 8)

- Google's Czech market coverage: strong for commercial and research queries; less dominant for social-native audiences (Meta wins there)
- Czech language ads: Use Czech diacritics correctly — "nejlepší," "zákazníků." Google Ads spell-check does not catch CZ errors.
- Product feed for Czech market: prices in CZK; use Kč symbol consistently
- VAT note: Google Shopping shows prices as listed; ensure product feed prices include VAT for B2C (standard Czech consumer expectation)
- ČNB regulatory: financial product ads on Google must comply with same rules as Meta — risk warnings, no guaranteed returns
- Czech brand terms: register brand terms as exact keywords immediately; competitor bidding on your brand is common in CZ market
