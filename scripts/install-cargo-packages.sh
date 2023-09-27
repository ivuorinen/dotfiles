#!/usr/bin/env bash
# Install cargo/rust packages.
#
# shellcheck source=shared.sh
DOTFILES_SHARED_LOADED=""
source "$HOME/.dotfiles/scripts/shared.sh"

! have cargo && {
  msg "cargo could not be found. installing cargo with rustup.rs"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
}

packages=(
  # a subprocess caching utility
  "bkt"
  # a structural diff that understands syntax
  "difftastic"
  # a modern replacement for ‘ls’.
  "eza"
  # A simple, fast and user-friendly alternative to 'find'
  "fd-find"
  "cargo-update"
  "pijul"
  "ripgrep"
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
