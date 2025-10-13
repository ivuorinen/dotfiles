#!/usr/bin/env bash
# Run all bats tests

set -euo pipefail

if [ -x "node_modules/bats/bin/bats" ]; then
  git ls-files '*.bats' -z | xargs -0 node_modules/bats/bin/bats
elif command -v npx > /dev/null; then
  git ls-files '*.bats' -z | xargs -0 npx --yes bats
elif command -v bats > /dev/null; then
  git ls-files '*.bats' -z | xargs -0 bats
else
  echo "bats not installed. Run 'yarn install' first." >&2
  exit 1
fi
