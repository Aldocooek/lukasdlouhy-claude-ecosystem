# Lukáš Dlouhý — Claude Code Ecosystem

Complete production plugin packaging, multi-agent orchestration, and observability infrastructure for Claude Code. Build, deploy, and monitor AI-powered skills with cost discipline and enterprise safety gates.

A curated collection of Claude Code rules, hooks, skills, and expertise configs for video/animation workflows, CRO marketing, and cost-disciplined AI development. This repo mirrors `~/.claude/` to enable peer cherry-picking and ecosystem sharing.

## What's in This Repo

### Core Production Systems
- **Plugin packaging** — Automated build/publish with semantic versioning, SHA256 checksums, GitHub releases
- **Production telemetry** — OpenTelemetry → Prometheus/Grafana/Loki stack with cost tracking and alerting
- **Multi-agent swarm** — Five orchestration patterns for parallel research, debate, sequential pipelines, tournaments, and watchdog recovery
- **Headless batch mode** — Non-interactive execution for nightly audits, CI/CD validation, scheduled skill evaluation
- **Safety framework** — Tool allowlists, cost limits, timeout controls, secret redaction, deployment protection

### Stack Focus

- **Video & Animation**: HyperFrames (OSS HTML→video), GSAP skill families (split by function), Remotion templates
- **Marketing & CRO**: landing page audits, funnel optimization, copywriting guardrails
- **Cost Discipline**: model-routing guards, Haiku/Sonnet delegation rules, token-aware architecture patterns
- **Multi-Agent Patterns**: map-reduce, debate, pipeline, tournament, watchdog for efficient distributed work
- **Developer Experience**: lean hook system, organized expertise YAML, skill inheritance, comprehensive observability

## Architecture

```
User Request
  ├─ Plugin Package (.claude-plugin/plugin.json)
  │   ├─ 10 skills
  │   ├─ 5 agents
  │   ├─ 4 commands
  │   └─ 4 hooks
  │
  ├─ Execution layer
  │   ├─ Interactive mode (GUI)
  │   ├─ Headless mode (batch, cron, CI/CD)
  │   └─ Swarm mode (multi-agent patterns)
  │
  ├─ Safety gates
  │   ├─ Tool allowlist
  │   ├─ Cost limit
  │   ├─ Timeout control
  │   └─ Secret redaction
  │
  ├─ Telemetry collection
  │   ├─ Metrics (Prometheus)
  │   ├─ Logs (Loki)
  │   └─ Alerts (Prometheus rules)
  │
  └─ Monitoring (Grafana)
      ├─ Cost dashboard
      ├─ Performance metrics
      └─ Alerting
```

## Repo Structure

```
lukasdlouhy-claude-ecosystem/
├── .claude-plugin/
│   └── plugin.json
├── scripts/
│   ├── build-plugin.sh
│   ├── publish-plugin.sh
│   ├── eval-dashboard.sh
│   ├── screenshot-competitors.sh
│   └── responsive-audit.sh
├── agents/
│   └── SWARM_PATTERNS.md
├── commands/
│   ├── swarm.md
│   └── eval-status.md
├── docs/
│   ├── PLUGIN_PUBLISHING.md
│   ├── HEADLESS_MODE.md
│   ├── TOP_001_PERCENT_GUIDE.md
│   ├── EVAL_RESULTS.md
│   └── WAVE4_SUMMARY.md
├── evals/
│   ├── runs/
│   │   └── 2026-04-26-first-run.json
│   ├── datasets/
│   │   ├── copywriting.jsonl
│   │   ├── lean-refactor.jsonl
│   │   └── 4 more datasets (staged)
│   └── baselines/
│       ├── copy-strategist-baseline.json
│       └── lean-refactor-baseline.json
├── experiments/
│   └── prompt-variants/
│       ├── copy-strategist-v1-standard.yaml
│       ├── copy-strategist-v2-persona-injection.yaml
│       ├── lean-refactor-v1-standard.yaml
│       └── lean-refactor-v2-language-guards.yaml
├── telemetry/
│   ├── docker-compose.yml
│   ├── otel-collector.yaml
│   ├── prometheus-rules.yaml
│   ├── grafana-dashboard.json
│   └── README.md
├── rules/
├── hooks/
│   ├── long-task-notification.sh
│   └── analytics-track.sh
├── expertise/
│   ├── instagram.yaml
│   ├── tiktok.yaml
│   ├── youtube.yaml
│   ├── brand-voice.yaml
│   └── campaign-planning.yaml
└── skills/
    ├── voice-generation.md
    ├── visual-synthesis.md
    └── form-validation.qa.md
```

