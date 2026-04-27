# Claude Managed Agents — Integration Guide

Status: PUBLIC BETA as of April 8, 2026. No allowlist required. Standard API key sufficient.
Beta header required: `managed-agents-2026-04-01`.
Memory sub-feature added April 23, 2026 under the same header.

---

## What Managed Agents Are

The standard Claude API is stateless: you send a message, get a response, manage all state client-side. Managed Agents decouple agent logic from the runtime layer. Anthropic's platform handles:

- **Sandboxed execution environment** — each session runs in an isolated container you configure
- **State continuity** — session history, memory, and in-flight tool calls persist server-side
- **Credential injection** — secrets stored in Vaults; agents receive credentials without your code ever holding them in-process
- **Tool orchestration** — built-in tools, MCP servers, and custom tools wired server-side
- **Event streaming** — SSE stream of agent thinking, tool calls, responses, and status transitions
- **Managed memory** — cross-session memory storage in beta (April 23, 2026)

The agent is a persistent, versioned entity. Environments are reusable execution configurations. Sessions are the actual running instances.

---

## When to Use Managed Agents vs In-Process Subagents

| Dimension              | In-process subagent (Agent tool / SDK) | Managed Agent                         |
|------------------------|----------------------------------------|---------------------------------------|
| Latency                | Lower (no round-trip to orchestration) | Higher (network + container startup)  |
| State management       | You own it (in-context or DB)          | Platform owns it                      |
| Credential handling    | Your code holds secrets                | Vault — agent never sees raw key      |
| Session duration       | Capped by context window               | Unbounded; resumes across reconnects  |
| Cost visibility        | Token-level                            | Token + platform session fee          |
| Vendor lock-in         | None (SDK abstraction)                 | Anthropic platform                    |
| Long-running tasks     | Fragile (context fills, timeouts)      | First-class; designed for this        |
| Scheduled/cron agents  | Requires external scheduler + state DB | Native (sessions are durable)         |
| Credential rotation    | Redeploy your service                  | Update Vault; no code change          |
| Audit trail            | Your responsibility                    | Platform-managed event log            |

**Use Managed Agents when:**
- The task runs longer than one context window
- You need credential isolation (OAuth tokens, API keys for external services)
- The task must survive network interruptions or process restarts
- You want an audit trail without building one
- You need cross-session persistent memory

**Stay with in-process subagents when:**
- Latency is critical (sub-second tool calls in a hot path)
- The task fits comfortably in one context window
- You want zero platform dependency
- You are running in an air-gapped or on-prem environment

---

## API Summary

All endpoints require:
```
anthropic-beta: managed-agents-2026-04-01
x-api-key: $ANTHROPIC_API_KEY
content-type: application/json
```

### Agents — `POST /v1/beta/agents`

Define reusable agent personas with model, system prompt, toolsets, and skills.

```python
agent = client.beta.agents.create(
    name="weekly-auditor",
    model="claude-sonnet-4-6",
    system="You are an ecosystem auditor...",
    toolsets=[
        {"type": "agent_toolset_20260401", "config": {"tools": ["web_search", "file_operations"]}},
        {"type": "mcp", "name": "github", "url": "https://api.githubcopilot.com/mcp/",
         "config": {"tools": ["list_repos", "create_pull_request"]}}
    ],
    skills=[{"type": "anthropic_skill", "id": "skill-id"}]
)
# Returns: agent.id, agent.version
```

CRUD: `retrieve(agent_id)`, `list()`, `update(agent_id, ...)`.

### Environments — `POST /v1/beta/environments`

Environments define sandbox configuration: network policy, container settings, mounted credentials.

```python
env = client.beta.environments.create(
    name="audit-sandbox",
    network_policy={"type": "unrestricted_network"}
    # or: {"type": "limited_network"} for allowlisted-only outbound
)
```

CRUD: `retrieve`, `list`, `update`, `delete`.

### Vaults — `POST /v1/beta/vaults`

Secure credential stores. Agents reference credentials by ID; the raw secret never leaves the platform.

```python
vault = client.beta.vaults.create(display_name="competitor-scrape-creds")

# Add a static bearer token
client.beta.vaults.credentials.create(
    vault.id,
    display_name="firecrawl-key",
    auth={"type": "static_bearer", "token": os.environ["FIRECRAWL_API_KEY"]}
)

# Add OAuth2
client.beta.vaults.credentials.create(
    vault.id,
    display_name="github-oauth",
    auth={
        "type": "mcp_oauth",
        "client_id": "...",
        "client_secret": "...",
        "token_endpoint": "https://github.com/login/oauth/access_token",
        "token_endpoint_auth": "post"
    }
)
```

### Sessions — `POST /v1/beta/sessions`

Sessions are running instances of an agent in an environment.

```python
session = client.beta.sessions.create(
    environment_id=env.id,
    agent={"type": "agent", "id": agent.id, "version": agent.version}
)
# Returns: session.id
```

### Events — Sending and Streaming

Send a task to a session:

```python
client.beta.sessions.events.send(
    session.id,
    events=[{
        "type": "user.message",
        "content": [{"type": "text", "text": "Run the weekly audit now."}]
    }]
)
```

Stream the response (SSE):

```python
with client.beta.sessions.events.stream(session.id) as stream:
    for event in stream:
        if event.type == "agent.message":
            print(event.content)
        elif event.type == "agent.tool_use":
            print(f"Tool: {event.name}")
        elif event.type in ("session.status_idle", "session.status_terminated"):
            break
```

