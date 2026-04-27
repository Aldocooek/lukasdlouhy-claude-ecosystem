---
name: instagram-analyzer
description: "Analyze an Instagram profile, post/reel, or bulk list of creators. Downloads metadata, videos, transcribes audio, extracts frames, and provides content analysis. Trigger: 'analyze IG', 'break down ig post', 'instagram analysis', 'bulk IG', URL containing instagram.com."
compatibility: Requires yt-dlp on Mac (residential IP), Whisper on transcription server, Google Sheets service account for bulk mode.
metadata:
  requires-env:
    - GOOGLE_SHEETS_SERVICE_ACCOUNT   # Path to service account JSON file
    - IG_TRANSCRIBE_HOST              # Hostname/IP of transcription server (e.g. 10.x.x.x)
    - IG_TRANSCRIBE_USER              # SSH user on transcription server
    - MAC_SSH_ALIAS                   # SSH alias for the Mac with residential IP (e.g. "mac")
    - IG_SCRIPTS_DIR                  # Path to social scripts on Mac (e.g. /Users/[YOU]/scripts/social)
  allowed-hosts:
    - instagram.com
    - "[YOUR_TRANSCRIPTION_SERVER_IP]"
  version: "1.0"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
last-updated: 2026-04-27
version: 1.0.0
---
<!-- Adapted from filipdopita-tech/claude-ecosystem-setup, MIT-style cherry-pick -->

# /instagram-analyzer — Instagram Content Analyzer

## When to use
- User writes `/instagram-analyzer`
- User shares an Instagram URL (reel/post)
- User says "analyze IG profile X", "break down this ig post", etc.
- User wants inspiration from others' IG content
- User wants to analyze creators from Google Sheets ("analyze creators", "bulk IG")

## Three modes

### A) Single Post/Reel (URL)
User provides a specific URL. Fast analysis of a single post.

### B) Profile Analysis (username)
Analysis of a full profile — metadata, engagement stats, top posts.

### C) Bulk Creator Analysis (Google Sheets)
Analyze all creators from a Google Sheets tab.

## PROCESS

### Step 1: Detect mode
- If input contains `instagram.com/reel/` or `instagram.com/p/` → mode A (single post)
- If input contains a username (no URL) → mode B (profile)
- If unclear, ask

### Step 2A: Single Post Analysis

**IMPORTANT: Transcription (Whisper) runs on the transcription server, NOT on the Mac.**
Mac has limited RAM and OOMs on parallel Whisper. The transcription server handles audio.
Max 2 parallel Whisper instances (semaphore enforced).

Use the orchestrator wrapper (yt-dlp on Mac → scp mp4 → transcription server → rsync results):

```bash
# Set these env vars before use (see requires-env above)
ssh $MAC_SSH_ALIAS "$IG_SCRIPTS_DIR/ig_transcribe_remote.sh 'URL'"
```

Supports multiple URLs:
```bash
ssh $MAC_SSH_ALIAS "$IG_SCRIPTS_DIR/ig_transcribe_remote.sh 'URL1' 'URL2' 'URL3'"
```

Output: `~/Desktop/ig_analysis/<shortcode>/{video.mp4, audio.mp3, transcript.txt, frames/}`

Pipeline steps:
1. Mac: yt-dlp downloads mp4 (residential IP bypasses IG rate-limit)
2. scp mp4 → transcription server `/home/[USER]/ig_transcribe/input/<shortcode>.mp4`
3. ssh transcription server runs worker service (oneshot, blocking)
4. Server: ffmpeg extracts audio+frames, openai-whisper medium (thread-local, max 2 parallel)
5. rsync `/home/[USER]/ig_transcribe/output/` → `~/Desktop/ig_analysis/`

Then **read the transcript** and **review frames** (Read tool on `.txt` and `.jpg` in `~/Desktop/ig_analysis/<shortcode>/`)

Then **analyze and present**:

#### Output format (single post):
```
## IG Analysis: [shortcode]

### Content
- **Topic:** [main topic of the video]
- **Format:** [talking head / screen recording / B-roll / carousel / mix]
- **Length:** [estimate from frame count * 3s]

### Transcript (key points)
1. [point 1]
2. [point 2]
3. [point 3]

### Hook analysis
- **Opening hook:** "[first sentence]"
- **Hook strength:** [1-10] — [why]

### Engagement patterns
- **CTA:** [what CTA is used]
- **Retention elements:** [what holds attention]

### Applicability for [YOUR BRAND]
- **Usable elements:** [what could be adapted]
- **Adaptation notes:** [how it would look in your context]
- **Recommendation:** [concrete action steps]
```

### Step 2B: Profile Analysis

1. **Run ig_analyzer.py from Mac** (server gets 429 rate-limits):
```bash
ssh $MAC_SSH_ALIAS "python3 $IG_SCRIPTS_DIR/ig_analyzer.py USERNAME --metadata-only --output-dir /tmp/ig_analysis"
```

