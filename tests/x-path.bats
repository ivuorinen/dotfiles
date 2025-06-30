#!/usr/bin/env bats

@test "x-path-append adds directory" {
  mkdir -p "$BATS_TMPDIR/dir"
  PATH="/usr/bin"
  VERBOSE=1 source local/bin/x-path-append "$BATS_TMPDIR/dir"
  [ "$PATH" = "/usr/bin:$BATS_TMPDIR/dir" ]
}

@test "x-path-prepend adds directory to start" {
  mkdir -p "$BATS_TMPDIR/dir"
  PATH="/usr/bin:/bin"
  VERBOSE=1 source local/bin/x-path-prepend "$BATS_TMPDIR/dir"
  [ "$PATH" = "$BATS_TMPDIR/dir:/usr/bin:/bin" ]
}

@test "x-path-remove removes directory" {
  mkdir -p "$BATS_TMPDIR/dir"
  PATH="$BATS_TMPDIR/dir:/usr/bin"
  VERBOSE=1 source local/bin/x-path-remove "$BATS_TMPDIR/dir"
  [ "$PATH" = "/usr/bin" ]
}
