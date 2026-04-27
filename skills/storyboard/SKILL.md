---
name: storyboard
description: Produce a 6-scene storyboard from a topic or script. Output to stdout as markdown.
allowed-tools: []
last-updated: 2026-04-27
version: 1.1.0
---

# Storyboard Skill

Produce a 6-scene video storyboard from a topic, script, or brief.

**Output: stdout as markdown. No file writes. No preamble before the table.**

---

## Input parsing

Extract from the user's input:

- **Product / service** and core value proposition
- **Target audience** and their pain
- **Platform** — determines aspect ratio, duration cap, caption requirement
  - TikTok / Reels / Shorts: 9:16, ≤60s, captions required
  - LinkedIn in-feed: 16:9, ≤3min, sound-off safe (captions required)
  - YouTube: 16:9, ≤3min, captions optional
  - App Store preview / website autoplay: 16:9, ≤60s, muted default (captions required)
  - Default if unspecified: 16:9, 90s total
- **Total duration** — stated in input (e.g. "60-second", "90-second"); use that number exactly
- **CTA goal** — click / book / sign up / buy / follow
- **Special constraints** — no voiceover, captions only, no specific UI elements shown, etc.

---

## Fixed scene structure

Use exactly this 6-scene arc. Scale each duration proportionally to hit the total.

| # | Scene | Role | Default share |
|---|-------|------|---------------|
| 1 | Hook | Pattern interrupt or specific outcome stated | ~8% |
| 2 | Problem | Name one specific pain — not a category | ~18% |
| 3 | Solution intro | Name the product and primary mechanism | ~18% |
| 4 | Demo / proof | Show the product doing something; use concrete steps or stat | ~28% |
| 5 | Social proof | Specific result: number, name, or measurable outcome | ~15% |
| 6 | CTA | Single action only — no two options | ~13% |

Duration rule: durations must sum exactly to the stated total. If the input says "60-second", all 6 Duration values must add to 60.

Hook rule: Scene 1 must not open with a brand name or logo. It must create a pattern interrupt or state a specific measurable outcome in the first 3 seconds.

---

## Output format

Output to stdout as markdown. Begin with a one-line metadata header, then the table.

```
**[Product] | [Platform] | [Total duration]s | [CTA goal]**
```

Then the storyboard table:

```markdown
| # | Scene | Duration (s) | Visual | Voiceover / Dialogue | Caption | Notes |
|---|-------|-------------|--------|----------------------|---------|-------|
| 1 | Hook | N | ... | ... | ... | ... |
| 2 | Problem | N | ... | ... | ... | ... |
| 3 | Solution | N | ... | ... | ... | ... |
| 4 | Demo | N | ... | ... | ... | ... |
| 5 | Social proof | N | ... | ... | ... | ... |
| 6 | CTA | N | ... | ... | ... | ... |
```

Column definitions:
- **Visual**: camera direction, subject, motion, text overlays. One sentence, no adjective padding.
- **Voiceover / Dialogue**: exact script copy, or `[silence]` if no narration.
- **Caption**: on-screen text for sound-off viewers. ≤8 words. Must be present for every scene — use `[none]` only if input explicitly prohibits captions AND the platform does not require them.
- **Notes**: transition type, music cue, SFX, asset requirement, or `—`.

After the table, add a duration check line:

```
**Duration check:** N + N + N + N + N + N = [total]s ✓
```

---

## Worked examples

### Example A — 60s LinkedIn SaaS ad, captions only, no voiceover

Input: "60-second product explainer for Glint (auto-generates engineering status reports). Target: engineering managers. LinkedIn. Goal: book a demo. No narration — captions only. Hook must establish pain in first 5 seconds."

**Glint | LinkedIn | 60s | Book a demo**

| # | Scene | Duration (s) | Visual | Voiceover / Dialogue | Caption | Notes |
|---|-------|-------------|--------|----------------------|---------|-------|
| 1 | Hook | 5 | ECU: Slack message thread — "Where's the status update?" scrolling fast | [silence] | Your team is shipping. Slack doesn't show it. | Cut on beat; tense background drone |
| 2 | Problem | 10 | Screen recording: EM copy-pasting Jira tickets into a doc at 11 PM | [silence] | Every Friday. 2 hours. Just to write what already happened. | Slow zoom in on tired cursor |
| 3 | Solution | 10 | Glint logo appears; split-screen: Jira + Slack → auto-generated report | [silence] | Glint reads Jira and Slack. Writes the report for you. | Smooth wipe transition |
| 4 | Demo | 20 | Screen recording: Glint dashboard — one click → report preview → send | [silence] | Connect in 2 minutes. Report ready in 30 seconds. | Show real UI; cursor movement visible |
| 5 | Social proof | 8 | Quote card: "Saved our team 3 hours every week." — Dan R., VP Eng @ Fora | [silence] | 3 hours saved. Every week. | Fade in on white background |
| 6 | CTA | 7 | Product UI fades to brand color; URL centered: glint.so/demo | [silence] | Book a 15-min demo → glint.so/demo | Pulse animation on URL |

**Duration check:** 5 + 10 + 10 + 20 + 8 + 7 = 60s ✓

---

### Example B — 30s TikTok/Reels e-commerce, ASMR, no voiceover

Input: "30-second TikTok/Reels organic video for a $220 mechanical keyboard. Hook: ASMR typing sounds first 2 seconds. Multiple angles, one satisfying feature detail shot, one typing test. No voiceover. Text overlays only."

**Mech Keyboard | TikTok/Reels | 30s | Brand awareness**

| # | Scene | Duration (s) | Visual | Voiceover / Dialogue | Caption | Notes |
|---|-------|-------------|--------|----------------------|---------|-------|
| 1 | Hook | 2 | ECU: fingers hitting keycaps; keys in slow-mo | [silence] | *that* sound. | ASMR mic; no music yet |
| 2 | Problem | 5 | B-roll: person frustrated with mushy membrane keyboard | [silence] | Tired of keys that feel like typing on bread. | Subtle lo-fi beat enters |
| 3 | Solution | 4 | Wide shot: keyboard on clean desk, backlight glow | [silence] | Meet the board that fixes that. | Beat drop |
| 4 | Demo | 12 | Three angles: top, 45°, side; detail shot of switch actuation; typing test on screen | [silence] | Linear switches. 1.8mm actuation. 220g build. | Fast cuts on beat |
| 5 | Social proof | 4 | Text card: "4.9★ from 2,400 reviews" over product shot | [silence] | 2,400 reviewers can't be wrong. | Zoom out |
| 6 | CTA | 3 | Logo + URL: mechanix.co | [silence] | mechanix.co — link in bio | Freeze frame last 0.5s |

**Duration check:** 2 + 5 + 4 + 12 + 4 + 3 = 30s ✓

---

## Validation before outputting

Check internally before writing the table:

- [ ] Exactly 6 rows
- [ ] Scene 1 has no brand name or logo in the first 3 seconds
- [ ] Scene 6 has a single CTA action
- [ ] Duration values sum to the stated total
- [ ] Caption column filled for every scene (not blank)
- [ ] Demo scene shows the product doing something, not just existing
- [ ] Social proof is specific (number, name, result) — not "customers love us"

If the duration sum is off, fix it before outputting. Do not output a table with a wrong total.
