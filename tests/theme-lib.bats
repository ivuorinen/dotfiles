#!/usr/bin/env bats
# shellcheck shell=bash disable=SC1090

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export THEME_LIB="$BATS_TEST_DIRNAME/../config/theme/_lib.sh"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "_atomic_write: writes content to file" {
  source "$THEME_LIB"
  _atomic_write "$TMPDIR_TEST/out" "hello"
  [ "$(cat "$TMPDIR_TEST/out")" = "hello" ]
}

@test "_atomic_write: replaces existing content atomically" {
  source "$THEME_LIB"
  echo "old" > "$TMPDIR_TEST/out"
  _atomic_write "$TMPDIR_TEST/out" "new"
  [ "$(cat "$TMPDIR_TEST/out")" = "new" ]
}

@test "_atomic_write: leaves no temp file on success" {
  source "$THEME_LIB"
  _atomic_write "$TMPDIR_TEST/out" "x"
  count=$(find "$TMPDIR_TEST" -name 'out.tmp.*' | wc -l)
  [ "$count" -eq 0 ]
}

@test "_idempotent_ln_sf: creates new symlink" {
  source "$THEME_LIB"
  echo data > "$TMPDIR_TEST/src"
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ -L "$TMPDIR_TEST/dst" ]
  [ "$(readlink "$TMPDIR_TEST/dst")" = "$TMPDIR_TEST/src" ]
}

@test "_idempotent_ln_sf: leaves correct symlink alone (no mtime churn)" {
  source "$THEME_LIB"
  echo data > "$TMPDIR_TEST/src"
  ln -s "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  before=$(stat -f %m "$TMPDIR_TEST/dst" 2> /dev/null || stat -c %Y "$TMPDIR_TEST/dst")
  sleep 1
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  after=$(stat -f %m "$TMPDIR_TEST/dst" 2> /dev/null || stat -c %Y "$TMPDIR_TEST/dst")
  [ "$before" = "$after" ]
}

@test "_idempotent_ln_sf: refuses to overwrite a regular file (N-021 guard)" {
  source "$THEME_LIB"
  echo data > "$TMPDIR_TEST/src"
  echo "user-content" > "$TMPDIR_TEST/dst"
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ ! -L "$TMPDIR_TEST/dst" ]
  [ "$(cat "$TMPDIR_TEST/dst")" = "user-content" ]
}

@test "_idempotent_ln_sf: repairs broken symlink" {
  source "$THEME_LIB"
  ln -s "$TMPDIR_TEST/missing" "$TMPDIR_TEST/dst"
  echo data > "$TMPDIR_TEST/src"
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ "$(readlink "$TMPDIR_TEST/dst")" = "$TMPDIR_TEST/src" ]
}
