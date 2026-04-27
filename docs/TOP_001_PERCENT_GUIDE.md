# Top 0.01% Ecosystem Guide

Complete feature inventory and operational excellence checklist for lukasdlouhy-claude-ecosystem production deployment.

---

## Feature Inventory

### Core Infrastructure (10 features)
1. **Plugin packaging system** — Automated tarball builds with SHA256, versioning, changelog integration
2. **GitHub release publishing** — Semantic versioning, release notes generation, multi-registry support
3. **Production telemetry** — OpenTelemetry collector with Prometheus metrics, Grafana dashboards, Loki logs
4. **Cost tracking dashboard** — Real-time spend monitoring, hourly/daily aggregation, model-based breakdown
5. **Error rate alerting** — Prometheus rules for token spikes, error thresholds, hook blocking detection
6. **Multi-agent orchestration** — Five swarm patterns (map-reduce, debate, pipeline, tournament, watchdog)
7. **Headless execution mode** — Batch jobs, CI/CD integration, scheduled tasks with tool allowlists
8. **Safety gates** — Tool allowlists, cost limits, timeout controls, secret redaction in logs
9. **Skill framework** — Standardized skill registration, hyperframe-cli integration, expert domain routing
10. **Performance monitoring** — Execution histograms, latency percentiles, skill invocation tracking

### Expert Domains (4 agents)
- `researcher-haiku-delegate` — Narrow research tasks, fast iteration, cost-optimized
- `synthesizer-sonnet` — Synthesis, analysis, decision support
- `video-reviewer` — HeyGen/Remotion content quality audit
- `cro-strategist` — Landing page optimization, funnel analysis

### Advanced Capabilities (6 patterns)
1. Map-Reduce: Parallel research (5 Haiku) → synthesis (Sonnet) = 70% cost savings
2. Debate: Adversarial evaluation (2 Sonnet + Opus judge) for high-stakes decisions
3. Pipeline: Sequential transformation (3-stage Haiku chain) for content generation
4. Tournament: Multi-candidate selection (3-4 Haiku + Sonnet scorer) for creative work
5. Watchdog: Long-running tasks with health monitoring and automatic recovery
6. Headless batch: Non-interactive execution for nightly audits, skill evaluation, cost reports

### Observability Stack
- **Prometheus** — 30-day retention, 10+ metrics, 6 recording rules, 4 alert rules
- **Grafana** — 8-panel dashboard: tokens/hour, daily cost, tool latency, error rate, skill invocations, hook fires, agent execution heatmap, memory usage
- **Loki** — Structured logs with secret redaction (api_key, prompt_content, tokens)
- **OTel Collector** — gRPC/HTTP receivers, batch processing, attributes redaction, Prometheus/Loki exporters

### CI/CD Integration
- Plugin build automation (scripts/build-plugin.sh)
- Release publishing (scripts/publish-plugin.sh)
- GitHub Actions workflow (validates skills before deployment)
- Headless skill evaluation (weekly, scored against baseline)

---

## Getting Started Checklist (15 Steps)

1. **Clone repository**
   ```bash
   git clone https://github.com/lukasdlouhy/claude-ecosystem.git
   cd claude-ecosystem
   chmod +x scripts/*.sh
   ```

2. **Install Claude Code CLI** — Download from Anthropic, add to PATH

3. **Verify plugin manifest** — `cat .claude-plugin/plugin.json | jq .version`

4. **Set API keys** — Export ANTHROPIC_API_KEY, HEY_GEN_API_KEY, etc.

5. **Start telemetry stack** — `cd telemetry && docker compose up -d`

6. **Access Grafana** — http://localhost:3000 (admin/admin)

7. **Load dashboard** — Import grafana-dashboard.json in Grafana UI

8. **Verify Prometheus scrape** — http://localhost:9090/targets (check "Up" status)

9. **Test plugin locally** — `claude plugin install .`

10. **Run skill validation** — `claude /swarm pipeline "Test all skills" --stages "Run,Score,Log" --model haiku`

11. **Enable headless mode** — `export CLAUDE_CODE_TELEMETRY_ENABLED=true`

12. **Schedule nightly audit** — Add cron: `0 2 * * * /path/to/headless-runner.sh prompts/nightly-audit.txt haiku 10 json`

13. **Set cost alert** — Configure Grafana alert for claude_cost_usd_total > $50/day

14. **Tag production release** — `git tag v1.0.0 && git push origin v1.0.0`

15. **Publish plugin** — `scripts/publish-plugin.sh` (validates tag, builds tarball, creates GitHub release)

---

## Maintenance Schedule

