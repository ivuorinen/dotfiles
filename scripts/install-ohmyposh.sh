#!/usr/bin/env zsh
#
# Install oh-my-posh
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

msg "Starting to install oh-my-posh"

# Install oh-my-posh
install_oh_my_posh()
{
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
  msg "oh-my-posh installed to ~/.local/bin"
}

# Initialize oh-my-posh
init_oh_my_posh()
{
  eval "$(oh-my-posh init zsh --config $OHMYPOSH_CFG)"
  msg "oh-my-posh initialized with config $OHMYPOSH_CFG"
}

main()
{
  install_oh_my_posh
  init_oh_my_posh
}

main "$@"
