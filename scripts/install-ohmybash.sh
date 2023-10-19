#!/usr/bin/env bash
#
# Install oh-my-bash
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

export OSH="$HOME/.local/share/oh-my-bash"

if [ ! -d "$OSH" ]; then
  [ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.temp"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
  [ -f "$HOME/.bashrc.temp" ] && mv "$HOME/.bashrc.temp" "$HOME/.bashrc"
else
  msg_done "oh-my-bash ($OSH) already installed"
fi
