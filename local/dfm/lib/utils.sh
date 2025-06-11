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

# Prints the provided text in black color using ANSI escape codes.
#
# Globals:
#   BLACK - ANSI escape code for black text.
#   RESET - ANSI escape code to reset terminal formatting.
#
# Arguments:
#   One or more strings that will be concatenated and printed.
#
# Outputs:
#   Writes the colored text to STDOUT (without a trailing newline).
#
# Example:
#   clr::black "This text will appear in black."
clr::black()
{
  printf "${BLACK}%s${RESET}" "$*"
}
# Prints the provided text in red using ANSI escape codes.
#
# Globals:
#   RED    - ANSI escape code for red.
#   RESET  - ANSI escape code to reset terminal formatting.
#
# Arguments:
#   One or more strings that will be printed in red.
#
# Outputs:
#   Writes the red formatted text to STDOUT.
#
# Example:
#   clr::red "Error: Invalid input"
clr::red()
{
  printf "${RED}%s${RESET}" "$*"
}
# Prints the given text in green using ANSI escape codes.
#
# Arguments:
#   * One or more strings to output in green. Multiple arguments are concatenated.
#
# Outputs:
#   Writes the formatted green text to STDOUT without a trailing newline.
#
# Example:
#   clr::green "Operation successful"
clr::green()
{
  printf "${GREEN}%s${RESET}" "$*"
}
# Prints the provided text in yellow color.
#
# Globals:
#   YELLOW - ANSI escape code for yellow text.
#   RESET  - ANSI escape code to reset text formatting.
#
# Arguments:
#   Any text passed as parameters will be printed in yellow.
#
# Outputs:
#   Colored text printed to STDOUT.
#
# Example:
#   clr::yellow "Hello, World!"
clr::yellow()
{
  printf "${YELLOW}%s${RESET}" "$*"
}
# Prints the provided text in blue using ANSI escape codes.
#
# Globals:
#   BLUE    ANSI escape sequence for blue text.
#   RESET   ANSI escape sequence to reset text formatting.
#
# Arguments:
#   $@      One or more strings to be printed in blue.
#
# Outputs:
#   Prints the input text in blue to STDOUT.
#
# Example:
#   clr::blue "Hello, World!"
clr::blue()
{
  printf "${BLUE}%s${RESET}" "$*"
}
# Prints the provided text in magenta color.
#
# This function outputs one or more strings wrapped in ANSI escape sequences
# to display them in magenta. It uses the global variables MAGENTA for the color
# and RESET to revert to the default formatting.
#
# Globals:
#   MAGENTA - ANSI escape sequence for magenta.
#   RESET   - ANSI escape code to reset formatting.
#
# Arguments:
#   One or more strings to print in magenta.
#
# Outputs:
#   Writes the formatted string directly to STDOUT.
#
# Example:
#   clr::magenta "Hello, World!"
clr::magenta()
{
  printf "${MAGENTA}%s${RESET}" "$*"
}
# Prints the provided text in white color using ANSI escape codes.
#
# Globals:
#   WHITE - ANSI escape code for white.
#   RESET - ANSI escape code to reset text formatting.
#
# Arguments:
#   Any text passed as arguments will be concatenated and printed.
#
# Outputs:
#   Writes the formatted text to STDOUT.
#
# Example:
#   clr::white "Hello, World!"
clr::white()
{
  printf "${WHITE}%s${RESET}" "$*"
}

# Applies bold styling to the provided text and prints it to STDOUT.
#
# Globals:
#   BOLD  - ANSI escape code for enabling bold text.
#   RESET - ANSI escape code for resetting text formatting.
#
# Arguments:
#   One or more strings to be printed in bold.
#
# Outputs:
#   Bold-formatted text is printed to STDOUT.
#
# Example:
#   style::bold "This is bold text"
style::bold()
{
  printf "${BOLD}%s${RESET}" "$*"
}
# Print the provided text in a dim style using ANSI escape codes.
#
# Globals:
#   DIM   - ANSI escape code for applying dim styling.
#   RESET - ANSI escape code to reset text formatting.
#
# Arguments:
#   $* - The text to be printed in dim style.
#
# Outputs:
#   Writes the formatted dim text to STDOUT.
#
# Example:
#   style::dim "This text will appear dimmed"
style::dim()
{
  printf "${DIM}%s${RESET}" "$*"
}
# Prints the provided text in italic style using ANSI escape sequences.
#
# Globals:
#   ITALIC - ANSI escape sequence for italic text styling.
#   RESET  - ANSI escape sequence to reset text styling.
#
# Arguments:
#   All passed arguments are combined and printed in italic formatting.
#
# Outputs:
#   The styled text is printed to STDOUT without an automatic newline.
#
# Example:
#   style::italic "Hello, world!"
style::italic()
{
  printf "${ITALIC}%s${RESET}" "$*"
}
# Underlines the provided text using ANSI escape codes.
#
# Globals:
#   UNDERLINE - ANSI escape sequence to start underlining.
#   RESET     - ANSI escape sequence to reset text formatting.
#
# Arguments:
#   $* - The text to be underlined.
#
# Outputs:
#   Prints the underlined text to STDOUT.
#
# Example:
#   style::underline "Underlined text"
style::underline()
{
  printf "${UNDERLINE}%s${RESET}" "$*"
}

