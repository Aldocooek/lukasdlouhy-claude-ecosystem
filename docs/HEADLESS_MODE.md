# Headless Mode: Batch Jobs & Scheduled Runs

Run Claude Code without a GUI for scheduled tasks, batch processing, and CI/CD integration. Use `claude -p` to execute prompts non-interactively.

## Quick Start

### One-off batch job

```bash
echo "Audit these 5 landing pages for CRO issues" | claude -p --output-format json
```

### Scheduled nightly task

```bash
0 2 * * * /path/to/headless-runner.sh prompts/nightly-audit.txt sonnet 5 json
```

### CI/CD integration

```bash
# In .github/workflows/skill-eval.yml
- name: Evaluate skills
  run: headless-runner.sh prompts/eval-skills.txt haiku 10 json
  env:
    CLAUDE_CODE_MODEL: haiku
    CLAUDE_CODE_MAX_TURNS: 10
```

---

## Command Syntax

```bash
claude -p [options] < prompt.txt
```

### Options

```
-p, --prompt-only           Run without interactive shell
--model MODEL               Override default model (haiku, sonnet, opus)
--max-turns N               Limit conversation to N turns (default: ∞)
--output-format FORMAT      json | stream-json | text (default: text)
--tools ALLOWED_LIST        Comma-separated tool allowlist (safety gate)
--timeout SECONDS           Kill process if no output for N seconds
--log-file PATH             Write logs to file
--cost-limit USD            Abort if cost exceeds $USD
--dry-run                   Print plan without executing
```

### Output Formats

#### text (default)

Human-readable, one event per line:

```
User: "Audit 5 landing pages..."
Claude: "I'll audit each page systematically..."
Tool: Read /path/to/page-1.html
...
Claude: "Final report: Top 3 CRO issues..."
```

#### json

Structured JSON, one object per line:

```json
{"type": "user_message", "content": "Audit 5 pages..."}
{"type": "assistant_message", "content": "I'll audit..."}
{"type": "tool_use", "tool": "Read", "input": {...}}
{"type": "tool_result", "content": "..."}
{"type": "cost", "tokens": 5000, "usd": 0.50}
```

#### stream-json

Same as json but emitted in real-time (useful for monitoring):

```
{"type": "chunk", "delta": "I'll", "timestamp": 1234567890}
{"type": "chunk", "delta": " audit", "timestamp": 1234567891}
...
```

---

## Use Cases

### 1. Nightly Content Audit

**Prompt:** `prompts/nightly-audit.txt`

```
You are a CRO auditor. Evaluate the top 5 landing pages in our portfolio.

For each page:
1. Analyze headline clarity and emotional impact
2. Check call-to-action placement and copy
3. Review social proof elements (testimonials, logos, stats)
4. Identify 3 quick wins for improvement

Output JSON with scores (1-10) and recommendations.

Pages to audit:
- /landing/pricing
- /landing/features
- /landing/free-trial
- /landing/case-study
- /landing/comparison
```

**Run:**

```bash
headless-runner.sh prompts/nightly-audit.txt haiku 10 json > audits/$(date +%Y-%m-%d).json
```

**Benefits:**
- Runs 02:00 UTC (cheap off-peak pricing)
- Haiku model is 80% cheaper than Sonnet
- JSON output feeds into dashboards/alerts
- Max 10 turns (prevents runaway loops)

### 2. Weekly Skill Evaluation

**Prompt:** `prompts/weekly-skill-eval.txt`

```
Run the full eval suite on all skills in ~/.claude/skills/.

For each skill:
1. Load its definition from YAML
2. Run 3 test cases
3. Score on: correctness, speed, cost, relevance
4. Compare to last week's baseline

Output: JSON with pass/fail, cost delta, recommendations.
```

**Run:**

```bash
headless-runner.sh prompts/weekly-skill-eval.txt sonnet 20 json | \
  jq '.evals[] | select(.score < 0.8) | {name, score, issue}' > alerts/low-scoring-skills.json
```

**Cron:**

```
0 9 * * 1 /path/to/headless-runner.sh prompts/weekly-skill-eval.txt sonnet 20 json >> ~/.claude/logs/evals.log 2>&1
```

### 3. Daily Cost Report

**Prompt:** `prompts/daily-cost-report.txt`

```
Query the telemetry database for usage stats from the last 24 hours.

Metrics:
- Total tokens by model (Opus, Sonnet, Haiku)
- Cost breakdown ($)
- Top 10 skills by invocation count
- Top 10 tools by latency (p99)
- Error rate (%)

If total cost > $50, flag as alert.
Output JSON.
```

**Run:**

```bash
headless-runner.sh prompts/daily-cost-report.txt haiku 15 json | \
  jq '. | select(.total_cost_usd > 50) | {alert: "Cost spike", cost: .total_cost_usd}' | \
  mail -s "Cost Alert" ops@company.com
```

**Cron:**

```
0 0 * * * /path/to/headless-runner.sh prompts/daily-cost-report.txt haiku 15 json > ~/.claude/logs/cost-$(date +\%Y-\%m-\%d).json
```

### 4. CI/CD Skill Validation

**Prompt:** `prompts/ci-validate-skills.txt`

```
Before deployment, validate all modified skills:

1. Load each skill from the modified files
2. Run quick smoke tests
3. Check for breaking changes vs main branch
4. Output PASS or FAIL

If any skill FAILs, exit with code 1 (fail the build).
```

**Workflow:**

