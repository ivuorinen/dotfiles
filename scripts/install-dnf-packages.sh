#!/usr/bin/env bash
set -euo pipefail
# @description Install essential dnf packages for development.
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

msgr run "Starting to install dnf packages"

if ! command -v dnf &> /dev/null; then
  msgr warn "dnf not found (not a Fedora/RHEL-based system)"
  exit 0
fi

packages=(
  # Build essentials (individual packages, group handled separately)
  cmake              # Cross-platform build system
  pkgconfig          # Helper for compiling against libraries
  autoconf           # Automatic configure script builder
  automake           # Makefile generator
  libtool            # Generic library support script

  # Libraries for compiling languages
  openssl-devel      # SSL development headers
  libffi-devel       # Foreign function interface
  zlib-devel         # Compression library
  readline-devel     # Command-line editing
  bzip2-devel        # Bzip2 compression
  sqlite-devel       # SQLite database
  ncurses-devel      # Terminal UI library

  # CLI utilities (not in cargo/go/npm)
  jq                 # JSON processor
  tmux               # Terminal multiplexer
  tree               # Directory listing
  unzip              # Archive extraction
  ShellCheck         # Shell script linter
  socat              # Multipurpose network relay
  gnupg2             # GPG encryption/signing
)

install_dev_tools_group()
{
  if dnf group list installed 2>/dev/null | grep -q "Development Tools"; then
    msgr ok "@development-tools group already installed"
  else
    msgr run "Installing @development-tools group"
    sudo dnf group install -y "Development Tools"
  fi
  return 0
}

install_packages()
{
  local to_install=()

  for pkg in "${packages[@]}"; do
    pkg="${pkg%%#*}"
    pkg="${pkg// /}"
    [[ -z "$pkg" ]] && continue

    if rpm -q "$pkg" &> /dev/null; then
      msgr ok "$pkg already installed"
    else
      to_install+=("$pkg")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    msgr run "Installing ${#to_install[@]} packages: ${to_install[*]}"
    sudo dnf install -y "${to_install[@]}"
  else
    msgr ok "All packages already installed"
  fi
  return 0
}

main()
{
  install_dev_tools_group
  install_packages
  msgr yay "dnf package installations complete"
  return 0
}

main "$@"
