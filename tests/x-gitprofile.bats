#!/usr/bin/env bats

# x-gitprofile writes .mise.toml enter hooks. HOME is redirected in every test
# because the no-argument path writes into $HOME/Code, and a test must never
# touch the real one.

setup()
{
  X_GITPROFILE="$BATS_TEST_DIRNAME/../local/bin/x-gitprofile"
  TMP="$(mktemp -d)"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-gitprofile: writes an enter hook for the named profile" {
  run env HOME="$TMP" "$X_GITPROFILE" work "$TMP/proj"
  [ "$status" -eq 0 ]
  [ -f "$TMP/proj/.mise.toml" ]
  grep -q '^\[hooks\]' "$TMP/proj/.mise.toml"
  grep -q 'git profile use work' "$TMP/proj/.mise.toml"
}

@test "x-gitprofile: creates the target directory when absent" {
  run env HOME="$TMP" "$X_GITPROFILE" work "$TMP/deep/nested/dir"
  [ "$status" -eq 0 ]
  [ -f "$TMP/deep/nested/dir/.mise.toml" ]
}

@test "x-gitprofile: reports what it configured" {
  run env HOME="$TMP" "$X_GITPROFILE" work "$TMP/proj"
  [[ "$output" == *"work"* ]]
  [[ "$output" == *"$TMP/proj"* ]]
}

@test "x-gitprofile: no arguments sets up both defaults under HOME" {
  run env HOME="$TMP" "$X_GITPROFILE"
  [ "$status" -eq 0 ]
  [ -f "$TMP/Code/ivuorinen/.mise.toml" ]
  [ -f "$TMP/Code/masf/.mise.toml" ]
  grep -q 'git profile use home' "$TMP/Code/ivuorinen/.mise.toml"
  grep -q 'git profile use masf' "$TMP/Code/masf/.mise.toml"
}

@test "x-gitprofile: one argument is rejected with usage on stderr" {
  run env HOME="$TMP" bash -c "'$X_GITPROFILE' work 2>&1 >/dev/null"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-gitprofile: three arguments are rejected" {
  run env HOME="$TMP" "$X_GITPROFILE" a b c
  [ "$status" -eq 1 ]
}

@test "x-gitprofile: overwrites an existing hook rather than appending" {
  env HOME="$TMP" "$X_GITPROFILE" work "$TMP/proj"
  env HOME="$TMP" "$X_GITPROFILE" other "$TMP/proj"
  run grep -c 'git profile use' "$TMP/proj/.mise.toml"
  [ "$output" -eq 1 ]
  grep -q 'git profile use other' "$TMP/proj/.mise.toml"
}
