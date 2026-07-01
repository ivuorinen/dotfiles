#!/usr/bin/env bash
# Unified sesh session picker with cascading tool detection:
#   1. tv      — television fuzzy finder; full TUI, renders in popup
#   2. fzf     — rich UI inline with dynamic reload bindings
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

# Seed zoxide in the background for fresh list -z results
command -v zoxide-seed > /dev/null 2>&1 && zoxide-seed > /dev/null 2>&1 &

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

# Pick a sesh session using television
pick_with_tv()
{
  tv sesh
}

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

# Cascading tool detection — tv is the primary picker; fzf provides the
# richer dynamic reload bindings as fallback. Both render correctly
# inside a tmux popup (display-popup -E in tmux.conf).
#
# A tv FAILURE (missing channel, crash, broken config) must fall through
# to fzf, not abort: under `set -e`, `selection=$(pick_with_tv)` would
# kill the script the instant tv exits non-zero, and display-popup -E
# closes on exit — so the error just flashes past unread. tv exits 0 on
# both a normal pick and a user cancel, so only a genuine failure cascades.
selection=""
tv_ok=0
if command -v tv &> /dev/null; then
  if selection=$(pick_with_tv); then
    tv_ok=1
  else
    printf 'sesh.sh: tv picker failed (exit %d); falling back\n' "$?" >&2
  fi
fi

if [[ $tv_ok -eq 0 ]]; then
  if command -v fzf &> /dev/null; then
    selection=$(pick_with_fzf)
  else
    selection=$(pick_with_select)
  fi
fi

if [[ -n "${selection-}" ]]; then
  sesh connect "$selection"
fi
