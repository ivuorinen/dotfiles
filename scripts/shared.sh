#!/usr/bin/env bash
#
# Shared bash functions and helpers
# that can be sourced to other scripts.
#

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
