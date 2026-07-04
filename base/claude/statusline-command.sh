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
model=${model% (1M context)}

# ponytail mode badge. The version dir changes on every plugin update, so glob
# it instead of pinning a version; the plugin ships the script without +x, so
# run it with bash rather than gating on [ -x ]. No plugin → glob stays literal
# → -f fails → badge stays empty.
badge=""
for ponytail_script in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/ponytail/ponytail/*/hooks/ponytail-statusline.sh; do
  [ -f "$ponytail_script" ] && badge=$(bash "$ponytail_script" 2> /dev/null)
done

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
yellow=$'\033[38;5;178m'
red=$'\033[38;5;196m'
reset=$'\033[0m'

# Context window — Claude Code supplies context_window.* (size already resolves
# 200k vs 1M). Absent on older CLIs → cw_size 0 → the segment is skipped.
read -r cw_size cw_used < <(
  printf '%s' "$input" | jq -r \
    '"\(.context_window.context_window_size // 0) \(.context_window.total_input_tokens // 0)"'
)
ctx_seg=""
ctx_col=""
if [ "${cw_size:-0}" -gt 0 ]; then
  pct=$((cw_used * 100 / cw_size))
  ncells=8
  filled=$(((pct * ncells + 50) / 100))
  [ "$filled" -gt "$ncells" ] && filled=$ncells
  [ "$filled" -lt 0 ] && filled=0
  bar=""
  for ((i = 0; i < ncells; i++)); do
    if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
  done
  # Green until it matters, yellow as it fills, red in the ≥95% danger zone.
  if [ "$pct" -ge 95 ]; then
    ctx_col=$red
  elif [ "$pct" -ge 75 ]; then
    ctx_col=$yellow
  else
    ctx_col=$green
  fi
  ctx_seg="[${ctx_col}${bar}${reset}] ${pct}%"
fi

out="${badge:+$badge }${model}"
[ -n "$ctx_seg" ] && out="$out ${ctx_seg}"
out="$out ${sky}${dir_display}${reset}"
[ -n "$branch" ] && out="$out ${green} ${branch}${reset}"

printf '%s\n' "$out"
