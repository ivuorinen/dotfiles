#!/usr/bin/env bats

# x-visit-folders walks one level of a directory and feeds the results to
# zoxide. zoxide is stubbed so the tests can assert exactly which paths were
# submitted — the selection rules (one level deep, no dot-directories, no
# files) are the contract.

setup()
{
  VISIT="$BATS_TEST_DIRNAME/../local/bin/x-visit-folders"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/tree/alpha" "$TMP/tree/beta" "$TMP/tree/.hidden"
  mkdir -p "$TMP/tree/alpha/deeper"
  touch "$TMP/tree/afile.txt"
  ADDED="$TMP/added"
  : > "$ADDED"
  cat > "$TMP/bin/zoxide" << STUB
#!/usr/bin/env bash
printf '%s\n' "\$@" >> "$ADDED"
STUB
  chmod +x "$TMP/bin/zoxide"
}

teardown()
{
  rm -rf "$TMP"
}

visit()
{
  run env PATH="$TMP/bin:$PATH" "$VISIT" "$@"
}

@test "x-visit-folders: adds the immediate subdirectories" {
  visit "$TMP/tree"
  [ "$status" -eq 0 ]
  grep -q 'alpha' "$ADDED"
  grep -q 'beta' "$ADDED"
}

# `run !` rather than a bare `!`: in bats a negated command that is not the
# last line of the test does not fail the test (shellcheck SC2314), so these
# assertions would pass no matter what the script did.
@test "x-visit-folders: skips dot-directories" {
  visit "$TMP/tree"
  run ! grep -q '.hidden' "$ADDED"
}

@test "x-visit-folders: does not descend past one level" {
  visit "$TMP/tree"
  run ! grep -q 'deeper' "$ADDED"
}

@test "x-visit-folders: ignores plain files" {
  visit "$TMP/tree"
  run ! grep -q 'afile.txt' "$ADDED"
}

@test "x-visit-folders: reports how many it visited" {
  visit "$TMP/tree"
  [[ "$output" == *"Visited 2 directories."* ]]
}

@test "x-visit-folders: dry run adds nothing" {
  visit --dry-run "$TMP/tree"
  [ "$status" -eq 0 ]
  [ ! -s "$ADDED" ]
  [[ "$output" == *"(dry-run)"* ]]
}

@test "x-visit-folders: dry run still counts" {
  visit -n "$TMP/tree"
  [[ "$output" == *"Visited 2 directories."* ]]
}

@test "x-visit-folders: verbose names each directory added" {
  visit --verbose "$TMP/tree"
  [[ "$output" == *"Added:"* ]]
}

@test "x-visit-folders: quiet by default" {
  visit "$TMP/tree"
  [[ "$output" != *"Added:"* ]]
}

@test "x-visit-folders: --help exits 0" {
  visit --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-visit-folders: an unknown option exits 1" {
  visit --bogus "$TMP/tree"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "x-visit-folders: a non-directory target exits 1" {
  visit "$TMP/tree/afile.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not a directory"* ]]
}

@test "x-visit-folders: an empty directory adds nothing and still succeeds" {
  mkdir -p "$TMP/empty"
  visit "$TMP/empty"
  [ "$status" -eq 0 ]
  [ ! -s "$ADDED" ]
  [[ "$output" == *"Visited 0 directories."* ]]
}

@test "x-visit-folders: survives zoxide failing" {
  cat > "$TMP/bin/zoxide" << 'STUB'
#!/usr/bin/env bash
exit 1
STUB
  chmod +x "$TMP/bin/zoxide"
  visit "$TMP/tree"
  [ "$status" -eq 0 ]
}
