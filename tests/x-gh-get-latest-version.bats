#!/usr/bin/env bats

@test "x-gh-get-latest-version help" {
  run bash local/bin/x-gh-get-latest-version --help
  [ "$status" -eq 0 ]
  [[ "$output" == "Usage: x-gh-get-latest-version"* ]]
}
