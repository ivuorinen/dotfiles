#!/usr/bin/env bats

# x-until-success and x-until-error are POSIX sh (see
# .claude/rules/posix-scripts.md) and retry until a condition flips. Tests use
# a counter file so the command genuinely fails a fixed number of times before
# succeeding, and --sleep 0 keeps the suite fast.

setup()
{
  UNTIL_SUCCESS="$BATS_TEST_DIRNAME/../local/bin/x-until-success"
  UNTIL_ERROR="$BATS_TEST_DIRNAME/../local/bin/x-until-error"
  TMP="$(mktemp -d)"
  # Fails until the counter reaches $1, then succeeds.
  cat > "$TMP/flaky" << 'STUB'
#!/usr/bin/env bash
count_file="$1"; threshold="$2"
n=$(cat "$count_file" 2>/dev/null || echo 0)
n=$((n + 1)); printf '%s' "$n" > "$count_file"
[ "$n" -ge "$threshold" ]
STUB
  chmod +x "$TMP/flaky"
  printf '0' > "$TMP/count"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-until-success: runs the command once when it succeeds immediately" {
  run "$UNTIL_SUCCESS" --sleep 0 "$TMP/flaky" "$TMP/count" 1
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/count")" -eq 1 ]
}

@test "x-until-success: retries until the command succeeds" {
  run "$UNTIL_SUCCESS" --sleep 0 "$TMP/flaky" "$TMP/count" 3
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/count")" -eq 3 ]
}

@test "x-until-success: always runs at least once" {
  run "$UNTIL_SUCCESS" --sleep 0 true
  [ "$status" -eq 0 ]
}

@test "x-until-success: --help exits 0" {
  run "$UNTIL_SUCCESS" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-until-success: no command is an error" {
  run "$UNTIL_SUCCESS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"No command specified"* ]]
}

@test "x-until-success: --sleep rejects a non-numeric argument" {
  run "$UNTIL_SUCCESS" --sleep abc true
  [ "$status" -eq 1 ]
  [[ "$output" == *"numeric"* ]]
}

@test "x-until-success: an unknown option is rejected" {
  run "$UNTIL_SUCCESS" --bogus true
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "x-until-success: -- stops option parsing" {
  run "$UNTIL_SUCCESS" --sleep 0 -- true
  [ "$status" -eq 0 ]
}

@test "x-until-error: runs once when the command fails immediately" {
  run "$UNTIL_ERROR" --sleep 0 false
  [ "$status" -ne 0 ]
}

@test "x-until-error: retries while the command keeps succeeding" {
  # Succeeds twice, then fails on the third run.
  cat > "$TMP/flip" << 'STUB'
#!/usr/bin/env bash
count_file="$1"
n=$(cat "$count_file" 2>/dev/null || echo 0)
n=$((n + 1)); printf '%s' "$n" > "$count_file"
[ "$n" -lt 3 ]
STUB
  chmod +x "$TMP/flip"
  run "$UNTIL_ERROR" --sleep 0 "$TMP/flip" "$TMP/count"
  [ "$status" -ne 0 ]
  [ "$(cat "$TMP/count")" -eq 3 ]
}

@test "x-until-error: --help exits 0" {
  run "$UNTIL_ERROR" --help
  [ "$status" -eq 0 ]
}

@test "both scripts parse as POSIX sh, not bash" {
  # .claude/rules/posix-scripts.md: these must stay dash-clean.
  if command -v dash > /dev/null 2>&1; then
    run dash -n "$UNTIL_SUCCESS"
    [ "$status" -eq 0 ]
    run dash -n "$UNTIL_ERROR"
    [ "$status" -eq 0 ]
  else
    skip "dash not installed"
  fi
}
