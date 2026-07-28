#!/usr/bin/env bats

# zoxide-seed runs from shell startup in the background, so its failure modes
# must be silent no-ops rather than errors: a missing fd or zoxide has to exit
# 0, or every new shell reports a failure.

setup()
{
  SEED="$BATS_TEST_DIRNAME/../local/bin/zoxide-seed"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  ADDED="$TMP/added"
  : > "$ADDED"
  cat > "$TMP/bin/zoxide" << STUB
#!/usr/bin/env bash
printf '%s\n' "\$@" >> "$ADDED"
STUB
  cat > "$TMP/bin/fd" << 'STUB'
#!/usr/bin/env bash
printf '%s\n' "/tmp/seed-one" "/tmp/seed-two"
STUB
  chmod +x "$TMP/bin/zoxide" "$TMP/bin/fd"
  for tool in bash env cat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
}

teardown()
{
  rm -rf "$TMP"
}

@test "zoxide-seed: feeds discovered directories to zoxide" {
  run env PATH="$TMP/bin" HOME="$TMP" "$SEED"
  [ "$status" -eq 0 ]
  grep -q 'seed-one' "$ADDED"
  grep -q 'seed-two' "$ADDED"
}

@test "zoxide-seed: uses add with a -- separator" {
  run env PATH="$TMP/bin" HOME="$TMP" "$SEED"
  grep -q '^add$' "$ADDED"
  grep -q '^--$' "$ADDED"
}

@test "zoxide-seed: exits 0 and adds nothing when fd is missing" {
  rm "$TMP/bin/fd"
  run env PATH="$TMP/bin" HOME="$TMP" "$SEED"
  [ "$status" -eq 0 ]
  [ ! -s "$ADDED" ]
}

@test "zoxide-seed: exits 0 when zoxide is missing" {
  rm "$TMP/bin/zoxide"
  run env PATH="$TMP/bin" HOME="$TMP" "$SEED"
  [ "$status" -eq 0 ]
}

@test "zoxide-seed: adds nothing when fd finds nothing" {
  cat > "$TMP/bin/fd" << 'STUB'
#!/usr/bin/env bash
exit 0
STUB
  chmod +x "$TMP/bin/fd"
  run env PATH="$TMP/bin" HOME="$TMP" "$SEED"
  [ "$status" -eq 0 ]
  [ ! -s "$ADDED" ]
}

@test "zoxide-seed: survives fd failing" {
  cat > "$TMP/bin/fd" << 'STUB'
#!/usr/bin/env bash
exit 2
STUB
  chmod +x "$TMP/bin/fd"
  run env PATH="$TMP/bin" HOME="$TMP" "$SEED"
  [ "$status" -eq 0 ]
}
