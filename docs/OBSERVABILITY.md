# Observability Stack for Claude Code

Track token usage, API costs, and performance metrics across Claude Code sessions and tools.

## 1. ccusage CLI

Command-line tool to monitor Claude API spending and session counts.

**Install:**
```bash
npx ccusage@latest
# or via Homebrew
brew install ccusage
```

**Usage:**
```bash
ccusage                    # Show today's spend
ccusage --week             # Weekly summary
ccusage --month            # Monthly summary
ccusage --all              # All-time total
```

**How it works:** Reads session metadata from `~/.claude/sessions` and calculates cost based on token counts (input + output) and current Claude model pricing.

**Output example:**
```
Today: $3.42 (1,250 input tokens, 850 output tokens)
Top 3 sessions:
  1. claude-code: $1.80 (850 out tokens)
  2. @awesome-mcp-servers: $1.12 (620 out tokens)
  3. video-render-debug: $0.50 (380 in tokens)
```

---

## 2. OpenTelemetry Exporter

Export Claude Code metrics (token usage, tool latency, errors) to an observability backend.

**Repository:** https://github.com/ColeMurray/claude-code-otel

**Environment Variables:**
```bash
export CLAUDE_CODE_OTEL_ENDPOINT="http://localhost:4318/v1/traces"
export CLAUDE_CODE_OTEL_HEADERS="Authorization: Bearer YOUR_TOKEN"
export CLAUDE_CODE_OTEL_SERVICE_NAME="claude-code"
```

**Exported Metrics:**
- `claude.tokens.input` — Input token count per request
- `claude.tokens.output` — Output token count per request
- `claude.tokens.cache_hit` — Cache hit/miss ratio
- `tool.duration_ms` — Execution time per tool (Bash, Read, Write, MCP calls)
- `tool.error_rate` — Failed tool invocations by type
- `agent.model` — Which model ran (Haiku, Sonnet, Opus)

**Installation:**
1. Clone the otel-exporter repo
2. Set env vars above
3. Restart Claude Code to enable telemetry
4. Traces appear in your observability backend within 60s

---

## 3. SigNoz Self-Hosted

Free, open-source observability platform (alternative to Datadog).

**Why SigNoz over Datadog:**
- Zero cost for small teams (self-hosted)
- Same OpenTelemetry integration
- Includes logs, traces, metrics in one UI
- No vendor lock-in

**Quick start:**
```bash
docker run -d \
  -p 3301:3301 \
  -p 4317:4317 \
  -p 4318:4318 \
  --name signoz \
  ghcr.io/signoz/signoz:latest
```

Visit `http://localhost:3301` and create a new datasource with OTEL endpoint `http://localhost:4318`.

**What to monitor:**
- Token cost per session (sum `claude.tokens.input` + `claude.tokens.output`)
- Tool error rate by type (failed Bash > failed MCP > failed Read)
- Cache hit ratio trend (should increase with repeated queries)
- Agent model distribution (which subagents used Sonnet vs Haiku)

---

## 4. Local Cost Dashboard

One-liner to display today's spend in your shell prompt or statusline:

```bash
alias cost-today='ccusage | grep "^Today:" | awk "{print \$2, \$3}"'

# In statusline.sh:
TODAY_COST=$(ccusage 2>/dev/null | grep "^Today:" | awk '{print $2, $3}' || echo "")
echo "Claude: $TODAY_COST | ..."
```

**Robust to missing ccusage:** Returns empty string if ccusage not installed; statusline continues.

See `scripts/cost-statusline-fragment.sh` for full implementation.

---

## 5. Log Aggregation

Local log files live in `~/.claude/logs/` (session transcripts, tool output, errors).

**View live logs:**
```bash
# Using multitail (install: brew install multitail)
multitail ~/.claude/logs/*.log

# Using lnav (install: brew install lnav)
lnav ~/.claude/logs/
```

**Filter by date:**
```bash
find ~/.claude/logs -mtime -1 -name "*.log" | xargs tail -f
```

**Search for errors:**
```bash
grep -r "ERROR\|FAIL" ~/.claude/logs/ | tail -20
```

**Archive old logs (>30 days):**
```bash
find ~/.claude/logs -mtime +30 -name "*.log" -exec gzip {} \;
```

---

## Recommended Setup Order

1. Install `ccusage` and test with `ccusage --all`
2. Set up local SigNoz instance (optional but recommended)
3. Configure OpenTelemetry exporter env vars
4. Add cost-today alias or statusline fragment
5. Set up log tailing with `lnav` for debugging
6. Create weekly cost review habit (run `ccusage --week` on Fridays)

---

## Cost Alerts

Create a bash script to alert on daily spend overages:

```bash
#!/bin/bash
LIMIT=5  # $5 daily limit
SPEND=$(ccusage | grep "^Today:" | awk '{print $2}' | tr -d '$')
if (( $(echo "$SPEND > $LIMIT" | bc -l) )); then
  echo "Daily spend ($SPEND) exceeds limit ($LIMIT). Session closed."
  # optional: pkill -f "claude-code"
fi
```

Schedule via cron:
```
0 18 * * * ~/.claude/scripts/cost-alert.sh
```
