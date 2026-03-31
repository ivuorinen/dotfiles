#!/usr/bin/env bash
#
# If our dark/light theme switching theme file can be found,
# source it in tmux. This is a separate file to keep the
# current theme settings separate from the main tmux configuration.
#
# This script requires the following in your tmux.conf:
# `run-shell "./theme-activate.sh"`
# and having the tmux-dark-notify plugin installed.
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

THEME_DIR="$HOME/.dotfiles/config/tmux"
THEME_FILE="$HOME/.local/state/tmux/tmux-dark-notify-theme.conf"

# Detect the current OS theme (dark or light).
# macOS: reads AppleInterfaceStyle via defaults(1)
# Linux: reads color-scheme via gsettings(1) (GNOME/Pop!_OS)
# Fallback: dark
detect_system_theme()
{
  local os
  os=$(uname -s)

  if [[ "$os" == "Darwin" ]]; then
    local mode
    mode=$(defaults read -g AppleInterfaceStyle 2> /dev/null)
    [[ "$mode" == "Dark" ]] && echo "dark" || echo "light"

  elif [[ "$os" == "Linux" ]] && command -v gsettings > /dev/null 2>&1; then
    local scheme
    scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2> /dev/null)
    [[ "$scheme" == "'prefer-dark'" ]] && echo "dark" || echo "light"

  else
    echo "dark"
  fi
}

# Ensure the state directory exists.
state_dir="$(dirname "$THEME_FILE")"
[[ ! -d "$state_dir" ]] && mkdir -p "$state_dir"

# Resolve the correct theme path from the system appearance,
# then point the state symlink at it before sourcing.
theme_mode=$(detect_system_theme)
if [[ "$theme_mode" == "dark" ]]; then
  theme_path="$THEME_DIR/theme-dark.conf"
else
  theme_path="$THEME_DIR/theme-light.conf"
fi

ln -sf "$theme_path" "$THEME_FILE"

[[ -e "$THEME_FILE" ]] && tmux source-file "$THEME_FILE"
