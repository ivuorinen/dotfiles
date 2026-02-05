#!/usr/bin/env bash
set -euo pipefail
# @description Install Python packages using uv.
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

msgr run "Starting to install Python packages"

# Ensure uv is available
if ! command -v uv &> /dev/null; then
  msgr nested "uv not found, installing via official installer"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# CLI tools — installed isolated with `uv tool install`
tools=(
  ansible                # IT automation and configuration management
  openapi-python-client  # Generate Python API clients from OpenAPI specs
)

# Library packages — installed into system Python with `uv pip install --system`
libraries=(
  libtmux    # Python API for tmux
  pynvim     # Neovim Python client
)

# Function to install CLI tools via uv tool install
install_tools()
{
  msgr run "Installing Python CLI tools"
  for pkg in "${tools[@]}"; do
    # Strip inline comments and trim whitespace
    pkg="${pkg%%#*}"
    pkg="${pkg// /}"
    [[ -z "$pkg" ]] && continue

    msgr nested "Installing tool: $pkg"
    uv tool install --upgrade "$pkg"
    echo ""
  done
}

# Function to install library packages via uv pip install
install_libraries()
{
  msgr run "Installing Python libraries"
  for pkg in "${libraries[@]}"; do
    # Strip inline comments and trim whitespace
    pkg="${pkg%%#*}"
    pkg="${pkg// /}"
    [[ -z "$pkg" ]] && continue

    msgr nested "Installing library: $pkg"
    uv pip install --system --upgrade "$pkg"
    echo ""
  done
}

# Function to upgrade all uv-managed tools
upgrade_tools()
{
  msgr run "Upgrading all uv-managed tools"
  uv tool upgrade --all
}

main()
{
  install_tools
  install_libraries
  upgrade_tools
  msgr yay "Python package installations complete"
}

main "$@"
