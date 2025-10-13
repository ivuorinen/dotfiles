#!/usr/bin/env bats

setup() {
  export DOTFILES="$PWD"
}

@test "dfm help shows usage" {
  run bash local/bin/dfm help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: dfm"* ]]
}
