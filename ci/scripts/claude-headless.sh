#!/usr/bin/env bash
# claude-headless.sh — Safe wrapper for running Claude Code CLI in headless mode.
#
# Usage:
#   echo "prompt text" | ./scripts/claude-headless.sh [options]
#   cat diff.txt | ./scripts/claude-headless.sh --model claude-haiku-4-5-20251001 --max-turns 3
#
# Options:
#   --prompt <text>       Prompt string (alternative to stdin)
#   --model <id>          Model ID (default: claude-sonnet-4-6)
#   --max-turns <n>       Max agentic turns (default: 5)
#   --output-format <fmt> json|text (default: json)
#   --tools <list>        Comma-separated tool allowlist
#   --max-cost <usd>      Soft cost ceiling; exit 1 if exceeded (default: 2.00)
#   --out-file <path>     Write raw JSON to this file (default: /tmp/claude_out.json)
#   --quiet               Suppress informational output to stderr
#
# Environment:
#   ANTHROPIC_API_KEY     Required. Must be set before calling this script.
#   MAX_COST_USD          Alternative to --max-cost.
#
# Output (stdout):
#   The extracted .result string from the Claude JSON envelope, with secrets redacted.
#
# Exit codes:
#   0  Success
#   1  Claude error, cost exceeded, or missing API key
#   2  Invalid arguments

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
MODEL="${CLAUDE_MODEL:-claude-sonnet-4-6}"
MAX_TURNS="${CLAUDE_MAX_TURNS:-5}"
OUTPUT_FORMAT="json"
TOOLS=""
MAX_COST="${MAX_COST_USD:-2.00}"
OUT_FILE="/tmp/claude_out_$$.json"
QUIET=false
PROMPT=""
STDIN_DATA=""

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt)       PROMPT="$2";         shift 2 ;;
    --model)        MODEL="$2";          shift 2 ;;
    --max-turns)    MAX_TURNS="$2";      shift 2 ;;
    --output-format) OUTPUT_FORMAT="$2"; shift 2 ;;
    --tools)        TOOLS="$2";          shift 2 ;;
    --max-cost)     MAX_COST="$2";       shift 2 ;;
    --out-file)     OUT_FILE="$2";       shift 2 ;;
    --quiet)        QUIET=true;          shift ;;
    --)             shift; break ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

log() {
  if [ "$QUIET" = false ]; then
    echo "[claude-headless] $*" >&2
  fi
}

# ── Safety checks ──────────────────────────────────────────────────────────────
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY is not set." >&2
  exit 1
fi

if echo "$MODEL" | grep -qi 'opus'; then
  echo "ERROR: opus model is prohibited in CI. Use sonnet or haiku." >&2
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "ERROR: 'claude' CLI not found. Run: npm install -g @anthropic-ai/claude-code" >&2
  exit 1
fi

# ── Read stdin if available and no explicit prompt set ─────────────────────────
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
  STDIN_DATA=$(cat)
fi

# ── Build CLI command ──────────────────────────────────────────────────────────
CLAUDE_ARGS=(
  -p
  --output-format "$OUTPUT_FORMAT"
  --model "$MODEL"
  --max-turns "$MAX_TURNS"
)

if [ -n "$TOOLS" ]; then
  CLAUDE_ARGS+=(--allowedTools "$TOOLS")
fi

# ── Execute ────────────────────────────────────────────────────────────────────
log "model=${MODEL} max-turns=${MAX_TURNS} output-format=${OUTPUT_FORMAT}"

if [ -n "$STDIN_DATA" ]; then
  EFFECTIVE_PROMPT="${PROMPT:-Review the following input and provide a structured analysis.}"
  echo "$STDIN_DATA" | claude "${CLAUDE_ARGS[@]}" "$EFFECTIVE_PROMPT" > "$OUT_FILE" 2>/tmp/claude_headless_err.txt
elif [ -n "$PROMPT" ]; then
  claude "${CLAUDE_ARGS[@]}" "$PROMPT" > "$OUT_FILE" 2>/tmp/claude_headless_err.txt
else
  echo "ERROR: No prompt provided via --prompt or stdin." >&2
  exit 2
fi

CLAUDE_EXIT=$?
if [ $CLAUDE_EXIT -ne 0 ]; then
  echo "ERROR: Claude CLI exited with code ${CLAUDE_EXIT}:" >&2
  cat /tmp/claude_headless_err.txt >&2
  exit 1
fi

# ── Extract and redact output ──────────────────────────────────────────────────
RESULT=$(jq -r '.result // .' "$OUT_FILE" 2>/dev/null || cat "$OUT_FILE")

# Redact common secret patterns
RESULT=$(echo "$RESULT" \
  | sed 's/\(sk-ant-[A-Za-z0-9_-]\{10,\}\)/[REDACTED_ANTHROPIC_KEY]/g' \
  | sed 's/\(ghp_[A-Za-z0-9]\{36\}\)/[REDACTED_GH_TOKEN]/g' \
  | sed 's/\(AKIA[A-Z0-9]\{16\}\)/[REDACTED_AWS_KEY]/g' \
  | sed 's/\(password\s*[:=]\s*\)[^[:space:],"}]*/\1[REDACTED]/gi' \
  | sed 's/\(secret\s*[:=]\s*\)[^[:space:],"}]*/\1[REDACTED]/gi' \
  | sed 's/\(token\s*[:=]\s*\)[^[:space:],"}]*/\1[REDACTED]/gi')

# ── Cost cap check ─────────────────────────────────────────────────────────────
COST=$(jq -r '.cost_usd // .costUsd // 0' "$OUT_FILE" 2>/dev/null || echo "0")
log "cost=\$${COST} cap=\$${MAX_COST}"

EXCEEDED=$(echo "$COST $MAX_COST" | awk '{print ($1 > $2) ? "yes" : "no"}')
if [ "$EXCEEDED" = "yes" ]; then
  echo "ERROR: Cost \$${COST} exceeded cap \$${MAX_COST}." >&2
  exit 1
fi

# ── GitHub Actions annotations ─────────────────────────────────────────────────
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "claude_cost_usd=${COST}" >> "$GITHUB_OUTPUT"
  echo "claude_model=${MODEL}" >> "$GITHUB_OUTPUT"
fi

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  echo "| claude-headless | model: \`${MODEL}\` | cost: \$${COST} |" >> "$GITHUB_STEP_SUMMARY"
fi

# ── Output result to stdout ────────────────────────────────────────────────────
echo "$RESULT"
