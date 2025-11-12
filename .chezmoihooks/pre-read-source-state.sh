#!/usr/bin/env bash
# Pre-read-source-state hook for chezmoi
# This runs before chezmoi reads the source state

set -e

DOTFILES="${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}"

# Update git submodules if they exist
if [ -d "$DOTFILES/.git" ]; then
  cd "$DOTFILES"
  git submodule update --init --recursive --quiet || true
fi
