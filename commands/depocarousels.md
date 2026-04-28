---
description: Generate N DEPO Cars & Coffee Instagram carousels (1080×1350px). Pass count as argument. Picks topics, writes copy via Sonnet, picks thematic blueprint PNG, renders via Puppeteer.
---

# /depocarousels

Generate **$ARGUMENTS** DEPO Cars & Coffee Instagram carousels.

## Workflow

Read `~/.claude/skills/depocarousels/SKILL.md` first for full system reference, then execute:

1. **Parse N** from `$ARGUMENTS` (default 1 if missing/non-numeric).
2. **Pick N topics** from `~/.claude/skills/depocarousels/topics_backlog.md` — skip already-shipped (c01–c08) and topics already in `~/Desktop/CLAUDE/depocarousels_out/`.
3. **For each topic, in parallel (up to 4 at a time)**:
   a. Dispatch ONE `general-purpose` agent with `model: "sonnet"` carrying the brief at `~/.claude/skills/depocarousels/prompts/copywriter_brief.md` plus topic ID + hook + key number + slide count. Agent returns ONLY JSON copy. Save to `/tmp/depo_copy_{topic_id}.json`.
   b. Pick blueprint PNG: grep `~/Desktop/CLAUDE/higgsfield_loop/outputs/blueprints_log.jsonl` for the topic's blueprint hint (e.g. "turbocharger"), pick first matching iteration whose PNG exists in `~/Desktop/CLAUDE/higgsfield_loop/outputs/blueprints/`. If no match: skip blueprint.
   c. Build HTML: `python3 ~/.claude/skills/depocarousels/scripts/build_carousel.py --copy /tmp/depo_copy_{topic_id}.json --blueprint {png} --out /tmp/depo_{topic_id}.html`
   d. Render: `node ~/.claude/skills/depocarousels/scripts/render.mjs --html /tmp/depo_{topic_id}.html --out ~/Desktop/CLAUDE/depocarousels_out/c{NN}_{slug}/`
4. **Verify**: `ls ~/Desktop/CLAUDE/depocarousels_out/c{NN}_{slug}/ | wc -l` should equal `total_slides` from the copy JSON. PNG dimensions = 1080×1350 (verify with `sips -g pixelWidth -g pixelHeight` on first slide).
5. **Report** to user: list of generated carousels with topic + slide count + output path.

## Quality gates (before reporting done)

- All N carousels have correct slide count
- First slide of each = hook (master logo bg), last slide = CTA (master logo bg, no separator above text)
- Topics not duplicated within batch or against c01–c08
- If Bahnschrift TTF not found on machine: warn user, fallback to Inter is active

## Cost guardrails

- Copywriter subagents: ALWAYS `model: "sonnet"`, NEVER opus
- Subagent prompts must be self-contained — pass topic context inline
- Cap subagent output at 2000 tokens (JSON copy is small)
