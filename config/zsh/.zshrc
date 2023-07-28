autoload -U colors zsh/terminfo
colors
setopt correct

# Add completion scripts to zsh path
FPATH="~/.config/zsh/completion:$FPATH"
autoload -Uz compinit && compinit -i
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

# Defaults
export DOTFILES="$HOME/.dotfiles"
# shellcheck source=shared.sh
source "$DOTFILES/scripts/shared.sh"

# Run x-load-configs in your terminal to reload the files.
function x-load-configs()
{
  # Load the shell dotfiles, and then some:
  for file in $DOTFILES/config/{exports,alias,functions}; do
    [ -f "$file" ] && source "$file"
    [ -f "$file-secret" ] && source "$file-secret"
    [ -f "$file-$HOSTNAME" ] && source "$file-$HOSTNAME"
    [ -f "$file-$HOSTNAME-secret" ] && source "$file-$HOSTNAME-secret"
  done
}
x-load-configs

# Import ssh keys in keychain
ssh-add -A 2>/dev/null;

# Try to load antigen, if present
ANTIGEN_ZSH_PATH="$XDG_BIN_HOME/antigen.zsh"
[[ -f "$ANTIGEN_ZSH_PATH" ]] && source "$ANTIGEN_ZSH_PATH"

# antigen is present
have antigen && {
  antigen use oh-my-zsh

  # config/functions
  x-default-antigen-bundles

  antigen apply
}

# starship is present
have starship && eval "$(starship init zsh)"

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] \
  && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh

export LESSHISTFILE="$XDG_CACHE_HOME"/less_history
