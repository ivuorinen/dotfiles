#!/usr/bin/env bash
# Install cargo/rust packages.
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

msg "Starting to install rust/cargo packages"

! have cargo && {
  msg "cargo could not be found. installing cargo with rustup.rs"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
}

source "$CARGO_HOME/env"

packages=(
  # An incremental parsing system for programming tools
  "tree-sitter-cli"
  # a subprocess caching utility
  "bkt"
  # a structural diff that understands syntax
  "difftastic"
  # a modern replacement for ‘ls’.
  "eza"
  # A simple, fast and user-friendly alternative to 'find'
  "fd-find"
  # A cargo subcommand for checking and applying
  # updates to installed executables
  "cargo-update"
  # recursively searches directories for a
  # regex pattern while respecting your gitignore
  "ripgrep"
  # A version manager for neovim
  "bob-nvim"
)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  msg_run "Installing cargo package $pkg"
  cargo install "$pkg"

  echo ""
done

msg_done "Installed cargo packages!"

msg_run "Now doing the next steps for cargo packages"

# use bob to install nvim
have bob && {
  bob use stable && path_append "$XDG_DATA_HOME/bob/nvim-bin"
}

msg_done "All next steps done!"
