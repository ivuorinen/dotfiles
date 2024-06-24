#!/usr/bin/env bash
# Install cargo/rust packages.
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/config/exports"
source "$HOME/.dotfiles/config/alias"
source "$HOME/.dotfiles/config/functions"
source "$HOME/.dotfiles/scripts/shared.sh"

msg "Starting to install rust/cargo packages"

! x-have cargo && {
  msg "cargo could not be found. installing cargo with rustup.rs"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
}

source "$CARGO_HOME/env"

! x-have rustup && {
  msg_err "rustup could not be found. Aborting..."
  exit 1
}

rustup default stable

# If we have cargo install-update, use it first
x-have cargo-install-update && {
  msg_run "Updating cargo packages with cargo install-update"
  cargo install-update -a
  msg_done "Done with cargo install-update"
}

packages=(
  # A cargo subcommand for checking and applying
  # updates to installed executables
  "cargo-update"
  # Cargo cache management utility
  "cargo-cache"
  # An incremental parsing system for programming tools
  "tree-sitter-cli"
  # a subprocess caching utility
  "bkt"
  # a structural diff that understands syntax
  "difftastic"
  # a modern replacement for ls.
  "eza"
  # A simple, fast and user-friendly alternative to 'find'
  "fd-find"
  # recursively searches directories for a
  # regex pattern while respecting your gitignore
  "ripgrep"
  # A version manager for neovim
  "bob-nvim"
  "bottom"
)

# Number of jobs to run in parallel, this helps to keep the system responsive
BUILD_JOBS=$(nproc --ignore=2)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  msg_run "Installing cargo package $pkg"
  cargo install --jobs $BUILD_JOBS "$pkg"

  echo ""
done

msg_done "Installed cargo packages!"

msg_run "Now doing the next steps for cargo packages"

# use bob to install latest stable nvim
x-have bob && {
  bob use stable && x-path-append "$XDG_DATA_HOME/bob/nvim-bin"
}

msg_run "Removing cargo cache"
cargo cache --autoclean
msg_done "Done removing cargo cache"

