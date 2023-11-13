#!/usr/bin/env bash
#
# Install ntfy
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"
set -e

x-have "ntfy" && msg "ntfy already installed" && exit 0

case $(dfm check arch) in
  Linux)
    NTFY_ARCH="linux_$(arch)"
    ;;
  Darwin)
    NTFY_ARCH="macOS_all"
    ;;
esac

NTFY_VERSION=2.2.0
NTFY_URL="https://github.com/binwiederhier/ntfy"
NTFY_DEST="ntfy_${NTFY_VERSION}_${NTFY_ARCH}"

curl -L "$NTFY_URL/releases/download/v${NTFY_VERSION}/${NTFY_DEST}.tar.gz" \
  > "${NTFY_DEST}.tar.gz"
tar zxvf "${NTFY_DEST}.tar.gz"
cp -a "${NTFY_DEST}/ntfy" ~/.local/bin/ntfy
mkdir -p ~/.config/ntfy

# copy config only if it does not exist
if [ ! -f "$HOME/.config/ntfy/client.yml" ]; then
  cp "${NTFY_DEST}/client/client.yml" ~/.config/ntfy/client.yml
fi

rm -rf "${NTFY_DEST}" "${NTFY_DEST}.tar.gz"
