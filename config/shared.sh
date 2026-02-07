#!/usr/bin/env bash
#
# Shared configuration
#
# shellcheck shell=bash

# Defaults
[[ -z "$DOTFILES" ]] && export DOTFILES="$HOME/.dotfiles"
DOTFILES_CURRENT_SHELL=$(basename "$SHELL")
export DOTFILES_CURRENT_SHELL

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"
# Enable debugging with DEBUG=1
DEBUG="${DEBUG:-0}"

# Enable debugging with DEBUG=1
[[ "${DEBUG:-0}" -eq 1 ]] && set -x

# Detect the current shell
CURRENT_SHELL=$(ps -p $$ -ocomm= | awk -F/ '{print $NF}')

# Function to prepend a path to PATH based on the shell
x-path-prepend()
{
  local dir=$1
  case "$CURRENT_SHELL" in
    fish)
      set -U fish_user_paths "$dir" "$fish_user_paths"
      ;;
    sh | bash | zsh)
      PATH="$dir:$PATH"
      ;;
    *)
      echo "Unsupported shell: $CURRENT_SHELL"
      exit 1
      ;;
  esac
  return 0
}

# Function to set environment variables based on the shell
x-set-env()
{
  local var=$1
  local value=$2
  case "$CURRENT_SHELL" in
    fish)
      set -x "$var" "$value"
      ;;
    sh | bash | zsh)
      export "$var=$value"
      ;;
    *)
      echo "Unsupported shell: $CURRENT_SHELL"
      exit 1
      ;;
  esac
  return 0
}

# Explicitly set XDG folders, if not already set
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
x-set-env XDG_CONFIG_HOME "$HOME/.config"
x-set-env XDG_DATA_HOME "$HOME/.local/share"
x-set-env XDG_CACHE_HOME "$HOME/.cache"
x-set-env XDG_STATE_HOME "$HOME/.local/state"
x-set-env XDG_BIN_HOME "$HOME/.local/bin"

# Paths
x-path-prepend "/usr/local/bin"
x-path-prepend "/opt/homebrew/bin"
x-path-prepend "$XDG_DATA_HOME/cargo/bin"
x-path-prepend "$XDG_DATA_HOME/bob/nvim-bin"
x-path-prepend "$DOTFILES/local/bin"
x-path-prepend "$XDG_BIN_HOME"

# Custom completion paths
[[ -z "$ZSH_CUSTOM_COMPLETION_PATH" ]] && export ZSH_CUSTOM_COMPLETION_PATH="$XDG_CONFIG_HOME/zsh/completion"
x-dc "$ZSH_CUSTOM_COMPLETION_PATH"
export FPATH="$ZSH_CUSTOM_COMPLETION_PATH:$FPATH"

if ! declare -f msg > /dev/null; then
  # Function to print messages if VERBOSE is enabled
  # $1 - message (string)
  msg()
  {
    [[ "$VERBOSE" -eq 1 ]] && msgr msg "$1"
    return 0
  }
  msg "msg was not defined, defined it now"
fi

if ! declare -f msg_err > /dev/null; then
  msg "msg_err was not defined, defined it now"
  # Function to print error messages and exit
  # $1 - error message (string)
  msg_err()
  {
    msgr err "$1" >&2
    exit 1
  }
fi

if ! declare -f msg_done > /dev/null; then
  msg "msg_done was not defined, defined it now"
  # Function to print done message
  # $1 - message (string)
  msg_done()
  {
    msgr "done" "$1"
    return 0
  }
fi

if ! declare -f msg_run > /dev/null; then
  msg "msg_run was not defined, defined it now"
  # Function to print running message
  # $1 - message (string)
  msg_run()
  {
    msgr run "$1"
    return 0
  }
fi

if ! declare -f msg_ok > /dev/null; then
  msg "msg_ok was not defined, defined it now"
  # Function to print ok message
  # $1 - message (string)
  msg_ok()
  {
    msgr ok "$1"
    return 0
  }
fi

if ! declare -f array_diff > /dev/null; then
  # Function to compare two arrays and return the difference
  # Example: array_diff DIFFERENCE ARRAY1 ARRAY2
  # $1 - variable to store the difference
  # $2 - first array
  # $3 - second array
  # Output to $1 the difference between $2 and $3
  # Source: https://stackoverflow.com/a/42399479/594940
  array_diff()
  {
    # shellcheck disable=SC1083,SC2086
    eval local ARR1=\(\"\${$2[@]}\"\)
    # shellcheck disable=SC1083,SC2086
    eval local ARR2=\(\"\${$3[@]}\"\)
    local IFS=$'\n'
    mapfile -t "$1" < <(comm -23 <(echo "${ARR1[*]}" | sort) <(echo "${ARR2[*]}" | sort))
    return 0
  }
fi

source "$DOTFILES/config/exports"
source "$DOTFILES/config/alias"
