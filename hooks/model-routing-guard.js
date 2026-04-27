#!/usr/bin/env node
// model-routing-guard.js — PreToolUse (Agent): advisory warning when expensive subagent types use Opus

const fs = require('fs');
const path = require('path');
const os = require('os');

const LOG_DIR = path.join(os.homedir(), '.claude', 'logs');
const LOG_FILE = path.join(LOG_DIR, 'model-routing.log');

// Ensure log directory exists
try { fs.mkdirSync(LOG_DIR, { recursive: true }); } catch {}

// Read all stdin then process
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  // Parse JSON input; on failure exit 0 — never block falsely
  let payload;
  try {
    payload = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const toolInput = payload?.tool_input ?? {};
  const subagentType = (toolInput.subagent_type ?? '').toLowerCase().trim();
  const model = (toolInput.model ?? '').toLowerCase().trim();

  // Subagent types that should NOT run on Opus
  const expensiveTypes = new Set([
    'general-purpose',
    'explore',
    'plan',
    'code-reviewer',
  ]);

  const isExpensiveType = expensiveTypes.has(subagentType);
  // Treat missing model OR explicit "opus" as a concern
  const isOpusOrUnset = model === '' || model.includes('opus');

  if (isExpensiveType && isOpusOrUnset) {
    const timestamp = new Date().toISOString();
    const currentModel = model === '' ? '(not set — defaults to parent = Opus on main thread)' : model;
    const isUnset = model === '';
    const severity = isUnset ? 'BLOCKED' : 'ADVISORY';
    const msg = `[${severity}] ${timestamp} | subagent_type=${subagentType} | model=${currentModel}`;

    try { fs.appendFileSync(LOG_FILE, msg + '\n'); } catch {}

    if (isUnset) {
      // BLOCK: missing model is a silent cost leak (363 violations in 16 sessions)
      process.stderr.write(
        `\n[model-routing-guard] BLOCKED: subagent_type="${subagentType}" launched without explicit model parameter.\n` +
        `  This silently inherits parent model (= Opus on main thread) and burns budget.\n` +
        `  Per CLAUDE.md routing rules:\n` +
        `    - Default: model: "sonnet" (covers 95% of delegated work)\n` +
        `    - Mechanical (grep, count, list, web fetch): model: "haiku"\n` +
        `    - Plans / critical code / high-stakes synthesis: model: "opus" (justify inline)\n` +
        `  Re-launch with explicit model parameter.\n` +
        `  Logged to: ${LOG_FILE}\n\n`
      );
      process.exit(2);
    }

    // Explicit opus = advisory only (user may have justified it)
    process.stderr.write(
      `\n[model-routing-guard] ADVISORY: subagent_type="${subagentType}" running on Opus.\n` +
      `  Acceptable for plans / critical code / high-stakes synthesis.\n` +
      `  Logged to: ${LOG_FILE}\n\n`
    );
  }

  process.exit(0);
});
