#!/usr/bin/env bash
set -euo pipefail
# @description Install ntfy
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

# Check if ntfy is already installed
if x-have "ntfy"; then
  msgr "done" "ntfy already installed"
  exit 0
fi

# Determine the architecture
case $(dfm check arch) in
  Linux)
    NTFY_ARCH="linux_$(arch)"
    ;;
  Darwin)
    NTFY_ARCH="macOS_all"
    ;;
  *)
    msgr err "Unsupported OS"
    exit 1
    ;;
esac

NTFY_VERSION="$(x-gh-get-latest-version binwiederhier/ntfy)"
NTFY_URL="https://github.com/binwiederhier/ntfy"
NTFY_TARBALL="ntfy_${NTFY_VERSION}_${NTFY_ARCH}.tar.gz"
NTFY_DIR="ntfy_${NTFY_VERSION}_${NTFY_ARCH}"

# Download and extract ntfy
install_ntfy()
{
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  curl -L "$NTFY_URL/releases/download/v${NTFY_VERSION}/${NTFY_TARBALL}" -o "$tmpdir/${NTFY_TARBALL}"
  tar zxvf "$tmpdir/${NTFY_TARBALL}" -C "$tmpdir"
  cp -a "$tmpdir/${NTFY_DIR}/ntfy" ~/.local/bin/ntfy
  mkdir -p ~/.config/ntfy

  # Copy config only if it does not exist
  if [ ! -f "$HOME/.config/ntfy/client.yml" ]; then
    cp "$tmpdir/${NTFY_DIR}/client/client.yml" ~/.config/ntfy/client.yml
  fi
}

main()
{
  install_ntfy
  msgr "done" "ntfy installation complete"
}

main "$@"
