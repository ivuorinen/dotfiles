#!/usr/bin/env bats

# x-clean-vendordirs deletes recursively, so the tests care most about what it
# does NOT remove. Everything runs in a temp tree.

setup()
{
  CLEAN="$BATS_TEST_DIRNAME/../local/bin/x-clean-vendordirs"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/proj/node_modules/pkg" "$TMP/proj/vendor/lib" "$TMP/proj/src"
  mkdir -p "$TMP/proj/.hidden/node_modules" "$TMP/proj/keep_vendor_files"
  touch "$TMP/proj/src/app.js" "$TMP/proj/node_modules/pkg/index.js"
  touch "$TMP/proj/keep_vendor_files/note.txt"
  # A file (not a directory) named vendor must survive: the script matches -type d.
  touch "$TMP/proj/vendor.txt"
}

teardown()
{
  rm -rf "$TMP"
}

@test "clean-vendordirs: removes node_modules and vendor directories" {
  run "$CLEAN" "$TMP/proj"
  [ "$status" -eq 0 ]
  [ ! -d "$TMP/proj/node_modules" ]
  [ ! -d "$TMP/proj/vendor" ]
}

@test "clean-vendordirs: reaches dot-directories" {
  run "$CLEAN" "$TMP/proj"
  [ "$status" -eq 0 ]
  [ ! -d "$TMP/proj/.hidden/node_modules" ]
  [ -d "$TMP/proj/.hidden" ]
}

@test "clean-vendordirs: keeps source and unrelated directories" {
  run "$CLEAN" "$TMP/proj"
  [ -d "$TMP/proj/src" ]
  [ -f "$TMP/proj/src/app.js" ]
  [ -d "$TMP/proj/keep_vendor_files" ]
  [ -f "$TMP/proj/keep_vendor_files/note.txt" ]
}

@test "clean-vendordirs: keeps a file named vendor" {
  run "$CLEAN" "$TMP/proj"
  [ -f "$TMP/proj/vendor.txt" ]
}

@test "clean-vendordirs: prints what it removed" {
  run "$CLEAN" "$TMP/proj"
  [[ "$output" == *"node_modules"* ]]
  [[ "$output" == *"vendor"* ]]
}

@test "clean-vendordirs: a missing directory is an error" {
  run "$CLEAN" "$TMP/no-such-dir"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "clean-vendordirs: defaults to the current directory" {
  run bash -c "cd '$TMP/proj' && '$CLEAN'"
  [ "$status" -eq 0 ]
  [ ! -d "$TMP/proj/node_modules" ]
}

@test "clean-vendordirs: succeeds on a tree with nothing to remove" {
  mkdir -p "$TMP/clean-tree/src"
  run "$CLEAN" "$TMP/clean-tree"
  [ "$status" -eq 0 ]
  [ -d "$TMP/clean-tree/src" ]
}
