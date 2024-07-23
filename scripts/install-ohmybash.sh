#!/usr/bin/env bash
#
# Install oh-my-bash
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

set -euo pipefail

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

OSH="$HOME/.local/share/oh-my-bash"

# Function to install oh-my-bash
install_oh_my_bash()
{
  if [ ! -d "$OSH" ]; then
    [ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.temp"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
    [ -f "$HOME/.bashrc.temp" ] && mv "$HOME/.bashrc.temp" "$HOME/.bashrc"
    msg "oh-my-bash installed to $OSH"
  else
    msg_done "oh-my-bash ($OSH) already installed"
  fi
}

main()
{
  install_oh_my_bash
}

main "$@"
