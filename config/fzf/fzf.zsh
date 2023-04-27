# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/ivuorinen/.config/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/ivuorinen/.config/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/ivuorinen/.config/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/ivuorinen/.config/fzf/shell/key-bindings.zsh"
