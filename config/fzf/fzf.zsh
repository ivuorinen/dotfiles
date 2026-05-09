#!/usr/bin/env zsh
# shellcheck disable=SC1071
# Setup fzf
# ---------

# Auto-completion
# ---------------
# shellcheck source=completion.zsh
[[ $- == *i* ]] && source "$HOME/.dotfiles/config/fzf/completion.zsh" 2> /dev/null

# Key bindings
# ------------
# shellcheck source=key-bindings.zsh
source "$HOME/.dotfiles/config/fzf/key-bindings.zsh"

# Catppuccin palette — see notes in fzf.bash. Same state-dir symlink,
# zsh-compatible source.
_fzf_active="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/fzf-active.sh"
[[ -r "$_fzf_active" ]] && source "$_fzf_active"
unset _fzf_active