Key event types:
- `user.message` — send task input
- `user.tool_confirmation` — approve tool execution (if confirmation mode enabled)
- `user.custom_tool_result` — provide result for a custom tool the agent invoked
- `agent.message` — agent text response
- `agent.thinking` — extended thinking blocks
- `agent.tool_use` / `agent.mcp_tool_use` / `agent.custom_tool_use`
- `session.status_idle` — agent finished turn, awaiting input
- `session.status_running` — agent is processing
- `session.status_rescheduled` — session paused, will resume
- `session.status_terminated` — session ended
- `session.error` — error with error type (see below)

Error types: `ModelRateLimitedError`, `ModelOverloadedError`, `MCPConnectionFailedError`, `MCPAuthenticationFailedError`, `BillingError`, `UnknownError`.

### Resources — Session Artifacts

Files produced or consumed during a session:

```python
client.beta.sessions.resources.add(session.id, resource)
resources = client.beta.sessions.resources.list(session.id)
result = client.beta.sessions.resources.retrieve_response(session.id, resource_id)
```

---

## Auth Flow and Credential Injection Patterns

### Pattern 1: Static API key for external service

1. Create a Vault once.
2. Create a `static_bearer` credential in the Vault.
3. Reference the credential in the Environment or Agent toolset config.
4. The agent receives the credential at session start; your orchestration code never holds it.

### Pattern 2: OAuth2 for MCP server

1. Create Vault + `mcp_oauth` credential with `client_id`, `client_secret`, `token_endpoint`.
2. Point MCP toolset at the OAuth credential.
3. Platform handles token refresh automatically.

### Pattern 3: Rotate credentials without code changes

1. Update the Vault credential via `client.beta.vaults.credentials.update(vault_id, cred_id, auth={...})`.
2. New sessions pick up the rotated credential immediately.
3. Existing sessions continue with their established tokens until they terminate.

---

## Cost Model

Managed Agents billing has two components:

1. **Token cost** — identical to standard Messages API pricing. Sonnet 4.6: $3/$15 per MTok in/out. Opus 4.7: $5/$25.
2. **Platform session fee** — Anthropic has not published a per-session or per-minute fee in the April 8 launch notes. Monitor your Console cost page. Assume a session overhead cost exists on top of token cost; actual rate TBD from your account.

Cost discipline for this ecosystem:
- Prefer Sonnet 4.6 for all managed sessions. Opus 4.7 only for tasks explicitly needing maximum reasoning.
- Use `budget_tokens` in `model_config` to cap per-session token spend:
  ```python
  model_config={"model": "claude-sonnet-4-6", "budget_tokens": 50000}
  ```
- Stream events and terminate sessions as soon as `session.status_idle` fires — idle sessions still accrue time if there is a session fee.

---

## Use Cases in Lukáš's Stack

### Long-running content audits

The existing `weekly-audit.yaml` routine runs `/audit-self all` via Claude Code's CronCreate scheduler. Pain points: context fills on large ecosystems, audit is lost if the session is interrupted.

With Managed Agents: create a persistent `auditor` agent with file-operations toolset. Dispatch the audit task to a session. Stream results back. Session survives reconnects; state is server-side. See `routines/managed-weekly-audit.yaml.template`.

### Scheduled competitor scrapes

The `competitor-snapshot` and `competitor-screenshot` skills require WebFetch/Firecrawl — expensive in the main Sonnet context per the cost rules. A Managed Agent session runs the scrape in an isolated sandbox, stores results as session resources, and returns only the summary. Main context receives a small payload.

### Persistent campaign monitoring

For ongoing campaigns: create one Managed Agent session per campaign. Each session holds campaign context (brief, past results, current status) server-side via managed memory. Trigger it periodically via Events API with new data. The session accumulates knowledge without rebuilding context from files on every run.

### Eval regression monitoring

The `eval-on-skill-change.yaml` routine currently runs on file change. A Managed Agent variant could run on a cron, hold the eval baseline in managed memory, and post a Slack message only on regression — without spinning up a Claude Code session at all.

---

## Migration: Existing Routines to Managed Agents

### `routines/weekly-audit.yaml`

| Current | Managed Agents equivalent |
|---------|--------------------------|
| CronCreate → Claude Code session | Anthropic cron trigger → Managed Session |
| Context holds audit state | Server-side session state |
| `tools_allowed: [Read, Bash, WebFetch, Write, Edit]` | `agent_toolset_20260401` with `file_operations`, `web_search` |
| Risk: context window fills | Risk: session fee; mitigated by `budget_tokens` |
| Max 25 iterations | No iteration cap; `budget_tokens` controls cost |

Activate template: `routines/managed-weekly-audit.yaml.template` (rename, remove `.template` suffix).

### `routines/eval-on-skill-change.yaml`

This is file-change-triggered, not time-based. Managed Agents sessions are event-driven (Events API), so this maps cleanly: a persistent `eval-runner` agent receives `user.message` with the changed file path, runs the eval, and emits the result. The session persists the baseline in managed memory, eliminating the baseline JSON files on disk for cross-session comparison.

Migration is lower priority — the current hook-based approach works and has no state continuity problem. Move to Managed Agents only if you want credential isolation for the GitHub PR step.

---

## Prerequisites Checklist

1. `ANTHROPIC_API_KEY` environment variable set
2. `anthropic` Python SDK >= 0.92.0 (added `client.beta.agents`, `client.beta.sessions`, `client.beta.vaults`, `client.beta.environments`)
3. Beta header `managed-agents-2026-04-01` on all requests
4. No allowlist required as of public beta (April 8, 2026)

Run `scripts/managed-agents-prereqs.sh` for automated readiness check.
