#!/bin/bash
# Claude Code statusline for Lukáš Dlouhý
# Receives JSON on stdin per Claude Code spec:
# { session_id, transcript_path, cwd, model:{id,display_name}, workspace:{current_dir,project_dir}, version }

set -o pipefail

GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# Read stdin (Claude Code closes pipe, no timeout needed; macOS lacks `timeout`)
input=$(cat 2>/dev/null)
[[ -z "$input" ]] && input='{}'

if command -v jq &>/dev/null; then
    model=$(echo "$input" | jq -r '.model.display_name // .model.id // .model // "Claude"' 2>/dev/null)
    model_id=$(echo "$input" | jq -r '.model.id // ""' 2>/dev/null)
    cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""' 2>/dev/null)
    transcript_path=$(echo "$input" | jq -r '.transcript_path // ""' 2>/dev/null)
else
    model=$(echo "$input" | grep -oE '"display_name":"[^"]*"' | head -1 | cut -d'"' -f4)
    [[ -z "$model" ]] && model="Claude"
    cwd=$(echo "$input" | grep -oE '"current_dir":"[^"]*"' | head -1 | cut -d'"' -f4)
    [[ -z "$cwd" ]] && cwd=$(echo "$input" | grep -oE '"cwd":"[^"]*"' | head -1 | cut -d'"' -f4)
    transcript_path=$(echo "$input" | grep -oE '"transcript_path":"[^"]*"' | head -1 | cut -d'"' -f4)
fi

# Shorten cwd
short_cwd="$cwd"
if [[ -n "$cwd" ]]; then
    short_cwd="${cwd/#$HOME/~}"
    if [[ ${#short_cwd} -gt 35 ]]; then
        short_cwd="…${short_cwd: -32}"
    fi
fi

# Git branch
branch=""
if [[ -n "$cwd" && -d "$cwd" ]]; then
    b=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -n "$b" && "$b" != "HEAD" ]] && branch=" ${DIM}⎇ ${b}${RESET}"
fi

# Message count from transcript (proxy for session length)
msg_count=0
indicator="${GREEN}●${RESET}"
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    msg_count=$(wc -l < "$transcript_path" 2>/dev/null | tr -d ' ')
    [[ -z "$msg_count" ]] && msg_count=0
    if [[ $msg_count -ge 100 ]]; then
        indicator="${RED}●${RESET}"
    elif [[ $msg_count -ge 50 ]]; then
        indicator="${YELLOW}●${RESET}"
    fi
fi

# Hook profile
profile="${HOOK_PROFILE:-?}"
[[ -f "$HOME/.claude/.hook-profile-current" ]] && profile=$(cat "$HOME/.claude/.hook-profile-current" 2>/dev/null | tr -d '\n')

printf "%s[%s%s%s]%s%s %s%s%s · msgs:%s%s %sprof:%s%s\n" \
    "$DIM" "$RESET" "$model" "$DIM" "$RESET" "$branch" \
    "$DIM" "$short_cwd" "$RESET" \
    "$msg_count" "$indicator" \
    "$DIM" "$profile" "$RESET"
