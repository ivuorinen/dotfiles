#!/usr/bin/env zsh
#
# Install oh-my-posh
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

eval "$(oh-my-posh init zsh --config $OHMYPOSH_CFG)"

