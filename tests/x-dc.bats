#!/usr/bin/env bats

# x-dc creates a directory. The interesting cases are idempotence and that it
# never reports failure for an already-existing path, since callers chain on
# its exit code.

setup()
{
  X_DC="$BATS_TEST_DIRNAME/../local/bin/x-dc"
  TMP="$(mktemp -d)"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-dc: creates a directory" {
  run "$X_DC" "$TMP/new"
  [ "$status" -eq 0 ]
  [ -d "$TMP/new" ]
}

@test "x-dc: creates intermediate directories" {
  run "$X_DC" "$TMP/deep/nested/path"
  [ "$status" -eq 0 ]
  [ -d "$TMP/deep/nested/path" ]
}

@test "x-dc: is idempotent for an existing directory" {
  mkdir -p "$TMP/existing"
  run "$X_DC" "$TMP/existing"
  [ "$status" -eq 0 ]
  [ -d "$TMP/existing" ]
}

@test "x-dc: is silent unless VERBOSE is set" {
  run "$X_DC" "$TMP/quiet"
  [ -z "$output" ]
}

@test "x-dc: VERBOSE reports creation" {
  VERBOSE=1 run "$X_DC" "$TMP/loud"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Creating directory"* ]]
}

@test "x-dc: VERBOSE distinguishes an existing directory" {
  mkdir -p "$TMP/there"
  VERBOSE=1 run "$X_DC" "$TMP/there"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exists"* ]]
}

@test "x-dc: no argument prints usage and exits 1" {
  run "$X_DC"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-dc: more than one argument is rejected" {
  run "$X_DC" "$TMP/a" "$TMP/b"
  [ "$status" -eq 1 ]
  [ ! -d "$TMP/a" ]
}
