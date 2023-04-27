#!/usr/bin/env bash
#
# Install fzf
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

FZF_GIT="https://github.com/junegunn/fzf.git"
FZF_PATH="${XDG_CONFIG_HOME}/fzf"

if [ ! -d "$FZF_PATH" ]; then
  git clone --depth 1 "$FZF_GIT" "$FZF_PATH"
  $FZF_PATH/install --xdg --all --no-update-rc
else
  msg_done "fzf ($FZF_PATH/) already installed"
fi

