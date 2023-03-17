#!/usr/bin/env bash
#
# Install XCode CLI Tools with osascript magic.
# Ismo Vuorinen <https://github.com/ivuorinen> 2018
#

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `settler` has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2> /dev/null &

# https://unix.stackexchange.com/a/408305
# check if user has git installed and propose to install if not installed
if [ "$(which git)" ]; then
  echo "You already have git. Continuing..."
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

until [ "$(which git)" ]; do
  echo -n "."
  sleep 1
done
