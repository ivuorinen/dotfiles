#!/usr/bin/env bash
# dfm utility functions for common tasks
# Source this file to use the functions in your scripts.
#
# @author Ismo Vuorinen <https://github.com/ivuorinen>
# @license MIT
set -euo pipefail

# ANSI escape codes
readonly RESET="\033[0m"
readonly BOLD="\033[1m"
readonly DIM="\033[2m"
readonly ITALIC="\033[3m"
readonly UNDERLINE="\033[4m"

# Colors
readonly BLACK="\033[30m"
readonly RED="\033[31m"
readonly GREEN="\033[32m"
readonly YELLOW="\033[33m"
readonly BLUE="\033[34m"
readonly MAGENTA="\033[35m"
readonly CYAN="\033[36m"
readonly WHITE="\033[37m"

clr::black()
{
  printf "${BLACK}%s${RESET}" "$*"
}
clr::red()
{
  printf "${RED}%s${RESET}" "$*"
}
clr::green()
{
  printf "${GREEN}%s${RESET}" "$*"
}
clr::yellow()
{
  printf "${YELLOW}%s${RESET}" "$*"
}
clr::blue()
{
  printf "${BLUE}%s${RESET}" "$*"
}
clr::magenta()
{
  printf "${MAGENTA}%s${RESET}" "$*"
}
clr::white()
{
  printf "${WHITE}%s${RESET}" "$*"
}

style::bold()
{
  printf "${BOLD}%s${RESET}" "$*"
}
style::dim()
{
  printf "${DIM}%s${RESET}" "$*"
}
style::italic()
{
  printf "${ITALIC}%s${RESET}" "$*"
}
style::underline()
{
  printf "${UNDERLINE}%s${RESET}" "$*"
}

# Function to print formatted line
list::print_formatted()
{
  local format=$1
  shift
  printf "${format}%s${RESET}\n" "$@"
}

# Function to print a header
list::print_header()
{
  printf "\n  ${BOLD}${BLUE}%s${RESET}\n" "$1"
  printf "%s\n" "  $(printf '%.s─' {1..60})"
}

# Function to print a group header
list::print_group()
{
  local group=$1
  printf "\n  ${YELLOW}${BOLD}%s${RESET}\n\n" "$group"
}

# Function to print a command
list::print_command()
{
  local cmd=$1
  local desc=${2:-""}
  printf "  ${BOLD}${CYAN}%-15s${RESET} ${DIM}%s${RESET}\n" "$cmd" "$desc"
}

# Function to print a subcommand
list::print_subcommand()
{
  local cmd=$1
  local desc=${2:-""}
  printf "    ${GREEN}%-13s${RESET} ${desc}\n" "$cmd"
}

list::loop_functions()
{
  local cmd_file="$1"
  while IFS= read -r func; do
    # Get the function description from the function definition in the
    # command file. If no description is found, print only the function name.
    # The description is printed without the @description prefix.
    # If the function is not found, print only the function name.
    # The function name is printed with a bullet point.
    local doc
    doc=$(main::get_function_description "$cmd_file" "$func")
    if [[ -n "$doc" ]]; then
      list::print_subcommand "$func:" "${doc#*@description}"
    else
      list::print_subcommand "$func" ""
    fi
  done < <(main::get_command_functions "$cmd_file")
}

# Get the documentation for a function from a command file.
list::get_function_docs()
{
  local cmd_file="$1"
  local func="$2"

  awk -v func="$func" '
        # Start collecting documentation when a function is found and the line contains @
        /^[[:space:]]*#[[:space:]]*@/ {
            tag = $2
            sub(/^[[:space:]]*#[[:space:]]*@[[:space:]]*[a-zA-Z]+[[:space:]]*/, "")
            docs[tag] = $0
            last_tag = tag
        }

        # Collect multi-line documentation
        /^[[:space:]]*#/ && last_tag && !/^[[:space:]]*#[[:space:]]*@/ {
            sub(/^[[:space:]]*#[[:space:]]*/, "")
            docs[last_tag] = docs[last_tag] " " $0
        }

        # Empty line or comment line ends documentation
        !/^[[:space:]]*#/ {
            last_tag = ""
        }

        # When the function is found, print the documentation
        $0 ~ "^[[:space:]]*(function[[:space:]]+)?" func "\\(\\)" {
            for (tag in docs) {
                printf "@%s %s\n", tag, docs[tag]
            }
        }
    ' "$cmd_file"
}

# Check if a command exists in the current environment and return 0 if it does.
# Otherwise, return 1.
#
# @example
# if utils::is_installed curl; then
#    echo "curl is installed"
# else
#  echo "curl is not installed"
# fi
#
# @description Check if a command exists
# @param $1 Command to check
# @return 0 if the command exists, 1 otherwise
utils::is_installed()
{
  command -v "$1" > /dev/null 2>&1
}

# Check if a directory exists in the current env PATH and return 0 if it does.
# Otherwise, return 1.
#
# @example
# if utils::in_path /usr/local/bin; then
#   echo "/usr/local/bin is in PATH"
# else
#  echo "/usr/local/bin is not in PATH"
# fi
#
# @description Check if a directory is in PATH
# @param $1 Directory to check
# @return 0 if the directory is in PATH, 1 otherwise
utils::in_path()
{
  local cmd=$1
  local result=1
  IFS=: read -ra path <<< "$PATH"
  for p in "${path[@]}"; do
    if [[ -x "$p/$cmd" ]]; then
      result=0
      break
    fi
  done
  return $result
}

