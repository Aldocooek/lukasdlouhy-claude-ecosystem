# @lukasdlouhy/hyperframes-mcp

MCP server that exposes [HyperFrames](https://github.com/heygen-com/hyperframes) CLI tools to Claude Code via the Model Context Protocol.

## Install & Build

```bash
cd mcp-servers/hyperframes-mcp
npm install
npm run build
```

Or use the provided script (checks prerequisites automatically):

```bash
./install.sh
```

## Connect to Claude Code

**Option A — claude mcp add (recommended):**

```bash
claude mcp add hyperframes node /path/to/mcp-servers/hyperframes-mcp/dist/index.js
```

**Option B — settings.json:**

Add to your `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "hyperframes": {
      "command": "node",
      "args": ["/absolute/path/to/mcp-servers/hyperframes-mcp/dist/index.js"]
    }
  }
}
```

Restart Claude Code after adding, then verify with `/mcp`.

## Available Tools

| Tool | Description |
|------|-------------|
| `hyperframes_lint` | Lint a composition file; returns parsed errors/warnings |
| `hyperframes_preview` | Generate a preview thumbnail; returns path or URL |
| `hyperframes_render` | Render to video; returns output path, duration, file size |
| `hyperframes_transcribe` | Transcribe audio to SRT; returns SRT text + segment count |
| `hyperframes_tts` | Text-to-speech; returns audio file path |
| `hyperframes_doctor` | Environment diagnostics; returns check results |
| `hyperframes_benchmark` | Per-phase timing metrics for a composition |
| `hyperframes_estimate_cost` | Static analysis → estimated render cost before running |
| `hyperframes_session_cost` | Running cost total (renders, TTS, transcriptions) |

## Cost Estimation Rationale

`hyperframes_estimate_cost` performs a dry-run analysis of the composition without executing any API calls. It counts:

- **Scenes** — each scene adds ~0.5 render-minutes of estimated compute
- **TTS blocks** — estimated ~500 chars/block at $0.015/1k chars
- **Audio assets** — counted but not priced (local files)

Actual costs depend on your cloud provider and plan. The session cost tracker (`hyperframes_session_cost`) accumulates real usage after each render/TTS/transcribe call and persists to `~/.hyperframes-mcp-state.json`.

## Troubleshooting

**`hf` not in PATH**

The MCP server requires `hf` (hyperframes-cli) to be on the system PATH. Install it:

```bash
npm install -g hyperframes-cli
```

If installed globally but not found, check that your global npm bin is on PATH:

```bash
npm bin -g   # shows the bin directory
echo $PATH   # verify it's included
```

**Permission denied on install.sh**

```bash
chmod +x install.sh
```

**Server starts but tools return errors**

Run `hyperframes_doctor` first — it checks all environment dependencies (FFmpeg, API keys, etc.) and reports what's missing.

**TypeScript build errors**

Ensure you're on Node 18+ and TypeScript 5+:

```bash
node --version   # should be >= 18
npx tsc --version  # should be >= 5
```

**Checking server is connected**

In Claude Code, type `/mcp` to list active servers and their tool counts.