# Prints a formatted line to STDOUT using the provided format string and arguments.
#
# Globals:
#   RESET - ANSI escape code to reset text formatting.
#
# Arguments:
#   $1 - A format string that may include ANSI styling codes (do not include a conversion specifier for the text).
#   $@ - The text to be formatted and printed.
#
# Outputs:
#   Writes the formatted text to STDOUT with an appended newline, ensuring that styling is reset afterward.
#
# Example:
#   list::print_formatted "${BOLD}" "Bold Text"
list::print_formatted()
{
  local format=$1
  shift
  printf "${format}%s${RESET}\n" "$@"
}

# Prints a formatted header with a decorative underline.
#
# Globals:
#   BOLD   - ANSI escape code for bold text.
#   BLUE   - ANSI escape code for blue text.
#   RESET  - ANSI escape code to reset text formatting.
#
# Arguments:
#   $1 - The header title to be displayed.
#
# Outputs:
#   Writes a styled header to STDOUT, including the title in bold blue and a subsequent decorative line.
#
# Example:
#   list::print_header "Available Commands"
list::print_header()
{
  printf "\n  ${BOLD}${BLUE}%s${RESET}\n" "$1"
  printf "%s\n" "  $(printf '%.s─' {1..60})"
}

# Prints a group header with bold yellow formatting.
#
# Globals:
#   YELLOW - ANSI escape code for yellow color.
#   BOLD   - ANSI escape code for bold text.
#   RESET  - ANSI escape code to reset text formatting.
#
# Arguments:
#   group  - The title text to display as the group header.
#
# Outputs:
#   Writes the formatted group header to STDOUT.
#
# Example:
#   list::print_group "My Group"
list::print_group()
{
  local group=$1
  printf "\n  ${YELLOW}${BOLD}%s${RESET}\n\n" "$group"
}

# Prints a formatted command with an optional description.
#
# Globals:
#   BOLD   - ANSI escape sequence for bold text.
#   CYAN   - ANSI escape sequence for cyan text.
#   RESET  - ANSI escape sequence to reset text formatting.
#   DIM    - ANSI escape sequence for dim text.
#
# Arguments:
#   cmd    - The command name to display.
#   desc   - Optional description of the command (defaults to an empty string).
#
# Outputs:
#   Writes the formatted command and description to STDOUT.
#
# Example:
#   list::print_command "ls" "List directory contents"
list::print_command()
{
  local cmd=$1
  local desc=${2:-""}
  printf "  ${BOLD}${CYAN}%-15s${RESET} ${DIM}%s${RESET}\n" "$cmd" "$desc"
}

# Prints a subcommand in a formatted style.
#
# This function displays a subcommand name in green with a fixed width for neat alignment,
# followed by an optional description text. The ANSI escape codes for green text and reset
# styling are used to highlight the subcommand.
#
# Globals:
#   GREEN  - ANSI escape code applied to the subcommand name.
#   RESET  - ANSI escape code used to reset text formatting.
#
# Arguments:
#   cmd   - The subcommand name to print.
#   desc  - (Optional) A description string for the subcommand. Defaults to empty if not provided.
#
# Outputs:
#   Prints the formatted subcommand and optional description to STDOUT.
#
# Example:
#   list::print_subcommand "deploy" "Deploy the application to the production server"
list::print_subcommand()
{
  local cmd=$1
  local desc=${2:-""}
  printf "    ${GREEN}%-13s${RESET} ${desc}\n" "$cmd"
}

# Iterates over functions defined in a command file and prints each as a formatted subcommand.
#
# This function reads function names from the specified command file, retrieves their descriptions
# (removing any '@description' prefix), and prints each function name as a bullet point with its
# associated description if available.
#
# Arguments:
#   cmd_file - The path to the command file containing function definitions.
#
# Outputs:
#   Prints formatted subcommand entries to STDOUT.
#
# Example:
#   list::loop_functions "/path/to/command_file.sh"
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

