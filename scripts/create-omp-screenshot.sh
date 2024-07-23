#!/usr/bin/env bash
#
# Export oh-my-posh configuration as an image
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

main()
{
  cd "$DOTFILES" || msg_err "Failed to change directory to $DOTFILES"

  oh-my-posh config export image \
    --config "$OHMYPOSH_CFG" \
    --output "$HOME/.dotfiles/.github/screenshots/oh-my-posh.png" \
    --author "Ismo Vuorinen"
}

main "$@"