### Daily (automated)
- Cost report generation (headless-runner.sh, 00:00 UTC)
- Prometheus rule evaluation (TokenSpike, ErrorRateHigh, HookBlocking, CostThreshold)
- Grafana dashboard auto-refresh (5-minute interval)

### Weekly (manual review)
- Check Prometheus targets for missed scrapes
- Review top 5 most costly skills in Grafana
- Audit error logs (Loki: `error_type != null`)
- Validate plugin version in manifest vs git tags

### Monthly (maintenance)
- Rotate API keys, update OTEL_EXPORTER_OTLP_HEADERS
- Audit redaction rules in otel-collector.yaml (confirm sensitive fields match environment)
- Export usage reports from Grafana
- Review alert thresholds, adjust based on growth

### Quarterly (strategic)
- Benchmark model costs (haiku vs sonnet vs opus) against baseline
- Optimize dashboard queries (slow queries >1s latency)
- Prune Prometheus data older than 30 days
- Update CHANGELOG.md, plan next major version
- Audit skill framework for deprecated skills

---

## Upgrade Philosophy

### Semantic Versioning Rules
- **MAJOR (X.0.0)** — Breaking changes to plugin manifest, incompatible skill signatures, new required MCP servers
- **MINOR (1.X.0)** — New skills, new agents, new swarm patterns, backward compatible
- **PATCH (1.0.X)** — Bug fixes, documentation, telemetry improvements, no API changes

### Release Process
1. Update CHANGELOG.md with added/changed/fixed sections
2. Bump version in .claude-plugin/plugin.json
3. Commit: `git commit -am "Release v1.1.0"`
4. Tag: `git tag v1.1.0`
5. Push: `git push origin main v1.1.0`
6. Publish: `scripts/publish-plugin.sh` (auto-creates GitHub release with CHANGELOG excerpt)

### Rollback Procedure
```bash
git tag -d v1.1.0
git push origin :v1.1.0
git revert HEAD
git tag v1.0.1
git push origin main v1.0.1
scripts/publish-plugin.sh
```

---

## Cost Per Feature Estimate

| Feature | Model | Tokens/Month | Est. USD/Month |
|---------|-------|--------------|-----------------|
| Nightly audit (5 pages) | Haiku | 50K | $0.40 |
| Weekly skill eval (10 skills) | Sonnet | 100K | $1.50 |
| Daily cost report | Haiku | 30K | $0.24 |
| Map-reduce research (4 subqueries) | Haiku+Sonnet | 80K | $0.95 |
| Debate decision (high-stakes) | Sonnet+Opus | 150K | $3.50 |
| Video script tournament (3 candidates) | Haiku+Sonnet | 60K | $0.85 |
| **Total baseline** | | **470K** | **$7.44** |

**Cost optimization strategies:**
- Use Haiku for research (80% cheaper than Sonnet)
- Limit swarm size to 3-5 agents (diminishing returns beyond)
- Enable cost-limit safety gate (abort if exceeds $10/run)
- Batch similar jobs (map-reduce cheaper than sequential)
- Cache skill contexts (avoid re-evaluating same skills weekly)

---

## Performance Targets

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Tokens/hour (peak) | <500k | >500k (TokenSpike alert) |
| Tool latency p99 | <2s | >3s (manual review) |
| Error rate | <2% | >5% (ErrorRateHigh alert) |
| Hook blocking rate | <5/hour | >10/hour (HookBlocking alert) |
| Daily cost | <$25 | >$50 (CostThreshold alert) |
| Skill invocation success | >98% | <95% (investigate failures) |
| Agent execution time (median) | <60s | >120s (profile for bottlenecks) |

---

## Troubleshooting Reference

**Plugin won't install?** Check manifest version, verify SHA256 matches tarball.

**Telemetry not showing in Grafana?** Verify OTel collector scrape interval (should be 10s), check Prometheus targets at http://localhost:9090/targets.

**Cost spike?** Review claude_cost_usd_total in Prometheus, identify top-consuming skills, reduce model size or max-turns.

**Agent spawn failures?** Check `.claude-plugin/plugin.json` for registered agents, verify agent prompts are deterministic, add error handling to prompt.

**Headless timeout?** Increase --timeout flag, reduce task scope, split into smaller batches.

---

## Resources

- [Plugin Publishing Guide](./PLUGIN_PUBLISHING.md)
- [Headless Mode Patterns](./HEADLESS_MODE.md)
- [Multi-Agent Swarm Patterns](../agents/SWARM_PATTERNS.md)
- [Swarm Command Reference](../commands/swarm.md)
- [Production Telemetry Setup](../telemetry/README.md)

---

Last updated: 2026-04-26
