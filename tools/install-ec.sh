#!/usr/bin/env bash
# Install editorconfig-checker if not already installed
set -euo pipefail

if command -v ec > /dev/null 2>&1; then
  exit 0
fi

if ! command -v yarn > /dev/null 2>&1; then
  echo "yarn is required to install editorconfig-checker" >&2
  exit 1
fi

if yarn --version | grep -q '^1\.'; then
  yarn global add --silent editorconfig-checker@"${VERSION:-latest}"
else
  yarn dlx --quiet editorconfig-checker@"${VERSION:-latest}" --version > /dev/null
fi
