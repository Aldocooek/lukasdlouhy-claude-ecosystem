#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST="$SCRIPT_DIR/dist/index.js"

echo "==> HyperFrames MCP Server installer"
echo ""

# Check Node.js
if ! command -v node &>/dev/null; then
  echo "ERROR: node is not installed. Install Node.js 18+ from https://nodejs.org" >&2
  exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "ERROR: Node.js 18+ required (found $(node --version))" >&2
  exit 1
fi
echo "  [ok] Node.js $(node --version)"

# Check hf CLI
if command -v hf &>/dev/null; then
  echo "  [ok] hyperframes-cli found at $(command -v hf)"
else
  echo "  [warn] hf not found in PATH"
  echo "         Install hyperframes-cli before using the MCP server tools."
  echo "         e.g.: npm install -g hyperframes-cli"
fi

# Install dependencies
echo ""
echo "==> Installing npm dependencies..."
cd "$SCRIPT_DIR"
npm install

# Build TypeScript
echo ""
echo "==> Building TypeScript..."
npm run build

if [ ! -f "$DIST" ]; then
  echo "ERROR: Build failed — $DIST not found" >&2
  exit 1
fi
echo "  [ok] Built to $DIST"

# Print connection instructions
echo ""
echo "==> Installation complete!"
echo ""
echo "To connect Claude Code, run ONE of the following:"
echo ""
echo "  Option A (claude mcp add):"
echo "    claude mcp add hyperframes node $DIST"
echo ""
echo "  Option B (.claude/settings.json snippet):"
echo '    {
      "mcpServers": {
        "hyperframes": {
          "command": "node",
          "args": ["'"$DIST"'"]
        }
      }
    }'
echo ""
echo "Then restart Claude Code and verify with: /mcp"
