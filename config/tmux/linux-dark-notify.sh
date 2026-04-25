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
  # Don't exit on missing option — a transient empty read during a config
  # reload would otherwise kill the daemon. Caller checks for empty output.
  tmux show-option -gqv "$1" 2> /dev/null
}

# Query xdg-desktop-portal for color-scheme via D-Bus.
# Returns "dark", "light", or "" (no answer).
# Spec: org.freedesktop.portal.Settings → 1=dark, 2=light, 0=no preference.
get_portal_theme()
{
  program_is_in_path busctl || return 0
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

# Query GNOME color-scheme via gsettings.
# Returns "dark", "light", or "" (no answer).
get_gsettings_theme()
{
  program_is_in_path gsettings || return 0
  local scheme
  scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2> /dev/null)
  case "$scheme" in
    "'prefer-dark'") echo "dark" ;;
    "'default'" | "'prefer-light'") echo "light" ;;
    *) : ;;
  esac
}

# Resolve the current appearance.
# Order: xdg-desktop-portal (cross-DE), gsettings (GNOME), then fallback dark.
get_current_theme()
{
  local theme
  theme=$(get_portal_theme)
  [[ -n "$theme" ]] && {
    echo "$theme"
    return
  }
  theme=$(get_gsettings_theme)
  [[ -n "$theme" ]] && {
    echo "$theme"
    return
  }
  echo "dark"
}

# Sources the tmux theme file and updates the shared state symlink. Fish
# polls that symlink on each prompt render (see
# config/fish/conf.d/theme-switch.fish) — we deliberately avoid OS signals
# because fish's default disposition for SIGUSR1/SIGUSR2 is Terminate, which
# would kill any fish that hasn't yet loaded the handler (including the
# desktop-session login shell).
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
  if [[ -z "$theme_path" ]]; then
    echo "linux-dark-notify: option '$theme_opt' is unset; skipping switch." >&2
    return 0
  fi

  # Expand ~ and $HOME without eval to avoid arbitrary code execution.
  theme_path="${theme_path/#\~/$HOME}"
  theme_path="${theme_path//\$HOME/$HOME}"

  if [[ ! -r "$theme_path" ]]; then
    echo "linux-dark-notify: theme file not readable: $theme_path" >&2
    return 0
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

  # Stream gsettings changes and re-apply theme on every color-scheme update.
  # The outer `while true` ensures the daemon self-recovers if `gsettings
  # monitor` ever exits (e.g. dbus restart, transient pipe close). The
  # trailing `|| :` keeps errexit from killing the daemon when the pipeline
  # produces no matches before EOF.
  while true; do
    gsettings monitor org.gnome.desktop.interface 2> /dev/null \
      | grep --line-buffered '^color-scheme ' \
      | while IFS= read -r _line; do
        apply_theme "$(get_current_theme)"
      done || :
    sleep 1
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
