# shellcheck shell=bash
#
# _apply-theme.sh — shared dark/light theme machinery for tmux daemons.
#
# Sourced (NOT executed) by:
#   - config/tmux/theme-activate.sh   (one-shot at tmux config load)
#   - config/tmux/linux-dark-notify.sh (Linux gsettings/portal watcher)
#   - config/tmux/macos-dark-notify.sh (macOS defaults poller)
#
# Provides:
#   detect_macos_theme       echo "dark" | "light"
#   detect_portal_theme      echo "dark" | "light" | "" (no answer)
#   detect_gsettings_theme   echo "dark" | "light" | "" (no answer)
#   get_current_theme        echo "dark" | "light" (with fallback to "dark")
#   apply_theme MODE         source the matching tmux theme + flip both symlinks,
#                            errexit-safe and idempotent
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

THEME_DIR="$HOME/.dotfiles/config/tmux"
THEME_LINK="${XDG_STATE_HOME:-$HOME/.local/state}/tmux/tmux-dark-notify-theme.conf"

# macOS: AppleInterfaceStyle is only present when dark mode is on.
detect_macos_theme()
{
  local mode
  mode=$(defaults read -g AppleInterfaceStyle 2> /dev/null)
  [[ "$mode" == "Dark" ]] && echo "dark" || echo "light"
}

# xdg-desktop-portal (cross-DE on Linux). Returns "dark", "light", or "" (no answer).
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

# GNOME color-scheme via gsettings. Returns "dark", "light", or "" (no answer).
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

# Resolve current appearance, OS-aware. Falls back to "dark" if no source answers.
get_current_theme()
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

# Idempotent symlink: only call ln(1) when target actually changes. Avoids
# pointless mtime churn that obscures last-real-change time during debugging.
#
# Refuses to overwrite a regular file at the destination — that's user data,
# not something the daemon owns. If the user manually replaced one of our
# managed symlinks (e.g. ~/.config/starship.toml) with a hand-rolled config
# file, we leave it alone instead of silently destroying their work.
_idempotent_ln_sf()
{
  local src=$1 dst=$2
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    return 0
  fi
  if [[ "$(readlink "$dst" 2> /dev/null)" != "$src" ]]; then
    ln -sf "$src" "$dst"
  fi
}

# Apply the matching tmux theme file and update both shared symlinks.
#
# Errexit-safe by design: every external command that can fail transiently
# (`tmux source-file` against a dying server, missing dotbot symlinks during
# install) is masked with `|| true` or guarded so the caller's daemon loop
# can keep running.
#
# Updates:
#   - $THEME_LINK              (tmux state symlink, picked up by fish handler)
#   - ~/.config/starship.toml  (starship config, read fresh each prompt)
apply_theme()
{
  local mode="$1"
  local theme_path

  case "$mode" in
    dark) theme_path="$THEME_DIR/theme-dark.conf" ;;
    light) theme_path="$THEME_DIR/theme-light.conf" ;;
    *)
      echo "_apply-theme: unknown mode '$mode'; skipping." >&2
      return 0
      ;;
  esac

  if [[ ! -r "$theme_path" ]]; then
    echo "_apply-theme: theme file not readable: $theme_path" >&2
    return 0
  fi

  # `|| true` prevents a transient tmux server failure (kill-server,
  # socket-busy) from terminating the caller under `set -o errexit`.
  tmux source-file "$theme_path" 2> /dev/null || true
  _idempotent_ln_sf "$theme_path" "$THEME_LINK"

  # Starship config symlink — bash/zsh/fish prompts pick up the matching
  # Catppuccin palette on the next prompt subprocess invocation. No
  # shell-side reload needed; starship reads its config fresh each prompt.
  local starship_src="$HOME/.config/starship/starship-${mode}.toml"
  if [[ -f "$starship_src" ]]; then
    _idempotent_ln_sf "$starship_src" "$HOME/.config/starship.toml"
  fi
}
