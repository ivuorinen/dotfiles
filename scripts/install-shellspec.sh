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
  local version
  version=$(x-gh-get-latest-version shellspec/shellspec)
  msgr ok "Latest shellspec version: $version"

  if [[ -d "$SHELLSPEC_CACHE" ]]; then
    msgr ok "shellspec repo already cloned, fetching $version..."
    git -C "$SHELLSPEC_CACHE" fetch --depth=1 origin "refs/tags/$version"
    git -C "$SHELLSPEC_CACHE" checkout "$version"
  else
    git clone --branch "$version" --depth=1 "$SHELLSPEC_REPO" "$SHELLSPEC_CACHE"
  fi

  msgr run "Running make install..."
  make -C "$SHELLSPEC_CACHE" install PREFIX="$HOME/.local"
  msgr run_done "shellspec $version installed to $HOME/.local/bin/shellspec"
  return 0
}

main()
{
  install_shellspec
  return 0
}

main "$@"
