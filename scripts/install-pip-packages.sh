#!/usr/bin/env bash
# Install python/pip packages.
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

msgr run "Starting to install pip packages"

if ! command -v python3 &> /dev/null; then
  msgr err "Could not find python3, something really weird is going on."
  exit 1
fi

msgr nested "Upgrading pip"
python3 -m pip install --user --upgrade pip

packages=(
  "pipx"
  "libtmux"
)

# Function to install pip packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Trim spaces
    pkg=${pkg// /}
    # Skip comments
    if [[ ${pkg:0:1} == "#" ]]; then continue; fi

    msgr nested "Installing pip package: $pkg"
    python3 -m pip install --user --upgrade "$pkg"
    echo ""
  done
}

install_packages
msgr run_done "Run pip package installations"
