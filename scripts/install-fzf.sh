#!/usr/bin/env bash
#
# Install fzf
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

FZF_GIT="https://github.com/junegunn/fzf.git"
FZF_PATH="${XDG_CONFIG_HOME}/fzf"
FZF_BUILD="/tmp/fzf"

if [ ! -d "$FZF_BUILD" ]; then
  git clone --depth 1 "$FZF_GIT" "$FZF_BUILD"
  "$FZF_BUILD/install" \
    --xdg \
    --bin
else
  msg_done "fzf ($FZF_PATH/) already installed"
fi
