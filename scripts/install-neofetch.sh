#!/usr/bin/env bash
#
# Install neofetch from source
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

if ! declare -f msg > /dev/null; then
  # Function to print messages if VERBOSE is enabled
  # $1 - message (string)
  msg()
  {
    [ "$VERBOSE" -eq 1 ] && echo "$1"
    return 0
  }
fi

if ! declare -f msg_err > /dev/null; then
  # Function to print error messages and exit
  # $1 - error message (string)
  msg_err()
  {
    echo "(!) ERROR: $1" >&2
    exit 1
  }
fi

if ! declare -f msg_done > /dev/null; then
  # Function to print done message
  # $1 - message (string)
  msg_done()
  {
    echo "✓ $1"
    return 0
  }
fi

NEOFETCH_VERSION="$(x-gh-get-latest-version dylanaraps/neofetch)"
NEOFETCH_REPO="https://github.com/dylanaraps/neofetch"
NEOFETCH_URL="${NEOFETCH_REPO}/archive/refs/tags/${NEOFETCH_VERSION}.tar.gz"
NEOFETCH_TEMP="/tmp/neofetch"
NEOFETCH_INSTALL_PREFIX="$HOME/.local"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

# Function to install neofetch from source
install_neofetch()
{
  LC_ALL=C

  mkdir -p "$NEOFETCH_TEMP" "$NEOFETCH_INSTALL_PREFIX"

  curl -L "$NEOFETCH_URL" -o "$NEOFETCH_TEMP.tar.gz"
  tar zxvf "$NEOFETCH_TEMP.tar.gz" --directory="$NEOFETCH_TEMP"
  cd "$NEOFETCH_TEMP/neofetch-$NEOFETCH_VERSION" \
    && make PREFIX="${NEOFETCH_INSTALL_PREFIX}" install \
    && rm -rf "$NEOFETCH_TEMP*" \
    && msg_yay "neofetch installed!"
}

main()
{
  if ! command -v neofetch &> /dev/null; then
    install_neofetch
  elif [ "$NEOFETCH_VERSION" != "$(neofetch --version | awk '{print $2}')" ]; then
    install_neofetch
  else
    msg_done "neofetch v.${NEOFETCH_VERSION} already installed"
  fi
}

main "$@"
