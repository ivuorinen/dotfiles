#!/usr/bin/env bash
# dfm common functions for logging and error handling, etc.
# Source this file to use the functions in your scripts.
#
# @author Ismo Vuorinen <https://github.com/ivuorinen>
# @license MIT
set -euo pipefail

declare -A ERROR_CODES=(
  [SUCCESS]=0
  [INVALID_ARGUMENT]=1
  [COMMAND_NOT_FOUND]=2
  [FUNCTION_NOT_FOUND]=3
  [EXECUTION_FAILED]=4
)

declare -A LOG_LEVELS=(
  [DEBUG]=0
  [INFO]=1
  [WARN]=2
  [ERROR]=3
)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Simple logging function
#
# @example
# lib::log "Hello, world!"
#
# @description Log a message to the console
# @param $* Message to log
# @return void
lib::log()
{
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

# Simple error logging function
#
# @example
# lib::error "Something went wrong"
#
# @description Log an error message to the console
# @param $* Error message
# @return void
lib::error()
{
  printf '[%s] ERROR: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

# Handle an error by logging an error message to the console
# and exiting with an error code based on the error type.
#
# @example
# lib::error::handle $LINENO $0
#
# @description Handle an error
# @param $1 Line number
# @param $2 Command
# @return void
lib::error::handle()
{
  local exit_code=$?
  local line_no=$1
  local command=$2

  case $exit_code in
    "${ERROR_CODES[INVALID_ARGUMENT]}")
      lib::error "Invalid argument at line $line_no in command '$command'"
      ;;
    "${ERROR_CODES[COMMAND_NOT_FOUND]}")
      lib::error "Command not found at line $line_no"
      ;;
    "${ERROR_CODES[FUNCTION_NOT_FOUND]}")
      lib::error "Function not found at line $line_no in command '$command'"
      ;;
    "${ERROR_CODES[EXECUTION_FAILED]}")
      lib::error "Execution failed at line $line_no in command '$command'"
      ;;
    *)
      lib::error "Unknown error ($exit_code) at line $line_no in command '$command'"
      ;;
  esac

  return $exit_code
}

# Throw an error by logging an error message to the console and exiting
# with an error code based on the error type. The error code name is used
# to determine the error code from the ERROR_CODES associative array.
# The error message is passed as arguments to the function.
#
# @example
# lib::error::throw INVALID_ARGUMENT "Invalid argument"
# lib::error::throw COMMAND_NOT_FOUND "Command not found"
# lib::error::throw FUNCTION_NOT_FOUND "Function not found"
# lib::error::throw EXECUTION_FAILED "Execution failed"
#
# @description Throw an error
# @param $1 Error code name
# @param $* Error message
# @return void
lib::error::throw()
{
  local code_name=$1
  shift
  local message=$*

  lib::error "$message"
  return "${ERROR_CODES[$code_name]}"
}

# Logs a message to the console if the current log level is set so that the
# message is displayed. The log level is compared to the log level of the
# message and if the message log level is greater than or equal to the current
# log level, the message is displayed.
# The log levels are defined in the LOG_LEVELS associative array.
#
# @example
# logger::log "INFO" "This is an info message"
# logger::log "DEBUG" "This is a debug message"
# logger::log "WARN" "This is a warning message"
# logger::log "ERROR" "This is an error message"
#
# @description Log a message to the console based on the log level setting.
# @param $1 Log level
# @param $2 Message
# @return void
logger::log()
{
  local level=$1
  shift
  local msg=$1

  if [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[$LOG_LEVEL]} ]]; then
    printf '[%s] [%s]: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$msg" >&2
  fi
}

# Logs a debug message to the console, if the current log level is set to DEBUG or greater.
# The message is passed as arguments to the function.
# The function is defined above.
#
# @example
# logger::debug "This is a debug message"
#
# @description Log a debug message to the console
# @param $* Message
# @return void
logger::debug()
{
  logger::log "DEBUG" "$@"
}

# Logs an info message to the console, if the current log level is set to INFO or greater.
# The message is passed as arguments to the function.
# The function is defined above.
#
# @example
# logger::info "This is an info message"
#
# @description Log an info message to the console
# @param $* Message
# @return void
logger::info()
{
  logger::log "INFO" "$@"
}

# Logs a warning message to the console, if the current log level is set to WARN or greater.
# The message is passed as arguments to the function.
# The function is defined above.
#
# @example
# logger::warn "This is a warning message"
#
# @description Log a warning message to the console
# @param $* Message
# @return void
logger::warn()
{
  logger::log "WARN" "$@"
}

# Logs an error message to the console, if the current log level is set to ERROR or greater.
# The message is passed as arguments to the function.
# The function is defined above.
#
# @example
# logger::error "This is an error message"
#
# @description Log an error message to the console
# @param $* Message
# @return void
logger::error()
{
  logger::log "ERROR" "$@"
}

# Cleanup function to remove temporary files and directories
# when the script exits or is interrupted by a signal (e.g. Ctrl+C).
# The function is registered with the `EXIT` trap.
#
# @description Remove temporary files and directories
# @return void
cleanup()
{
  local exit_code=$?
  [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
  exit $exit_code
}

# Register the cleanup function to run on EXIT signal.
#
# This will ensure that temporary files and directories are removed
# when the script exits or is interrupted by a signal (e.g. Ctrl+C).
# The cleanup function is defined above.
trap cleanup EXIT

# Handle errors by logging an error message to the console.
#
# The function is registered with the `ERR` trap.
# The line number where the error occurred is passed as an argument to the function.
# The function is defined above.
#
# @description Handle an error
# @param $1 Line number
# @return void
handle_error()
{
  local exit_code=$?
  local line_no=$1
  logger::error "Failed at line ${line_no} with exit code ${exit_code}"
}

trap 'handle_error ${LINENO}' ERR
