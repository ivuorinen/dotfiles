#!/usr/bin/env zsh
#
# Install oh-my-posh
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

OHMYPOSH_CFG="$HOME/.dotfiles/config/oh-my-posh.omp.json"

eval "$(oh-my-posh init zsh --config $OHMYPOSH_CFG)"

#cd ~/.dotfiles || exit
#oh-my-posh config export image \
#  --config "$OHMYPOSH_CFG" \
#  --output "~/.dotfiles/.github/screenshots/oh-my-posh.png" \
#  --author "Ismo Vuorinen"
