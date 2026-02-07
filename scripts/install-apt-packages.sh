#!/usr/bin/env bash
set -euo pipefail
# @description Install essential apt packages for development.
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

msgr run "Starting to install apt packages"

if ! command -v apt &> /dev/null; then
  msgr warn "apt not found (not a Debian-based system)"
  exit 0
fi

packages=(
  # Build essentials
  build-essential    # gcc, g++, make
  cmake              # Cross-platform build system
  pkg-config         # Helper for compiling against libraries
  autoconf           # Automatic configure script builder
  automake           # Makefile generator
  libtool            # Generic library support script

  # Libraries for compiling languages
  libssl-dev         # SSL development headers
  libffi-dev         # Foreign function interface
  zlib1g-dev         # Compression library
  libreadline-dev    # Command-line editing
  libbz2-dev         # Bzip2 compression
  libsqlite3-dev     # SQLite database
  libncurses-dev     # Terminal UI library

  # CLI utilities (not in cargo/go/npm)
  jq                 # JSON processor
  tmux               # Terminal multiplexer
  tree               # Directory listing
  unzip              # Archive extraction
  shellcheck         # Shell script linter
  socat              # Multipurpose network relay
  gnupg              # GPG encryption/signing
  software-properties-common  # add-apt-repository command
)

install_packages()
{
  local to_install=()

  for pkg in "${packages[@]}"; do
    pkg="${pkg%%#*}"
    pkg="${pkg// /}"
    [[ -z "$pkg" ]] && continue

    if dpkg -s "$pkg" &> /dev/null; then
      msgr ok "$pkg already installed"
    else
      to_install+=("$pkg")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    msgr run "Installing ${#to_install[@]} packages: ${to_install[*]}"
    sudo apt update
    sudo apt install -y "${to_install[@]}"
  else
    msgr ok "All packages already installed"
  fi
  return 0
}

main()
{
  install_packages
  msgr yay "apt package installations complete"
  return 0
}

main "$@"
