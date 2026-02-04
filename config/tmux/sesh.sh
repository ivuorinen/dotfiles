#!/usr/bin/env bash
# Unified sesh session picker with cascading tool detection:
#   1. gum       — simple fuzzy filter
#   2. fzf-tmux  — rich UI with keybinds, preview, session kill
#   3. fzf       — same as fzf-tmux but inline
#   4. select    — bare minimum numbered menu

set -euo pipefail

# Fall back to native tmux session picker if sesh is not installed
if ! command -v sesh &>/dev/null; then
  tmux choose-tree -Zs
  exit 0
fi

pick_with_gum() {
  sesh list -i \
    | gum filter \
      --limit 1 \
      --no-sort \
      --fuzzy \
      --placeholder 'Pick a sesh' \
      --height 50 \
      --prompt='⚡'
}

FZF_COMMON_OPTS=(
  --no-sort --ansi
  --border-label ' sesh '
  --prompt '⚡  '
  --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find'
  --bind 'tab:down,btab:up'
  --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)'
  --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)'
  --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)'
  --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)'
  --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)'
  --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)'
  --preview-window 'right:55%'
  --preview 'sesh preview {}'
)

pick_with_fzf_tmux() {
  sesh list --icons | fzf-tmux -p 80%,70% "${FZF_COMMON_OPTS[@]}"
}

pick_with_fzf() {
  sesh list --icons | fzf "${FZF_COMMON_OPTS[@]}"
}

pick_with_select() {
  local sessions
  mapfile -t sessions < <(sesh list)
  if [[ ${#sessions[@]} -eq 0 ]]; then
    return
  fi
  PS3="Select session: "
  select choice in "${sessions[@]}"; do
    if [[ -n "${choice-}" ]]; then
      printf '%s' "$choice"
      break
    fi
  done
}

# Cascading tool detection
if command -v gum &>/dev/null; then
  selection=$(pick_with_gum)
elif command -v fzf-tmux &>/dev/null; then
  selection=$(pick_with_fzf_tmux)
elif command -v fzf &>/dev/null; then
  selection=$(pick_with_fzf)
else
  selection=$(pick_with_select)
fi

if [[ -n "${selection-}" ]]; then
  sesh connect "$selection"
fi
