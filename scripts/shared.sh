#!/usr/bin/env bash
# Shared bash functions and helpers.

# Helper env variables. Use like this: VERBOSE=1 ./script.sh
: "${VERBOSE:=0}"

# Source the main shared config if not already loaded
if [ -z "${SHARED_SCRIPTS_SOURCED:-}" ]; then
  source "${DOTFILES}/config/shared.sh"
  export SHARED_SCRIPTS_SOURCED=1
fi
