#!/usr/bin/env bats

@test "x-when-up without args shows usage" {
  run bash local/bin/x-when-up
  [ "$status" -eq 1 ]
  [[ "$output" == "Usage:"* ]]
}

@test "x-when-down without args shows usage" {
  run bash local/bin/x-when-down
  [ "$status" -eq 1 ]
  [[ "$output" == "Usage:"* ]]
}
