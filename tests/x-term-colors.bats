#!/usr/bin/env bats

# x-term-colors prints truecolor swatch rows. Its output is pure escape
# sequences, so the tests assert structure — row count, that every row resets
# the colour, and that the rainbow rows really vary — rather than pixel
# values.

setup()
{
  COLORS="$BATS_TEST_DIRNAME/../local/bin/x-term-colors"
}

@test "x-term-colors: exits 0" {
  run "$COLORS"
  [ "$status" -eq 0 ]
}

@test "x-term-colors: emits truecolor background sequences" {
  run "$COLORS"
  [[ "$output" == *$'\x1b[48;2;'* ]]
}

@test "x-term-colors: resets the colour at the end of every row" {
  run "$COLORS"
  rows="${#lines[@]}"
  resets=$(printf '%s' "$output" | grep -c $'\x1b\\[0m')
  [ "$resets" -eq "$rows" ]
}

@test "x-term-colors: prints the expected number of rows" {
  # Six swatch rows: red, green, blue and two rainbow halves plus the first.
  run "$COLORS"
  [ "${#lines[@]}" -ge 6 ]
}

@test "x-term-colors: the rainbow rows are not a single flat colour" {
  run "$COLORS"
  distinct=$(printf '%s' "$output" | grep -oE '48;2;[0-9]+;[0-9]+;[0-9]+' | sort -u | wc -l)
  [ "$distinct" -gt 100 ]
}

@test "x-term-colors: leaves the terminal reset, not mid-colour" {
  run "$COLORS"
  last="${lines[${#lines[@]} - 1]}"
  [[ "$last" == *$'\x1b[0m'* ]]
}
