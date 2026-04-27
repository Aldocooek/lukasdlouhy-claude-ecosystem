---
name: seedance-ecommerce-ad
description: Generate e-commerce product advertisement video prompts and scripts for Seedance 2.0 on Higgsfield. Covers hook frameworks, ad philosophy, and shot structures that convert.
allowed-tools: Read, Write, WebFetch, Bash
last-updated: 2026-04-27
version: 1.0.0
---

# E-Commerce Product Ad Videos — Seedance 2.0

Create high-converting e-commerce product advertisement videos using Seedance 2.0 on Higgsfield.

## Technical Specifications

- Resolution: Up to 1080p
- Duration: 6–60 seconds (15–30s typical for ads)
- Frame rate: 24fps (cinematic) or 30fps (web-optimized)
- Color accuracy: 99% sRGB
- Motion: Smooth camera movements, product rotations, zoom transitions
- Supported formats: 9:16 (vertical/Reels/TikTok), 1:1 (square/feed), 16:9 (horizontal/YouTube)

## The 2-Second Hook Framework

The first 2 seconds determine whether the viewer keeps watching. Use one of these 12 proven patterns:

1. **Product Drop with Dramatic Impact** — Product descends with motion blur and dramatic lighting.
2. **Satisfying Texture ASMR Close-Up** — Macro shot of product texture triggers sensory engagement.
3. **Before/After Transformation** — Split-screen: problem state → solved state.
4. **"Stop Scrolling" Direct Address** — Model looks directly at camera with hand gesture.
5. **Unboxing Reveal** — Hands open premium packaging, product emerges.
6. **Color/Variant Cascade** — Products line up, rotating through variants in 2 seconds.
7. **Ingredient Explosion** — Ingredients splinter outward from product center.
8. **Problem-Solution Snap** — Text "Problem:" → hard cut → "Solution:" with product.
9. **In-Hand Usage Tease** — Hands holding product, demonstrating the key feature.
10. **Lifestyle Aspiration Flash** — Quick cut to aspirational, relatable lifestyle scene.
11. **Scarcity/Urgency Signal** — "Limited Drop" text with product glow effect.
12. **Creator Reaction** — Unboxing with genuine surprised/delighted expression.

## E-Commerce Ad Philosophy

**Hero shots are non-negotiable.** Every ad needs at least one pure, isolated product shot with perfect lighting. This is the visual anchor.

**Multi-angle storytelling.** Rotate through: front, back, side, close detail. Viewers buy what they can inspect.

**In-context usage.** Product in real life beats sterile photography. Show it being used.

**Before/After is psychology gold.** Sequence: problem → moment of realization → product → happy outcome. Follow the emotional arc.

**Quick-cut energy.** 0.5–1 second cuts. Build momentum. Slow = low intent signal for the algorithm.

**Texture and tactile detail.** Close-ups create tactile desire. Fabric, finish, packaging material — shoot it at macro.

**Lifestyle aspiration.** Sell the life the product enables, not the product itself.

**Text overlays that convert.** Layer in: problem identification → key benefit → social proof → pricing/offer → CTA.

## Shot Structure Templates

### 15-Second Product Ad
- 0:00–0:02 — Hook (pick from hook framework above)
- 0:02–0:06 — Hero shot + key feature demonstration
- 0:06–0:10 — In-context lifestyle usage
- 0:10–0:13 — Social proof overlay (rating, testimonial snippet, sales count)
- 0:13–0:15 — CTA + offer (price, discount, urgency)

### 30-Second Product Ad
- 0:00–0:02 — Hook
- 0:02–0:08 — Problem demonstration (relatable pain point)
- 0:08–0:16 — Product solution reveal + multi-angle hero shots
- 0:16–0:22 — In-context lifestyle usage
- 0:22–0:27 — Social proof + testimonial
- 0:27–0:30 — CTA + offer + urgency

## Prompt Engineering for Seedance 2.0

Structure each scene prompt as: `[Camera move] [Subject] [Action] [Setting] [Lighting] [Mood]`

Example:
> Slow push-in on a matte black skincare bottle resting on a marble surface. Morning light streams from the left, casting a soft shadow. Steam rises gently in the background. Premium, minimalist, aspirational.

Keep prompts under 100 words per scene. Be specific about lighting — it is the biggest quality lever in Seedance output.
