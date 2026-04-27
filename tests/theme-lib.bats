#!/usr/bin/env bats
# shellcheck shell=bash disable=SC1090

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export THEME_LIB="$BATS_TEST_DIRNAME/../config/theme/_lib.sh"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "_atomic_write: writes content to file" {
  source "$THEME_LIB"
  _atomic_write "$TMPDIR_TEST/out" "hello"
  [ "$(cat "$TMPDIR_TEST/out")" = "hello" ]
}

@test "_atomic_write: replaces existing content atomically" {
  source "$THEME_LIB"
  echo "old" > "$TMPDIR_TEST/out"
  _atomic_write "$TMPDIR_TEST/out" "new"
  [ "$(cat "$TMPDIR_TEST/out")" = "new" ]
}

@test "_atomic_write: leaves no temp file on success" {
  source "$THEME_LIB"
  _atomic_write "$TMPDIR_TEST/out" "x"
  count=$(find "$TMPDIR_TEST" -name 'out.tmp.*' | wc -l)
  [ "$count" -eq 0 ]
}
