#!/usr/bin/env bash
# macos-dark-notify.sh — watch macOS appearance and switch tmux theme.
#
# Runs only on Darwin; exits silently on other platforms. macOS doesn't
# expose a clean event-stream for the AppleInterfaceStyle preference
# without an extra binary, so this daemon polls `defaults read -g
# AppleInterfaceStyle` every 2 s — cheap (a single defaults call), and the
# user-perceptible delay is bounded.
#
# Uses config/tmux/_apply-theme.sh as the single source of truth for theme
# resolution and symlink updates so behaviour matches linux-dark-notify.sh.
#
# Add to tmux.conf after theme-activate.sh:
#   run-shell "$HOME/.dotfiles/config/tmux/macos-dark-notify.sh"
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

set -o pipefail
[[ "${TRACE-0}" =~ ^(1|t|y|true|yes)$ ]] && set -o xtrace

[[ "$(uname -s)" != "Darwin" ]] && exit 0

# shellcheck source=config/tmux/_apply-theme.sh
. "$HOME/.dotfiles/config/tmux/_apply-theme.sh"

POLL_INTERVAL_SECONDS=2

# =============================================================================
# LOCK FILE MANAGEMENT
# =============================================================================

TMUX_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
_tmux_sock_name="$(basename "${TMUX%%,*}" 2> /dev/null || echo "default")"
LOCK_FILE="${TMUX_STATE_DIR}/macos-dark-notify-${_tmux_sock_name}.lock"

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

  # Skip the initial apply if theme-activate.sh already established the
  # state symlink during config load (avoids racing it with potentially
  # different answers).
  local last_mode
  last_mode=$(get_current_theme)
  if [[ ! -L "$THEME_LINK" ]]; then
    apply_theme "$last_mode" || true
  fi

  # Poll loop. `defaults` is fast (subsecond) and the 2 s cadence keeps the
  # user-perceived flip latency low while staying out of the way.
  while true; do
    sleep "$POLL_INTERVAL_SECONDS"
    local current_mode
    current_mode=$(get_current_theme)
    if [[ "$current_mode" != "$last_mode" ]]; then
      apply_theme "$current_mode" || true
      last_mode="$current_mode"
    fi
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
