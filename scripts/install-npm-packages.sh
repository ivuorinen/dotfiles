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
  # Node module to create a release or a changelog from
  # a tag and uses issues or commits to creating the release notes.
  "github-release-notes"
  "neovim"
  "prettier"
  "@bchatard/alfred-jetbrains"
  "@johnnymorganz/stylua-bin"
  "js-debug"
  "stylelint-lsp"
  "blade-formatter"
)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  msg_run "Installing npm package:" "$pkg"
  npm install -g --force --no-fund --no-progress --no-timing "$pkg"
  echo ""
done

