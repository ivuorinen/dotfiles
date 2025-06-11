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
# Logs a message with a timestamp.
#
# Description:
#   Outputs the provided message(s) to standard output, prepended with the current date and
#   time in the format [YYYY-MM-DD HH:MM:SS]. This timestamp helps in tracking log events.
#
# Arguments:
#   One or more strings that form the log message.
#
# Outputs:
#   Writes the timestamped log message to standard output.
#
# Example:
#   lib::log "Server started"   # Outputs: [2025-02-28 09:45:00] Server started
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
# Logs an error message with a timestamp to standard error.
#
# This function formats the provided message(s) by prefixing it with the current date
# and time along with an "ERROR:" label, then outputs the result to STDERR.
#
# Arguments:
#   $* - The error message or messages to be logged.
#
# Outputs:
#   Writes the formatted error message to STDERR.
#
# Example:
#   lib::error "Failed to read the configuration file."
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
# Logs an error message based on the previous command's exit code and the provided context.
#
# This function captures the exit code from the last executed command and, using the provided
# line number and command string, determines the appropriate error message to log based on
# predefined error codes stored in the ERROR_CODES associative array.
#
# Globals:
#   ERROR_CODES - An associative array mapping error code names to numeric values.
#   lib::error  - Logs error messages to STDERR.
#
# Arguments:
#   line_no  - The line number in the script where the error occurred.
#   command  - The command that was executed when the error occurred.
#
# Outputs:
#   Writes a descriptive error message to STDERR.
#
# Returns:
#   The exit code of the failed command.
#
# Example:
#   # If a command fails with an exit code corresponding to an invalid argument:
#   lib::error::handle 42 "some_command"
#   # This logs: "Invalid argument at line 42 in command 'some_command'" (if the exit code matches ERROR_CODES[INVALID_ARGUMENT])
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
# Logs an error message and terminates the script by performing cleanup with a specified error code.
#
# Globals:
#   ERROR_CODES - Associative array mapping error code names to numeric exit values.
#
# Arguments:
#   code_name - The key to retrieve the error code from the ERROR_CODES array.
#   message   - The error message to log, constructed from all subsequent arguments.
#
# Outputs:
#   Logs the error message to standard error.
#
# Returns:
#   Exits the script via the cleanup function; does not return.
#
# Example:
#   lib::error::throw "FILE_NOT_FOUND" "Required file not found: /path/to/file"
lib::error::throw()
{
  local code_name=$1
  shift
  local message=$*

  lib::error "$message"
  cleanup "${ERROR_CODES[$code_name]}"
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
# Logs a message if its severity meets or exceeds the global log level.
#
# Globals:
#   LOG_LEVELS - Associative array mapping log level names to severity values.
#   LOG_LEVEL  - The current log level threshold.
#
# Arguments:
#   level: A string representing the log severity (e.g., DEBUG, INFO, WARN, ERROR).
#   msg:   The message to log.
#
# Outputs:
#   Prints a formatted log message with a timestamp to STDERR when the specified level qualifies.
#
# Example:
#   logger::log INFO "Initialization complete"
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
# Logs a debug-level message.
#
# This function logs a message at the DEBUG level by delegating to logger::log.
# It accepts one or more arguments that form the debug message, which are passed along
# to the underlying logger::log function.
#
# Example:
#   logger::debug "Debug info for variable x:" "$x"
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
# Logs an informational message to the console.
#
# Description:
#   This function wraps the logger::log function to log messages at the "INFO" level. All provided arguments are
#   forwarded to logger::log, where the message is formatted and output based on the current logging configuration.
#
# Arguments:
#   A message string followed by optional additional parameters used to format the message.
#
# Outputs:
#   The formatted informational message is written to STDOUT if the INFO log level is enabled.
#
# Example:
#   logger::info "Service started successfully on port" 8080
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
# Logs a warning message.
#
# This function acts as a wrapper around `logger::log` by setting the log level to "WARN"
# for all provided message arguments. It forwards the given messages to the logger for output.
#
# Arguments:
#   A variable list of strings representing the warning message.
#
# Outputs:
#   Writes a formatted warning message to the console.
#
# Example:
#   logger::warn "Low disk space" "Free up some space to avoid issues"
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
# Logs an error message at the ERROR level.
#
# This function wraps the generic logging mechanism to record error messages by automatically
# specifying the ERROR severity level. It passes all provided arguments to the underlying logging function.
#
# Arguments:
#   Error message(s) – One or more strings that describe the error.
#
# Example:
#   logger::error "Unable to open file" "/path/to/file"
logger::error()
{
  logger::log "ERROR" "$@"
}

# Cleanup function to remove temporary files and directories
# when the script exits or is interrupted by a signal (e.g. Ctrl+C).
# The function is registered with the `EXIT` trap.
#
# @description Remove temporary files and directories
# Cleans up temporary resources before exiting.
#
# Globals:
#   TEMP_DIR - Path to the temporary directory to be removed if it exists.
#
# Returns:
#   Exits the script with the original exit code.
#
# Example:
#   trap cleanup EXIT
cleanup() {
  local exit_code=${1:-$?}
  if [[ -n ${TEMP_DIR:-} && -d $TEMP_DIR ]]; then
    rm -rf "$TEMP_DIR"
  fi
  exit "$exit_code"
}

# Register the cleanup function to run on EXIT signal.
# This ensures temporary files and directories are removed
# when the script exits or is interrupted.
trap cleanup EXIT

# Handle errors by logging an error message to the console.
# The `ERR` trap passes the line number and command to lib::error::handle.
#
# Example:
#   lib::error::handle ${LINENO} "$BASH_COMMAND"
trap 'lib::error::handle ${LINENO} "$BASH_COMMAND"' ERR
