#!/usr/bin/env zsh
# Install npm packages globally.

source "$HOME/.dotfiles/scripts/shared.sh"

if ! command -v npm &> /dev/null; then
  msg_err "npm could not be found."
  exit 1
fi

packages=(
  # This is a tool to check if your files consider your .editorconfig rules.
  "editorconfig-checker"
)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  msg_run "Installing npm package:" "$pkg"
  npm install -g --force "$pkg"
  echo ""
done

