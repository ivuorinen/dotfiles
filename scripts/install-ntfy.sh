#!/usr/bin/env bash
#
# Install ntfy
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

# Check if ntfy is already installed
if x-have "ntfy"; then
  msgr done "ntfy already installed"
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
    ;;
esac

NTFY_VERSION="$(x-gh-get-latest-version binwiederhier/ntfy)"
NTFY_URL="https://github.com/binwiederhier/ntfy"
NTFY_DEST="/tmp/ntfy_${NTFY_VERSION}_${NTFY_ARCH}"

# Download and extract ntfy
install_ntfy()
{
  curl -L "$NTFY_URL/releases/download/v${NTFY_VERSION}/${NTFY_DEST}.tar.gz" -o "${NTFY_DEST}.tar.gz"
  tar zxvf "${NTFY_DEST}.tar.gz"
  cp -a "${NTFY_DEST}/ntfy" ~/.local/bin/ntfy
  mkdir -p ~/.config/ntfy

  # Copy config only if it does not exist
  if [ ! -f "$HOME/.config/ntfy/client.yml" ]; then
    cp "${NTFY_DEST}/client/client.yml" ~/.config/ntfy/client.yml
  fi

  # Clean up
  rm -rf "${NTFY_DEST}" "${NTFY_DEST}.tar.gz"
}

main()
{
  install_ntfy
  msgr done "ntfy installation complete"
}

main "$@"
