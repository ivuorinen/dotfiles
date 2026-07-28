#!/usr/bin/env bats

# x-datetime and x-timestamp back `x datetime` / `x timestamp`. Their output
# format is the contract — anything parsing them breaks if it drifts.

setup()
{
  X_DATETIME="$BATS_TEST_DIRNAME/../local/bin/x-datetime"
  X_TIMESTAMP="$BATS_TEST_DIRNAME/../local/bin/x-timestamp"
}

@test "x-datetime: prints YYYY-MM-DD HH:MM:SS" {
  run "$X_DATETIME"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]
}

@test "x-datetime: prints a single line" {
  run "$X_DATETIME"
  [ "${#lines[@]}" -eq 1 ]
}

@test "x-timestamp: prints digits only" {
  run "$X_TIMESTAMP"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "x-timestamp: prints a plausible epoch, not a truncated value" {
  # Ten digits until 2286; guards against a format change to %S or similar.
  run "$X_TIMESTAMP"
  [ "${#output}" -ge 10 ]
}

@test "x-timestamp: agrees with the shell's own clock" {
  run "$X_TIMESTAMP"
  now=$(date +%s)
  delta=$((now - output))
  [ "$delta" -ge -5 ]
  [ "$delta" -le 5 ]
}
