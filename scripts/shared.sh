#!/usr/bin/env bash
#
# Shared bash functions and helpers
# that can be sourced to other scripts.

# Helper env variables. Use like this: VERBOSE=1 ./script.sh
: "${VERBOSE:=0}"

# -- Colors -- #
CLR_RED="\033[1;31m"
CLR_YELLOW="\033[1;33m"
CLR_GREEN="\033[1;32m"
CLR_BLUE="\033[1;34m"
CLR_RESET="\033[0m"

# -- Color functions -- #
function __color_red()
{
  local MSG="$1"
  echo -e "${CLR_RED}${MSG}${CLR_RESET}"
}
function __color_yellow()
{
  local MSG="$1"
  echo -e "${CLR_YELLOW}${MSG}${CLR_RESET}"
}
function __color_green()
{
  local MSG="$1"
  echo -e "${CLR_GREEN}${MSG}${CLR_RESET}"
}
function __color_blue()
{
  local MSG="$1"
  echo -e "${CLR_BLUE}${MSG}${CLR_RESET}"
}

# -- Helpers -- #
function __log_marker()
{
  echo -e "${CLR_BLUE}➜${CLR_RESET}"
}

function __log_marker_ok()
{
  echo -e "${CLR_GREEN}✔${CLR_RESET}"
}

function __log_marker_ok_blue()
{
  echo -e "${CLR_BLUE}✔${CLR_RESET}"
}

function __log_marker_warn()
{
  echo -e "${CLR_YELLOW}⁕${CLR_RESET}"
}

function __log_marker_question()
{
  echo -e "${CLR_YELLOW}?${CLR_RESET}"
}

function __log_marker_err()
{
  echo -e "${CLR_RED}⛌${CLR_RESET}"
}

function __log_indent()
{
  echo "    "
}

# -- Log -- #
function msg()
{
  echo -e "$(__log_marker) $1"
}

function msg_yay()
{
  echo -e "🎉 $1"
}

function msg_yay_done()
{
  echo -e "🎉 $1 ...$(__log_marker_ok)"
}

function msg_done()
{
  echo -e "$(__log_marker) $1 ...$(__log_marker_ok)"
}

function msg_done_suffix()
{
  echo -e "$(__log_marker) ...$(__log_marker_ok)"
}

function msg_prompt()
{
  echo -e "$(__log_marker_question) $1"
}

function msg_prompt_done()
{
  echo -e "$(__log_marker_question) $1 ...$(__log_marker_ok)"
}

function msg_nested()
{
  echo -e "$(__log_indent)$(__log_marker) $1"
}

function msg_nested_done()
{
  echo -e "$(__log_indent)$(__log_marker) $1 ...$(__log_marker_ok)"
}

function msg_run()
{
  echo -e "${CLR_GREEN}➜ $1${CLR_RESET} $2"
}

function msg_run_done()
{
  echo -e "${CLR_GREEN}➜ $1${CLR_RESET} $2 ...$(__log_marker_ok)"
}

function msg_ok()
{
  echo -e "$(__log_marker_ok) $1"
}

function msg_warn()
{
  echo -e "$(__log_marker_warn) $1"
}

function msg_err()
{
  echo -e "$(__log_marker_err) $1"
}

# -- Menu builder -- #
function menu_section()
{
  LINE=$(printf '%-18s [ %-15s ]\n' "$1" "$2")
  echo -e " $(__log_marker) $LINE"
}
function menu_item()
{
  LINE=$(printf '%-15s %-30s\n' "$1" "$2")
  echo -e "$(__log_indent)$(__log_marker) $LINE"
}

# https://stackoverflow.com/a/85932
function fn_exists()
{
  declare -f -F "$1" > /dev/null
  return $?
}

