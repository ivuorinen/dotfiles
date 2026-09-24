#!/usr/bin/env zsh
# shellcheck disable=SC1071
# Setup fzf
# ---------
# Key bindings and completion come from the mise-installed fzf itself
# (`fzf --zsh`), cached by lib::init_cached — see notes in fzf.bash.
command -v fzf > /dev/null 2>&1 && lib::init_cached fzf fzf --zsh

# Catppuccin palette — see notes in fzf.bash. Same state-dir symlink,
# zsh-compatible source.
_fzf_active="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/fzf-active.sh"
[[ -r "$_fzf_active" ]] && source "$_fzf_active"
unset _fzf_active
