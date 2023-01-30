#!/usr/bin/env bash
#
# Shared bash functions and helpers
# that can be sourced to other scripts.
#

# -- Colors -- #
CLR_RED="\033[1;31m"
CLR_YELLOW='\033[1;33m'
CLR_GREEN="\033[1;32m"
CLR_BLUE='\033[1;34m'
CLR_RESET="\033[0m"

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

function msg_done()
{
  echo -e "$(__log_marker) $1 ...$(__log_marker_ok)"
}

function msg_prompt()
{
  echo -e "$(__log_marker) $1"
}

function msg_prompt_done()
{
  echo -e "$(__log_marker) $1 ...$(__log_marker_ok)"
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
