#!/usr/bin/env bash
#
# Shared bash functions and helpers
# that can be sourced to other scripts.

# Helper env variables. Use like this: VERBOSE=1 ./script.sh
: "${VERBOSE:=0}"

# Modified from https://stackoverflow.com/a/28776166
(
  [[ -n $ZSH_VERSION && $ZSH_EVAL_CONTEXT =~ :file$ ]] \
    || [[ -n $BASH_VERSION ]] && (return 0 2> /dev/null)
) && sourced=1 || sourced=0

export DOTFILES="$HOME/.dotfiles"
DOTFILES_CURRENT_SHELL=$(ps -p $$ -oargs=)
export DOTFILES_CURRENT_SHELL

# Explicitly set XDG folders
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# custom variables
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="$HOME/.local/run"

# Remove directory from the PATH variable
# usage: path_remove ~/.local/bin
function path_remove
{
  x-path-remove "$1"
}

# Append directory to the PATH
# usage: path_append ~/.local/bin
function path_append
{
  x-path-remove "$1"
  x-path-prepend "$1"
}

# Prepend directory to the PATH
# usage: path_prepend ~/.local/bin
function path_prepend
{
  x-path-remove "$1"
  x-path-prepend "$1"
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