# Retry a command until it succeeds or the maximum number of retries is reached.
# Logs a warning message if the command fails and is retried after a short delay.
#
# @example
# if utils::retry 3 curl -sSL https://example.com; then
#    echo "Success"
# else
#   echo "Failed"
# fi
#
# @description Retry a command
# @param $1 Maximum number of retries
# @param $2.. Command to run
# @return 0 if the command succeeds, 1 otherwise
# @dependencies logger::warn
utils::retry()
{
  local tries=$1
  shift
  local count=1

  until "$@"; do
    [[ $count -gt $tries ]] && return 1
    logger::warn "Failed, retry $count/$tries"
    ((count++))
    sleep 1
  done
  return 0
}

# Ask for confirmation before proceeding. The default value is used if the user
# presses Enter without providing an answer.
#
# @example
# if utils::interactive::confirm "Are you sure?"; then
#    echo "Confirmed"
# else
#   echo "Not confirmed"
# fi
#
# @description Confirm an action
# @param $1 Prompt message
# @param $2 Default value
# @return 0 if the user confirms, 1 otherwise
utils::interactive::confirm()
{
  local prompt=$1
  local default=${2:-Y}

  while true; do
    read -rp "$prompt [Y/n]: " response
    case ${response:-$default} in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer yes or no" ;;
    esac
  done
}

# Find all command files in the cmd directory and return them
# as a space-separated string of filenames (e.g. "cmd1.sh cmd2.sh").
#
# The function uses a while loop to read the output of the find command
# line by line. The -print0 option is used to separate the filenames with
# a null character (\0) instead of a newline. This is necessary to handle
# filenames with spaces correctly.
#
# The read command reads the null-separated filenames and appends them to
# the cmd_files array. Finally, the function prints the array elements
# separated by a space.
#
# @return A space-separated string of command files.
main::find_commands()
{
  local cmd_files=()
  while IFS= read -r -d '' file; do
    cmd_files+=("$file")
  done < <(find "$DFM_CMD_DIR" -type f -name "*.sh" -print0)
  echo "${cmd_files[@]}"
}

# Get the function names from a command file.
#
# The function uses grep to find function definitions (function xxx() or xxx())
# and sed to extract the function names. The function names are printed one per
# line.
#
# @param cmd_file The command file to extract function names from.
# @return A list of function names.
main::get_command_functions()
{
  local cmd_file="$1"
  # Find function definitions (function xxx() or xxx())
  grep -E '^[[:space:]]*(function[[:space:]]+)?[a-zA-Z0-9_]+\(\)[[:space:]]*{' "$cmd_file" \
    | sed -E 's/^[[:space:]]*(function[[:space:]]+)?([a-zA-Z0-9_]+).*/\2/'
}

# Get the description of a function from a command file.
#
# The function uses grep to find the function definition and sed to extract
# the description. The description is printed without the @description prefix.
#
# @param cmd_file The command file to extract the function description from.
# @param func The function name.
# @return The function description.
main::get_function_description()
{
  local cmd_file="$1"
  local func="$2"

  grep -B1 "^[[:space:]]*\(function[[:space:]]*\)\{0,1\}$func().*{" "$cmd_file" \
    | grep "@description" \
    | sed -E 's/^[[:space:]]*#[[:space:]]*@description[[:space:]]*//'
}

# List all available commands and their functions.
#
# The function uses main::find_commands to get a list of command files.
# It then iterates over the files and prints the command name and
# its functions.
#
# @return None
main::list_available_commands()
{
  local cmd_files
  cmd_files=$(main::find_commands)

  list::print_header "dfm - dotfiles manager"
  list::print_group "Available commands"

  for cmd_file in $cmd_files; do
    local cmd_name
    cmd_name=$(basename "$cmd_file" .sh)
    list::print_command "$cmd_name"

    list::loop_functions "$cmd_file"
  done
}

# Execute a command function.
#
# The function loads the command file and checks if the function exists.
# If the function exists, it executes the function with the provided arguments.
#
# @param cmd The command name.
# @param func The function name.
# @param args The function arguments.
# @return None
main::execute_command()
{
  local cmd="$1"
  shift
  local func="$1"
  shift

  # Validate input
  if [[ ! "$cmd" =~ ^[a-zA-Z0-9_-]+$ ]] || [[ ! "$func" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    lib::error "Invalid command or function name"
    return 1
  fi

  local cmd_file="${DFM_CMD_DIR}/${cmd}.sh"
  if [[ ! -f "$cmd_file" ]] || [[ ! -r "$cmd_file" ]]; then
    lib::error "Command '$cmd' not found"
    return 1
  fi

  # Validate command file
  if ! bash -n "$cmd_file"; then
    lib::error "Command file '$cmd' contains syntax errors"
    return 1
  fi

  # Source the command file
  # shellcheck source=/dev/null
  source "$cmd_file"

  # Check if the function exists
  if ! declare -f "$func" > /dev/null; then
    lib::error "Function '$func' not found in command '$cmd'"
    return 1
  fi

  # Run the function with the provided arguments
  "$func" "$@"
}
