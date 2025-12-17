# Setup fzf
# ---------

# Auto-completion
# ---------------
# shellcheck source=completion.bash
[[ $- == *i* ]] && source "$HOME/.dotfiles/config/fzf/completion.bash" 2>/dev/null

# Key bindings
# ------------
# shellcheck source=key-bindings.bash
source "$HOME/.dotfiles/config/fzf/key-bindings.bash"
