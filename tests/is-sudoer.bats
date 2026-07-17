#!/usr/bin/env bats
# Tests for local/bin/is-sudoer.
# Only deterministic invariants are asserted — the current user's real sudo
# status varies by host, so those paths are exercised loosely (0-or-1) rather
# than pinned.

setup()
{
  export DOTFILES="$PWD"
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "is-sudoer: root (uid 0) is always a sudoer" {
  run bash local/bin/is-sudoer root
  [ "$status" -eq 0 ]
}

@test "is-sudoer: a non-privileged system user is not a sudoer" {
  id nobody > /dev/null 2>&1 || skip "no 'nobody' user on this host"
  run bash local/bin/is-sudoer nobody
  [ "$status" -eq 1 ]
}

@test "is-sudoer: unknown user errors with exit 2" {
  run bash local/bin/is-sudoer no_such_user_xyz_9999
  [ "$status" -eq 2 ]
  [[ "$output" == *"no such user"* ]]
}

@test "is-sudoer: no argument yields a valid determination for the current user" {
  run bash local/bin/is-sudoer
  # 0 (sudoer) or 1 (not) — never an error (2) for a user that exists.
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}
