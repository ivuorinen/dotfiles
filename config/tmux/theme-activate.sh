#!/usr/bin/env bash
#
# Bootstrap the tmux dark/light theme at config load.
#
# Detects the current OS appearance, points the shared state symlink at the
# matching theme file, and sources it. Fish picks up the change on its next
# prompt render via config/fish/conf.d/theme-switch.fish (poll-based; we do
# not signal fish processes because SIGUSR1's default disposition is
# Terminate). Bash/zsh/fish prompts via starship pick up the change on the
# next prompt subprocess (config swap takes effect immediately).
#
# Required in tmux.conf (after TPM bootstrap so catppuccin.tmux exists):
#   run-shell "$HOME/.dotfiles/config/tmux/theme-activate.sh"
#
# Companion daemons keep everything in sync after launch by watching OS
# events:
#   - linux-dark-notify.sh  (gsettings monitor on Linux/GNOME)
#   - macos-dark-notify.sh  (defaults read polling on macOS)
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

# Library provides detect_*, get_current_theme, apply_theme.
# shellcheck source=config/tmux/_apply-theme.sh
. "$HOME/.dotfiles/config/tmux/_apply-theme.sh"

# Ensure the state directory exists.
state_dir="$(dirname "$THEME_LINK")"
[[ ! -d "$state_dir" ]] && mkdir -p "$state_dir"

apply_theme "$(get_current_theme)"
