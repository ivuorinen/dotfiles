#!/bin/bash

NFTY_VERSION=2.2.0

curl -L "https://github.com/binwiederhier/ntfy/releases/download/v${NFTY_VERSION}/ntfy_${NFTY_VERSION}_macOS_all.tar.gz" > "ntfy_${NFTY_VERSION}_macOS_all.tar.gz"
tar zxvf "ntfy_${NFTY_VERSION}_macOS_all.tar.gz"
cp -a "ntfy_${NFTY_VERSION}_macOS_all/ntfy" ~/.local/bin/ntfy
mkdir -p ~/.config/ntfy 
cp "ntfy_${NFTY_VERSION}_macOS_all/client/client.yml" ~/.config/ntfy/client.yml
ntfy --help
rm -rf "ntfy_${NFTY_VERSION}_macOS_all" "ntfy_${NFTY_VERSION}_macOS_all.tar.gz"
