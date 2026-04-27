# Recommended MCP Servers for Claude Code

High-value Model Context Protocol integrations for video production, marketing automation, and CRO workflows.

## 1. Notion MCP

**Source:** https://github.com/notionhq/notion-mcp  
**Install:** `npm install -g @notionhq/notion-mcp`

**Environment Variables:**
- `NOTION_API_KEY` — Notion integration token (create at notion.so/my-integrations)

**Use Cases:**
- Store marketing campaign briefs and creative requirements in Notion database; Claude fetches and auto-generates ad copy variations
- Query project docs for video specs (duration, resolution, format) when planning HeyGen render jobs
- Sync CRO experiment results and hypothesis notes; Claude suggests next iteration based on past learnings

**settings.json snippet:**
```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["@notionhq/notion-mcp"],
      "env": {
        "NOTION_API_KEY": "${NOTION_API_KEY}"
      }
    }
  }
}
```

---

## 2. Linear MCP

**Source:** https://github.com/modelcontextprotocol/server-linear  
**Install:** `npx -y @modelcontextprotocol/server-linear`

**Environment Variables:**
- `LINEAR_API_KEY` — Linear workspace API key (settings → API → Personal API Keys)

**Use Cases:**
- Auto-create Linear issues for video render failures with stack trace; attach render logs as issue description
- Query active sprint tasks and extract blockers; Claude summarizes blockers for standup
- Update issue status when Claude completes video editing tasks (e.g., "Sync Slack notification on completion")

**settings.json snippet:**
```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-linear"],
      "env": {
        "LINEAR_API_KEY": "${LINEAR_API_KEY}"
      }
    }
  }
}
```

---

## 3. Figma MCP

**Source:** https://github.com/modelcontextprotocol/server-figma  
**Install:** `npm install -g @modelcontextprotocol/server-figma`

**Environment Variables:**
- `FIGMA_TOKEN` — Personal access token (Figma settings → Personal Access Tokens)
- `FIGMA_FILE_ID` — (optional) default file ID to reduce context

**Use Cases:**
- Inspect design system tokens (colors, typography) for brand-consistent video overlays
- Extract Figma component specs and auto-generate React components or CSS for web pages
- Pull thumbnail images and design dimensions to inform video output resolution

**settings.json snippet:**
```json
{
  "mcpServers": {
    "figma": {
      "command": "npm",
      "args": ["exec", "@modelcontextprotocol/server-figma"],
      "env": {
        "FIGMA_TOKEN": "${FIGMA_TOKEN}",
        "FIGMA_FILE_ID": "${FIGMA_FILE_ID}"
      }
    }
  }
}
```

---

## 4. Slack MCP

**Source:** https://github.com/slack/mcp  
**Install:** `npm install -g @slack/mcp`

**Environment Variables:**
- `SLACK_BOT_TOKEN` — Bot token (Slack app settings → OAuth & Permissions → Bot User OAuth Token)
- `SLACK_SIGNING_SECRET` — Signing secret (for request verification)

**Use Cases:**
- Send completion notifications to #video-renders channel when HeyGen jobs finish
- Post daily CRO experiment summaries to marketing team Slack; include A/B test results
- Query Slack thread to extract customer feedback on video ads; feed into next design iteration

**settings.json snippet:**
```json
{
  "mcpServers": {
    "slack": {
      "command": "npm",
      "args": ["exec", "@slack/mcp"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_SIGNING_SECRET": "${SLACK_SIGNING_SECRET}"
      }
    }
  }
}
```

---

## 5. Google Sheets MCP

**Source:** https://github.com/christopheryork/mcp-server-googlesheets  
**Install:** `npm install -y mcp-server-googlesheets`

**Environment Variables:**
- `GOOGLE_SERVICE_ACCOUNT_EMAIL` — Service account email (from credentials.json)
- `GOOGLE_PRIVATE_KEY` — Private key from service account JSON
- `GOOGLE_SHEETS_SPREADSHEET_ID` — Target spreadsheet ID

