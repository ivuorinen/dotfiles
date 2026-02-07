#!/usr/bin/env bash
set -euo pipefail
# @description Install git-crypt
#
# NOTE: Experimental, wip
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

msgr run "Installing git-crypt"

if ! command -v git-crypt &> /dev/null; then
  REPO_URL="https://github.com/AGWA/git-crypt.git"
  CHECK_PATH="${XDG_BIN_HOME}/git-crypt"
  BUILD_PATH="$(mktemp -d)"
  trap 'rm -rf "$BUILD_PATH"' EXIT

  if [[ ! -f "$CHECK_PATH" ]]; then
    git clone --depth 1 "$REPO_URL" "$BUILD_PATH" || { msgr err "Failed to clone $REPO_URL"; exit 1; }
    cd "$BUILD_PATH" || { msgr err "$BUILD_PATH not found"; exit 1; }
    make && make install PREFIX="$HOME/.local"
  else
    msgr run_done "git-crypt ($CHECK_PATH) already installed"
  fi
fi

msgr run_done "Done installing git-crypt"