```yaml
# .github/workflows/validate-skills.yml
name: Validate Skills

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate skills
        run: |
          bash scripts/headless-runner.sh prompts/ci-validate-skills.txt sonnet 10 json > /tmp/results.json
          jq '.status' /tmp/results.json | grep -q "PASS" || exit 1
```

### 5. Batch Prompt Generator

**Prompt:** `prompts/batch-generate-scripts.txt`

```
Generate video scripts for 10 product features.

Features (one per line):
- Feature 1: Price optimization
- Feature 2: A/B testing
- Feature 3: Reporting
...

For each feature:
1. Write a 60-second script (engaging, benefits-focused)
2. Add visual directions (e.g., "show graph animation")
3. Output JSON

Total scripts: 10
```

**Run:**

```bash
headless-runner.sh prompts/batch-generate-scripts.txt sonnet 30 json | \
  jq '.scripts[] | {feature, script, visuals}' > output/scripts.json
```

---

## Safety: Tool Allowlists

Restrict which tools agents can call:

```bash
# Only Read and Write, no web access
claude -p --tools Read,Write < prompt.txt

# Only safe CLI tools
claude -p --tools Bash,Read < prompt.txt
# (Bash is auto-sandboxed; can't write outside project)

# For nightly background jobs: deny dangerous tools
claude -p --tools Read,Write \
  --deny-tools WebSearch,WebFetch,DeleteFile < prompt.txt
```

Built-in tool groups:

```
safe         Read, Write, Bash (limited)
research     Read, WebSearch, WebFetch, Bash
external     Agent, RemoteTrigger
dangerous    DeleteFile, DeleteDir, UpdateConfig
```

Example: Research job with cost cap

```bash
claude -p \
  --tools research \
  --max-turns 10 \
  --cost-limit 5.00 \
  --model sonnet \
  < prompts/market-research.txt
```

---

## Prompt Structure for Headless

Write prompts that work well non-interactively:

### Good (deterministic, bounded)

```
Evaluate 5 landing pages for CRO. Output JSON.
```

### Bad (interactive, unbounded)

```
Help me improve our landing page.
```

### Best Practice Template

```
[TASK]
You are a [role]. Your job is [specific goal].

[INPUTS]
- Input 1: [source]
- Input 2: [source]

[PROCESS]
1. Step 1
2. Step 2
3. Validate step

[OUTPUT]
Format: JSON
Structure:
  {
    "key1": "...",
    "key2": "..."
  }

[CONSTRAINTS]
- Max X turns
- Max Y tokens
- Tools allowed: [list]

[EXAMPLES]
Example 1: ...
Example 2: ...
```

---

## Implementation: headless-runner.sh

```bash
#!/bin/bash
# See scripts/headless-runner.sh for full script
```

Usage:

```bash
headless-runner.sh <prompt-file> <model> <max-turns> <output-format> [options]

Example:
  headless-runner.sh prompts/audit.txt haiku 10 json
  headless-runner.sh prompts/eval.txt sonnet 20 text --cost-limit 10
  headless-runner.sh prompts/gen.txt opus 50 stream-json --timeout 300
```

Features:
- Redacts secrets before logging
- Captures cost from output
- Auto-rotates logs
- Exit codes (0=success, 1=failure, 124=timeout)

---

## Monitoring & Alerting

### Log to structured format

```bash
{
  "timestamp": "2026-04-26T14:23:00Z",
  "prompt_file": "prompts/nightly-audit.txt",
  "model": "haiku",
  "status": "success",
  "cost_usd": 0.32,
  "tokens": 4000,
  "duration_seconds": 45,
  "output_lines": 87,
  "error": null
}
```

### Monitor for anomalies

```bash
# High cost for haiku (should be cheap)
jq 'select(.model == "haiku" and .cost_usd > 5)' logs/*.json

# Job timeouts
jq 'select(.status == "timeout")' logs/*.json

# Errors
jq 'select(.error != null)' logs/*.json
```

### Set alerts in Grafana

```promql
# Failed headless jobs in last 24h
count(increase(claude_headless_failures_total[24h]))

# Cost anomaly (more than 2 std devs above mean)
abs(claude_headless_cost_usd - avg(claude_headless_cost_usd)) > 2 * stddev(claude_headless_cost_usd)
```

---

## Troubleshooting

**"Command not found: claude"**

Ensure Claude Code is installed and in PATH:

```bash
which claude
# Should output: /usr/local/bin/claude (or similar)

# If not found:
export PATH="$PATH:/path/to/claude/bin"
```

**"Timeout exceeded"**

Increase timeout or reduce task complexity:

```bash
# Increase to 10 minutes
claude -p --timeout 600 < prompt.txt

# Or reduce max-turns
claude -p --max-turns 5 < prompt.txt
```

**"Cost limit exceeded"**

Use cheaper model or constrain output:

```bash
# Use haiku instead of sonnet
--model haiku

# Or lower cost-limit to fail fast
--cost-limit 1.00
```

**"Tool denied: X"**

Add to allowlist:

```bash
# Current allowlist: Read,Write
# Add Bash:
--tools Read,Write,Bash
```

---

## Performance Tips

1. **Use Haiku for research** — 80% cheaper, fast for narrow queries
2. **Limit turns aggressively** — 10-20 is usually plenty
3. **Use json output** — Smaller than text, easier to parse
4. **Cache contexts** — Reuse `--context` if available
5. **Batch similar jobs** — Map-reduce pattern is faster + cheaper

---

See [/commands/swarm.md](../commands/swarm.md) for orchestrating multiple headless jobs.

Last updated: 2026-04-26
