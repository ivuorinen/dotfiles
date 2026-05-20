#!/usr/bin/env bash
# Run all bats tests

set -euo pipefail

if command -v bats > /dev/null; then
  git ls-files '*.bats' -z | xargs -0 bats
else
  echo "bats not installed. Run 'mise install' first." >&2
  exit 1
fi
