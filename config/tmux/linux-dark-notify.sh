#!/usr/bin/env bash
# linux-dark-notify.sh — Monitor GNOME color-scheme and switch tmux theme.
#
# Runs only on Linux; exits silently on other platforms.
# Uses the same state file and @dark-notify-theme-path-* options as
# tmux-dark-notify so both share a single source of truth.
#
# Add to tmux.conf after loading the tmux-dark-notify plugin:
#   run-shell "$HOME/.dotfiles/config/tmux/linux-dark-notify.sh"
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

set -o errexit
set -o pipefail
[[ "${TRACE-0}" =~ ^(1|t|y|true|yes)$ ]] && set -o xtrace

# Only run on Linux.
[[ "$(uname -s)" != "Linux" ]] && exit 0

# =============================================================================
# GLOBAL VARIABLES
# =============================================================================

TMUX_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
# Key lock per tmux server socket so multiple independent servers each get a daemon.
_tmux_sock_name="$(basename "${TMUX%%,*}" 2> /dev/null || echo "default")"
LOCK_FILE="${TMUX_STATE_DIR}/linux-dark-notify-${_tmux_sock_name}.lock"
THEME_LINK="${TMUX_STATE_DIR}/tmux-dark-notify-theme.conf"
OPTION_THEME_LIGHT="@dark-notify-theme-path-light"
OPTION_THEME_DARK="@dark-notify-theme-path-dark"

# =============================================================================
# UTILITIES
# =============================================================================

program_is_in_path()
{
  type "$1" > /dev/null 2>&1
}

is_process_running()
{
  local pid=$1
  [[ -n "$pid" ]] && kill -0 "$pid" 2> /dev/null
}

# =============================================================================
# LOCK FILE MANAGEMENT
# =============================================================================

check_lock()
{
  [[ -f "$LOCK_FILE" ]] || return 1
  local lock_pid
  lock_pid=$(grep "^PID:" "$LOCK_FILE" 2> /dev/null | cut -d' ' -f2)
  [[ -z "$lock_pid" ]] && {
    rm -f "$LOCK_FILE"
    return 1
  }
  is_process_running "$lock_pid" && return 0
  rm -f "$LOCK_FILE"
  return 1
}

create_lock()
{
  [[ ! -d "$TMUX_STATE_DIR" ]] && mkdir -p "$TMUX_STATE_DIR"
  (
    set -C
    {
      echo "PID: $$"
      echo "STARTED: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    } > "$LOCK_FILE"
  ) 2> /dev/null
}

remove_lock()
{
  [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
}

cleanup_and_exit()
{
  remove_lock
  exit 0
}

# =============================================================================
# THEME HELPERS
# =============================================================================

tmux_get_option()
{
  local opt_val
  opt_val=$(tmux show-option -gqv "$1")
  if [[ -z "$opt_val" ]]; then
    echo "Required tmux option '$1' not set" >&2
    exit 1
  fi
  echo "$opt_val"
}

# Returns "dark" or "light" based on the GNOME color-scheme gsettings key.
# Falls back to "dark" when gsettings is unavailable or returns an empty/unknown value.
get_current_theme()
{
  if program_is_in_path gsettings; then
    local scheme
    scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2> /dev/null)
    case "$scheme" in
      "'prefer-dark'") echo "dark" ;;
      "'default'" | "'prefer-light'") echo "light" ;;
      *) echo "dark" ;; # empty or unknown → dark fallback
    esac
    return
  fi
  echo "dark"
}

# Sources the tmux theme file and updates the shared state symlink.
apply_theme()
{
  local mode="$1"
  local theme_opt theme_path

  if [[ "$mode" == "dark" ]]; then
    theme_opt="$OPTION_THEME_DARK"
  else
    theme_opt="$OPTION_THEME_LIGHT"
  fi

  theme_path=$(tmux_get_option "$theme_opt")
  # Expand ~ and $HOME without eval to avoid arbitrary code execution.
  theme_path="${theme_path/#\~/$HOME}"
  theme_path="${theme_path//\$HOME/$HOME}"

  if [[ ! -r "$theme_path" ]]; then
    echo "Theme file not readable: $theme_path" >&2
    return 1
  fi

  tmux source-file "$theme_path"
  ln -sf "$theme_path" "$THEME_LINK"
}

# =============================================================================
# DAEMON MODE
# =============================================================================

daemon_mode()
{
  check_lock && exit 0

  create_lock || exit 1

  trap cleanup_and_exit SIGTERM SIGINT SIGHUP

  if ! program_is_in_path gsettings; then
    echo "linux-dark-notify: gsettings(1) not found; theme monitoring unavailable." >&2
    cleanup_and_exit
  fi

  # Apply current appearance before entering the monitor loop.
  apply_theme "$(get_current_theme)"

  # Stream gsettings changes; re-apply theme on every color-scheme update.
  gsettings monitor org.gnome.desktop.interface 2> /dev/null \
    | grep --line-buffered "color-scheme" \
    | while IFS= read -r _line; do
      apply_theme "$(get_current_theme)"
    done

  cleanup_and_exit
}

# =============================================================================
# ENTRY POINT
# =============================================================================

main()
{
  if [[ "${1-}" == "--daemon" ]]; then
    daemon_mode
  fi

  # Already running — nothing to do.
  check_lock && exit 0

  # Launch the daemon in the background so run-shell returns immediately.
  nohup "$0" --daemon < /dev/null > /dev/null 2>&1 &

  # Brief pause to let the daemon create its lock file.
  sleep 0.1
}

main "$@"
