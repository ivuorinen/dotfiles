#!/bin/bash

NTFY_VERSION=2.2.0
NTFY_URL="https://github.com/binwiederhier/ntfy"
NTFY_DEST="ntfy_${NTFY_VERSION}_macOS_all"

curl -L "$NTFY_URL/releases/download/v${NTFY_VERSION}/${NTFY_DEST}.tar.gz" > "${NTFY_DEST}.tar.gz"
tar zxvf "${NTFY_DEST}.tar.gz"
cp -a "${NTFY_DEST}/ntfy" ~/.local/bin/ntfy
mkdir -p ~/.config/ntfy
cp "${NTFY_DEST}/client/client.yml" ~/.config/ntfy/client.yml
ntfy --help
rm -rf "${NTFY_DEST}" "${NTFY_DEST}.tar.gz"
