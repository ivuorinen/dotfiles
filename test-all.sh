#!/usr/bin/env bash
# Run all bats tests

set -e

if [ -x "node_modules/bats/bin/bats" ]; then
  node_modules/bats/bin/bats $(git ls-files '*.bats')
elif command -v npx >/dev/null; then
  npx --yes bats $(git ls-files '*.bats')
elif command -v bats >/dev/null; then
  bats $(git ls-files '*.bats')
else
  echo "bats not installed. Run 'npm install' first." >&2
  exit 1
fi
