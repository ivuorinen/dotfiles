#!/usr/bin/env bash
# Run all bats tests

set -euo pipefail

if command -v bats > /dev/null; then
  # bats-run.sh ends the run with a list of every failing test (file:line).
  # It defaults to tests/, the same run the pre-push hook and CI make.
  "$(dirname -- "$0")/scripts/bats-run.sh"
else
  echo "bats not installed. Run 'mise install' first." >&2
  exit 1
fi
