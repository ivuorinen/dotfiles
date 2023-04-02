#!/usr/bin/env bash

Z_GIT_PATH="https://github.com/rupa/z.git"
Z_BIN_PATH="$XDG_BIN_HOME/z"

if [ ! -d "$Z_BIN_PATH" ]; then
  git clone "$Z_GIT_PATH" "$Z_BIN_PATH"
else
  echo "z ($Z_BIN_PATH/) already installed"
fi
