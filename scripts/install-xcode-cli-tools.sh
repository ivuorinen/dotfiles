#!/usr/bin/env bash
set -euo pipefail
# @description Install XCode CLI Tools with osascript magic.
#USAGE about "Install Xcode Command Line Tools (macOS)"
# Ismo Vuorinen <https://github.com/ivuorinen> 2018
#
# shellcheck source=../config/shared.sh
source "${DOTFILES}/config/shared.sh"

# Check if the script is running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  msgr warn "Not a macOS system"
  exit 0
fi

# Check if xcode-select is available
if ! command -v xcode-select &> /dev/null; then
  msgr err "xcode-select could not be found, skipping"
  exit 0
fi

# Keep-alive: update existing `sudo` time stamp until the script has finished
keep_alive_sudo()
{
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2> /dev/null &
  return 0
}

# How long to wait for the installer to finish, in seconds. Overridable so
# the test suite can exercise the timeout without waiting half an hour.
XCODE_INSTALL_TIMEOUT="${XCODE_INSTALL_TIMEOUT:-1800}"

# Path to swift under the active developer directory, or empty when no
# Command Line Tools are installed. xcode-select -p exits 2 in that case, and
# a bare call would end the script under set -e before it could prompt.
xcode_swift_path()
{
  local tools_path
  if tools_path="$(xcode-select -p 2> /dev/null)"; then
    echo "$tools_path/usr/bin/swift"
  fi
  return 0
}

# Function to prompt for XCode CLI Tools installation
prompt_xcode_install()
{
  # Cancel makes `display dialog` raise error -128 and osascript exit 1, so
  # the substitution sits in the condition: a bare assignment would end the
  # script under set -e before the warning below.
  if XCODE_MESSAGE="$(
    osascript -e \
      'tell app "System Events" to display dialog "Please click install when Command Line Developer Tools appears"' \
      2> /dev/null
  )" && [[ "$XCODE_MESSAGE" = "button returned:OK" ]]; then
    xcode-select --install
  else
    msgr warn "You have cancelled the installation, please rerun the installer."
    exit 1
  fi
  return 0
}

# Main function
main()
{
  local swift_path
  swift_path="$(xcode_swift_path)"
  if [[ -n "$swift_path" && -x "$swift_path" ]]; then
    msgr run "You have swift from xcode-select. Continuing..."
    return 0
  fi

  # Ask for the administrator password only when there is something to install
  sudo -v
  keep_alive_sudo
  prompt_xcode_install

  # Bounded: cancelling the system installer dialog leaves nothing to wait
  # for, and an unbounded loop would hang the bootstrap with sudo kept alive.
  local waited=0
  until swift_path="$(xcode_swift_path)" && [[ -n "$swift_path" && -f "$swift_path" ]]; do
    if ((waited >= XCODE_INSTALL_TIMEOUT)); then
      echo
      msgr err "Timed out after ${XCODE_INSTALL_TIMEOUT}s waiting for Command Line Tools"
      exit 1
    fi
    echo -n "."
    sleep 1
    waited=$((waited + 1))
  done
  echo
  return 0
}

main "$@"