## Quick Start (10 commands)

```bash
# 1. Clone repo
git clone https://github.com/lukasdlouhy/claude-ecosystem.git
cd lukasdlouhy-claude-ecosystem

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Start telemetry stack
cd telemetry && docker compose up -d && cd ..

# 4. Access Grafana
open http://localhost:3000  # admin / admin

# 5. Install plugin locally
claude plugin install .

# 6. Test map-reduce pattern
/swarm map-reduce "Research CRO best practices" \
  --subqueries 5 --model-research haiku --model-synthesize sonnet

# 7. Schedule nightly audit
0 2 * * * /path/to/headless-runner.sh prompts/nightly-audit.txt haiku 10 json

# 8. Deploy to production
git tag v1.0.0 && git push origin v1.0.0 && scripts/publish-plugin.sh

# 9. Monitor costs in real-time
open http://localhost:3000/d/claude-code-prod

# 10. Set cost alert
# In Grafana: Alert Rules → New Rule → claude_cost_usd_total > 50
```

## Top 0.01% Features

1. **Intelligent cost optimization** — Map-reduce pattern with Haiku + Sonnet = 70% savings. Nightly audit costs $0.40 instead of $1.50.
2. **Production-grade observability** — OpenTelemetry → Prometheus + Grafana/Loki. Automatic secret redaction in logs.
3. **Multi-agent orchestration** — Five swarm patterns (map-reduce, debate, pipeline, tournament, watchdog) for parallel research, debates, pipelines, creative selection, and automatic recovery.
4. **Safety gates everywhere** — Tool allowlists, cost limits ($10/run), timeout controls, skill validation.
5. **Enterprise plugin distribution** — Semantic versioning, SHA256 checksums, GitHub releases with changelog.
6. **CI/CD readiness** — GitHub Actions validates skills before merge. Headless evaluation runs weekly.
7. **Cost discipline framework** — Haiku ($0.08/MTok), Sonnet ($0.15/MTok), Opus ($3/MTok). Baseline: $7.44/month.
8. **Zero-config telemetry** — Cloud: export CLAUDE_CODE_OTEL_ENDPOINT + key. Local: docker compose up.
9. **Headless batch patterns** — Five use cases (audit, skill eval, cost report, CI/CD, batch generation) with cron schedules.
10. **Comprehensive documentation** — Plugin publishing, operational excellence, swarm patterns, headless mode, cost estimates.
11. **Eval framework with live baselines** — Multi-skill evaluation, regression detection, A/B prompt variants. First run: 8.83 avg, 92.6% pass rate.
12. **Content pipeline integrations** — ElevenLabs voice synthesis, Replicate image generation, PostHog analytics tracking.
13. **Browser automation QA** — Competitor screenshot suite, form-fill testing, responsive design validation with Playwright.
14. **Long-task notifications** — Desktop alerts + Slack webhook for >30s skill execution (video generation progress updates).

## Cost Profile

| Component | Est. USD/Month |
|-----------|-----------------|
| Nightly audit (5 pages × 4) | $1.60 |
| Weekly skill eval (6 cases × 2 models) | $6.50 |
| Daily cost report (30 days) | $7.20 |
| Analytics tracking + notifications | $0.50 |
| **Total (post-Wave 4)** | **$15.80** |
| Baseline (pre-Wave 4) | $14.80 |
| **Overhead per interactive session** | **<5%** |

See **[TOP_001_PERCENT_GUIDE.md](./docs/TOP_001_PERCENT_GUIDE.md)** for 15-step setup checklist, monthly maintenance schedule, and upgrade philosophy.

## Next Steps

1. **Read the guides** — Start with [TOP_001_PERCENT_GUIDE.md](./docs/TOP_001_PERCENT_GUIDE.md) for setup
2. **Start telemetry** — `cd telemetry && docker compose up -d`
3. **Test patterns** — Try map-reduce or debate from [SWARM_PATTERNS.md](./agents/SWARM_PATTERNS.md)
4. **Schedule jobs** — Add cron entry from [HEADLESS_MODE.md](./docs/HEADLESS_MODE.md)
5. **Release version** — Follow [PLUGIN_PUBLISHING.md](./docs/PLUGIN_PUBLISHING.md) to tag and deploy

## Credits

Thanks to **Filip Dopita** ([@filipdopita-tech](https://github.com/filipdopita-tech)) for the peer protocol template and proof-of-concept.

## License

MIT. Copy, fork, adapt freely. Attribution appreciated.

---

**Questions?** Open an issue. See [COLLABORATION.md](./COLLABORATION.md) to cherry-pick items or share your ecosystem.

Last updated: 2026-04-26
