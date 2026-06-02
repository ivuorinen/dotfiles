#!/usr/bin/env bats

# These tests deliberately shrink PATH to assert path-manipulation behavior.
# On macOS rm lives in /bin, so a test leaving PATH="/usr/bin" breaks bats'
# own post-test cleanup (rm). Save the real PATH and restore it in teardown,
# which runs before that cleanup.
setup()
{
  REAL_PATH="$PATH"
}

teardown()
{
  PATH="$REAL_PATH"
}

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

@test "x-path-append skips missing directory" {
  PATH="/usr/bin"
  VERBOSE=1 source local/bin/x-path-append "$BATS_TMPDIR/no-such"
  [ "$PATH" = "/usr/bin" ]
}
