#!/usr/bin/env bash
#
# Shared bash functions and helpers
# that can be sourced to other scripts.

# Helper env variables. Use like this: VERBOSE=1 ./script.sh
: "${VERBOSE:=0}"

source "$DOTFILES/local/bin/msgr"

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

# Cache commands using bkt if installed
if command -v bkt >&/dev/null; then
  bkt()
  {
    command bkt --cache-dir="$XDG_CACHE_HOME/bkt" "$@"
  }
else
  # If bkt isn't installed skip its arguments and just execute directly.
  # Optionally write a msg to stderr suggesting users install bkt.
  bkt()
  {
    while [[ "$1" == --* ]]; do shift; done
    "$@"
  }
fi

# shorthand for checking if the system has the bin in path,
# this version does not use caching
# usage: have_command php && php -v
function have_command
{
  command -v "$1" >&/dev/null
}

# shorthand for checking if the system has the bin in path,
# this version uses caching
# usage: have php && php -v
function have
{
  bkt -- command -v "$1" >&/dev/null
}

function brew_installed
{
  bkt -- brew list
}

# shorthand for checking if brew package is installed
# usage: have_brew php && php -v
function have_brew
{
  ! have brew && return 125

  if bkt -- brew list "$1" &> /dev/null; then
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

# Check if a file contains non-ascii characters
nonascii()
{
  LC_ALL=C grep -n '[^[:print:][:space:]]' "${@}"
}
