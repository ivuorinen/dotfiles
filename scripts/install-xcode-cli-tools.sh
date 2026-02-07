#!/usr/bin/env bash
set -euo pipefail
# @description Install XCode CLI Tools with osascript magic.
# Ismo Vuorinen <https://github.com/ivuorinen> 2018
#

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

# Ask for the administrator password upfront
sudo -v

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

XCODE_TOOLS_PATH="$(xcode-select -p)"
XCODE_SWIFT_PATH="$XCODE_TOOLS_PATH/usr/bin/swift"

# Function to prompt for XCode CLI Tools installation
prompt_xcode_install()
{
  XCODE_MESSAGE="$(
    osascript -e \
      'tell app "System Events" to display dialog "Please click install when Command Line Developer Tools appears"'
  )"

  if [[ "$XCODE_MESSAGE" = "button returned:OK" ]]; then
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
  keep_alive_sudo

  if [[ -x "$XCODE_SWIFT_PATH" ]]; then
    msgr run "You have swift from xcode-select. Continuing..."
  else
    prompt_xcode_install
  fi

  until [[ -f "$XCODE_SWIFT_PATH" ]]; do
    echo -n "."
    sleep 1
  done
  return 0
}

main "$@"
