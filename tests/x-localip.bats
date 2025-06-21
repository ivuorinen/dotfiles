#!/usr/bin/env bats

@test "x-localip prints version" {
  run bash local/bin/x-localip --version
  [ "$status" -eq 0 ]
  [[ "$output" == "x-localip version"* ]]
}
