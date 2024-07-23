#!/usr/bin/env bash
#
# Shared configuration
#
# shellcheck shell=bash

# Defaults
[ -z "$DOTFILES" ] && export DOTFILES="$HOME/.dotfiles"
export DOTFILES_CURRENT_SHELL=$(basename "$SHELL")

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"
# Enable debugging with DEBUG=1
DEBUG="${DEBUG:-0}"

# Enable debugging with DEBUG=1
[ "${DEBUG:-0}" -eq 1 ] && set -x

# Explicitly set XDG folders, if not already set
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z "$XDG_CACHE_HOME" ] && export XDG_CACHE_HOME="$HOME/.cache"
[ -z "$XDG_STATE_HOME" ] && export XDG_STATE_HOME="$HOME/.local/state"
[ -z "$XDG_BIN_HOME" ] && export XDG_BIN_HOME="$HOME/.local/bin"

# Paths
x-path-prepend "/usr/local/bin"
x-path-prepend "/opt/homebrew/bin"
x-path-prepend "$XDG_DATA_HOME/cargo/bin"
x-path-prepend "$XDG_DATA_HOME/bob/nvim-bin"
x-path-prepend "$DOTFILES/local/bin"
x-path-prepend "$XDG_BIN_HOME"

# Custom completion paths
[ -z "$ZSH_CUSTOM_COMPLETION_PATH" ] && export ZSH_CUSTOM_COMPLETION_PATH="$XDG_CONFIG_HOME/zsh/completion"
x-dc "$ZSH_CUSTOM_COMPLETION_PATH"
export FPATH="$ZSH_CUSTOM_COMPLETION_PATH:$FPATH"

if ! declare -f msg > /dev/null; then
  # Function to print messages if VERBOSE is enabled
  # $1 - message (string)
  msg()
  {
    [ "$VERBOSE" -eq 1 ] && echo "$1"
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
    echo "(!) ERROR: $1" >&2
    exit 1
  }
fi

if ! declare -f msg_done > /dev/null; then
  msg "msg_done was not defined, defined it now"
  # Function to print done message
  # $1 - message (string)
  msg_done()
  {
    echo "✓ $1"
    return 0
  }
fi

if ! declare -f msg_run > /dev/null; then
  msg "msg_run was not defined, defined it now"
  # Function to print running message
  # $1 - message (string)
  msg_run()
  {
    echo "→ $1"
    return 0
  }
fi

if ! declare -f msg_ok > /dev/null; then
  msg "msg_ok was not defined, defined it now"
  # Function to print ok message
  # $1 - message (string)
  msg_ok()
  {
    echo "✓ $1"
    return 0
  }
fi

source "$DOTFILES/config/exports"
source "$DOTFILES/config/alias"
