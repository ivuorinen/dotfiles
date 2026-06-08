# shellcheck shell=bash
#
# config/lib.sh — centralized shell library.
#
# Structured, level-filtered logging plus opt-in error-handling and
# cleanup helpers, adapted from the dfm common.sh logging functions.
#
# Sourced by config/shared.sh, so it loads into every interactive bash
# and zsh session and into every script that sources shared.sh. Because
# it lands in interactive shells it MUST stay side-effect-free on load:
# it only DEFINES functions and constants. It never runs
# `set -euo pipefail`, installs traps, or calls `exit` at the top level
# — a script that wants strict mode opts in by calling `lib::strict`.
#
# Portable across bash 3.2+, bash 5, and zsh: severities are mapped with
# a case statement rather than an associative array, whose assignment
# syntax differs between bash and zsh.
#
# (c) Ismo Vuorinen <https://github.com/ivuorinen> 2024
# Licensed under MIT, see LICENSE
#
# vim: ft=bash ts=2 sw=2 et

# Guard against double-sourcing — defining these functions twice is
# harmless, but the guard keeps re-sources cheap in long shell sessions.
[[ -n "${__DOTFILES_LIB_SOURCED:-}" ]] && return 0
__DOTFILES_LIB_SOURCED=1

# ╭──────────────────────────────────────────────────────────╮
# │ Error codes                                              │
# ╰──────────────────────────────────────────────────────────╯
# Named exit codes for use with `exit`/`return` and lib::error::handle.
LIB_E_SUCCESS=0
LIB_E_INVALID_ARGUMENT=1
LIB_E_COMMAND_NOT_FOUND=2
LIB_E_FUNCTION_NOT_FOUND=3
LIB_E_EXECUTION_FAILED=4
LIB_E_FILE_NOT_FOUND=5
export LIB_E_SUCCESS LIB_E_INVALID_ARGUMENT LIB_E_COMMAND_NOT_FOUND
export LIB_E_FUNCTION_NOT_FOUND LIB_E_EXECUTION_FAILED LIB_E_FILE_NOT_FOUND

_LIB_DATE_FMT='+%Y-%m-%d %H:%M:%S'

# ╭──────────────────────────────────────────────────────────╮
# │ Log levels                                               │
# ╰──────────────────────────────────────────────────────────╯
# Severity threshold. Honors $LOG_LEVEL from the environment; defaults
# to INFO. Messages below this level are suppressed.
: "${LOG_LEVEL:=INFO}"

# Map a level name to its numeric severity. Unknown names map to -1.
# Using a case statement keeps this portable between bash and zsh, which
# disagree on associative-array assignment syntax.
#
# Arguments:
#   $1 - level name (DEBUG, INFO, WARN, ERROR)
# Outputs:
#   The numeric severity on stdout (-1 for an unknown level).
lib::_level_num()
{
  local level_name=$1
  case "$level_name" in
    DEBUG) printf '0' ;;
    INFO) printf '1' ;;
    WARN) printf '2' ;;
    ERROR) printf '3' ;;
    *) printf -- '-1' ;;
  esac
  return 0
}

# Validate $LOG_LEVEL once, at load. An invalid value falls back to INFO
# with a warning — never `exit`, which would terminate a shell that
# sourced us.
if [[ "$(lib::_level_num "$LOG_LEVEL")" -lt 0 ]]; then
  printf '[%s] ERROR: Invalid LOG_LEVEL: %s (falling back to INFO)\n' \
    "$(date "$_LIB_DATE_FMT")" "$LOG_LEVEL" >&2
  LOG_LEVEL=INFO
fi

# ╭──────────────────────────────────────────────────────────╮
# │ Simple logging                                           │
# ╰──────────────────────────────────────────────────────────╯
# Log a timestamped message to stdout.
#
# Arguments:
#   $* - message to log
# Example:
#   lib::log "Server started"   # [2024-02-28 09:45:00] Server started
lib::log()
{
  printf '[%s] %s\n' "$(date "$_LIB_DATE_FMT")" "$*"
  return 0
}

# Log a timestamped error message to stderr.
#
# Arguments:
#   $* - error message
# Example:
#   lib::error "Failed to read the configuration file."
lib::error()
{
  printf '[%s] ERROR: %s\n' "$(date "$_LIB_DATE_FMT")" "$*" >&2
  return 0
}

