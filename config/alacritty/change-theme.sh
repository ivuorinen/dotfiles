#!/usr/bin/env bash
# Adapted from https://gist.github.com/xqm32/17777d035930d622d0ff7530bfab61fd
#

A_DIR="$HOME/.dotfiles/config/alacritty"

set_alacritty_theme() {
  cp -f "$A_DIR/theme-$1.toml" "$A_DIR/theme-active.toml"
}
ALACRITTY_THEME=$1
if [ "$ALACRITTY_THEME" = "dark" ] || [ "$ALACRITTY_THEME" = "night" ]; then
  set_alacritty_theme "night"
else
  set_alacritty_theme "day"
fi

# Notify alacritty about the changes
touch "$A_DIR/alacritty.toml"

