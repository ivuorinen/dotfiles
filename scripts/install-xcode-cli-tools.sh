#!/usr/bin/env bash
#
# Install XCode CLI Tools with osascript magic.
# Ismo Vuorinen <https://github.com/ivuorinen> 2018
#

[ "$(uname)" != "Darwin" ] && echo "Not a macOS system" && exit 0

! x-have xcode-select \
  && msg_err "xcode-select could not be found, skipping" \
  && exit 0

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `settler` has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2> /dev/null &

XCODE_TOOLS_PATH=$(xcode-select -p)
XCODE_SWIFT_PATH="$XCODE_TOOLS_PATH/usr/bin/swift"

# Modified from https://unix.stackexchange.com/a/408305
if [ -a "$XCODE_SWIFT_PATH" ]; then
  echo "You have swift from xcode-select. Continuing..."
else
  XCODE_MESSAGE="$(
    osascript -e \
      'tell app "System Events" to display dialog "Please click install when Command Line Developer Tools appears"'
  )"

  if [ "$XCODE_MESSAGE" = "button returned:OK" ]; then
    xcode-select --install
  else
    echo "You have cancelled the installation, please rerun the installer."
    exit
  fi
fi

until [ -f "$XCODE_SWIFT_PATH" ]; do
  echo -n "."
  sleep 1
done
