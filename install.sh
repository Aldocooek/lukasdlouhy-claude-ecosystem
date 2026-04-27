#!/usr/bin/env bash
# install.sh — Production installer for Lukáš Dlouhý's Claude Code Ecosystem
# Usage: bash install.sh [--dry-run] [--no-backup] [-y|--yes] [--force] [--help]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"
BACKUP_BASE="${HOME}/.claude.backups"
TIMESTAMP="$(date +%Y-%m-%d-%H%M%S)"
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"
DRY_RUN=false BACKUP=true YES=false FORCE=false
ROLLBACK_TRIGGERED=false BACKUP_TAKEN=false

# ─── Color output (TTY only) ─────────────────────────────────────────────────
if [ -t 1 ]; then
  G='\033[0;32m' Y='\033[0;33m' R='\033[0;31m' B='\033[1m' X='\033[0m'
else
  G='' Y='' R='' B='' X=''
fi
ok()   { printf "${G}✓${X} %s\n" "$*"; }
warn() { printf "${Y}⚠${X} %s\n" "$*"; }
err()  { printf "${R}✗${X} %s\n" "$*" >&2; }
hdr()  { printf "\n${B}=== %s ===${X}\n" "$*"; }
dry()  { printf "${Y}[DRY RUN]${X} %s\n" "$*"; }

# ─── Argument parsing ─────────────────────────────────────────────────────────
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)   DRY_RUN=true ;;
      --no-backup) BACKUP=false ;;
      -y|--yes)    YES=true ;;
      --force)     FORCE=true ;;
      --help|-h)   cat <<'EOF'
Claude Code Ecosystem Installer

Usage: bash install.sh [flags]

Flags:
  --dry-run     Log every action that WOULD happen; make no changes
  --no-backup   Skip timestamped backup before overwriting files
  -y, --yes     Skip confirmation prompts for destructive operations
  --force       Overwrite settings.json even if it already exists
  --help        Show this help and exit

Exit codes:
  0  Success
  1  User aborted
  2  Validation failure
  3  Mid-install failure (rollback fired)
  4  Missing prerequisites
EOF
        exit 0 ;;
      *) err "Unknown flag: $1"; exit 4 ;;
    esac; shift
  done
}

# ─── Prerequisites ────────────────────────────────────────────────────────────
check_prerequisites() {
  hdr "Checking prerequisites"
  local missing=0
  if [[ "${BASH_VERSINFO[0]}" -ge 3 ]]; then ok "bash $BASH_VERSION"
  else err "bash 3+ required"; missing=$((missing+1)); fi
  local cmd
  for cmd in git jq ln cp mkdir; do
    if command -v "$cmd" &>/dev/null; then ok "$cmd found"
    else
      case "$cmd" in
        git) err "git not found — brew install git" ;;
        jq)  err "jq not found — brew install jq" ;;
        *)   err "$cmd not found" ;;
      esac
      missing=$((missing+1))
    fi
  done
  if [[ "$missing" -gt 0 ]]; then err "$missing prerequisite(s) missing"; exit 4; fi
}

