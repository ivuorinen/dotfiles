#!/usr/bin/env bash
set -euo pipefail
# @description Install Python libraries via uv pip (tools are managed by mise).
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

msgr run "Starting to install Python libraries"

# Ensure uv is available
if ! command -v uv &> /dev/null; then
  msgr err "uv not found — install it via mise first"
  exit 1
fi

# Library packages — installed into system Python with `uv pip install --system`
libraries=(
  libtmux # Python API for tmux
  pynvim  # Neovim Python client
)

# Function to install library packages via uv pip install
install_libraries()
{
  for pkg in "${libraries[@]}"; do
    # Strip inline comments and trim whitespace
    pkg="${pkg%%#*}"
    pkg="${pkg// /}"
    [[ -z "$pkg" ]] && continue

    msgr nested "Installing library: $pkg"
    uv pip install --system --upgrade "$pkg"
    echo ""
  done
  return 0
}

install_libraries
msgr yay "Python library installations complete"
