#!/usr/bin/env bash
# @description Install cargo/rust packages.
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/config/shared.sh"

msgr run "Starting to install rust/cargo packages"

source "$CARGO_HOME/env"

# If we have cargo install-update, use it first
if command -v cargo-install-update &> /dev/null; then
  msgr run "Updating cargo packages with cargo install-update"
  cargo install-update -a
  msgr run_done "Done with cargo install-update"
fi

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

# Function to install cargo packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Trim spaces
    pkg=${pkg// /}
    # Skip comments
    if [[ ${pkg:0:1} == "#" ]]; then continue; fi

    msgr run "Installing cargo package $pkg"
    cargo install --jobs $BUILD_JOBS "$pkg"
    msgr run_done "Done installing $pkg"
    echo ""
  done
}

# Function to perform additional steps for installed cargo packages
post_install_steps()
{
  msgr run "Now doing the next steps for cargo packages"

  # use bob to install latest stable nvim
  if command -v bob &> /dev/null; then
    bob use stable && x-path-append "$XDG_DATA_HOME/bob/nvim-bin"
  fi

  msgr run "Removing cargo cache"
  cargo cache --autoclean
  msg_done "Done removing cargo cache"
}

main()
{
  install_packages
  msg_done "Installed cargo packages!"
  post_install_steps
}

main "$@"