# ─── Idempotency check ────────────────────────────────────────────────────────
check_idempotent() {
  hdr "Checking current state"
  local changes=0
  local name
  for name in skills agents commands hooks; do
    local link="${CLAUDE_HOME}/${name}" target="${REPO_DIR}/${name}"
    if [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$target" ]]; then
      ok "$name already linked"
    else
      changes=$((changes+1))
    fi
  done
  for name in settings.json CLAUDE.md; do
    if [[ -f "${CLAUDE_HOME}/${name}" ]]; then ok "$name already present"
    else changes=$((changes+1)); fi
  done
  if [[ "$changes" -eq 0 ]] && [[ "$FORCE" == false ]]; then
    ok "Already installed (no changes)"; post_install_validation; exit 0
  fi
}

# ─── Backup / Rollback ────────────────────────────────────────────────────────
take_backup() {
  [[ "$BACKUP" == false ]] && return; hdr "Backup"
  if [[ "$DRY_RUN" == true ]]; then dry "Would create backup: $BACKUP_DIR"; return; fi
  mkdir -p "$BACKUP_DIR"
  for item in skills agents commands hooks settings.json CLAUDE.md; do
    local src="${CLAUDE_HOME}/${item}"
    [[ -e "$src" || -L "$src" ]] && cp -rP "$src" "${BACKUP_DIR}/${item}" 2>/dev/null || true
  done
  BACKUP_TAKEN=true; ok "Backup created: $BACKUP_DIR"
}

rollback() {
  [[ "$ROLLBACK_TRIGGERED" == true ]] && return; ROLLBACK_TRIGGERED=true
  err "Install failed — rolling back"
  if [[ "$BACKUP_TAKEN" == true ]] && [[ -d "$BACKUP_DIR" ]]; then
    for item in skills agents commands hooks settings.json CLAUDE.md; do
      local bak="${BACKUP_DIR}/${item}" dst="${CLAUDE_HOME}/${item}"
      [[ -e "$bak" ]] && { rm -rf "$dst"; cp -rP "$bak" "$dst" 2>/dev/null || true; }
    done
    warn "Restored from backup: $BACKUP_DIR"
  else
    warn "No backup — manual inspection required"
  fi
  exit 3
}

trap 'rc=$?; [[ $rc -ne 0 && "$ROLLBACK_TRIGGERED" == false && "$DRY_RUN" == false ]] && rollback' EXIT

# ─── Helpers ──────────────────────────────────────────────────────────────────
confirm() {
  [[ "$YES" == true || "$DRY_RUN" == true ]] && return 0
  printf "${Y}?${X} %s [y/N] " "$1"; read -r a; case "$a" in [yY]*) return 0 ;; *) return 1 ;; esac
}

