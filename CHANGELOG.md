# Changelog

All notable changes to the Lukáš Dlouhý Claude Code Ecosystem are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-04-26

### Added

- **Plugin packaging system**: Complete `.claude-plugin/` manifest with skill/agent/hook registry. Distributable as installable plugin via GitHub releases.
- **Security pipeline**: Pre-push leak scanner (`hooks/pre-push-leak-scan`), secret redaction in logs, credentials never exported in telemetry.
- **Hierarchical agent patterns**: Map-reduce, debate, pipeline, tournament, watchdog. Multi-agent swarm orchestration for research, synthesis, and validation.
- **Vector memory system**: Persistent episodic memory with semantic search. Skill eval results and past recommendations queryable across sessions.
- **Custom MCP integration**: Internal vector store + knowledge graph. Enables skills to retrieve domain context without external API calls.
- **CI/CD automation**: GitHub Actions for skill eval, cost audits, dependency updates. Pre-commit hooks for leak detection and test coverage.
- **Observability framework**: OpenTelemetry exporter, Prometheus metrics, Grafana dashboards. Local docker-compose stack with Loki logs, SigNoz integration.
- **Cost discipline system**: Token budgets by model, daily spend alerts, model-routing guards. Prevents Opus overspend on exploratory research.
- **Skill framework**: 16 skill families (GSAP timeline/easing/morphing, HyperFrames CLI, landing page audit, CRO funnel optimization, copywriting guardrails, model router).
- **Expert domains**: YAML expertise configs for video production, animation, marketing, cost optimization, and AI agent design.
- **Decision rules**: Cost-discipline, model-routing-guard, security-pipeline, skill-eval-framework rules. Codified governance for AI development.
- **Production telemetry**: Structured logs, metrics per-tool, error tracking. Dashboard queries for daily cost/hour, tool latency p50/p99, error rates.
- **Headless mode patterns**: Batch job templates, cron scheduling, output format control (JSON/text/stream). Examples: nightly audits, weekly skill evals.
- **Plugin publishing guide**: Semver versioning, changelog format, release automation via GitHub. Instructions for other teams to cherry-pick.
- **Top 0.01% documentation**: Capstone guide covering feature inventory, getting started (15 steps), maintenance schedule, upgrade philosophy.
- **Ecosystem comparison**: Side-by-side benchmark vs peer ecosystems (Filip Dopita). Highlights cost savings, eval speed, architectural patterns.
- **COLLABORATION.md protocol**: Framework for peer cherry-picking and ecosystem sharing under MIT license.

### Changed

- Consolidated skill families under unified inheritance model. Easing/timeline/morphing GSAP skills now share common templates.
- Refactored cost-discipline rules to support daily budgets, per-model thresholds, and real-time alerts.
- Updated README with new sections: "What's in this repo", architecture diagram, quick start (10 commands), top 0.01% features.

### Removed

- Deprecated old skill versioning system. Now using plugin.json registry.

---

[Unreleased]: https://github.com/lukasdlouhy/claude-ecosystem-setup/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/lukasdlouhy/claude-ecosystem-setup/releases/tag/v1.0.0
