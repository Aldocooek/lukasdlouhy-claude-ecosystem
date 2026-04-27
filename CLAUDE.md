# Global instructions

## Model routing for delegated work

Do not do research, search, audit, or web work yourself on Opus. Delegate via the `Agent` tool and pass an explicit `model` override. Rules:

- **Research / codebase exploration / audit** (Explore, Plan, general-purpose, code-reviewer, or any multi-file reading, grep-heavy investigation, architectural review): spawn as subagent with `model: "sonnet"` or `model: "haiku"`. Use Haiku when the task is mechanical (listing files, counting, simple greps); Sonnet when judgment is needed (reviewing logic, writing a plan).
- **WebSearch / WebFetch / Firecrawl / any web-scraping MCP**: always delegate to a subagent with `model: "haiku"`. Never call these tools directly from the main thread if the main model is Opus or Sonnet — the output lands in the expensive context.
- **Implementation / editing** can stay on the main agent's model.

Why: prior sessions on this machine ran research + audit + web work directly from Opus 4.7, pumping tool output into the expensive context. Estimated overspend in the tens of USD on `davinci-automation` alone.

How to apply: before using Bash (grep/find), Read (multi-file), WebSearch, or WebFetch for an exploratory/investigative purpose, stop and spawn an Agent with the appropriate `model` override instead. Exception: a single targeted Read/grep with a known path is fine — the rule is about bulk exploration.
