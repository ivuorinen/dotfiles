#!/usr/bin/env bash
# Claude Code statusline.
#
# Ports the colors from the starship prompt (config/starship.toml in the
# dotfiles repo — sky directory, green git branch) and prepends the
# ponytail plugin's mode badge when active.
set -euo pipefail

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(printf '%s' "$input" | jq -r '.model.display_name')

# ponytail mode badge (no-op if the plugin/flag is absent)
ponytail_script="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cache/ponytail/ponytail/4.8.3/hooks/ponytail-statusline.sh"
badge=""
[ -x "$ponytail_script" ] && badge=$("$ponytail_script")

# Directory — mirrors starship's [directory] truncation_length = 3.
dir_display=$(cd "$cwd" 2> /dev/null && pwd || printf '%s' "$cwd")
dir_display="${dir_display/#$HOME/\~}"
IFS='/' read -ra parts <<< "$dir_display"
[ -z "${parts[0]:-}" ] && parts=("${parts[@]:1}")
if [ "${#parts[@]}" -gt 3 ]; then
  last3=("${parts[@]: -3}")
  dir_display=$(
    IFS=/
    printf '…/%s' "${last3[*]}"
  )
fi

# Git branch — mirrors starship's [git_branch] style, locks skipped.
branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2> /dev/null)
fi

sky=$'\033[38;5;39m'
green=$'\033[38;5;70m'
reset=$'\033[0m'

out="${badge:+$badge }${sky}${dir_display}${reset}"
[ -n "$branch" ] && out="$out ${green} ${branch}${reset}"
out="$out ${model}"

printf '%s\n' "$out"
