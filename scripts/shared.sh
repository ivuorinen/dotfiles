#!/usr/bin/env bash
# Shared bash functions and helpers.

# Helper env variables. Use like this: VERBOSE=1 ./script.sh
: "${VERBOSE:=0}"

# Set variable that checks if the shared.sh script has been
# sourced only once If the script has been sourced more than once,
# the script not be sourced again.
[ -z "$SHARED_SCRIPTS_SOURCED" ] && {

  source "${DOTFILES}/config/shared.sh"
  # Warn the user if the shared configuration hasn't been loaded yet
  msgr warn "(!) shared.sh not sourced"

  # Set variable that checks if the shared.sh script has been
  # sourced only once.
  # shellcheck disable=SC2034
  export SHARED_SCRIPTS_SOURCED=1
}
