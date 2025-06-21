#!/usr/bin/env bats

@test "x-mkd creates directory" {
  dir="$BATS_TMPDIR/mkd-test"
  run env VERBOSE=1 bash local/bin/x-mkd "$dir"
  [ "$status" -eq 0 ]
  [ -d "$dir" ]
}
