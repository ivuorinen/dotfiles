#!/usr/bin/env bash
##
# This script contains helper for sha256 validating your downloads
#
# Source: https://gist.github.com/onnimonni/b49779ebc96216771a6be3de46449fa1
# Author: Onni Hakala
# License: MIT
#
# Updated by Ismo Vuorinen <https://github.com/ivuorinen> 2022
##

if ! command -v sha256 &> /dev/null; then
  echo "git could not be found, please install it first"
  exit
fi

# Stop program and give error message
# $1 - error message (string)
function error
{
  echo "(!) ERROR: $1"
  exit 1
}

# return sha256sum for file
# $1 - filename (string)
function get_sha256sum
{
  sha256sum "$1" | head -c 64
}

# Good variable names pls
filename=$1
file_hash=$2

# Check input
if [ -z "$filename" ]; then
  error "You need to provide filename in first parameter"
fi

if [ -z "$file_hash" ]; then
  error "You need to provide sha256sum in second parameter"
fi

# Check if the file is valid
if [ ! -f "$filename" ]; then
  error "File $filename doesn't exist"
elif [ "$(get_sha256sum "$filename")" = "$file_hash" ]; then
  echo "(*) Success: $filename matches provided sha256sum"
else
  error "$filename doesn't match provided sha256sum"
fi
