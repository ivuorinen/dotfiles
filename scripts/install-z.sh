#!/usr/bin/env bash
#
# Install z
#
# shellcheck source=shared.sh
eval "$HOME/.dotfiles/scripts/shared.sh"

Z_GIT_PATH="https://github.com/rupa/z.git"
Z_BIN_PATH="$XDG_BIN_HOME/z"

if [ ! -d "$Z_BIN_PATH" ]; then
  git clone "$Z_GIT_PATH" "$Z_BIN_PATH"
else
  msg_done "z ($Z_BIN_PATH/) already installed"
fi
