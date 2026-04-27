#!/usr/bin/env bash
# memory-index.sh — Index session archives into SQLite with Voyage embeddings.
# Usage: memory-index.sh [--incremental]
# Env:   VOYAGE_API_KEY  (optional; skips embedding if absent)
# DB:    ~/.claude/memory.db

set -euo pipefail

ARCHIVE_DIR="${HOME}/.claude/sessions-archive"
DB="${HOME}/.claude/memory.db"
LOG="${HOME}/.claude/logs/memory-index.log"
VOYAGE_EMBED_URL="https://api.voyageai.com/v1/embeddings"
VOYAGE_MODEL="voyage-3"
INCREMENTAL=0

mkdir -p "$(dirname "$LOG")"
log() { echo "[$(date '+%Y-%m-%dT%H:%M:%S')] $*" | tee -a "$LOG"; }

for arg in "$@"; do
  [[ "$arg" == "--incremental" ]] && INCREMENTAL=1
done

# ── ensure sqlite3 available ──────────────────────────────────────────────────
if ! command -v sqlite3 &>/dev/null; then
  log "ERROR: sqlite3 not found. Install via: brew install sqlite3"
  exit 1
fi

# ── bootstrap schema ─────────────────────────────────────────────────────────
sqlite3 "$DB" <<'SQL'
CREATE TABLE IF NOT EXISTS archives (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  path       TEXT    NOT NULL UNIQUE,
  date       TEXT,
  project    TEXT,
  summary    TEXT,
  embedding  BLOB,
  indexed_at TEXT    NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_archives_path ON archives(path);
SQL

log "DB ready: $DB"

# ── scan archive files ────────────────────────────────────────────────────────
if [[ ! -d "$ARCHIVE_DIR" ]]; then
  log "WARN: archive dir not found: $ARCHIVE_DIR — nothing to index"
  exit 0
fi

indexed=0
skipped=0
errors=0

while IFS= read -r -d '' fpath; do
  # skip non-text files
  [[ "$fpath" =~ \.(md|txt|json)$ ]] || continue

  mtime=$(stat -f '%m' "$fpath" 2>/dev/null || stat -c '%Y' "$fpath" 2>/dev/null || echo 0)

  # check if already indexed at same mtime
  existing=$(sqlite3 "$DB" "SELECT indexed_at FROM archives WHERE path='$fpath';" 2>/dev/null || true)
  if [[ -n "$existing" && "$INCREMENTAL" -eq 1 ]]; then
    stored_mtime=$(sqlite3 "$DB" "SELECT strftime('%s', indexed_at) FROM archives WHERE path='$fpath';" 2>/dev/null || echo 0)
    if [[ "$mtime" -le "$stored_mtime" ]]; then
      ((skipped++)) || true
      continue
    fi
  fi

  # ── extract metadata ──────────────────────────────────────────────────────
  fname=$(basename "$fpath")
  # try to parse date from filename pattern: YYYY-MM-DD or similar
  date_str=$(echo "$fname" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || true)
  [[ -z "$date_str" ]] && date_str=$(date -r "$fpath" '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d')

  # project: parent directory name
  project=$(basename "$(dirname "$fpath")")
  [[ "$project" == "sessions-archive" ]] && project="unknown"

  # ── extract summary ───────────────────────────────────────────────────────
  # look for a ## Summary or # Summary section; fall back to first 500 chars
  summary=$(awk '
    /^#+[[:space:]]*(Summary|SUMMARY)/ { found=1; next }
    found && /^#/ { exit }
    found { print }
  ' "$fpath" 2>/dev/null | head -20 | tr -s '\n' ' ' | cut -c1-800)

  if [[ -z "$summary" ]]; then
    summary=$(head -c 800 "$fpath" 2>/dev/null | tr -s '\n' ' ')
  fi

  # sanitize for SQL
  summary_safe="${summary//\'/\'\'}"
  fpath_safe="${fpath//\'/\'\'}"
  project_safe="${project//\'/\'\'}"

  # ── call Voyage API for embedding ─────────────────────────────────────────
  embedding_blob=""
  if [[ -n "${VOYAGE_API_KEY:-}" ]]; then
    embed_text=$(echo "$summary" | cut -c1-4000)
    json_payload=$(printf '{"model":"%s","input":[%s]}' \
      "$VOYAGE_MODEL" \
      "$(python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))" <<< "$embed_text" 2>/dev/null || echo "\"$embed_text\"")")

    response=$(curl -s -w "\n%{http_code}" \
      -H "Authorization: Bearer ${VOYAGE_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$json_payload" \
      "$VOYAGE_EMBED_URL" 2>/dev/null || true)

    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]]; then
      # extract embedding array as comma-separated floats
      embedding_blob=$(echo "$body" | python3 -c "
import sys, json
d = json.load(sys.stdin)
vec = d['data'][0]['embedding']
print(','.join(str(v) for v in vec))
" 2>/dev/null || true)
    else
      log "WARN: Voyage API returned $http_code for $fpath"
    fi
  fi

  # ── insert / update record ────────────────────────────────────────────────
  now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  sqlite3 "$DB" <<SQL2
INSERT INTO archives (path, date, project, summary, embedding, indexed_at)
VALUES ('${fpath_safe}', '${date_str}', '${project_safe}', '${summary_safe}', '${embedding_blob}', '${now}')
ON CONFLICT(path) DO UPDATE SET
  date       = excluded.date,
  project    = excluded.project,
  summary    = excluded.summary,
  embedding  = excluded.embedding,
  indexed_at = excluded.indexed_at;
SQL2

  ((indexed++)) || true
  log "Indexed: $fname"

done < <(find "$ARCHIVE_DIR" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.json" \) -print0 2>/dev/null)

# ── final stats ───────────────────────────────────────────────────────────────
total=$(sqlite3 "$DB" "SELECT COUNT(*) FROM archives;" 2>/dev/null || echo 0)
db_size=$(du -sh "$DB" 2>/dev/null | cut -f1 || echo "?")
log "Done. indexed=$indexed skipped=$skipped errors=$errors total=$total db=$db_size"
echo "memory-index complete: indexed=$indexed skipped=$skipped total=$total db_size=$db_size"
