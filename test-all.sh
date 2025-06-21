#!/usr/bin/env bash
# Run all bats tests

if command -v bats >/dev/null; then
  bats $(git ls-files '*.bats')
else
  echo "bats not installed, running via Docker" >&2
  docker run --rm -v "$PWD":/work -w /work bats/bats:latest \
    $(git ls-files '*.bats')
fi
bats "${tests[@]}"
