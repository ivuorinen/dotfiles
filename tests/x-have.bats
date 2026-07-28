#!/usr/bin/env bats

# x-have backs `x-have <cmd> && ...` guards throughout the repo, so its exit
# code is the contract — dfm-install, the theme handlers and several x- tools
# branch on it.

setup()
{
  X_HAVE="$BATS_TEST_DIRNAME/../local/bin/x-have"
}

@test "x-have: exits 0 for a command that exists" {
  run "$X_HAVE" bash
  [ "$status" -eq 0 ]
}

@test "x-have: exits 1 for a command that does not exist" {
  run "$X_HAVE" definitely-not-a-real-command-xyz
  [ "$status" -eq 1 ]
}

@test "x-have: stays silent unless VERBOSE is set" {
  run "$X_HAVE" bash
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "x-have: VERBOSE=1 reports the command as available" {
  VERBOSE=1 run "$X_HAVE" bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"bash"* ]]
  [[ "$output" == *"available"* ]]
}

@test "x-have: VERBOSE=1 reports a missing command" {
  VERBOSE=1 run "$X_HAVE" definitely-not-a-real-command-xyz
  [ "$status" -eq 1 ]
  [[ "$output" == *"NOT available"* ]]
}

@test "x-have: no argument prints usage and exits 1" {
  run "$X_HAVE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-have: more than one argument prints usage and exits 1" {
  run "$X_HAVE" bash sh
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}
