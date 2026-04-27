#!/bin/bash

set -euo pipefail

# eval-dashboard.sh — read all eval runs and baselines, print dashboard with trend analysis

RUNS_DIR="evals/runs"
BASELINES_DIR="evals/baselines"
HTML_OUTPUT="${1:---json}"

# Check if directories exist
if [[ ! -d "$RUNS_DIR" ]]; then
  echo "Error: $RUNS_DIR not found" >&2
  exit 1
fi

# Parse latest run for a skill
get_latest_run() {
  local skill="$1"
  local runs
  runs=$(find "$RUNS_DIR" -name "*.json" -type f 2>/dev/null | sort -r | head -5)

  for run in $runs; do
    local score
    score=$(jq -r ".targets[] | select(.target == \"$skill\") | .avg" "$run" 2>/dev/null || echo "")
    if [[ -n "$score" && "$score" != "null" ]]; then
      echo "$score"
      return 0
    fi
  done
  echo "N/A"
}

# Parse baseline for a skill
get_baseline() {
  local skill="$1"
  local baseline_file="$BASELINES_DIR/${skill}-baseline.json"
  if [[ -f "$baseline_file" ]]; then
    jq -r '.baseline_avg' "$baseline_file"
  else
    echo "N/A"
  fi
}

# Check if baseline is pending fix
get_pending_fix() {
  local skill="$1"
  local baseline_file="$BASELINES_DIR/${skill}-baseline.json"
  if [[ -f "$baseline_file" ]]; then
    jq -r '.pending_fix // false' "$baseline_file"
  else
    echo "false"
  fi
}

# Calculate trend (compare to baseline)
calculate_trend() {
  local score="$1"
  local baseline="$2"

  if [[ "$score" == "N/A" || "$baseline" == "N/A" ]]; then
    echo "→"
    return
  fi

  local delta
  delta=$(echo "$score - $baseline" | bc -l 2>/dev/null || echo "0")
  if (( $(echo "$delta < -0.5" | bc -l) )); then
    echo "↓ REGRESS"
  elif (( $(echo "$delta > 0.5" | bc -l) )); then
    echo "↑"
  else
    echo "→"
  fi
}

# JSON output mode
if [[ "$HTML_OUTPUT" == "--json" ]]; then
  echo "{"
  echo '  "dashboard": {'
  echo '    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",'
  echo '    "skills": ['

  first=true
  if [[ -d "$BASELINES_DIR" ]]; then
    for baseline in "$BASELINES_DIR"/*.json; do
      [[ -f "$baseline" ]] || continue

      [[ "$first" == false ]] && echo ","
      first=false

      skill=$(jq -r '.skill' "$baseline")
      last_score=$(get_latest_run "$skill")
      baseline_score=$(jq -r '.baseline_avg' "$baseline")
      pending=$(jq -r '.pending_fix // false' "$baseline")

      echo -n '    {'
      echo -n '"skill": "'$skill'",'
      echo -n '"last_score": '$last_score','
      echo -n '"baseline": '$baseline_score','
      echo -n '"pending_fix": '$pending
      echo -n '}'
    done
  fi

  echo "    ]"
  echo "  }"
  echo "}"
  exit 0
fi

# HTML output mode
if [[ "$HTML_OUTPUT" == "--html" ]]; then
  cat > evals-dashboard.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
  <title>Eval Dashboard</title>
  <style>
    body { font-family: monospace; margin: 20px; background: #f5f5f5; }
    h1 { color: #333; }
    table { border-collapse: collapse; width: 100%; background: white; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background: #4CAF50; color: white; }
    tr:hover { background: #f9f9f9; }
    .regress { background: #ffcccc; color: #c00; font-weight: bold; }
    .pending { background: #fff3cd; color: #856404; }
    .pass { background: #d4edda; color: #155724; }
  </style>
</head>
<body>
  <h1>Eval Dashboard</h1>
  <p>Generated: <span id="timestamp"></span></p>
  <table>
    <thead>
      <tr>
        <th>Skill</th>
        <th>Last Score</th>
        <th>Baseline</th>
        <th>Delta</th>
        <th>Trend</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody id="tbody"></tbody>
  </table>
  <script>
    document.getElementById('timestamp').textContent = new Date().toISOString();
  </script>
</body>
</html>
HTMLEOF

  # Inject data into HTML
  {
    echo "document.getElementById('tbody').innerHTML = \`"
    if [[ -d "$BASELINES_DIR" ]]; then
      for baseline in "$BASELINES_DIR"/*.json; do
        [[ -f "$baseline" ]] || continue

        skill=$(jq -r '.skill' "$baseline")
        last_score=$(get_latest_run "$skill")
        baseline_score=$(jq -r '.baseline_avg' "$baseline")
        pending=$(jq -r '.pending_fix // false' "$baseline")

        delta="—"
        trend="→"
        if [[ "$last_score" != "N/A" && "$baseline_score" != "N/A" ]]; then
          delta=$(echo "scale=2; $last_score - $baseline_score" | bc -l 2>/dev/null || echo "—")
          trend=$(calculate_trend "$last_score" "$baseline_score")
        fi

        status_class="pass"
        status_text="OK"
        if [[ "$pending" == "true" ]]; then
          status_class="pending"
          status_text="Pending Fix"
        elif [[ "$trend" == "↓"* ]]; then
          status_class="regress"
          status_text="REGRESSION"
        fi

        echo "      <tr class=\"$status_class\">"
        echo "        <td>$skill</td>"
        echo "        <td>$last_score</td>"
        echo "        <td>$baseline_score</td>"
        echo "        <td>$delta</td>"
        echo "        <td>$trend</td>"
        echo "        <td>$status_text</td>"
        echo "      </tr>"
      done
    fi
    echo "\`;"
  } >> evals-dashboard.html

  echo "HTML dashboard written to evals-dashboard.html"
  exit 0
fi

# Default: terminal table output
echo ""
echo "EVAL DASHBOARD — $(date -u +%Y-%m-%d\ %H:%M:%SZ)"
echo "==========================================="
echo ""
printf "%-20s %-12s %-12s %-10s %-12s\n" "Skill" "Last Score" "Baseline" "Delta" "Trend"
echo "-------------------------------------------"

if [[ -d "$BASELINES_DIR" ]]; then
  for baseline in "$BASELINES_DIR"/*.json; do
    [[ -f "$baseline" ]] || continue

    skill=$(jq -r '.skill' "$baseline")
    last_score=$(get_latest_run "$skill")
    baseline_score=$(jq -r '.baseline_avg' "$baseline")
    pending=$(jq -r '.pending_fix // false' "$baseline")

    delta="—"
    trend="→"
    if [[ "$last_score" != "N/A" && "$baseline_score" != "N/A" ]]; then
      delta=$(echo "scale=2; $last_score - $baseline_score" | bc -l 2>/dev/null || echo "—")
      trend=$(calculate_trend "$last_score" "$baseline_score")
    fi

    # Highlight regressions
    if [[ "$trend" == "↓"* ]]; then
      echo "REGRESSION: $skill delta=$delta" >&2
    fi

    if [[ "$pending" == "true" ]]; then
      echo "WARNING: $skill pending fix" >&2
    fi

    printf "%-20s %-12s %-12s %-10s %-12s\n" "$skill" "$last_score" "$baseline_score" "$delta" "$trend"
  done
fi

echo ""
echo "For JSON output: eval-dashboard.sh --json"
echo "For HTML report: eval-dashboard.sh --html"
