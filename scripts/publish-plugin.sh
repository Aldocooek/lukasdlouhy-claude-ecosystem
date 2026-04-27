#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

DRY_RUN="${1:---dry-run}"

echo "[publish-plugin] Reading plugin metadata..."

PLUGIN_NAME=$(jq -r '.name' "$PROJECT_ROOT/.claude-plugin/plugin.json")
PLUGIN_VERSION=$(jq -r '.version' "$PROJECT_ROOT/.claude-plugin/plugin.json")
HOMEPAGE=$(jq -r '.homepage' "$PROJECT_ROOT/.claude-plugin/plugin.json")
TARBALL_NAME="${PLUGIN_NAME}-${PLUGIN_VERSION}.tar.gz"
TARBALL_PATH="$PROJECT_ROOT/dist/$TARBALL_NAME"

# Validate tarball exists
if [ ! -f "$TARBALL_PATH" ]; then
  echo "[publish-plugin] ERROR: Tarball not found: $TARBALL_PATH"
  echo "[publish-plugin] Run: bash scripts/build-plugin.sh"
  exit 1
fi

# Verify git tag matches version
CURRENT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "")
EXPECTED_TAG="v$PLUGIN_VERSION"

if [ -z "$CURRENT_TAG" ]; then
  echo "[publish-plugin] WARNING: No git tag found. Create with:"
  echo "  git tag $EXPECTED_TAG"
  echo "  git push origin $EXPECTED_TAG"
  if [ "$DRY_RUN" != "--force" ]; then
    exit 1
  fi
elif [ "$CURRENT_TAG" != "$EXPECTED_TAG" ]; then
  echo "[publish-plugin] ERROR: Tag mismatch. Found: $CURRENT_TAG, expected: $EXPECTED_TAG"
  exit 1
fi

echo "[publish-plugin] Generating release notes from CHANGELOG.md..."

if [ -f "$PROJECT_ROOT/CHANGELOG.md" ]; then
  # Extract v1.0.0 section
  RELEASE_NOTES=$(sed -n '/^## \[1\.0\.0\]/,/^## \[/p' "$PROJECT_ROOT/CHANGELOG.md" | head -n -1)
else
  RELEASE_NOTES="Plugin release v$PLUGIN_VERSION"
fi

echo "[publish-plugin] Release notes:"
echo "$RELEASE_NOTES"
echo ""

# Compute checksums
SHA256=$(shasum -a 256 "$TARBALL_PATH" | awk '{print $1}')
SIZE=$(du -h "$TARBALL_PATH" | awk '{print $1}')

RELEASE_NOTES="$RELEASE_NOTES

**Install:**
\`\`\`bash
claude plugin install $HOMEPAGE
\`\`\`

**Checksums:**
- SHA256: \`$SHA256\`
- Size: $SIZE
"

echo "[publish-plugin] Creating GitHub release: $EXPECTED_TAG"

if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "[publish-plugin] DRY RUN: Would execute:"
  echo "  gh release create $EXPECTED_TAG '$TARBALL_PATH' --title 'Plugin v$PLUGIN_VERSION' --notes '...'"
  echo ""
  echo "[publish-plugin] To publish for real, run:"
  echo "  bash scripts/publish-plugin.sh --force"
else
  gh release create "$EXPECTED_TAG" "$TARBALL_PATH" \
    --title "Plugin Release $PLUGIN_VERSION" \
    --notes "$RELEASE_NOTES" || {
    echo "[publish-plugin] Release already exists or gh auth failed."
    echo "[publish-plugin] Check: gh release view $EXPECTED_TAG"
  }

  echo "[publish-plugin] Release published!"
  echo "  URL: $HOMEPAGE/releases/tag/$EXPECTED_TAG"
fi

echo ""
echo "[publish-plugin] Next: Users can install with:"
echo "  claude plugin install $HOMEPAGE"
