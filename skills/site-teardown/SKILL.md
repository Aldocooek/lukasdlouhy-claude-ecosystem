---
name: site-teardown
description: Reverse-engineer a live URL into tech stack analysis, token budget estimate, animation inventory, and section-by-section rebuild plan
version: 1.0.0
last-updated: 2026-04-27
trigger: /site-teardown <url>
model: sonnet
---
<!-- Adapted from adamkropacek/claude-ecosystem-adam -->

# Skill: site-teardown

## Purpose

Given a URL, produce a structured teardown covering: tech stack detection, token cost estimate for a rebuild, animation/interaction inventory, and a numbered section plan ready for implementation handoff.

## Trigger

```
/site-teardown <url>
```

## Execution Steps

### 1. Fetch and fingerprint

Fetch the URL. Extract:
- Framework signals: meta generators, script src patterns (`_next/`, `__nuxt`, `gatsby`, `remix`, Astro island markers, etc.)
- CSS framework signals: Tailwind class patterns, Bootstrap grid classes, custom property naming conventions
- Animation library signals: GSAP, Framer Motion, Lottie, AOS, ScrollTrigger data attributes
- Hosting signals: response headers (`x-vercel-id`, `cf-ray`, Netlify `x-nf-request-id`, etc.)
- CMS signals: WordPress REST API endpoints, Contentful/Sanity/Prismic SDK patterns in JS bundles
- Analytics tags: GA4, GTM, Plausible, PostHog snippet patterns

Output: **Tech Stack Card** (≤ 15 lines, name + confidence %).

### 2. Token budget estimate

Estimate tokens to rebuild the site from scratch using Claude Code:
- Count visible sections (hero, nav, features, testimonials, CTA, footer, etc.)
- Estimate complexity per section (simple = 800 tokens, medium = 2 000, complex = 5 000)
- Add 20% overhead for iteration
- Output: **Token Budget Table** (section | complexity | est. tokens)
- Add total and note which model tier is appropriate (Haiku / Sonnet / Opus)

### 3. Animation inventory

List every animation and interaction observed:
- Scroll-triggered reveals (fade, slide, parallax)
- Hover states (scale, color, underline, magnetic)
- Page transitions
- Looping background animations (blobs, gradients, particles)
- Micro-interactions (button press, form feedback)

For each: name | trigger | library likely used | reimplementation difficulty (1–5)

### 4. Section plan

Produce a numbered section rebuild plan:
1. Component name
2. Layout description (1 sentence)
3. Key props / data shape
4. Animation notes
5. Suggested implementation order (dependencies first)

### 5. Output format

Return a single markdown document with four H2 sections:
```
## Tech Stack
## Token Budget
## Animation Inventory
## Section Plan
```

Keep total output under 1 200 words. If the URL is behind auth or returns 4xx/5xx, report the error and stop — do not hallucinate content.

## Stop Conditions

- Max 3 fetch attempts per URL.
- If page JS is required to render and the fetched HTML is a skeleton, note "SPA — static fetch incomplete" and proceed with what is visible.
- Never fabricate section content not present in the fetched HTML.