# Takes a bash array ("cow:moo", "dinosaur:roar") and loops
# through the keys to build menu section listing.
function menu_usage_header()
{
  MENU_CMD="$1"
  shift
  MENU_ARRAY=("$@")

  KEYS=""
  for item in "${MENU_ARRAY[@]}"; do
    CMD=$(echo "${item}" | awk -F ":" '{print $1}')
    KEYS+="${CMD} | "
  done

  # "???" removes 3 last characters, being " | " from the end
  menu_section "$MENU_CMD" "${KEYS%???}"
}

# Takes the usage command "$0 dotfiles" and a
# bash array ("cow:moo" "dinosaur:roar") and loops
# through in building a menu for dfm command usage listing.
function menu_usage()
{
  MENU_CMD="$1"
  shift
  MENU_ARRAY=("$@")

  msg "$MENU_CMD"

  for item in "${MENU_ARRAY[@]}"; do
    CMD=$(echo "${item}" | awk -F ":" '{print $1}')
    DESC=$(echo "${item}" | awk -F ":" '{print $2}')
    menu_item "$CMD" "$DESC"
  done
}

# shorthand for checking if the system has the bin in path.
# usage: have php && php -v
function have
{
  command -v "$1" >&/dev/null
}

# shorthand for checking if brew package is installed
# usage: have_brew php && php -v
function have_brew
{
  ! have brew && return 125

  if brew list "$1" &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# Remove directory from the PATH variable
# usage: path_remove ~/.local/bin
function path_remove
{
  PATH=$(echo -n "$PATH" | awk -v RS=: -v ORS=: "\$0 != \"$1\"" | sed 's/:$//')
}

# Append directory to the PATH
# usage: path_append ~/.local/bin
function path_append
{
  path_remove "$1"
  PATH="${PATH:+"$PATH:"}$1"
}

# Prepend directory to the PATH
# usage: path_prepend ~/.local/bin
function path_prepend
{
  path_remove "$1"
  PATH="$1${PATH:+":$PATH"}"
}

# Creates a random string
rnd()
{
  echo $RANDOM | md5sum | head -c 20
}

# return sha256sum for file
# $1 - filename (string)
function get_sha256sum()
{
  sha256sum "$1" | head -c 64
}

# Replacable file
#
# $1 - filename (string)
# $2 - filename (string)
#
# Returns 1 when replacable, 0 when not replacable.
function replacable()
{
  FILE1="$1"
  FILE2="$2"

  [[ ! -r "$FILE1" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "File 1 ($FILE1) does not exist"
    return 0
  }
  [[ ! -r "$FILE2" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "File 2 ($FILE2) does not exist, replacable"
    return 1
  }

  FILE1_HASH=$(get_sha256sum "$FILE1")
  FILE2_HASH=$(get_sha256sum "$FILE2")

  [[ $FILE1_HASH = "" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "Could not get hash for file 1 ($FILE1)"
    return 0
  }
  [[ $FILE2_HASH = "" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "Could not get hash for file 2 ($FILE2), replacable"
    return 1
  }

  [[ "$FILE1_HASH" == "$FILE2_HASH" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_ok "Files match, not replacable: $FILE1"
    return 0
  }

  [[ $VERBOSE -eq 1 ]] && msg_warn "Files do not match ($FILE1_HASH != $FILE2_HASH), replacable"

  return 1
}

# Create directory if it doesn't exist already
x-dc()
{
  dir="$1"

  [ $# -eq 0 ] && {
    echo "Usage: $0 full/path/to/dir/to/create"
    exit 1
  }

  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" && exit 0
  fi
}

# Create a new directory and enter it
mkd()
{
  mkdir -p "$@" && cd "$@" || exit
}

# Run command silently
# Usage: silent uptime
silent()
{
  "$@" >&/dev/null
}

# Create a prompt which you have to answer y/n to continue
ask()
{
  while true; do
    read -p "$1 ([y]/n) " -r
    REPLY=${REPLY:-"y"}
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      return 1
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
      return 0
    fi
  done
}