# Extracts and prints the documentation associated with a specific function from a command file.
#
# Globals:
#   None
#
# Arguments:
#   cmd_file - The file containing function definitions and their associated documentation.
#   func     - The name of the function whose documentation should be extracted.
#
# Outputs:
#   Writes the extracted documentation tags and their content to STDOUT.
#
# Returns:
#   None
#
# Example:
#   list::get_function_docs "commands.sh" "build_project"
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
# Checks if a specified command is available in the system.
#
# Arguments:
#   $1 - Command name to check.
#
# Returns:
#   0 if the command is found in the system's PATH, 1 otherwise.
#
# Example:
#   utils::is_installed "git" && echo "Git is installed" || echo "Git is not installed"
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
# Checks if a specified executable is available in one of the directories in the PATH.
#
# Globals:
#   PATH - The system's PATH environment variable listing directories to search.
#
# Arguments:
#   cmd: The name of the executable file to look for.
#
# Returns:
#   0 if the executable is found in one of the PATH directories, 1 otherwise.
#
# Example:
#   utils::in_path ls && echo "ls is available in PATH"
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
# Retries a command until it succeeds or the maximum number of attempts is reached.
#
# Arguments:
#   tries                   - Maximum number of attempts to execute the command.
#   command and its args    - The command to run and any arguments to pass.
#
# Globals:
#   logger::warn            - Logs a warning message for each failed attempt.
#
# Outputs:
#   Warning messages are printed to STDERR for each retry.
#
# Returns:
#   0 if the command eventually succeeds; 1 if all attempts fail.
#
# Example:
#   utils::retry 3 my_command --option value
#
# Dependencies:
#   logger::warn
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
# Prompts the user for confirmation with a yes/no question.
#
# Arguments:
#   prompt: The message displayed to the user when asking for confirmation.
#   default: An optional default answer used if no input is provided (defaults to "Y").
#
# Outputs:
#   Repeatedly prompts the user until a valid yes or no answer is received.
#   An error message is displayed for any invalid response.
#
# Returns:
#   0 if the user confirms (answers yes), 1 if the user declines (answers no).
#
# Example:
#   if utils::interactive::confirm "Do you want to proceed?"; then
#       echo "Proceeding..."
#   else
#       echo "Operation cancelled."
#   fi
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
# Finds all command script files (*.sh) in the directory specified by DFM_CMD_DIR.
#
# Globals:
#   DFM_CMD_DIR - The directory to search for command files.
#
# Outputs:
#   Echoes a space-separated list of command file paths.
#
# Example:
#   files=$(main::find_commands)
#   echo "$files"  # Displays the list of found command files.
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
# Extracts the names of functions defined in the specified command file.
#
# This function parses the provided file for Bash function definitions using
# regex patterns matching both "function name() {" and "name() {" styles.
# It outputs the names of the functions, one per line.
#
# Globals:
#   None.
#
# Arguments:
#   cmd_file - Path to the file containing Bash function definitions.
#
# Outputs:
#   Writes the list of function names to STDOUT.
#
# Returns:
#   A list of function names extracted from the file.
#
# Example:
#   main::get_command_functions "/path/to/command_file.sh"
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
# Retrieves the annotated description of a specified function from a command file.
#
# This function searches the provided command file for an "@description" comment
# preceding the definition of the designated function. It then extracts and prints
# the description text. If no description is found, nothing is printed.
#
# Arguments:
#   cmd  - Command name or path to the file containing the function definitions.
#   func - Name of the function whose description is to be extracted.
#
# Outputs:
#   The extracted description text is printed to STDOUT.
#
# Example:
#   desc=$(main::get_function_description "install" "my_function")
main::get_function_description()
{
  local cmd_file="$1"
  local func="$2"

  if [[ ! -f "$cmd_file" ]]; then
    [[ -n ${DFM_CMD_DIR:-} ]] || return 1
    cmd_file="${DFM_CMD_DIR}/${cmd_file}.sh"
  fi

  [[ -f "$cmd_file" ]] || return 1

  grep -B3 -E "^[[:space:]]*(function[[:space:]]*)?${func}\(\)[[:space:]]*(\{)?" "$cmd_file" \
    | grep "@description" \
    | sed -E 's/^[[:space:]]*#[[:space:]]*@description[[:space:]]*//'
}

# List all available commands and their functions.
#
# The function uses main::find_commands to get a list of command files.
# It then iterates over the files and prints the command name and
# its functions.
#
# Lists all available commands and their subcommands.
#
# Description:
#   Uses main::find_commands to locate command files and prints a header followed by a group title.
#   For each command file, extracts the command name (removing the '.sh' extension) and prints it,
#   then calls list::loop_functions to display detailed subcommands.
#
# Globals:
#   None.
#
# Arguments:
#   None.
#
# Outputs:
#   Writes the formatted list of commands and associated subcommands to STDOUT.
#
# Example:
#   main::list_available_commands
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
# Executes a specified function from a command file.
#
# This function validates and runs a function defined within a command file. It checks that both
# the command and function names contain only allowed characters (alphanumeric, underscores, or dashes),
# verifies that the command file (located in DFM_CMD_DIR) exists, is readable, and is free of syntax errors,
# and then sources the file. If the specified function exists in the file, it is executed with any additional
# arguments provided.
#
# Globals:
#   DFM_CMD_DIR - Directory containing command files.
#
# Arguments:
#   command: The command file name (without .sh extension) to execute. Must match ^[a-zA-Z0-9_-]+$.
#   function: The function name to be executed from the command file. Must match ^[a-zA-Z0-9_-]+$.
#   [additional arguments]: Extra parameters to pass to the executed function.
#
# Outputs:
#   Any output generated by the executed function. Error messages are output via lib::error.
#
# Returns:
#   0 if the function executes successfully; 1 if an error occurs (e.g., invalid names, missing or unreadable
#   command file, syntax errors in the command file, or if the specified function is not found).
#
# Example:
#   main::execute_command "deploy" "run_deploy" "arg1" "arg2"
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
