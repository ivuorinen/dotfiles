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

THEME_FILE="$HOME/.local/state/tmux/tmux-dark-notify-theme.conf"

[[ -e $THEME_FILE ]] && tmux source-file "$THEME_FILE"
