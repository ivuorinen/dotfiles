#!/usr/bin/env bash
# Install npm packages globally.
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

msg "Starting to install npm packages"

! x-have "npm" && msg_err "npm could not be found." && exit 0

packages=(
  # This is a tool to check if your files consider your .editorconfig rules.
  "editorconfig-checker"
  # Node module to create a release or a changelog from
  # a tag and uses issues or commits to creating the release notes.
  "github-release-notes"
  "neovim"
  "corepack"
)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  if [[ $(npm ls -g -p "$pkg") != "" ]]; then
    msg_run_done "$pkg" "already installed"
  else
    msg_run "Installing npm package:" "$pkg"
    npm install -g --no-fund --no-progress --no-timing "$pkg"
  fi

  echo ""
done

msg_run "Upgrading all global packages"
npm -g --no-progress --no-timing --no-fund outdated
npm -g --no-timing --no-fund upgrade

msg_run "Cleaning up npm cache"
npm cache verify
npm cache clean --force
npm cache verify
