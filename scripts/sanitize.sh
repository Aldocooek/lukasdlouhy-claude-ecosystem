#!/usr/bin/env bash
#
# Leak scan script for Claude Code ecosystem repos
# Detects common secret patterns before git push
#
# Usage: bash scripts/sanitize.sh
# Exit code: 0 if clean, 1 if leaks found

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAN_DIR="${1:-.}"
LEAKED=false

echo "Scanning $SCAN_DIR for secret patterns..."
echo ""

# Array of secret patterns (regex-safe)
declare -a patterns=(
  "API_KEY"
  "Bearer "
  "BEGIN PRIVATE"
  "BEGIN OPENSSH"
  "BEGIN RSA PRIVATE"
  "BEGIN EC PRIVATE"
  "AKIA[0-9A-Z]{16}"           # AWS Access Key
  "ghp_[A-Za-z0-9_]{36,255}"   # GitHub Personal Access Token
  "sk-ant-[A-Za-z0-9_-]{90,}"  # Anthropic API Key
  "sk-proj-[A-Za-z0-9_-]{20,}" # OpenAI Project Key
  "xoxb-[0-9]+-[0-9]+-[A-Za-z0-9_-]{24,34}"  # Slack Bot Token
  "GEMINI_API_KEY=[A-Za-z0-9_-]{20,}"        # Google Gemini API Key
  "password.*=.*[A-Za-z0-9!@#\$%^&*]{8,}"    # Common password= patterns
  "secret.*=.*[A-Za-z0-9!@#\$%^&*]{8,}"      # Common secret= patterns
  "token.*=.*[A-Za-z0-9_-]{20,}"             # Common token= patterns
)

# Scan for each pattern
for pattern in "${patterns[@]}"; do
  hits=$(grep -ril "$pattern" "$SCAN_DIR" 2>/dev/null | \
    grep -v "\.git/" | \
    grep -v ".backup-" | \
    grep -v "sanitize.sh" | \
    grep -v "\.gitignore" | \
    grep -v "COMPARISON.md" || true)

  if [ -n "$hits" ]; then
    echo "LEAK DETECTED: $pattern"
    echo "  Files: $(echo "$hits" | tr '\n' ', ' | sed 's/,$//')"
    echo ""
    LEAKED=true
  fi
done

if [ "$LEAKED" = false ]; then
  echo "✓ No secrets detected. Safe to push."
  exit 0
else
  echo "FAIL: Leaks found. Do not push."
  echo ""
  echo "Remediation:"
  echo "  1. Identify the leaking files (above)"
  echo "  2. Remove or redact the secrets"
  echo "  3. Rerun: bash scripts/sanitize.sh"
  echo "  4. If using git, amend the last commit:"
  echo "     git add . && git commit --amend --no-edit"
  exit 1
fi
