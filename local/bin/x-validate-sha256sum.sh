#!/usr/bin/env bash
#
# This script contains a helper for sha256 validating your downloads
#
# Source: https://gist.github.com/onnimonni/b49779ebc96216771a6be3de46449fa1
# Author: Onni Hakala
# License: MIT
#
# Updated by Ismo Vuorinen <https://github.com/ivuorinen> 2022
##

set -euo pipefail

# Stop program and give error message
# $1 - error message (string)
error()
{
  echo "(!) ERROR: $1" >&2
  exit 1
}

# Check for sha256sum command
if ! command -v sha256sum &> /dev/null; then
  error "sha256sum could not be found, please install it first"
fi

# Return sha256sum for file
# $1 - filename (string)
get_sha256sum()
{
  sha256sum "$1" | head -c 64
}

# Validate input arguments
validate_inputs()
{
  if [ -z "${filename:-}" ]; then
    error "You need to provide filename as the first parameter"
  fi

  if [ -z "${file_hash:-}" ]; then
    error "You need to provide sha256sum as the second parameter"
  fi
}

# Main validation logic
validate_file()
{
  if [ ! -f "$filename" ]; then
    error "File $filename doesn't exist"
  elif [ "$(get_sha256sum "$filename")" = "$file_hash" ]; then
    echo "(*) Success: $filename matches provided sha256sum"
  else
    error "$filename doesn't match provided sha256sum"
  fi
}

# Main function
main()
{
  filename=$1
  file_hash=$2

  validate_inputs
  validate_file
}

main "$@"
