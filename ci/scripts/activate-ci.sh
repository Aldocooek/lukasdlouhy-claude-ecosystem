#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(dirname "$CI_DIR")"

DRY_RUN=false
FORCE=false
TARGET_REPO=""

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <target-repo-path>

Options:
  --dry-run    Preview what would be copied without making changes
  --force      Overwrite existing workflow files
  -h, --help   Show this help message

Arguments:
  target-repo-path  Path to the target repository where workflows will be deployed

Example:
  $(basename "$0") /path/to/my-project
  $(basename "$0") --dry-run /path/to/my-project
EOF
    exit 1
}

log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARN] $1" >&2
}

log_error() {
    echo "[ERROR] $1" >&2
}

confirm() {
    local prompt="$1"
    local response
    read -p "$prompt (yes/no): " response
    [[ "$response" == "yes" ]]
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            TARGET_REPO="$1"
            shift
            ;;
    esac
done

if [[ -z "$TARGET_REPO" ]]; then
    log_error "Target repository path is required"
    usage
fi

TARGET_REPO="$(cd "$TARGET_REPO" 2>/dev/null && pwd)" || {
    log_error "Target path does not exist: $TARGET_REPO"
    exit 1
}

if [[ ! -d "$TARGET_REPO/.git" ]]; then
    log_error "Target is not a git repository: $TARGET_REPO"
    exit 1
fi

log_info "Target repo: $TARGET_REPO"

if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    log_error "GitHub CLI is not authenticated. Run 'gh auth login' first"
    exit 1
fi

log_info "GitHub CLI authenticated"

if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN MODE]"
fi

cat << 'EOF'

This script will deploy Claude Code CI/CD workflows to your target repository:
  - Copies all workflow files from ci/.github/workflows/
  - Copies composite actions from ci/.github/actions/
  - Does NOT commit changes (you do that manually)
  - Does NOT set repository secrets (you do that via gh secret set)

IMPORTANT NEXT STEPS AFTER DEPLOYMENT:
  1. Review copied files in <target>/.github/workflows/ and <target>/.github/actions/
  2. Commit: git add .github && git commit -m "Add Claude Code CI workflows"
  3. Set secret: gh secret set ANTHROPIC_API_KEY --body "$ANTHROPIC_API_KEY"
  4. Disable expensive workflows initially (edit to add 'if: false' or disable in Actions UI)
  5. Enable ONLY claude-pr-review.yml first for testing
  6. Monitor costs on Anthropic dashboard closely during first week

EOF

if ! confirm "Proceed with deployment to $TARGET_REPO?"; then
    log_info "Deployment cancelled"
    exit 0
fi

WORKFLOWS_SRC="$CI_DIR/.github/workflows"
WORKFLOWS_DST="$TARGET_REPO/.github/workflows"
ACTIONS_SRC="$CI_DIR/.github/actions"
ACTIONS_DST="$TARGET_REPO/.github/actions"

if [[ ! -d "$WORKFLOWS_SRC" ]]; then
    log_error "Source workflows directory not found: $WORKFLOWS_SRC"
    exit 1
fi

mkdir -p "$WORKFLOWS_DST" "$ACTIONS_DST"

copied_count=0
skipped_count=0

for workflow in "$WORKFLOWS_SRC"/*.yml; do
    basename=$(basename "$workflow")
    dst_file="$WORKFLOWS_DST/$basename"

    if [[ -f "$dst_file" ]]; then
        if [[ "$FORCE" == true ]]; then
            if [[ "$DRY_RUN" == false ]]; then
                cp "$workflow" "$dst_file"
                log_info "[OVERWRITE] $basename"
            else
                log_info "[DRY RUN] Would overwrite $basename"
            fi
            ((copied_count++))
        else
            log_warn "[SKIP] $basename already exists (use --force to overwrite)"
            ((skipped_count++))
        fi
    else
        if [[ "$DRY_RUN" == false ]]; then
            cp "$workflow" "$dst_file"
            log_info "[COPY] $basename"
        else
            log_info "[DRY RUN] Would copy $basename"
        fi
        ((copied_count++))
    fi
done

if [[ -d "$ACTIONS_SRC" ]]; then
    for action_dir in "$ACTIONS_SRC"/*; do
        if [[ -d "$action_dir" ]]; then
            action_name=$(basename "$action_dir")
            dst_action="$ACTIONS_DST/$action_name"

            if [[ -d "$dst_action" ]]; then
                if [[ "$FORCE" == true ]]; then
                    if [[ "$DRY_RUN" == false ]]; then
                        rm -rf "$dst_action"
                        cp -r "$action_dir" "$dst_action"
                        log_info "[OVERWRITE] action/$action_name"
                    else
                        log_info "[DRY RUN] Would overwrite action/$action_name"
                    fi
                    ((copied_count++))
                else
                    log_warn "[SKIP] action/$action_name already exists (use --force to overwrite)"
                    ((skipped_count++))
                fi
            else
                if [[ "$DRY_RUN" == false ]]; then
                    cp -r "$action_dir" "$dst_action"
                    log_info "[COPY] action/$action_name"
                else
                    log_info "[DRY RUN] Would copy action/$action_name"
                fi
                ((copied_count++))
            fi
        fi
    done
fi

if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN COMPLETE] No files were modified"
fi

log_info "Deployment summary: $copied_count copied/overwritten, $skipped_count skipped"

if [[ "$DRY_RUN" == false ]]; then
    cat << 'EOF'

DEPLOYMENT COMPLETE

Next steps (run these commands):

1. Navigate to target repo:
   cd <target-repo>

2. Verify workflows were copied:
   ls -la .github/workflows/
   ls -la .github/actions/

3. Stage and commit:
   git add .github
   git commit -m "Add Claude Code CI workflows"

4. Set Anthropic API key (replace <YOUR_KEY> with actual key):
   gh secret set ANTHROPIC_API_KEY --body "<YOUR_KEY>"

5. Configure which workflows to enable:
   - View workflows: gh workflow list
   - Disable expensive ones initially (test with claude-pr-review.yml first)

6. Set up monitoring:
   - Check GitHub Actions tab regularly
   - Watch Anthropic dashboard for token usage
   - Review PR quality and false-positive rate

See ci/ACTIVATION_CHECKLIST.md for detailed steps and ci/MONITORING_DURING_FIRST_WEEK.md for what to watch.

EOF
fi
