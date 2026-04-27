<!-- Adapted from adamkropacek/claude-ecosystem-adam -->

# Research via NotebookLM — Token-First SOP

Use NotebookLM to pre-digest sources before spending Claude tokens. This 5-step SOP keeps expensive context clean.

## Why NotebookLM First

NotebookLM indexes PDFs, URLs, YouTube transcripts, and Google Docs for free. Running a multi-source literature review directly in Claude can cost 20–50k tokens per session. NotebookLM collapses that to a single distilled brief you paste into Claude once.

## 5-Step SOP

### Step 1: Gather sources (outside Claude)

Before opening a Claude session, collect your sources:
- PDFs → upload directly to NotebookLM notebook
- URLs → paste as website sources (NotebookLM fetches and indexes)
- YouTube → paste video URL (NotebookLM uses the transcript)
- Google Docs → connect via Drive

Cap at **15 sources per notebook**. More than that degrades answer quality.

### Step 2: Generate a distilled brief (NotebookLM)

In NotebookLM, ask:

> "Summarize the key findings, patterns, and contradictions across all sources. Output: 5 bullet points of consensus, 3 open questions the sources disagree on, and the single most actionable insight. Under 400 words."

Save the output as a text file or copy it.

### Step 3: Validate coverage gaps

Still in NotebookLM, ask:

> "What important angle on [topic] is missing from these sources? Name 1–2 specific gaps."

Add this gap list to your brief.

### Step 4: Open Claude with the brief only

Paste the distilled brief (Steps 2–3 output) into Claude. Do NOT paste raw source text. The brief is the only input Claude needs.

Example prompt structure:
```
Here is a pre-digested research brief on [topic]:

[paste NotebookLM output]

Given this brief, [your actual question for Claude].
```

### Step 5: Claude synthesizes and acts

Claude answers using the brief. If it needs a specific quote or deeper dive on one source, pull that single excerpt from NotebookLM and paste it — not the whole document.

## Cost Comparison

| Approach | Typical tokens | Approx. Sonnet cost |
|---|---|---|
| Paste 5 PDFs directly into Claude | ~80 000 | ~$0.24 |
| NotebookLM brief → Claude | ~2 000 | ~$0.006 |
| Savings | ~97% | ~40× cheaper |

## When to Skip NotebookLM

- Single short source (< 2 pages) — paste directly.
- Source is already structured data (JSON, CSV) — feed to Claude directly.
- Task is implementation, not research — NotebookLM adds no value.

## NotebookLM Limits (as of 2026)

- 50 sources per notebook max
- URLs must be publicly accessible
- YouTube videos must have auto-captions enabled
- No API — manual only (open in browser)