**Use Cases:**
- Read analytics dashboard (CTR, conversion rate by variant); Claude identifies trends and suggests optimizations
- Query content calendar to see scheduled videos; auto-generate social media captions for upcoming posts
- Log A/B test results to shared sheet; team collaborates on experiment design in real-time

**settings.json snippet:**
```json
{
  "mcpServers": {
    "sheets": {
      "command": "npx",
      "args": ["-y", "mcp-server-googlesheets"],
      "env": {
        "GOOGLE_SERVICE_ACCOUNT_EMAIL": "${GOOGLE_SERVICE_ACCOUNT_EMAIL}",
        "GOOGLE_PRIVATE_KEY": "${GOOGLE_PRIVATE_KEY}",
        "GOOGLE_SHEETS_SPREADSHEET_ID": "${GOOGLE_SHEETS_SPREADSHEET_ID}"
      }
    }
  }
}
```

---

## 6. Replicate MCP

**Source:** https://github.com/modelcontextprotocol/server-replicate  
**Install:** `npm install -g @modelcontextprotocol/server-replicate`

**Environment Variables:**
- `REPLICATE_API_TOKEN` — API token (replicate.com → Account → API Tokens)

**Use Cases:**
- Generate product images with Stable Diffusion XL for e-commerce video ads
- Upscale low-res mockups to 4K using real-ESRGAN for video backgrounds
- Transcribe video audio with Whisper for subtitle generation before HeyGen render

**settings.json snippet:**
```json
{
  "mcpServers": {
    "replicate": {
      "command": "npm",
      "args": ["exec", "@modelcontextprotocol/server-replicate"],
      "env": {
        "REPLICATE_API_TOKEN": "${REPLICATE_API_TOKEN}"
      }
    }
  }
}
```

---

## 7. Browserbase MCP

**Source:** https://github.com/browserbase/mcp-server-browserbase  
**Install:** `npm install -g @browserbase/mcp-server-browserbase`

**Environment Variables:**
- `BROWSERBASE_API_KEY` — API key (browserbase.com → Settings → API Keys)
- `BROWSERBASE_PROJECT_ID` — Project ID from dashboard

**Use Cases:**
- Scrape competitor landing pages with stealth mode enabled; extract CTA button copy for A/B test ideas
- Capture full-page screenshots of live ads; analyze layout and visual hierarchy for redesign
- Monitor competitor video ad campaigns by scraping ad libraries with JavaScript rendering

**settings.json snippet:**
```json
{
  "mcpServers": {
    "browserbase": {
      "command": "npm",
      "args": ["exec", "@browserbase/mcp-server-browserbase"],
      "env": {
        "BROWSERBASE_API_KEY": "${BROWSERBASE_API_KEY}",
        "BROWSERBASE_PROJECT_ID": "${BROWSERBASE_PROJECT_ID}"
      }
    }
  }
}
```

---

## 8. Postgres MCP

**Source:** https://github.com/modelcontextprotocol/server-postgres  
**Install:** `npm install -g @modelcontextprotocol/server-postgres`

**Environment Variables:**
- `DATABASE_URL` — PostgreSQL connection string (postgres://user:pass@host:port/db)

**Use Cases:**
- Query video render logs table to debug failures; correlate failures with HeyGen API version
- Fetch user behavior analytics from production DB; segment viewers by engagement for targeted video ads
- Store and retrieve A/B test experiment metadata (hypothesis, variant IDs, results); run cohort analysis

**settings.json snippet:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npm",
      "args": ["exec", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    }
  }
}
```

---

## Setup Checklist

1. Generate/retrieve API keys for each service
2. Add environment variables to `.env` or use `update-config` skill
3. Install via npm globally or locally
4. Add mcpServers entries to `settings.json`
5. Restart Claude Code to load MCPs
6. Test each with a simple query (e.g., "List my Notion databases")
