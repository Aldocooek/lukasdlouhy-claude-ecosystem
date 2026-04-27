#!/usr/bin/env bash
# memory-search.sh — Semantic search over indexed session archives.
# Usage: memory-search.sh <query string>
# Env:   VOYAGE_API_KEY  (optional; falls back to ripgrep if absent)
# DB:    ~/.claude/memory.db

set -euo pipefail

DB="${HOME}/.claude/memory.db"
LOG="${HOME}/.claude/logs/memory-search.log"
VOYAGE_EMBED_URL="https://api.voyageai.com/v1/embeddings"
VOYAGE_MODEL="voyage-3"
TOP_N=5

mkdir -p "$(dirname "$LOG")"
log() { echo "[$(date '+%Y-%m-%dT%H:%M:%S')] $*" >> "$LOG"; }

if [[ $# -eq 0 ]]; then
  echo "Usage: memory-search.sh <query string>" >&2
  exit 1
fi

QUERY="$*"
log "Query: $QUERY"

# ── ripgrep fallback ──────────────────────────────────────────────────────────
ripgrep_fallback() {
  local query="$1"
  local archive_dir="${HOME}/.claude/sessions-archive"
  echo "=== Fallback: ripgrep search (no VOYAGE_API_KEY) ==="
  echo "Query: $query"
  echo ""
  if command -v rg &>/dev/null && [[ -d "$archive_dir" ]]; then
    rg -l --max-count=1 -i "$query" "$archive_dir" 2>/dev/null | head -"$TOP_N" | while read -r fpath; do
      echo "--- $fpath ---"
      rg -i -m 3 --context 2 "$query" "$fpath" 2>/dev/null | head -20
      echo ""
    done
  elif command -v grep &>/dev/null && [[ -d "$archive_dir" ]]; then
    grep -ril "$query" "$archive_dir" 2>/dev/null | head -"$TOP_N" | while read -r fpath; do
      echo "--- $fpath ---"
      grep -i -m 3 -A 2 "$query" "$fpath" 2>/dev/null | head -20
      echo ""
    done
  else
    echo "No search backend available. Install ripgrep: brew install ripgrep"
  fi
}

# ── check sqlite3 ────────────────────────────────────────────────────────────
if ! command -v sqlite3 &>/dev/null; then
  log "WARN: sqlite3 not found, falling back to ripgrep"
  ripgrep_fallback "$QUERY"
  exit 0
fi

# ── check db exists ───────────────────────────────────────────────────────────
if [[ ! -f "$DB" ]]; then
  log "WARN: DB not found at $DB. Run memory-index.sh first."
  echo "No index found. Run: memory-index.sh"
  echo ""
  ripgrep_fallback "$QUERY"
  exit 0
fi

total=$(sqlite3 "$DB" "SELECT COUNT(*) FROM archives;" 2>/dev/null || echo 0)
if [[ "$total" -eq 0 ]]; then
  log "WARN: DB is empty. Run memory-index.sh first."
  echo "Index is empty. Run: memory-index.sh"
  ripgrep_fallback "$QUERY"
  exit 0
fi

# ── embedding path ────────────────────────────────────────────────────────────
if [[ -z "${VOYAGE_API_KEY:-}" ]]; then
  log "No VOYAGE_API_KEY, using ripgrep fallback"
  ripgrep_fallback "$QUERY"
  exit 0
fi

# ── embed the query ───────────────────────────────────────────────────────────
log "Embedding query via Voyage..."
json_payload=$(printf '{"model":"%s","input":[%s]}' \
  "$VOYAGE_MODEL" \
  "$(python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))" <<< "$QUERY" 2>/dev/null || echo "\"$QUERY\"")")

response=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer ${VOYAGE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$json_payload" \
  "$VOYAGE_EMBED_URL" 2>/dev/null)

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" != "200" ]]; then
  log "Voyage API error $http_code, falling back to ripgrep"
  echo "Voyage API error ($http_code). Falling back to ripgrep."
  echo ""
  ripgrep_fallback "$QUERY"
  exit 0
fi

query_vec=$(echo "$body" | python3 -c "
import sys, json
d = json.load(sys.stdin)
vec = d['data'][0]['embedding']
print(','.join(str(v) for v in vec))
" 2>/dev/null || true)

if [[ -z "$query_vec" ]]; then
  log "Failed to parse query embedding, falling back to ripgrep"
  ripgrep_fallback "$QUERY"
  exit 0
fi

# ── cosine similarity in awk ──────────────────────────────────────────────────
# Pull all rows with embeddings, compute similarity, sort, top N
python3 - "$DB" "$query_vec" "$TOP_N" <<'PYEOF'
import sys, sqlite3, math

db_path, query_vec_str, top_n = sys.argv[1], sys.argv[2], int(sys.argv[3])

qvec = list(map(float, query_vec_str.split(',')))
qmag = math.sqrt(sum(v*v for v in qvec))

conn = sqlite3.connect(db_path)
rows = conn.execute(
    "SELECT id, path, date, project, summary, embedding FROM archives WHERE embedding IS NOT NULL AND embedding != ''"
).fetchall()
conn.close()

results = []
for row in rows:
    rid, path, date, project, summary, emb_str = row
    if not emb_str:
        continue
    try:
        dvec = list(map(float, emb_str.split(',')))
        dot  = sum(q*d for q,d in zip(qvec, dvec))
        dmag = math.sqrt(sum(v*v for v in dvec))
        score = dot / (qmag * dmag) if qmag and dmag else 0.0
        results.append((score, path, date, project, summary or ""))
    except Exception:
        continue

results.sort(reverse=True)
results = results[:top_n]

print(f"=== Semantic Search Results ===")
print(f"Query embedded via Voyage. Top {top_n} matches:\n")
for i, (score, path, date, project, summary) in enumerate(results, 1):
    pct = int(score * 100)
    snippet = summary[:200].replace('\n', ' ')
    print(f"{i}. [{pct}% relevance] {project} / {date}")
    print(f"   Path: {path}")
    print(f"   Snippet: {snippet}")
    print()
PYEOF

log "Search complete for query: $QUERY"
