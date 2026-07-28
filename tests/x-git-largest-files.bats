#!/usr/bin/env bats

# x-git-largest-files.py reads packfiles with git verify-pack. The tests build
# a throwaway repository with one deliberately large object rather than
# pointing the script at this one, so the numbers are known and the result
# does not drift as this repo grows.

setup()
{
  GLF="$BATS_TEST_DIRNAME/../local/bin/x-git-largest-files.py"
  TMP="$(mktemp -d)"
  REPO="$TMP/repo"
  mkdir -p "$REPO"
  # No global or system git config: no hooks, no templates, no user identity
  # leaking in from the machine running the suite.
  export GIT_CONFIG_GLOBAL=/dev/null
  export GIT_CONFIG_SYSTEM=/dev/null
  git -C "$REPO" init --quiet
  # Random bytes so the object does not compress away to nothing.
  head -c 200000 /dev/urandom > "$REPO/big.bin"
  printf 'small\n' > "$REPO/small.txt"
  git -C "$REPO" add big.bin small.txt
  git -C "$REPO" -c user.email=t@example.com -c user.name=Test \
    commit --quiet -m "add files"
}

teardown()
{
  rm -rf "$TMP"
}

pack_it()
{
  git -C "$REPO" gc --quiet
}

glf()
{
  run env -C "$REPO" python3 "$GLF" "$@"
}

@test "glf: --help documents the options" {
  glf --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--files-exceeding"* ]]
  [[ "$output" == *"--match-count"* ]]
}

@test "glf: tells you to run git gc when there is no packfile" {
  # verify-pack has nothing to read in a repo of loose objects. Without the
  # guard the glob returns empty and git is handed no arguments.
  glf
  [ "$status" -eq 1 ]
  [[ "$output" == *"No packfiles found"* ]]
  [[ "$output" == *"git gc"* ]]
}

@test "glf: finds the large file once the repo is packed" {
  pack_it
  glf
  [ "$status" -eq 0 ]
  [[ "$output" == *"big.bin"* ]]
}

@test "glf: prints the column header and the size unit" {
  pack_it
  glf
  [[ "$output" == *"All sizes in kB"* ]]
  [[ "$output" == *"path"* ]]
}

@test "glf: --match-count limits how many objects are listed" {
  pack_it
  glf --match-count 1
  # One data row: the header line plus one path.
  [ "$(printf '%s\n' "$output" | grep -c 'big.bin\|small.txt')" -eq 1 ]
}

@test "glf: --files-exceeding keeps the files above the cutoff" {
  pack_it
  glf --files-exceeding 1
  [[ "$output" == *"big.bin"* ]]
  [[ "$output" != *"small.txt"* ]]
}

@test "glf: --files-exceeding says so when nothing is that large" {
  pack_it
  glf --files-exceeding 999999
  [ "$status" -eq 0 ]
  [[ "$output" == *"No files found which match those criteria"* ]]
}

@test "glf: -p sorts by on-disk size instead of pack size" {
  pack_it
  glf -p
  [ "$status" -eq 0 ]
  [[ "$output" == *"big.bin"* ]]
}
