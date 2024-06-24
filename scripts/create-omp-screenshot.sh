#!/usr/bin/env bash
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"
set -e

cd "$DOTFILES" || exit
oh-my-posh config export image \
  --config "$OHMYPOSH_CFG" \
  --output "$HOME/.dotfiles/.github/screenshots/oh-my-posh.png" \
  --author "Ismo Vuorinen"
