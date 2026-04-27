#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "[build-plugin] Starting plugin build from $PROJECT_ROOT"

# Read plugin metadata
PLUGIN_NAME=$(jq -r '.name' "$PROJECT_ROOT/.claude-plugin/plugin.json")
PLUGIN_VERSION=$(jq -r '.version' "$PROJECT_ROOT/.claude-plugin/plugin.json")
TARBALL_NAME="${PLUGIN_NAME}-${PLUGIN_VERSION}.tar.gz"

BUILD_DIR="$PROJECT_ROOT/dist"
STAGING_DIR="/tmp/plugin-staging-$$"

mkdir -p "$BUILD_DIR" "$STAGING_DIR"
trap "rm -rf $STAGING_DIR" EXIT

echo "[build-plugin] Staging plugin: $PLUGIN_NAME v$PLUGIN_VERSION"

# Copy plugin manifest
mkdir -p "$STAGING_DIR/.claude-plugin"
cp "$PROJECT_ROOT/.claude-plugin/plugin.json" "$STAGING_DIR/.claude-plugin/"

# Copy skills (exclude tests, node_modules, .tmp)
echo "[build-plugin] Bundling skills..."
mkdir -p "$STAGING_DIR/skills"
find "$PROJECT_ROOT/skills" -maxdepth 2 -type f \
  -not -path "*/.*" \
  -not -path "*/__pycache__/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.tmp/*" \
  -not -name "*.test.*" \
  -not -name "*_test.*" \
  | while read -r file; do
  rel_path="${file#$PROJECT_ROOT/}"
  mkdir -p "$(dirname "$STAGING_DIR/$rel_path")"
  cp "$file" "$STAGING_DIR/$rel_path"
done

# Copy agents
echo "[build-plugin] Bundling agents..."
mkdir -p "$STAGING_DIR/agents"
find "$PROJECT_ROOT/agents" -maxdepth 2 -type f \
  -not -path "*/.*" \
  -not -name "*.test.*" \
  | while read -r file; do
  rel_path="${file#$PROJECT_ROOT/}"
  mkdir -p "$(dirname "$STAGING_DIR/$rel_path")"
  cp "$file" "$STAGING_DIR/$rel_path"
done

# Copy commands
echo "[build-plugin] Bundling commands..."
mkdir -p "$STAGING_DIR/commands"
find "$PROJECT_ROOT/commands" -maxdepth 2 -type f \
  -not -path "*/.*" \
  -not -name "*.test.*" \
  | while read -r file; do
  rel_path="${file#$PROJECT_ROOT/}"
  mkdir -p "$(dirname "$STAGING_DIR/$rel_path")"
  cp "$file" "$STAGING_DIR/$rel_path"
done

# Copy hooks
echo "[build-plugin] Bundling hooks..."
mkdir -p "$STAGING_DIR/hooks"
find "$PROJECT_ROOT/hooks" -maxdepth 2 -type f \
  -not -path "*/.*" \
  | while read -r file; do
  rel_path="${file#$PROJECT_ROOT/}"
  mkdir -p "$(dirname "$STAGING_DIR/$rel_path")"
  cp "$file" "$STAGING_DIR/$rel_path"
done

# Copy rules
echo "[build-plugin] Bundling rules..."
mkdir -p "$STAGING_DIR/rules"
find "$PROJECT_ROOT/rules" -maxdepth 1 -type f -name "*.md" \
  | while read -r file; do
  cp "$file" "$STAGING_DIR/rules/"
done

# Copy core docs
echo "[build-plugin] Bundling documentation..."
mkdir -p "$STAGING_DIR/docs"
for doc in LICENSE CHANGELOG.md; do
  if [ -f "$PROJECT_ROOT/$doc" ]; then
    cp "$PROJECT_ROOT/$doc" "$STAGING_DIR/"
  fi
done

# Copy telemetry config
if [ -d "$PROJECT_ROOT/telemetry" ]; then
  echo "[build-plugin] Bundling telemetry config..."
  mkdir -p "$STAGING_DIR/telemetry"
  cp "$PROJECT_ROOT/telemetry"/*.yaml "$STAGING_DIR/telemetry/" 2>/dev/null || true
  cp "$PROJECT_ROOT/telemetry"/*.json "$STAGING_DIR/telemetry/" 2>/dev/null || true
  cp "$PROJECT_ROOT/telemetry/README.md" "$STAGING_DIR/telemetry/" 2>/dev/null || true
fi

# Exclude patterns
EXCLUDES=(
  "*.env"
  ".env*"
  "*.secret"
  ".git"
  ".github"
  ".DS_Store"
  "__pycache__"
  "node_modules"
  ".tmp"
  "*.test.md"
)

# Create tarball
cd "$STAGING_DIR"
tar --exclude='.DS_Store' \
    --exclude='*.env' \
    --exclude='.*secret*' \
    --exclude='__pycache__' \
    -czf "$BUILD_DIR/$TARBALL_NAME" .

# Compute SHA256
SHA256=$(shasum -a 256 "$BUILD_DIR/$TARBALL_NAME" | awk '{print $1}')

echo ""
echo "[build-plugin] Build complete!"
echo "  Tarball: dist/$TARBALL_NAME"
echo "  Size:    $(du -h "$BUILD_DIR/$TARBALL_NAME" | cut -f1)"
echo "  SHA256:  $SHA256"
echo ""
echo "Next: bash scripts/publish-plugin.sh"
