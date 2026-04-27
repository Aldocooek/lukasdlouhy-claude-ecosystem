---
name: ig-content-creator
description: "Generate Instagram content (carousels, reels, static posts) aligned with your brand voice and content strategy. Trigger: 'write ig post', 'create carousel', 'reel script', 'ig content', 'instagram post for'."
metadata:
  requires-env:
    - BRAND_CONTEXT_FILE   # Path to local brand voice/guidelines file (e.g. ~/Documents/brand-context.md)
  version: "1.0"
allowed-tools:
  - Read
  - Write
  - Bash
last-updated: 2026-04-27
version: 1.0.0
---
<!-- Adapted from filipdopita-tech/claude-ecosystem-setup, MIT-style cherry-pick -->

# /ig-content-creator — Instagram Content Generator

## When to use
- User writes `/ig-content-creator`
- User asks for an Instagram post, carousel, or reel script
- User says "write ig post about X", "create a carousel for Y", etc.

## Brand Context

**Load first:** Read `$BRAND_CONTEXT_FILE` (or equivalent local brand guidelines) before generating content. If not set, ask the user for key brand parameters: niche, tone, target audience, banned words.

---

## Three Tone Archetypes

Select the archetype that fits the content type. Do not mix archetypes in one piece.

### 1. Patient Observer (150-200 words)
- Calm, observational, storytelling register
- Use for: founder stories, behind-the-scenes, process reveals
- Sentence rhythm: varied, some long + some short
- Avoids: urgency language, superlatives

### 2. Dramatic Prophet (100-150 words)
- Contrarian, provocative, confident
- Use for: bold takes, market contrarianism, uncomfortable truths
- Sentence rhythm: punchy, declarative
- Avoids: hedging, "maybe", "possibly"

### 3. Quiet Devastator (50-100 words)
- Minimal, ironic, deadpan
- Use for: single-insight observations, data drops, pattern interrupts
- Sentence rhythm: extremely short. One idea. One punch.
- Avoids: explanations, overwriting

---

## Content Pillars

Weight output toward these pillars:

| Pillar | Weight | Examples |
|--------|--------|---------|
| [YOUR CORE TOPIC 1] | 30% | Insights, tips, analysis |
| [YOUR CORE TOPIC 2] | 25% | Behind-the-scenes, process |
| [YOUR MARKET/DATA] | 20% | Numbers, local context |
| Personal brand | 15% | Founder story, beliefs |
| Adjacent topic (e.g. AI/tech) | 10% | Crossover relevance |

Replace pillar names with your actual content pillars from `$BRAND_CONTEXT_FILE`.

---

## Process

### Step 1: Load brand context
```bash
cat "$BRAND_CONTEXT_FILE" 2>/dev/null || echo "Brand context file not found — proceeding with user-provided parameters."
```

### Step 2: Identify format
- **Carousel** → 7 slides, max 18 words per sentence, visual flow required
- **Reel script** → 30-90 seconds, direct first-person voice, tight hook
- **Static post** → single caption under 150 words

### Step 3: Select pillar and archetype
Match the topic to a content pillar. Match the energy of the topic to an archetype.

### Step 4: Generate hook using the 15-angle Contrast Formula

Generate 15 hook options across these angles, then score each (1-10) on: engagement potential, surprise factor, brand relevance. Pick the top 2-3 for the user to choose from.

Hook angles:
1. Emotional contrast ("Everyone says X. Nobody talks about Y.")
2. Data + teaser ("93% of [audience] doesn't know this number.")
3. In-medias-res (start in the middle of the story)
4. Pattern interrupt (violates a genre expectation)
5. Provocation ("The [common advice] is wrong.")
6. Confession ("I made a mistake that cost me X.")
7. Counterintuitive result ("Less X → more Y.")
8. Specific micro-story opener (name, date, place)
9. Question that creates urgency
10. Bold prediction
11. Before/after framing
12. "Nobody told me" opener
13. Status inversion ("The experts are doing this backwards.")
14. Timely hook (tied to a recent event)
15. Audience segmentation ("If you do X, read this.")

### Step 5: Structure content per format

#### Carousel structure (7 slides):
```
Slide 1: Hook (chosen from Step 4)
Slide 2: Problem / tension setup
Slide 3: Key insight or data point
Slide 4: Explanation / mechanism
Slide 5: Example or proof
Slide 6: Implication / so what
Slide 7: CTA (one clear action)
```
Max 18 words per sentence on any slide. Each slide = one idea.

#### Reel script structure:
```
[0-3s]   Hook — visual or verbal
[3-15s]  Setup — establish the stakes or tension
[15-50s] Payload — the actual content/insight
[50-70s] Proof or example
[70-90s] CTA — one action
```
Write as first-person direct address. No passive voice.

#### Static post structure:
```
Line 1-2: Hook (chosen from Step 4)
Lines 3-8: Payload — compressed insight
Final line: CTA
```
Under 150 words total. One concrete number mandatory.

### Step 6: Quality audit checklist

Before finalizing, verify:
- [ ] Sentence lengths vary (no 3+ consecutive sentences of similar length)
- [ ] Active verbs only — no "is", "was", "has been" as main verbs where avoidable
- [ ] At least one concrete number in the piece
- [ ] CTA is present and specific (not "engage with this")
- [ ] No banned words: "innovative", "revolutionary", "synergy", "leverage" (as a verb), "ecosystem" (as a buzzword), "game-changer"
- [ ] Hook is in the correct archetype register
- [ ] Word count within format bounds

### Step 7: Track performance (optional)

If the project has a performance tracking database or sheet, log:
- Content ID / date / format / pillar / archetype / hook angle used
- After posting: engagement rate, reach, saves — to identify winning patterns

---

## Output format

Present to user:
```
## Hook options (pick one)
A) [hook option 1]
B) [hook option 2]
C) [hook option 3]

## Draft (using Hook A — swap if you prefer B or C)

[full draft]

## Quality check
- Word count: X / [limit]
- Archetype: [Patient Observer / Dramatic Prophet / Quiet Devastator]
- Pillar: [which pillar]
- Numbers used: [list them]
- CTA: "[exact CTA text]"
```

---

## Common Mistakes

1. **Do not mix archetypes.** Dramatic Prophet opening + Patient Observer body = incoherent.
2. **Do not write uniform sentence lengths.** Monotony kills retention.
3. **Do not use vague CTAs.** "Let me know your thoughts" → "Save this for your next content planning session."
4. **Do not skip the hook competition.** The best hook is rarely the first one.
5. **Do not generate content without loading brand context first.** Off-brand content is wasted effort.
