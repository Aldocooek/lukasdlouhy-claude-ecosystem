---
name: seo-content
description: 2026 SEO content writing for marketing sites — search intent, on-page structure, keyword research, E-E-A-T, internal linking, and AI Overview optimization.
allowed-tools: Read, Write, Edit, WebSearch, WebFetch
last-updated: 2026-04-27
version: 1.0.0
triggers:
  - SEO
  - blog post
  - search intent
  - AI Overview
  - ranking
---

# SEO Content — 2026 Marketing Site Writing

## Search Intent Classification — Do This First

Before writing a single word, classify the intent of the target query. Getting this wrong means the page will not rank regardless of quality.

| Intent | What the user wants | Content format |
|--------|--------------------|--------------  |
| Informational | Learn something | Long-form guide, tutorial, comparison |
| Navigational | Find a specific site/page | Not a content play — fix your brand SERP |
| Commercial investigation | Evaluate options before buying | Comparison, listicle, review |
| Transactional | Buy or sign up now | Landing page, product page |

To verify intent: Google the keyword. Look at the top 5 results. Match their format and depth. If the SERP is all listicles, write a listicle. If it is all tutorials, write a tutorial.

## Title, H1, and Meta Description

**Title tag:**
- 50–60 characters max (Google truncates at ~580px).
- Primary keyword near the front.
- Differentiation signal: year, number, modifier ("Best", "Complete Guide", "For [ICP]").
- Example: `B2B Cold Email Templates That Actually Book Meetings (2026)`

**H1:**
- Can differ from the title tag — use the keyword naturally, not stuffed.
- One H1 per page only.

**Meta description:**
- 120–158 characters.
- Not a ranking factor but directly affects CTR.
- Include primary keyword, a benefit, and an implicit CTA.
- Example: `Skip the generic templates. These cold email frameworks generated 3,000+ replies for SaaS teams in 2025. Copy and adapt.`

## Keyword Research Workflow

Paid tools: Ahrefs Keywords Explorer, Semrush Keyword Magic.

Free stack (in order):
1. **Google Search Console** — find queries where you rank 8–20 and optimize for them (fastest wins).
2. **Bing Keyword Research Tool** — free, underused, shows volume and CPC.
3. **AlsoAsked.com** — maps the "People Also Ask" tree; reveals the sub-questions to answer in the article.
4. **Google autocomplete + related searches** — primary keyword in the search bar, scrape suggestions.

Targeting signal: primary keyword + 3–5 secondary/LSI keywords woven naturally into H2s and body copy. Do not stuff. Google detects unnatural density.

Difficulty vs. opportunity heuristic: target keywords with KD < 30 for new sites, KD 30–60 for established domains. Above 60 requires serious authority and backlinks — a content play alone will not rank.

## E-E-A-T Signals (Experience, Expertise, Authoritativeness, Trustworthiness)

Google's quality rater guidelines penalize thin, anonymous, unverifiable content. Countermeasures:

- **Author byline** with real name, photo, credentials, and LinkedIn link.
- **First-person experience.** "I tested X" or "Our team ran Y" signals real experience.
- **Citations and sources.** Link to primary research, studies, and authoritative domains.
- **Publication date + last-updated date.** Keep evergreen content updated annually at minimum.
- **About page and author bio pages.** Must exist and be detailed.
- **Expert quotes.** Pull quotes from named practitioners (with permission).

For YMYL (Your Money or Your Life) topics — finance, health, legal — E-E-A-T requirements are significantly stricter. Anonymous content will not rank.

## Internal Linking

Internal links distribute PageRank and signal topical authority. Do both:

- **Hub-and-spoke.** Create a pillar page for a broad topic; link to it from all related cluster posts. Pillar links back to clusters.
- **Contextual links.** Link from body copy using descriptive anchor text (not "click here"). Anchor text should describe the destination page's topic.
- Rule of thumb: 3–5 internal links per 1,000 words.
- Audit broken internal links quarterly.

## AI Overview / SGE Optimization

Google's AI Overviews (formerly SGE) cite specific sources. To be citation-worthy:

- **Answer the question in the first 100 words.** The model favors content that answers directly before elaborating.
- **Use structured formats.** Numbered steps, definition-first paragraphs, comparison tables — all easier for LLMs to parse and cite.
- **Claim specificity.** "Reduces churn by 18%" is citable. "Reduces churn significantly" is not.
- **FAQ schema.** Marks up questions and answers explicitly for AI parsing (see snippet below).
- **Structured data.** Article, BreadcrumbList, and FAQPage schemas increase the signal-to-noise ratio for crawlers.

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is a good cold email open rate?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A good cold email open rate for B2B outreach is 40–60%. Below 30% usually signals deliverability problems or weak subject lines."
      }
    }
  ]
}
```

Add this in a `<script type="application/ld+json">` block in the page `<head>`.

## On-Page Checklist Before Publishing

- [ ] Keyword in title, H1, first 100 words, at least one H2.
- [ ] Meta description written, under 158 characters.
- [ ] Images have descriptive alt text including keyword where natural.
- [ ] Internal links to 3+ relevant pages.
- [ ] External links to at least 2 authoritative sources (opens in new tab).
- [ ] Author byline with credentials.
- [ ] FAQ schema added if the post answers specific questions.
- [ ] Core Web Vitals pass (LCP < 2.5s, CLS < 0.1, INP < 200ms) — check via PageSpeed Insights.
- [ ] Mobile rendering verified.

## What Not to Do

- Do not keyword-stuff. "Best CRM software best CRM best software for CRM" will trigger a manual or algorithmic penalty.
- Do not write for bots. Write for the user who typed that query — what do they need to know?
- Do not publish thin content (< 600 words) unless the intent is genuinely a short answer.
- Do not ignore cannibalization. Two pages targeting the same keyword split authority. Merge or redirect one.
- Do not chase volume alone. A keyword with 200 monthly searches and clear transactional intent often converts better than a 10,000-search informational keyword.
