#!/usr/bin/env bash
#
# Bootstrap the tmux dark/light theme at config load.
#
# Detects the current OS appearance, points the shared state symlink at the
# matching theme file, and sources it. Fish picks up the change on its next
# prompt render via config/fish/conf.d/theme-switch.fish (poll-based; we do
# not signal fish processes because SIGUSR1's default disposition is
# Terminate).
#
# Required in tmux.conf (after TPM bootstrap so catppuccin.tmux exists):
#   run-shell "$HOME/.dotfiles/config/tmux/theme-activate.sh"
#
# A companion daemon (linux-dark-notify.sh) keeps everything in sync after
# launch by watching gsettings/portal events.
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

THEME_DIR="$HOME/.dotfiles/config/tmux"
THEME_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/tmux/tmux-dark-notify-theme.conf"

# macOS: read the AppleInterfaceStyle default.
# AppleInterfaceStyle is only present when dark mode is on, so an empty read
# means light.
detect_macos_theme()
{
  local mode
  mode=$(defaults read -g AppleInterfaceStyle 2> /dev/null)
  [[ "$mode" == "Dark" ]] && echo "dark" || echo "light"
}

# Linux: query xdg-desktop-portal first (cross-DE), then GNOME's gsettings.
# Returns "dark", "light", or "" (no answer).
detect_portal_theme()
{
  command -v busctl > /dev/null 2>&1 || return 0
  local out
  out=$(busctl --user --json=short call \
    org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop \
    org.freedesktop.portal.Settings Read \
    ss org.freedesktop.appearance color-scheme 2> /dev/null) || return 0
  case "$out" in
    *'"data":1'*) echo "dark" ;;
    *'"data":2'*) echo "light" ;;
    *) : ;;
  esac
}

detect_gsettings_theme()
{
  command -v gsettings > /dev/null 2>&1 || return 0
  local scheme
  scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2> /dev/null)
  case "$scheme" in
    "'prefer-dark'") echo "dark" ;;
    "'default'" | "'prefer-light'") echo "light" ;;
    *) : ;;
  esac
}

# Resolve the appearance, falling back to "dark" if no source answers.
detect_system_theme()
{
  local os theme
  os=$(uname -s)

  if [[ "$os" == "Darwin" ]]; then
    detect_macos_theme
    return
  fi

  if [[ "$os" == "Linux" ]]; then
    theme=$(detect_portal_theme)
    [[ -n "$theme" ]] && {
      echo "$theme"
      return
    }
    theme=$(detect_gsettings_theme)
    [[ -n "$theme" ]] && {
      echo "$theme"
      return
    }
  fi

  echo "dark"
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
