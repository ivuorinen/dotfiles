#!/usr/bin/env bash
set -euo pipefail
# @description Install shellspec testing framework
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

SHELLSPEC_REPO="https://github.com/shellspec/shellspec.git"
SHELLSPEC_CACHE="$HOME/.cache/shellspec"

install_shellspec()
{
  if [[ -d "$SHELLSPEC_CACHE" ]]; then
    msgr ok "shellspec repo already cloned, pulling latest..."
    git -C "$SHELLSPEC_CACHE" pull --quiet
  else
    git clone --depth 1 "$SHELLSPEC_REPO" "$SHELLSPEC_CACHE"
  fi

  msgr run "Running make install..."
  make -C "$SHELLSPEC_CACHE" install PREFIX="$HOME/.local"
  msgr run_done "shellspec installed to $HOME/.local/bin/shellspec"
  return 0
}

main()
{
  install_shellspec
  return 0
}

main "$@"
