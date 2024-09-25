#!/usr/bin/env bash
#
# Install fzf
#

echo "This file ($0) has been deprecated in favor of asdf. Please use asdf instead."
exit 0

# shellcheck source=shared.sh
eval "$DOTFILES/config/shared.sh"

FZF_GIT="https://github.com/junegunn/fzf.git"
FZF_PATH="${XDG_CONFIG_HOME}/fzf"
FZF_BUILD="/tmp/fzf"

main()
{
  if [ ! -d "$FZF_BUILD" ]; then
    git clone --depth 1 "$FZF_GIT" "$FZF_BUILD"
    "$FZF_BUILD/install" \
      --xdg \
      --bin
    msg_done "fzf installed"
  else
    msg_done "fzf ($FZF_PATH/) already installed"
  fi
}

main "$@"
