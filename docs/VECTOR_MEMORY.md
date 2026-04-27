# Vector Memory Architecture

## Overview

The vector memory system gives Claude Code durable, semantic recall across
sessions. It indexes session archives into a local SQLite database with
optional Voyage AI embeddings. Search degrades gracefully to ripgrep when
embeddings are unavailable.

## Components

| File | Role |
|------|------|
| `scripts/memory-index.sh` | Builds / updates the index |
| `scripts/memory-search.sh` | Queries the index |
| `skills/semantic-recall/SKILL.md` | Claude skill that calls the searcher |
| `commands/memory-index.md` | `/memory-index` slash command |
| `hooks/auto-index-on-archive.sh` | PostToolUse hook, keeps index fresh |

## Data Flow

```
session-archive.sh runs
        |
        v
auto-index-on-archive.sh (PostToolUse hook)
        |
        v
memory-index.sh --incremental
        |
    for each new .md/.txt/.json in ~/.claude/sessions-archive/
        |-- extract Summary section (or first 800 chars)
        |-- call Voyage API: POST /v1/embeddings (voyage-3)
        |-- store in ~/.claude/memory.db
        |
        v
    archives table: id, path, date, project, summary, embedding BLOB, indexed_at

User query: "what did we decide about X?"
        |
        v
memory-search.sh "what did we decide about X"
        |
    embed query via Voyage
        |
    SELECT all rows with embedding from archives
        |
    compute cosine similarity in Python
        |
    return top 5 by score
```

## Storage

- Database: `~/.claude/memory.db` (SQLite, no server needed)
- Embeddings: stored as comma-separated float strings in a BLOB column
- Typical size: ~4 KB per archive with embedding; ~0.5 KB without

## Cost

Voyage AI pricing (as of 2025): approximately $0.02 per 1M tokens.

A typical session archive summary is 200-800 tokens. Indexing 1,000 archives
costs roughly $0.02-0.08 total — negligible. Search queries are single
embeddings: effectively free at this scale.

Model used: `voyage-3` (1,024-dimension general purpose).

## Failover to ripgrep

When `VOYAGE_API_KEY` is not set, or when the Voyage API returns an error:

1. `memory-search.sh` falls back to `rg` (ripgrep) or `grep`.
2. Results are keyword-based, not semantic.
3. Precision is lower but recall on exact terms is good.
4. Install ripgrep for best fallback: `brew install ripgrep`

## When to Rebuild Full Index

Run `memory-index.sh` (without `--incremental`) to re-embed all archives when:

- You change the Voyage model (e.g., upgrading to `voyage-3-large`).
- Archives were edited or re-summarized.
- The DB was deleted or corrupted.

Incremental mode (`--incremental`) is fast: it skips files whose mtime has not
changed since last index.

## Privacy Considerations

- All data stays local: `~/.claude/memory.db` is on your machine only.
- Summaries and embeddings are sent to Voyage AI's API (api.voyageai.com).
  Review Voyage's data retention policy at https://www.voyageai.com/privacy.
- To opt out: do not set `VOYAGE_API_KEY`. Ripgrep fallback uses no external API.
- The archive dir (`~/.claude/sessions-archive/`) may contain conversation
  content. Review what is archived before enabling the hook in shared environments.

## Setup

```bash
# 1. Make scripts executable
chmod +x ~/Desktop/lukasdlouhy-claude-ecosystem/scripts/memory-index.sh
chmod +x ~/Desktop/lukasdlouhy-claude-ecosystem/scripts/memory-search.sh
chmod +x ~/Desktop/lukasdlouhy-claude-ecosystem/hooks/auto-index-on-archive.sh

# 2. Set Voyage API key (optional but recommended)
export VOYAGE_API_KEY="your-key-here"

# 3. Initial index run
~/Desktop/lukasdlouhy-claude-ecosystem/scripts/memory-index.sh

# 4. Register hook in ~/.claude/settings.json (see hook file header)
```
