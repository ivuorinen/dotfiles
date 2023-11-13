#!/usr/bin/env bash
#
# Install neofetch from source
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

NEOFETCH_VERSION="7.1.0"
NEOFETCH_REPO="https://github.com/dylanaraps/neofetch"
NEOFETCH_URL="${NEOFETCH_REPO}/archive/refs/tags/${NEOFETCH_VERSION}.tar.gz"
NEOFETCH_TEMP="/tmp/neofetch"
NEOFETCH_INSTALL_PREFIX="$HOME/.local"

x-have "neofetch" || {
  LC_ALL=C

  mkdir -p "$NEOFETCH_TEMP" "$NEOFETCH_INSTALL_PREFIX"

  curl -L "$NEOFETCH_URL" > "$NEOFETCH_TEMP.tar.gz"
  tar zxvf "$NEOFETCH_TEMP.tar.gz" --directory="$NEOFETCH_TEMP"
  cd "$NEOFETCH_TEMP/neofetch-$NEOFETCH_VERSION" \
    && make PREFIX="${NEOFETCH_INSTALL_PREFIX}" install \
    && rm -rf "$NEOFETCH_TEMP*" \
    && msg_yay "neofetch installed!"
}
