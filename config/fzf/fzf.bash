# Setup fzf
# ---------

# Auto-completion
# ---------------
# shellcheck source=completion.bash
[[ $- == *i* ]] && source "$HOME/.dotfiles/config/fzf/completion.bash" 2> /dev/null

# Key bindings
# ------------
# shellcheck source=key-bindings.bash
source "$HOME/.dotfiles/config/fzf/key-bindings.bash"

# Catppuccin palette — published by config/theme/handlers.d/fzf as a
# symlink in the orchestrator state dir. Sourced last so it overrides
# any FZF_DEFAULT_OPTS set earlier in shell init.
# shellcheck source=/dev/null
_fzf_active="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/fzf-active.sh"
[[ -r "$_fzf_active" ]] && source "$_fzf_active"
unset _fzf_active
