#!/usr/bin/env bats

# x-hr draws a separator line. Under bats stdout is a pipe, so the width comes
# from COLUMNS or the 80 default rather than tput.

setup()
{
  X_HR="$BATS_TEST_DIRNAME/../local/bin/x-hr"
}

# Strip the colour escapes the script wraps the line in.
plain()
{
  printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

@test "x-hr: draws a line with no argument" {
  run "$X_HR"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "x-hr: repeats the character it is given" {
  run "$X_HR" =
  [ "$status" -eq 0 ]
  line="$(plain "$output")"
  [[ "$line" == *"===="* ]]
  [[ "$line" != *"----"* ]]
}

@test "x-hr: honours COLUMNS for the line width" {
  COLUMNS=20 run "$X_HR" =
  [ "$status" -eq 0 ]
  line="$(plain "$output")"
  [ "${#line}" -le 20 ]
  [ "${#line}" -gt 10 ]
}

@test "x-hr: falls back to 80 columns when COLUMNS is not a number" {
  COLUMNS=not-a-number run "$X_HR" =
  [ "$status" -eq 0 ]
  line="$(plain "$output")"
  [ "${#line}" -le 80 ]
  [ "${#line}" -gt 70 ]
}

@test "x-hr: draws one line per argument" {
  COLUMNS=20 run "$X_HR" = -
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}
