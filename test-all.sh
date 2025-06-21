#!/usr/bin/env bash
# Run all bats tests

if ! command -v bats &> /dev/null; then
  echo "bats is not installed. Install via 'brew install bats-core' or 'apt-get install bats'" >&2
  exit 1
fi

readarray -t tests < <(git ls-files '*.bats')
bats "${tests[@]}"
