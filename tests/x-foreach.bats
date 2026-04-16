#!/usr/bin/env bats

@test "x-foreach: exits 1 with usage when fewer than 2 args given" {
  run bash local/bin/x-foreach
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-foreach: runs command in each matched directory" {
  local tmpdir
  tmpdir=$(mktemp -d)
  mkdir -p "$tmpdir/alpha" "$tmpdir/beta"
  run bash local/bin/x-foreach "ls -d $tmpdir/*/" echo ok
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok"* ]]
  rm -rf "$tmpdir"
}
