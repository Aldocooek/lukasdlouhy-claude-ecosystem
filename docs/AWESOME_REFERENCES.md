# Awesome References

Curated external resources for Claude Code mastery and MCP ecosystem.

## Core & Official

**https://github.com/hesreallyhim/awesome-claude-code**  
Master list of Claude Code tools, skills, and integrations. Check here first for latest community projects.

**https://github.com/anthropics/claude-code**  
Official Claude Code repository. Reference for API changes, release notes, and canonical examples.

**https://github.com/modelcontextprotocol/servers**  
Official MCP server collection. Includes Postgres, Slack, Linear, Figma reference implementations.

---

## Community Leaders

**https://github.com/filipdojcak/filip-dopita-repo**  
Filip Dopita's curated Claude Code extensions and automations. Steal his command patterns.

**https://github.com/citadelai/orchestrator**  
Citadel orchestrator for multi-agent workflows. Useful for coordinating subagents across projects.

**https://github.com/ColeMurray/claude-mem**  
claude-mem library for persistent session memory across Claude Code runs. Better than built-in compaction for long-running projects.

---

## Security & Auditing

**https://github.com/trailofbits/mcp-inspection-suite**  
Trail of Bits security skills for MCP validation. Use to audit MCP server permissions before installing.

**https://github.com/anthropics/anthropic-sdk-python**  
Anthropic SDK reference. Study prompt caching, batching, and token management patterns.

---

## MCP Ecosystem

**https://github.com/modelcontextprotocol/awesome-mcp-servers**  
Comprehensive MCP server registry. Filter by use case (database, API, file, integrations).

---

## What to Steal From Each

- **awesome-claude-code** — Latest community skills; copy /commands structure if building new ones
- **official claude-code** — Hook API spec; copy settings.json schema for type safety
- **Filip Dopita's repo** — Aggressive automation patterns; steal his slash command logic and worktree workflows
- **Citadel orchestrator** — Multi-agent routing logic; use if managing 5+ concurrent subagents
- **claude-mem** — Session persistence strategy; integrate if sessions exceed 2h
- **Trail of Bits security** — Permission allow-lists for MCPs; apply before production deployment
- **MCP awesome-list** — New server recommendations; add to MCP_RECOMMENDED.md quarterly
