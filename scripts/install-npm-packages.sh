#!/usr/bin/env bash
# Install npm packages globally.
#
# shellcheck source=shared.sh

echo "This file has been deprecated in favor of asdf. Please use asdf instead."
exit 0

eval "$DOTFILES/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

msg "Starting to install npm packages"

if ! command -v npm &> /dev/null; then
  msg_err "npm could not be found."
  exit 0
fi

packages=(
  # This is a tool to check if your files consider your .editorconfig rules.
  "editorconfig-checker"
  # Node module to create a release or a changelog from
  # a tag and uses issues or commits to creating the release notes.
  "github-release-notes"
  "neovim"
  "corepack"
)

# Function to install npm packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Trim spaces
    pkg=${pkg// /}
    # Skip comments
    if [[ ${pkg:0:1} == "#" ]]; then continue; fi

    if npm ls -g -p "$pkg" &> /dev/null; then
      msg_run_done "$pkg" "already installed"
    else
      msg_run "Installing npm package:" "$pkg"
      npm install -g --no-fund --no-progress --no-timing "$pkg"
    fi
    echo ""
  done
}

# Function to upgrade all global npm packages
upgrade_global_packages()
{
  msg_run "Upgrading all global packages"
  npm -g --no-progress --no-timing --no-fund outdated
  npm -g --no-timing --no-fund upgrade
}

# Function to clean npm cache
clean_npm_cache()
{
  msg_run "Cleaning up npm cache"
  npm cache verify
  npm cache clean --force
  npm cache verify
}

main()
{
  install_packages
  upgrade_global_packages
  clean_npm_cache
  msg_yay "npm package installations complete"
}

main "$@"
