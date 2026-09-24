# Setup fzf
# ---------
# Key bindings and completion come from the mise-installed fzf itself
# (`fzf --bash`), so they always match the binary. lib::init_cached
# (config/lib.sh) keeps the generated script in $XDG_CACHE_HOME/shell-init
# and rebuilds it when the mise config changes, so startup does not pay
# for running fzf on every shell.
command -v fzf > /dev/null 2>&1 && lib::init_cached fzf fzf --bash

# Catppuccin palette — published by config/theme/handlers.d/fzf as a
# symlink in the orchestrator state dir. Sourced last so it overrides
# any FZF_DEFAULT_OPTS set earlier in shell init.
_fzf_active="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/fzf-active.sh"
# shellcheck source=/dev/null
[[ -r "$_fzf_active" ]] && source "$_fzf_active"
unset _fzf_active
