#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  PROBE="$BATS_TEST_DIRNAME/../config/theme/probe-osc11"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "probe-osc11: dark hex => 'dark'" {
  printf '\033]11;rgb:1e1e/1e1e/2e2e\007' > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 1
  [ "$status" -eq 0 ]
  [ "$output" = "dark" ]
}

@test "probe-osc11: light hex => 'light'" {
  printf '\033]11;rgb:eff1/f5f5/f5f5\007' > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 1
  [ "$status" -eq 0 ]
  [ "$output" = "light" ]
}

@test "probe-osc11: no response => empty stdout, exit 0" {
  : > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 0.1
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "probe-osc11: malformed response => empty stdout, exit 0" {
  printf 'not a valid sequence' > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 0.1
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
