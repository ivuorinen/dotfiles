#!/usr/bin/env bats
# Tests for local/bin/x-palette-probe. bats run() gives the script
# /dev/null for stdin, so every colour query takes the no-tty path; the
# OSC round trip itself needs a real terminal and is not tested here.

bats_require_minimum_version 1.5.0

setup()
{
  export DOTFILES="$PWD"
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
  PROBE="$BATS_TEST_DIRNAME/../local/bin/x-palette-probe"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "x-palette-probe: exits 0 without a terminal" {
  run "$PROBE"
  [ "$status" -eq 0 ]
}

@test "x-palette-probe: warns on stderr that queries are skipped" {
  run --separate-stderr "$PROBE"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"stdin is not a terminal"* ]]
  [[ "$output" != *"stdin is not a terminal"* ]]
}

@test "x-palette-probe: every query reports n/a without a terminal" {
  run --separate-stderr "$PROBE"
  [[ "$output" == *"Default fg (OSC 10): n/a (no tty)"* ]]
  [[ "$output" == *"Default bg (OSC 11): n/a (no tty)"* ]]
  [ "$(grep -c '^ *[0-9]\{1,2\} n/a (no tty)$' <<< "$output")" -eq 16 ]
}

@test "x-palette-probe: draws indexed swatches and the truecolor control row" {
  run --separate-stderr "$PROBE"
  [[ "$output" == *$'\033[41m'* ]]
  [[ "$output" == *$'\033[107m'* ]]
  [[ "$output" == *$'\033[48;2;255;0;0m'* ]]
  [[ "$output" == *"Truecolor control row (must NOT change):"* ]]
}
