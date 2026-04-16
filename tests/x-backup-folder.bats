#!/usr/bin/env bats

setup()
{
  WORK_DIR="$(mktemp -d)"
  SCRIPT="$(pwd)/local/bin/x-backup-folder"
  cd "$WORK_DIR" || exit 1
}

teardown()
{
  cd - > /dev/null || exit 1
  rm -rf "$WORK_DIR"
}

@test "x-backup-folder: exits 1 with clear message for nonexistent directory" {
  run bash "$SCRIPT" "/tmp/does-not-exist-$$"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "x-backup-folder: creates tar.gz for existing directory" {
  mkdir -p "$WORK_DIR/src"
  echo "hello" > "$WORK_DIR/src/file.txt"
  run bash "$SCRIPT" "$WORK_DIR/src"
  [ "$status" -eq 0 ]
  local found=0
  for f in ./*.tar.gz; do [ -f "$f" ] && found=1 && break; done
  [ "$found" -eq 1 ]
}

@test "x-backup-folder: exits 1 when no arguments given" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
}
