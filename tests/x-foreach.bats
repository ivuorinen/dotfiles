#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "x-foreach: exits 1 with usage when fewer than 2 args given" {
  run bash local/bin/x-foreach
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-foreach: runs command in each matched directory" {
  mkdir -p "$TMPDIR_TEST/alpha" "$TMPDIR_TEST/beta"
  run bash local/bin/x-foreach "ls -d $TMPDIR_TEST/*/" echo ok
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok"* ]]
}
