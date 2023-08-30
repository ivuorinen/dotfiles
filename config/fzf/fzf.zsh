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
