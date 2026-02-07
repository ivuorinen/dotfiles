#!/usr/bin/env bash
set -euo pipefail
# @description Install npm packages globally.
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

msgr msg "Starting to install npm packages"

if ! command -v npm &> /dev/null; then
  msgr err "npm could not be found."
  exit 0
fi

packages=(
  editorconfig-checker   # Check files against .editorconfig rules
  github-release-notes   # Create release notes from tags and issues
  neovim                 # Neovim node client
  corepack               # Node.js package manager version management
)

# Function to install npm packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Strip inline comments and trim whitespace
    pkg="${pkg%%#*}"
    pkg="${pkg// /}"
    [[ -z "$pkg" ]] && continue

    if npm ls -g -p "$pkg" &> /dev/null; then
      msgr run_done "$pkg" "already installed"
    else
      msgr run "Installing npm package:" "$pkg"
      npm install -g --no-fund --no-progress --no-timing "$pkg"
    fi
    echo ""
  done
  return 0
}

# Function to upgrade all global npm packages
upgrade_global_packages()
{
  msgr run "Upgrading all global packages"
  npm -g --no-progress --no-timing --no-fund outdated
  npm -g --no-timing --no-fund upgrade
  return 0
}

# Function to clean npm cache
clean_npm_cache()
{
  msgr run "Cleaning up npm cache"
  npm cache verify
  npm cache clean --force
  npm cache verify
  return 0
}

main()
{
  install_packages
  upgrade_global_packages
  clean_npm_cache
  msgr yay "npm package installations complete"
  return 0
}

main "$@"
