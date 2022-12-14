#!/usr/bin/env bash
#
# Settler - my macOS setup automator
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

# Install brew
if [ "$(which brew)" ]; then
  echo 'Brew already installed'
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

bash "$HOME/.dotfiles/local/bin/dfm" brew install && "Installed Brewfile contents"
bash "$HOME/.dotfiles/local/bin/dfm" dotfiles link && "Linked all dotfiles"

read -r -p "Do you want to set macOS defaults? (y/N) " yn

case $yn in
  [yY])
    bash "set-defaults.sh"
    ;;
  *)
    echo "Skipping..."
    ;;
esac

echo "Done. Note that some of these changes require a logout/restart to take effect."
