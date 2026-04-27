# Monitor Tool — Reference Guide

Monitor is a Claude Code built-in tool (GA as of Q2 2026). It streams stdout from a
background process into the conversation as live notifications — one notification per
stdout line (lines within 200ms are batched). The tool is available in this workspace.

## Tool Spec (verified from live schema)

```
Monitor(
  command:     string,   // shell command; each stdout line = one notification
  description: string,   // shown in every notification — make it specific
  timeout_ms:  number,   // kill deadline; default 300000, max 3600000; ignored when persistent
  persistent:  boolean   // true = run for session lifetime; stop with TaskStop
)
```

Key behaviors:
- Only stdout reaches the notification stream. Stderr goes to an output file (readable via Read).
  Merge with `2>&1` in the command if you need stderr in notifications.
- Exit ends the watch; exit code is reported.
- Lines within 200ms are batched into a single notification.
- Monitors emitting too many events are auto-stopped. Restart with a tighter filter.
- The command runs in the same shell environment as Bash.

## When to Use Monitor vs run_in_background vs blocking Bash

| Situation                                          | Right tool                              |
|----------------------------------------------------|-----------------------------------------|
| Wait for one event, then done ("tell me when ready") | Bash with run_in_background + until loop |
| One notification per occurrence, indefinitely     | Monitor with persistent: true           |
| One notification per occurrence, until known end  | Monitor with appropriate timeout_ms     |
| Task takes < 10s and you need the output           | Blocking Bash (no background needed)    |
| Task takes < 2 min, you need result before next step | Bash with run_in_background, then Read  |
| Task takes > 2 min, you want to keep working      | Monitor (net win — see cost section)    |

Do NOT use Monitor for a single notification — use Bash run_in_background instead.
`tail -f log | grep -m 1 pattern` does not fix this: if the log goes quiet after the
match, tail never receives SIGPIPE and the pipeline hangs.

## Cost Profile

Each Monitor notification = one tool call in the conversation context.

| Task duration | Notifications/min | Monitor cost vs blocking | Verdict           |
|---------------|-------------------|--------------------------|-------------------|
| < 30s         | N/A               | Monitor adds overhead    | Use blocking Bash |
| 30s – 2 min   | ~5–20             | Roughly equal            | Either works      |
| 2 – 10 min    | ~10–50            | Monitor saves idle tokens | Net win           |
| > 10 min      | ~10–50            | Clear win                | Use Monitor       |

The "idle wait" cost: blocking on a 10-minute build keeps the context open and charges
input tokens on every model call during that wait. Monitor externalizes the wait; the
model is idle between notifications and only pays for the notification lines themselves.

Filter aggressively. A Docker build emitting raw layer pulls at 50 lines/sec will
trigger auto-stop. Use `grep --line-buffered` with a tight alternation pattern. Always
include failure signatures — silence from a filter that only watches for success looks
identical to a process that is still running.

## Integration with notify-on-long-task Hook

If the ecosystem has a `notify-on-long-task` hook in settings.json, Monitor is
complementary, not a replacement. The hook fires on Bash completion; Monitor fires
on individual stdout lines during execution. Use both:

1. Arm Monitor for per-event progress during the task.
2. Let the hook send a desktop notification on task completion.

This gives you in-chat progress + a system-level ping when done.

## Script Quality Checklist

Before arming Monitor, verify:

- [ ] `grep --line-buffered` used in all pipes (plain grep buffers output, delaying events by minutes)
- [ ] Failure signatures included in grep alternation (not just success)
- [ ] Poll loops use `|| true` on network calls (one failed curl should not kill the monitor)
- [ ] Poll interval: 0.5–1s for local checks, 30s+ for remote APIs
- [ ] `description` is specific ("HyperFrames render: main" not "watching logs")
- [ ] `timeout_ms` is set to 1.5× expected duration, not left at default 300000 for long tasks
- [ ] Unbounded commands (`tail -f`, `while true`) use `persistent: true`

## Examples

### HyperFrames Render Watch

```bash
# Spawn render
LOG=/tmp/hf-render-$$.log
hyperframes-cli render --composition main --output ./renders/ > "$LOG" 2>&1 &

# Arm Monitor
# timeout_ms = estimated render time * 1.5
```

```
Monitor(
  command: "tail -f /tmp/hf-render-<pid>.log | grep -E --line-buffered 'frame [0-9]+/[0-9]+|encoding|output written|ERROR|FAILED|exit [1-9]'",
  description: "HyperFrames render: main",
  timeout_ms: 1800000,
  persistent: false
)
```

Invoked by: `monitor-render` skill. Triggers: "watch render", "monitor render".

### Vercel Deploy Watch

```bash
LOG=/tmp/deploy-$(date +%s).log
vercel deploy --prod > "$LOG" 2>&1 &
```

```
Monitor(
  command: "tail -f /tmp/deploy-<ts>.log | grep -E --line-buffered 'Production:|Ready|Error:|Build failed|exit [1-9]'",
  description: "deploy: vercel --prod",
  timeout_ms: 600000,
  persistent: false
)
```

Invoked by: `monitor-deploy` skill. Triggers: "watch deploy", "monitor deploy".

### npm Build Watch

```bash
LOG=/tmp/build-$(date +%s).log
npm run build > "$LOG" 2>&1 &
```

```
Monitor(
  command: "tail -f /tmp/build-<ts>.log | grep -E --line-buffered 'error TS|ERROR|Compiled|Build complete|chunks|failed'",
  description: "build: npm run build",
  timeout_ms: 600000,
  persistent: false
)
```

Invoked by: `monitor-build` skill. Triggers: "watch build", "monitor build".

### Generic /watch Command

```
/watch <any shell command>
```

Defined in `commands/watch.md`. Spawns $ARGUMENTS in background, arms Monitor with a
generic filter covering error/warning/complete patterns. Adjust the filter if output
is too noisy or too silent.

## Available Skills and Commands

| Artifact                              | Path                                             | Trigger phrases                              |
|---------------------------------------|--------------------------------------------------|----------------------------------------------|
| skill: monitor-render                 | skills/monitor-render/SKILL.md                  | "watch render", "monitor render"             |
| skill: monitor-deploy                 | skills/monitor-deploy/SKILL.md                  | "watch deploy", "monitor deploy"             |
| skill: monitor-build                  | skills/monitor-build/SKILL.md                   | "watch build", "monitor build"               |
| command: /watch                       | commands/watch.md                               | /watch <command>                             |

## Stopping a Monitor

Call `TaskStop` with the monitor's task ID to cancel early.
For `persistent: true` monitors, TaskStop is the only way to stop (the session ending
also stops them).

If you lose the task ID, a persistent monitor will stop when the session ends. There
is no `Monitor list` command — track IDs if you arm multiple monitors in one session.

## Known Limitations (as of Q2 2026)

- No way to query running monitors or list active task IDs after the fact.
- Stderr does not trigger notifications — merge with `2>&1` if needed.
- Auto-stop threshold for high-volume output is not documented precisely; empirically
  it triggers around 50+ lines/sec sustained. Filter before it reaches Monitor.
- `timeout_ms` max is 3600000 (1 hour). For truly open-ended watches, use `persistent: true`.
