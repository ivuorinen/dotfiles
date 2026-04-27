#!/usr/bin/env bash
# linux-dark-notify.sh — watch GNOME color-scheme and switch tmux theme.
#
# Runs only on Linux; exits silently on other platforms. Uses
# config/tmux/_apply-theme.sh as the single source of truth for theme
# resolution and symlink updates so the macOS counterpart shares behaviour.
#
# Add to tmux.conf after theme-activate.sh:
#   run-shell "$HOME/.dotfiles/config/tmux/linux-dark-notify.sh"
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

set -o pipefail
[[ "${TRACE-0}" =~ ^(1|t|y|true|yes)$ ]] && set -o xtrace

[[ "$(uname -s)" != "Linux" ]] && exit 0

# shellcheck source=config/tmux/_apply-theme.sh
. "$HOME/.dotfiles/config/tmux/_apply-theme.sh"

# =============================================================================
# LOCK FILE MANAGEMENT
# =============================================================================

TMUX_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
# Per-tmux-socket lock so multiple independent servers each get a daemon.
# basename(1) on an empty string returns empty with exit 0, so the
# `|| echo "default"` fallback can't catch a missing TMUX env — split the
# fallback into a parameter expansion that triggers on empty.
_tmux_sock_name="$(basename "${TMUX%%,*}" 2> /dev/null)"
_tmux_sock_name="${_tmux_sock_name:-default}"
LOCK_FILE="${TMUX_STATE_DIR}/linux-dark-notify-${_tmux_sock_name}.lock"

is_process_running()
{
  local pid=$1
  [[ -n "$pid" ]] && kill -0 "$pid" 2> /dev/null
}

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

cleanup_and_exit()
{
  [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
  exit 0
}

# =============================================================================
# DAEMON MODE
# =============================================================================

daemon_mode()
{
  check_lock && exit 0
  create_lock || exit 1

  trap cleanup_and_exit SIGTERM SIGINT SIGHUP

  if ! command -v gsettings > /dev/null 2>&1; then
    echo "linux-dark-notify: gsettings(1) not found; theme monitoring unavailable." >&2
    cleanup_and_exit
  fi

  # Skip the initial apply if theme-activate.sh already established a
  # working state symlink during config load (avoids the race where this
  # daemon and theme-activate.sh both update the symlink at startup with
  # potentially different answers from portal vs gsettings caches).
  #
  # `[[ ! -e ]]` catches BOTH cases that need fixing — absent symlink
  # AND dangling symlink (target missing). `[[ ! -L ]]` would skip the
  # dangling case and leave the broken state in place.
  if [[ ! -e "$THEME_LINK" ]]; then
    apply_theme "$(get_current_theme)" || true
  fi

  # Stream gsettings changes and re-apply theme on every color-scheme update.
  # Outer `while true` self-recovers if `gsettings monitor` exits (dbus
  # restart, transient pipe close). Trailing `|| :` tolerates the inner
  # pipeline returning non-zero under `set -o pipefail` — e.g. when grep
  # matches nothing before the monitor stream closes.
  while true; do
    gsettings monitor org.gnome.desktop.interface 2> /dev/null \
      | grep --line-buffered '^color-scheme ' \
      | while IFS= read -r _line; do
        apply_theme "$(get_current_theme)" || true
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

  check_lock && exit 0

  # Launch the daemon in the background so run-shell returns immediately.
  nohup "$0" --daemon < /dev/null > /dev/null 2>&1 &

  sleep 0.1
}

main "$@"