# ╭──────────────────────────────────────────────────────────╮
# │ Level-filtered logging                                   │
# ╰──────────────────────────────────────────────────────────╯
# Log a message to stderr if its severity meets or exceeds $LOG_LEVEL.
# The level tag is colorized when stderr is a terminal.
#
# Arguments:
#   $1  - level name (DEBUG, INFO, WARN, ERROR)
#   $2+ - message
# Example:
#   logger::log INFO "Initialization complete"
logger::log()
{
  [[ $# -ge 1 ]] || {
    lib::error "logger::log: missing level argument"
    return "$LIB_E_INVALID_ARGUMENT"
  }
  local level=$1
  shift
  local lvl_num threshold
  lvl_num=$(lib::_level_num "$level")
  if [[ "$lvl_num" -lt 0 ]]; then
    lib::error "Invalid log level: $level"
    return "$LIB_E_INVALID_ARGUMENT"
  fi
  threshold=$(lib::_level_num "$LOG_LEVEL")
  if [[ "$threshold" -lt 0 ]]; then
    LOG_LEVEL=INFO
    threshold=1
  fi
  [[ "$lvl_num" -lt "$threshold" ]] && return 0

  local color='' reset=''
  if [[ -t 2 ]]; then
    case "$level" in
      DEBUG) color=$'\033[2m' ;;
      INFO) color=$'\033[34m' ;;
      WARN) color=$'\033[33m' ;;
      ERROR) color=$'\033[31m' ;;
      *) ;;
    esac
    reset=$'\033[0m'
  fi

  printf '[%s] [%s%s%s]: %s\n' \
    "$(date "$_LIB_DATE_FMT")" "$color" "$level" "$reset" "$*" >&2
  return 0
}

# Convenience wrappers around logger::log, one per severity.
logger::debug()
{
  logger::log DEBUG "$@"
  return 0
}

logger::info()
{
  logger::log INFO "$@"
  return 0
}

logger::warn()
{
  logger::log WARN "$@"
  return 0
}

logger::error()
{
  logger::log ERROR "$@"
  return 0
}

# ╭──────────────────────────────────────────────────────────╮
# │ Error handling                                           │
# ╰──────────────────────────────────────────────────────────╯
# ERR-trap handler: log a descriptive message based on the exit code of
# the failed command. Install with `lib::strict` (or a manual trap).
#
# Arguments:
#   $1 - line number (e.g. ${LINENO})
#   $2 - command (e.g. ${BASH_COMMAND})
# Returns:
#   The exit code of the failed command.
# Example:
#   trap 'lib::error::handle ${LINENO} "${BASH_COMMAND}"' ERR
lib::error::handle()
{
  local exit_code=$?
  local line_no=${1:-?}
  local command=${2:-?}
  case "$exit_code" in
    "$LIB_E_INVALID_ARGUMENT")
      lib::error "Invalid argument at line $line_no in command '$command'"
      ;;
    "$LIB_E_COMMAND_NOT_FOUND")
      lib::error "Command not found at line $line_no in command '$command'"
      ;;
    "$LIB_E_FUNCTION_NOT_FOUND")
      lib::error "Function not found at line $line_no in command '$command'"
      ;;
    "$LIB_E_EXECUTION_FAILED")
      lib::error "Execution failed at line $line_no in command '$command'"
      ;;
    *)
      lib::error "Unknown error ($exit_code) at line $line_no in command '$command'"
      ;;
  esac
  return "$exit_code"
}

# ╭──────────────────────────────────────────────────────────╮
# │ Cleanup                                                  │
# ╰──────────────────────────────────────────────────────────╯
# Paths queued for removal by lib::cleanup. Append with
# lib::register_cleanup; consumed by the EXIT trap lib::trap_cleanup
# installs.
LIB_CLEANUP_PATHS=()

# Queue one or more paths for removal on exit.
#
# Arguments:
#   $* - paths to remove when lib::cleanup runs
lib::register_cleanup()
{
  LIB_CLEANUP_PATHS+=("$@")
  return 0
}

# Remove queued temporary paths. Also honors a legacy $TEMP_DIR variable
# for parity with the upstream common.sh. Safe to call more than once.
lib::cleanup()
{
  if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
  local path
  for path in "${LIB_CLEANUP_PATHS[@]:-}"; do
    [[ -n "$path" && -e "$path" ]] && rm -rf "$path"
  done
  LIB_CLEANUP_PATHS=()
  return 0
}

# Install an EXIT trap that runs lib::cleanup. Call from a script (never
# from an interactive shell or rc file — the trap would fire on shell
# exit).
lib::trap_cleanup()
{
  trap 'lib::cleanup' EXIT
  return 0
}

# ╭──────────────────────────────────────────────────────────╮
# │ Strict mode                                              │
# ╰──────────────────────────────────────────────────────────╯
# Opt a SCRIPT into strict mode: `set -euo pipefail` plus an ERR trap
# routed through lib::error::handle. Do NOT call from an interactive
# shell or a sourced rc file — `set -e` would terminate the shell.
lib::strict()
{
  set -euo pipefail
  trap 'lib::error::handle "${LINENO}" "${BASH_COMMAND-?}"' ERR
  return 0
}
