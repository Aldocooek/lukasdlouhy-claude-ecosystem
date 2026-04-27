#!/bin/bash
set -e

# Install script for Lukáš Dlouhý's Claude Code Ecosystem
# Usage: bash install.sh [--dry-run]

DRY_RUN=false
BACKUP_DIR=""
CLAUDE_HOME="${HOME}/.claude"
AGENTS_SKILLS="${HOME}/.agents/skills"

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "DRY RUN MODE — no changes will be made"
fi

echo "=== Claude Code Ecosystem Installer ==="
echo ""

# Check if ~/.claude exists
if [ ! -d "$CLAUDE_HOME" ]; then
  echo "ERROR: $CLAUDE_HOME does not exist."
  echo "Please create it first: mkdir -p $CLAUDE_HOME"
  exit 1
fi

# Create backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$CLAUDE_HOME/.backup-$TIMESTAMP"

if [ "$DRY_RUN" = false ]; then
  echo "Backing up existing ~/.claude to $BACKUP_DIR"
  cp -r "$CLAUDE_HOME" "$BACKUP_DIR"
  echo "Backup created: $BACKUP_DIR"
else
  echo "[DRY RUN] Would backup to: $BACKUP_DIR"
fi

echo ""
echo "=== Installing Files ==="

# Install rules/
if [ -d "rules" ]; then
  echo "Installing rules/"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$CLAUDE_HOME/rules"
    cp -v rules/* "$CLAUDE_HOME/rules/" 2>/dev/null || true
  else
    echo "[DRY RUN] Would copy: rules/* → $CLAUDE_HOME/rules/"
  fi
fi

# Install hooks/
if [ -d "hooks" ]; then
  echo "Installing hooks/"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$CLAUDE_HOME/hooks"
    cp -v hooks/* "$CLAUDE_HOME/hooks/" 2>/dev/null || true
    chmod +x "$CLAUDE_HOME/hooks"/* 2>/dev/null || true
  else
    echo "[DRY RUN] Would copy: hooks/* → $CLAUDE_HOME/hooks/ (and chmod +x)"
  fi
fi

# Install expertise/
if [ -d "expertise" ]; then
  echo "Installing expertise/"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$CLAUDE_HOME/expertise"
    cp -v expertise/* "$CLAUDE_HOME/expertise/" 2>/dev/null || true
  else
    echo "[DRY RUN] Would copy: expertise/* → $CLAUDE_HOME/expertise/"
  fi
fi

# Install skills/
if [ -d "skills" ]; then
  echo "Installing skills/"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$CLAUDE_HOME/skills"
    cp -rv skills/* "$CLAUDE_HOME/skills/" 2>/dev/null || true

    # Also symlink to ~/.agents/skills if it exists
    if [ -d "$AGENTS_SKILLS" ]; then
      echo "Also linking to $AGENTS_SKILLS"
      for skill in skills/*; do
        skill_name=$(basename "$skill")
        ln -sf "$CLAUDE_HOME/skills/$skill_name" "$AGENTS_SKILLS/$skill_name" 2>/dev/null || true
      done
    fi
  else
    echo "[DRY RUN] Would copy: skills/* → $CLAUDE_HOME/skills/"
    echo "[DRY RUN] Would symlink to $AGENTS_SKILLS/ (if exists)"
  fi
fi

echo ""
echo "=== Next Steps ==="

if [ "$DRY_RUN" = false ]; then
  echo "✓ Files installed to $CLAUDE_HOME"
  echo ""
  echo "1. Wire hooks into settings.json:"
  echo "   cd ~/.claude && cat hooks/README.md (if available) for instructions"
  echo ""
  echo "2. Review installed rules/expertise:"
  echo "   ls -la $CLAUDE_HOME/rules/"
  echo "   ls -la $CLAUDE_HOME/expertise/"
  echo ""
  echo "3. Test a skill in your next Claude Code session:"
  echo "   @skill gsap-easing (example)"
  echo ""
  echo "4. If something breaks, restore from backup:"
  echo "   rm -rf $CLAUDE_HOME && mv $BACKUP_DIR $CLAUDE_HOME"
  echo ""
  echo "Backup location: $BACKUP_DIR"
else
  echo "[DRY RUN] No changes made. Run without --dry-run to proceed:"
  echo "  bash install.sh"
fi

echo ""
echo "For troubleshooting, see: COLLABORATION.md"
