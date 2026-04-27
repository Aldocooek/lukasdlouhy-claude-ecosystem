#!/usr/bin/env bash
# managed-agents-prereqs.sh
# Checks readiness for Anthropic Managed Agents integration.
# Safe to run without Managed Agents access -- exits 0 with clear report.
# Exit codes: 0=all pass, 1=failures present

set -euo pipefail

passes=0
failures=0
warnings=0

pass()  { echo "[PASS] $1"; ((passes++));   }
fail()  { echo "[FAIL] $1"; ((failures++)); }
warn()  { echo "[WARN] $1"; ((warnings++)); }

echo "=== Managed Agents Readiness Check ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# 1. ANTHROPIC_API_KEY
echo "-- API key"
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  fail "ANTHROPIC_API_KEY is not set. Export it before using /managed."
else
  KEY_PREFIX="${ANTHROPIC_API_KEY:0:10}"
  pass "ANTHROPIC_API_KEY is set (prefix: ${KEY_PREFIX}...)"
fi

# 2. Python 3
echo ""
echo "-- Python"
if command -v python3 &>/dev/null; then
  PY_VERSION=$(python3 --version 2>&1)
  pass "python3 found: $PY_VERSION"
else
  fail "python3 not found. Install Python 3.9+ to use the SDK."
fi

# 3. anthropic SDK version
echo ""
echo "-- anthropic SDK"
SDK_CHECK="SKIP"
if command -v python3 &>/dev/null; then
  SDK_CHECK=$(python3 -c "
import sys
try:
    import anthropic
    v = anthropic.__version__
    parts = list(map(int, v.split('.')))
    # Need >= 0.92.0
    if parts[0] > 0 or (parts[0] == 0 and parts[1] >= 92):
        print('OK:' + v)
    else:
        print('OLD:' + v)
except ImportError:
    print('MISSING')
" 2>&1)

  if [[ "$SDK_CHECK" == OK:* ]]; then
    pass "anthropic SDK ${SDK_CHECK#OK:} installed (>= 0.92.0 required)"
  elif [[ "$SDK_CHECK" == OLD:* ]]; then
    fail "anthropic SDK ${SDK_CHECK#OLD:} is too old. Run: pip install --upgrade anthropic"
  else
    fail "anthropic SDK not installed. Run: pip install anthropic"
  fi
else
  warn "Skipping SDK check -- python3 not available"
fi

# 4. curl available (used for API probe)
echo ""
echo "-- curl"
if command -v curl &>/dev/null; then
  pass "curl found: $(curl --version | head -1)"
else
  fail "curl not found. Install curl to run the API probe check."
fi

# 5. API reachability probe
echo ""
echo "-- Managed Agents API probe"
if [ -n "${ANTHROPIC_API_KEY:-}" ] && command -v curl &>/dev/null; then
  HTTP_CODE=$(curl -s -o /tmp/managed-agents-probe.json -w "%{http_code}" \
    --max-time 10 \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "anthropic-beta: managed-agents-2026-04-01" \
    "https://api.anthropic.com/v1/beta/agents" 2>/dev/null || echo "000")

  case "$HTTP_CODE" in
    200)
      pass "API probe returned 200 -- Managed Agents accessible"
      AGENT_COUNT=$(python3 -c "
import json
try:
    d = json.load(open('/tmp/managed-agents-probe.json'))
    print(f\"Existing agents: {len(d.get('data', []))}\")
except Exception as e:
    print(f'(could not parse response: {e})')
" 2>/dev/null || echo "(count unavailable)")
      echo "       $AGENT_COUNT"
      ;;
    401)
      fail "API probe returned 401 -- API key invalid or expired. Check ANTHROPIC_API_KEY."
      ;;
    403)
      fail "API probe returned 403 -- API key lacks Managed Agents permission. Verify at platform.claude.com."
      ;;
    404)
      fail "API probe returned 404 -- endpoint not found. Check SDK version and beta header."
      ;;
    000)
      warn "API probe failed to connect. Check network/firewall. Managed Agents may still work."
      ;;
    *)
      warn "API probe returned HTTP $HTTP_CODE. Check platform.claude.com for status."
      ;;
  esac
  rm -f /tmp/managed-agents-probe.json
else
  warn "Skipping API probe -- ANTHROPIC_API_KEY not set or curl unavailable"
fi

# 6. SDK beta attribute check
echo ""
echo "-- SDK beta.agents attribute"
if command -v python3 &>/dev/null && [[ "${SDK_CHECK:-SKIP}" == OK:* ]]; then
  ATTR_CHECK=$(python3 -c "
import anthropic
c = anthropic.Anthropic(api_key='placeholder')
has_agents = hasattr(c.beta, 'agents')
has_sessions = hasattr(c.beta, 'sessions')
has_vaults = hasattr(c.beta, 'vaults')
has_envs = hasattr(c.beta, 'environments')
missing = [n for n, v in [('agents',has_agents),('sessions',has_sessions),('vaults',has_vaults),('environments',has_envs)] if not v]
if missing:
    print('MISSING:' + ','.join(missing))
else:
    print('OK')
" 2>&1)

  if [ "$ATTR_CHECK" = "OK" ]; then
    pass "SDK exposes beta.agents, beta.sessions, beta.vaults, beta.environments"
  elif [[ "$ATTR_CHECK" == MISSING:* ]]; then
    fail "SDK missing attributes: ${ATTR_CHECK#MISSING:}. Run: pip install --upgrade anthropic"
  else
    warn "Could not verify SDK attributes: $ATTR_CHECK"
  fi
else
  warn "Skipping SDK attribute check"
fi

# 7. Session log file (optional)
echo ""
echo "-- Session log"
LOG_FILE="$HOME/.claude/managed-sessions.log"
if [ -f "$LOG_FILE" ]; then
  LINE_COUNT=$(wc -l < "$LOG_FILE")
  pass "Session log exists: $LOG_FILE ($LINE_COUNT entries)"
else
  warn "Session log not yet created at $LOG_FILE (created on first dispatch)"
fi

# Summary
echo ""
echo "=== Summary ==="
echo "PASS:    $passes"
echo "WARN:    $warnings"
echo "FAIL:    $failures"
echo ""

if [ "$failures" -gt 0 ]; then
  echo "Status: NOT READY -- fix $failures failure(s) above before using /managed"
  exit 1
elif [ "$warnings" -gt 0 ]; then
  echo "Status: READY WITH WARNINGS -- $warnings warning(s) above (non-blocking)"
  exit 0
else
  echo "Status: READY -- all checks passed"
  exit 0
fi
