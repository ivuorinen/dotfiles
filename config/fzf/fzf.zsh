#!/usr/bin/env zsh
# shellcheck disable=SC1071
# Setup fzf
# ---------
# Key bindings and completion come from the mise-installed fzf itself
# (`fzf --zsh`), cached by lib::init_cached — see notes in fzf.bash.
command -v fzf > /dev/null 2>&1 && lib::init_cached fzf fzf --zsh
