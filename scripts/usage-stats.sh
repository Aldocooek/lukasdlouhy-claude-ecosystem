#!/usr/bin/env bash
# usage-stats.sh — Parse ~/.claude/logs/*.log for skill/agent/hook invocations.
# Outputs table of invocation counts over last 30/7/1 days.
# Usage: usage-stats.sh [--json]

set -euo pipefail

LOG_DIR="${HOME}/.claude/logs"
SELF_LOG="${LOG_DIR}/usage-stats.log"
JSON_MODE=0

mkdir -p "$LOG_DIR"
log() { echo "[$(date '+%Y-%m-%dT%H:%M:%S')] $*" >> "$SELF_LOG"; }

for arg in "$@"; do
  [[ "$arg" == "--json" ]] && JSON_MODE=1
done

# ── date boundaries ───────────────────────────────────────────────────────────
now_ts=$(date +%s)
ts_30d=$((now_ts - 30*86400))
ts_7d=$((now_ts  - 7*86400))
ts_1d=$((now_ts  - 1*86400))

iso_30d=$(date -u -r "$ts_30d" '+%Y-%m-%d' 2>/dev/null || date -u -d "@$ts_30d" '+%Y-%m-%d' 2>/dev/null || date -u '+%Y-%m-%d')
iso_7d=$(date -u -r "$ts_7d"   '+%Y-%m-%d' 2>/dev/null || date -u -d "@$ts_7d" '+%Y-%m-%d' 2>/dev/null || date -u '+%Y-%m-%d')
iso_1d=$(date -u -r "$ts_1d"   '+%Y-%m-%d' 2>/dev/null || date -u -d "@$ts_1d" '+%Y-%m-%d' 2>/dev/null || date -u '+%Y-%m-%d')

# ── check log directory ───────────────────────────────────────────────────────
if [[ ! -d "$LOG_DIR" ]]; then
  echo "No log directory found at $LOG_DIR"
  exit 0
fi

log_files=$(find "$LOG_DIR" -name "*.log" -not -name "usage-stats.log" 2>/dev/null | head -200)
if [[ -z "$log_files" ]]; then
  echo "No log files found in $LOG_DIR"
  exit 0
fi

# ── extract invocations ───────────────────────────────────────────────────────
# Pattern: lines containing "skill:", "agent:", "hook:", "command:", "/skill-name"
# Assumes log lines start with ISO timestamps like [2025-11-20T...]

declare -A count_30d count_7d count_1d

while IFS= read -r line; do
  # extract date portion from log line
  line_date=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || true)
  [[ -z "$line_date" ]] && continue

  # extract component name from common patterns
  component=""
  if echo "$line" | grep -qiE '(skill|invoking|running|command|agent|hook)[: ]+[a-z]'; then
    component=$(echo "$line" | grep -oiE '(skill|invoking|running|command|agent|hook)[: ]+([a-zA-Z0-9_-]+)' | \
      awk -F'[ :]+' '{print $NF}' | head -1 | tr '[:upper:]' '[:lower:]')
  fi
  # also catch /slash-commands
  if [[ -z "$component" ]]; then
    component=$(echo "$line" | grep -oE '/[a-zA-Z][a-zA-Z0-9_-]+' | head -1 | tr -d '/' | tr '[:upper:]' '[:lower:]')
  fi

  [[ -z "$component" ]] && continue

  # increment counts by time bucket
  if [[ "$line_date" > "$iso_1d" || "$line_date" == "$iso_1d" ]]; then
    count_1d["$component"]=$(( ${count_1d["$component"]:-0} + 1 ))
  fi
  if [[ "$line_date" > "$iso_7d" || "$line_date" == "$iso_7d" ]]; then
    count_7d["$component"]=$(( ${count_7d["$component"]:-0} + 1 ))
  fi
  if [[ "$line_date" > "$iso_30d" || "$line_date" == "$iso_30d" ]]; then
    count_30d["$component"]=$(( ${count_30d["$component"]:-0} + 1 ))
  fi

done < <(cat $log_files 2>/dev/null)

# ── merge all known components ────────────────────────────────────────────────
declare -A all_components
for k in "${!count_30d[@]}" "${!count_7d[@]}" "${!count_1d[@]}"; do
  all_components["$k"]=1
done

# ── also enumerate known skills/agents from ecosystem ─────────────────────────
ECOSYSTEM="${HOME}/Desktop/lukasdlouhy-claude-ecosystem"
if [[ -d "$ECOSYSTEM" ]]; then
  while IFS= read -r -d '' fpath; do
    cname=$(basename "$(dirname "$fpath")")
    all_components["$cname"]=1
  done < <(find "$ECOSYSTEM/skills" "$ECOSYSTEM/agents" "$ECOSYSTEM/commands" "$ECOSYSTEM/hooks" \
    -name "SKILL.md" -o -name "*.md" -print0 2>/dev/null)
fi

# ── output ────────────────────────────────────────────────────────────────────
if [[ "$JSON_MODE" -eq 1 ]]; then
  echo "{"
  first=1
  for comp in $(echo "${!all_components[@]}" | tr ' ' '\n' | sort); do
    c30=${count_30d["$comp"]:-0}
    c7=${count_7d["$comp"]:-0}
    c1=${count_1d["$comp"]:-0}
    [[ "$first" -eq 0 ]] && echo ","
    printf '  "%s": {"30d": %d, "7d": %d, "1d": %d}' "$comp" "$c30" "$c7" "$c1"
    first=0
  done
  echo ""
  echo "}"
else
  printf "\n%-40s %6s %6s %6s\n" "Component" "30d" "7d" "1d"
  printf "%-40s %6s %6s %6s\n" "$(printf '%0.s-' {1..40})" "------" "------" "------"
  for comp in $(echo "${!all_components[@]}" | tr ' ' '\n' | sort); do
    c30=${count_30d["$comp"]:-0}
    c7=${count_7d["$comp"]:-0}
    c1=${count_1d["$comp"]:-0}
    printf "%-40s %6d %6d %6d\n" "$comp" "$c30" "$c7" "$c1"
  done
  echo ""
  echo "Log dir  : $LOG_DIR"
  echo "As of    : $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
fi

log "usage-stats run complete"
