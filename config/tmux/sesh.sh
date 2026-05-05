#!/usr/bin/env bash
# Unified sesh session picker with cascading tool detection:
#   1. gum     — simple fuzzy filter (works inside the prefix+t popup)
#   2. fzf     — rich UI inline; reachable when invoked outside a popup
#   3. select  — bare minimum numbered menu
#
# `fzf-tmux` is intentionally omitted: this script is bound to
# `prefix + t` via `display-popup -E` in config/tmux/tmux.conf, and
# `fzf-tmux -p` cannot nest a second popup inside the existing one
# (the failure mode that prompted N-057). Plain `fzf` covers the
# direct-invocation case.

set -euo pipefail

# Fall back to native tmux session picker if sesh is not installed
if ! command -v sesh &> /dev/null; then
  tmux choose-tree -Zs
  exit 0
fi

# Pick a sesh session using gum filter
pick_with_gum()
{
  sesh list --icons \
    | gum filter \
      --limit 1 \
      --no-sort \
      --fuzzy \
      --placeholder 'Pick a sesh' \
      --height 50 \
      --prompt='⚡'
  return 0
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

# Pick a sesh session using fzf inline
pick_with_fzf()
{
  sesh list --icons | fzf "${FZF_COMMON_OPTS[@]}"
  return 0
}

# Pick a sesh session using bash select menu
pick_with_select()
{
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

# Cascading tool detection — gum first because the script is invoked
# from inside a tmux popup (display-popup -E in tmux.conf); gum filter
# is the only fuzzy picker that renders inline in that context.
if command -v gum &> /dev/null; then
  selection=$(pick_with_gum)
elif command -v fzf &> /dev/null; then
  selection=$(pick_with_fzf)
else
  selection=$(pick_with_select)
fi

if [[ -n "${selection-}" ]]; then
  sesh connect "$selection"
fi