install_symlink() {
  local name="$1" target="${REPO_DIR}/$1" link="${CLAUDE_HOME}/$1"
  [[ ! -d "$target" ]] && { warn "Source missing, skipping: $target"; return; }
  [[ "$DRY_RUN" == true ]] && { dry "Would symlink: $link → $target"; return; }
  if [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$target" ]]; then ok "$name already linked"; return; fi
  if [[ -e "$link" ]] && [[ ! -L "$link" ]]; then
    confirm "Overwrite existing $link?" || { warn "Skipped $name"; return; }; rm -rf "$link"
  elif [[ -L "$link" ]]; then rm "$link"; fi
  ln -s "$target" "$link"; ok "Linked: $name → $target"
}

install_file() {
  local src="$1" dst="$2" label="$3"
  [[ ! -f "$src" ]] && { warn "Source missing, skipping: $src"; return; }
  [[ "$DRY_RUN" == true ]] && { dry "Would copy: $src → $dst"; return; }
  if [[ -f "$dst" ]] && [[ "$FORCE" == false ]]; then
    cmp -s "$src" "$dst" && { ok "$label already up to date"; return; }
    confirm "Overwrite existing $dst?" || { warn "Skipped $label"; return; }
  fi
  cp "$src" "$dst"; ok "Installed: $label"
}

# ─── Stages ──────────────────────────────────────────────────────────────────
stage_ensure_claude_home() {
  hdr "Claude home"
  if [[ ! -d "$CLAUDE_HOME" ]]; then
    [[ "$DRY_RUN" == true ]] && { dry "Would create $CLAUDE_HOME"; return; }
    mkdir -p "$CLAUDE_HOME"; ok "Created $CLAUDE_HOME"
  else ok "$CLAUDE_HOME exists"; fi
}

stage_symlinks() {
  hdr "Symlinking directories"
  install_symlink skills; install_symlink agents; install_symlink commands; install_symlink hooks
}

stage_hooks_executable() {
  hdr "Hook permissions"
  [[ ! -d "${REPO_DIR}/hooks" ]] && { warn "No hooks/ directory — skipping"; return; }
  [[ "$DRY_RUN" == true ]] && { dry "Would chmod +x hooks/*.sh hooks/*.js"; return; }
  local count=0
  for f in "${REPO_DIR}/hooks/"*.sh "${REPO_DIR}/hooks/"*.js; do
    [[ -f "$f" ]] || continue; chmod +x "$f"; count=$((count+1))
  done
  ok "$count hook file(s) marked executable"
}

stage_settings() {
  hdr "settings.json"
  local dst="${CLAUDE_HOME}/settings.json"
  [[ -f "$dst" ]] && [[ "$FORCE" == false ]] && { ok "settings.json exists (--force to overwrite)"; return; }
  install_file "${REPO_DIR}/settings.json.template" "$dst" "settings.json"
}

stage_claude_md() {
  hdr "CLAUDE.md"
  install_file "${REPO_DIR}/CLAUDE.md" "${CLAUDE_HOME}/CLAUDE.md" "CLAUDE.md"
}

# ─── Post-install validation ──────────────────────────────────────────────────
post_install_validation() {
  hdr "Post-install validation"
  local failures=0

  command -v claude &>/dev/null && ok "claude CLI: $(command -v claude)" || warn "claude CLI not in PATH"

  local skill_count; skill_count=$(ls -1 "${CLAUDE_HOME}/skills" 2>/dev/null | grep -c -v README || echo 0)
  if [[ "$skill_count" -gt 0 ]]; then ok "skills: $skill_count"
  else err "skills empty or missing"; failures=$((failures+1)); fi

  local agent_count cmd_count hook_count
  agent_count=$(ls -1 "${CLAUDE_HOME}/agents" 2>/dev/null | grep -c -v README || echo 0)
  cmd_count=$(ls -1   "${CLAUDE_HOME}/commands" 2>/dev/null | grep -c -v README || echo 0)
  hook_count=0
  for f in "${CLAUDE_HOME}/hooks/"*.sh "${CLAUDE_HOME}/hooks/"*.js; do
    [[ -f "$f" ]] && hook_count=$((hook_count+1))
  done
  ok "agents: $agent_count | commands: $cmd_count | hooks: $hook_count"

  local sj="${CLAUDE_HOME}/settings.json"
  if [[ -f "$sj" ]]; then
    jq empty "$sj" 2>/dev/null && ok "settings.json valid JSON" || { err "settings.json invalid JSON"; failures=$((failures+1)); }
  else warn "settings.json absent — skipping JSON validation"; fi

  local gs="${CLAUDE_HOME}/hooks/git-safety.sh"
  if [[ -f "$gs" ]] && [[ -x "$gs" ]]; then
    bash "$gs" --dry-run &>/dev/null && ok "git-safety.sh --dry-run passed" || warn "git-safety.sh --dry-run non-zero (may not support flag)"
  else warn "git-safety.sh not found — skipping hook smoke-test"; fi

  [[ "$failures" -gt 0 ]] && { err "$failures validation failure(s)"; exit 2; }
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  parse_args "$@"
  printf "\n${B}Claude Code Ecosystem Installer${X}"
  [[ "$DRY_RUN" == true ]] && printf " ${Y}(DRY RUN)${X}"
  echo ""

  check_prerequisites
  stage_ensure_claude_home
  check_idempotent
  take_backup
  stage_symlinks
  stage_hooks_executable
  stage_settings
  stage_claude_md

  if [[ "$DRY_RUN" == false ]]; then
    post_install_validation
    hdr "Done"
    ok "Installed to $CLAUDE_HOME"
    [[ "$BACKUP_TAKEN" == true ]] && ok "Backup: $BACKUP_DIR"
    echo ""
    echo "Next: open a Claude Code session and run @skill <name> to test."
  else
    hdr "Done"
    warn "DRY RUN complete — no changes made. Re-run without --dry-run to apply."
  fi
}

main "$@"
