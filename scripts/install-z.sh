#!/usr/bin/env bash
set -euo pipefail
# @description Install z
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

Z_GIT_PATH="https://github.com/rupa/z.git"
Z_BIN_PATH="$XDG_BIN_HOME/z"

# Function to clone the z repository
clone_z_repo()
{
  local git_path=$1
  local bin_path=$2

  if [[ ! -d "$bin_path" ]]; then
    git clone "$git_path" "$bin_path"
    msgr run_done "z installed at $bin_path"
  else
    msgr ok "z ($bin_path/) already installed"
  fi
  return 0
}

# Main function
main()
{
  clone_z_repo "$Z_GIT_PATH" "$Z_BIN_PATH"
  return 0
}

main "$@"