2. **Read outputs**:
```bash
ssh $MAC_SSH_ALIAS "cat /tmp/ig_analysis/USERNAME/profile.json"
ssh $MAC_SSH_ALIAS "cat /tmp/ig_analysis/USERNAME/posts.json"
ssh $MAC_SSH_ALIAS "cat /tmp/ig_analysis/USERNAME/stats.json"
```

3. **Analyze and present**:

#### Output format (profile):
```
## IG Profile: @username

### Overview
| Metric | Value |
|--------|-------|
| Followers | X |
| Posts | X |
| Avg Likes | X |
| Avg Comments | X |
| Engagement Rate | X% |

### Top 5 posts (by likes)
[table with shortcode, likes, date, caption preview]

### Content strategy
- **Posting frequency:** [how often per week]
- **Content mix:** [% video vs image vs carousel]
- **Main topics:** [analysis of captions]
- **Tone of voice:** [style description]
- **CTA patterns:** [what CTAs they use]

### What can be used for [YOUR BRAND]
- [concrete recommendation 1]
- [concrete recommendation 2]
- [concrete recommendation 3]
```

### Step 2C: Bulk Creator Analysis

1. **Run bulk analyzer from Mac** (server has no access to Google API or IG):
```bash
ssh $MAC_SSH_ALIAS "python3 $IG_SCRIPTS_DIR/ig_bulk_analyzer.py --max 10 --delay 5"
```

All PENDING creators (no limit):
```bash
ssh $MAC_SSH_ALIAS "python3 $IG_SCRIPTS_DIR/ig_bulk_analyzer.py"
```

Re-analyze all:
```bash
ssh $MAC_SSH_ALIAS "python3 $IG_SCRIPTS_DIR/ig_bulk_analyzer.py --force"
```

2. **Read results**:
```bash
ssh $MAC_SSH_ALIAS "cat /tmp/ig_analysis/bulk_report.json"
```

3. **Present summary report**:

#### Output format (bulk):
```
## Bulk IG Creator Analysis

### Overview
| Creator | Followers | Avg Likes | Avg Comments | Avg Views | ER% |
|---------|-----------|-----------|--------------|-----------|-----|
| @x      | X         | X         | X            | X         | X%  |

### Ranking (relevance for [YOUR BRAND])
1. @creator1 (score 9/10) — [why]
2. @creator2 (score 7/10) — [why]

### Implementation recommendations
1. [concrete action from top creator]
2. [concrete action from second creator]

### Content patterns to replicate
- Hook pattern: [common pattern in top posts]
- CTA pattern: [what works]
- Visual style: [what they have in common]
```

4. **Google Sheets** — results are automatically written back to the configured sheet.
   Required env: `GOOGLE_SHEETS_SERVICE_ACCOUNT` (path to service account JSON)
   Configure sheet ID and tab name in your local script or env.

### Step 3: Offer follow-up
- "Do you want to download and transcribe the top videos?"
- "Should I create an adapted version of the best post for your brand?"
- "Do you want to save this to a content plan?"
- "Do you want to add more creators to the sheet?"

## Important notes
- Instagram mobile API works ONLY from Mac (residential IP). Server gets 429.
- yt-dlp for Instagram reels MUST run from Mac (residential IP), server gets rate-limited.
- For profile scraping ALWAYS run via `ssh $MAC_SSH_ALIAS`.
- **Whisper transcription runs EXCLUSIVELY on the transcription server** via `ig_transcribe_remote.sh`.
  Medium model, thread-local per task, semaphore max 2 parallel. Mac NEVER runs Whisper (OOM risk).
- Single post output: `~/Desktop/ig_analysis/<shortcode>/` (rsynced from server).
- When analyzing for [YOUR BRAND] always factor in your brand voice (document it in a local reference file).

## Error Handling

| Situation | Action |
|---|---|
| yt-dlp 429 (rate limit) | STOP. Instagram is blocking the IP. Wait 30 min or try a different session cookie |
| yt-dlp login required | Refresh cookies: `yt-dlp --cookies-from-browser chrome` on Mac |
| Whisper OOM on server | Check `free -h`, downgrade model to `small`, verify semaphore (max 2 parallel) |
| scp/rsync timeout | Verify VPN/tunnel: `wg show` or equivalent, ping `$IG_TRANSCRIBE_HOST` |
| Empty transcript | Check audio: `ffprobe audio.mp3`. If silent/music, skip transcription |
| Google Sheets 403 | Service account lacks access. Share the sheet with the SA email |

## Common Mistakes

1. **Do not run yt-dlp from the server.** Datacenter IP = instant ban. ALWAYS from Mac (residential IP).
2. **Do not run Whisper on Mac.** Limited RAM = OOM. ALWAYS on transcription server via ig_transcribe_remote.sh.
3. **Do not mix bulk + single.** Bulk uses the Sheets pipeline; single uses direct URL.
4. **Do not parse IG HTML.** Use yt-dlp for metadata, not HTML scraping.
5. **Do not store cookies in memory or SKILL.md.** Session cookies belong in `~/.credentials/`.
