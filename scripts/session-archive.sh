#!/usr/bin/env bash
# session-archive.sh — Archive a Claude Code session transcript to ~/.claude/sessions-archive/
#
# Usage:
#   session-archive.sh <transcript_path> [tag]
#   session-archive.sh /path/to/transcript.jsonl "my-tag"
#
# The transcript is a JSONL file produced by Claude Code.
# Output: ~/.claude/sessions-archive/YYYY-MM-DD-<slug>.md

set -euo pipefail

TRANSCRIPT="${1:-}"
TAG="${2:-}"

if [[ -z "$TRANSCRIPT" ]]; then
  echo "Error: transcript path required as first argument." >&2
  echo "Usage: session-archive.sh <transcript.jsonl> [tag]" >&2
  exit 1
fi

if [[ ! -f "$TRANSCRIPT" ]]; then
  echo "Error: transcript file not found: $TRANSCRIPT" >&2
  exit 1
fi

# ── Dependency check ─────────────────────────────────────────────────────────
for cmd in jq date; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: required command not found: $cmd" >&2
    exit 1
  fi
done

# ── Output path ───────────────────────────────────────────────────────────────
ARCHIVE_DIR="$HOME/.claude/sessions-archive"
mkdir -p "$ARCHIVE_DIR"

DATE_STR=$(date +%Y-%m-%d)
BASENAME=$(basename "$TRANSCRIPT" .jsonl)

if [[ -n "$TAG" ]]; then
  SLUG="${DATE_STR}-${TAG}-${BASENAME}"
else
  SLUG="${DATE_STR}-${BASENAME}"
fi

# Sanitize slug: lowercase, replace non-alphanum with dash, collapse dashes
SLUG=$(echo "$SLUG" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/-\{2,\}/-/g' | sed 's/^-//;s/-$//')

OUT="$ARCHIVE_DIR/${SLUG}.md"

# ── Parse transcript ──────────────────────────────────────────────────────────
TOTAL_LINES=$(wc -l < "$TRANSCRIPT" | tr -d ' ')

# Determine sample range: first 200 + last 200 turns, flag if truncated
SAMPLE_FLAGGED=""
if [[ "$TOTAL_LINES" -gt 400 ]]; then
  SAMPLE_FLAGGED="NOTE: Transcript has ${TOTAL_LINES} turns; archive is based on first 200 + last 200 turns."
  TURNS_JSON=$(
    { head -n 200 "$TRANSCRIPT"; tail -n 200 "$TRANSCRIPT"; } \
      | jq -sc '.'
  )
else
  TURNS_JSON=$(jq -sc '.' "$TRANSCRIPT")
fi

# Tool usage counts
TOOL_STATS=$(jq -r '
  [ .[] | select(.type == "tool_use") | .name ] | group_by(.) |
  map({ tool: .[0], count: length }) |
  sort_by(-.count) |
  .[] | "  \(.count)x \(.tool)"
' <<< "$TURNS_JSON" 2>/dev/null || echo "  (unable to parse tool usage)")

# Models seen
MODELS=$(jq -r '[.[] | select(.model != null) | .model] | unique | .[]' <<< "$TURNS_JSON" 2>/dev/null | sort -u | paste -sd ', ' - || echo "unknown")

# Rough token/cost estimates (input_tokens + output_tokens from usage fields)
INPUT_TOKENS=$(jq '[.[] | select(.usage.input_tokens != null) | .usage.input_tokens] | add // 0' <<< "$TURNS_JSON" 2>/dev/null || echo 0)
OUTPUT_TOKENS=$(jq '[.[] | select(.usage.output_tokens != null) | .usage.output_tokens] | add // 0' <<< "$TURNS_JSON" 2>/dev/null || echo 0)
TOTAL_TOKENS=$(( INPUT_TOKENS + OUTPUT_TOKENS ))

# Rough cost: ~$3/M input, ~$15/M output (Sonnet-class defaults; adjust as needed)
EST_COST=$(awk "BEGIN { printf \"%.4f\", ($INPUT_TOKENS * 3 / 1000000) + ($OUTPUT_TOKENS * 15 / 1000000) }")

# Files touched: paths appearing in tool results or tool inputs with "path" key
FILES_TOUCHED=$(jq -r '
  [ .[] |
    (
      select(.type == "tool_use") |
      (.input.path // .input.file_path // empty)
    )
  ] | unique | .[] | select(. != null and . != "")
' <<< "$TURNS_JSON" 2>/dev/null | head -40 | sed 's/^/  /' || echo "  (none detected)")

# Project directory: first path seen or cwd fallback
PROJECT=$(jq -r '
  [ .[] | select(.type == "tool_use") |
    (.input.path // .input.file_path // empty)
  ] | map(select(. != null)) | first // ""
' <<< "$TURNS_JSON" 2>/dev/null | xargs -I{} dirname {} 2>/dev/null || echo "unknown")
[[ -z "$PROJECT" || "$PROJECT" == "." ]] && PROJECT="unknown"

# First user message as goal proxy
GOAL=$(jq -r '[ .[] | select(.role == "user") | .content | if type == "array" then .[0].text else . end ] | first // "No user message found."' <<< "$TURNS_JSON" 2>/dev/null | head -c 400 || echo "unknown")

# ── Write archive file ────────────────────────────────────────────────────────
cat > "$OUT" <<ARCHIVE
---
date: ${DATE_STR}
project: ${PROJECT}
models: "${MODELS}"
est_tokens: ${TOTAL_TOKENS}
est_cost_usd: ${EST_COST}
tag: "${TAG}"
source_transcript: "${TRANSCRIPT}"
---

# Session Archive: ${SLUG}

${SAMPLE_FLAGGED}

## GOAL

${GOAL}

## KEY DECISIONS

<!-- Fill in manually or have Claude summarize before archiving. -->
- (none captured automatically)

## FILES TOUCHED

${FILES_TOUCHED}

## TOOL USAGE STATS

${TOOL_STATS:-  (none)}

## BLOCKERS

<!-- Note any blockers encountered during the session. -->
- (none captured automatically)

## OPEN QUESTIONS

<!-- Questions that came up but were not resolved. -->
- (none captured automatically)

## NEXT ACTIONS

<!-- What should happen at the start of the next session? -->
- (none captured automatically)
ARCHIVE

echo "Archived to: $OUT"
