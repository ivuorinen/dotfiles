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
  before=$(stat -c %Y "$TMPDIR_TEST/dst" 2> /dev/null || stat -f %m "$TMPDIR_TEST/dst")
  sleep 1
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  after=$(stat -c %Y "$TMPDIR_TEST/dst" 2> /dev/null || stat -f %m "$TMPDIR_TEST/dst")
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

@test "_idempotent_ln_sf: retargets a link to a directory instead of writing inside it" {
  source "$THEME_LIB"
  mkdir -p "$TMPDIR_TEST/a" "$TMPDIR_TEST/b"
  ln -s "$TMPDIR_TEST/a" "$TMPDIR_TEST/dst"
  _idempotent_ln_sf "$TMPDIR_TEST/b" "$TMPDIR_TEST/dst"
  [ "$(readlink "$TMPDIR_TEST/dst")" = "$TMPDIR_TEST/b" ]
  [ -z "$(ls -A "$TMPDIR_TEST/a")" ]
}

@test "_idempotent_ln_sf: returns 1 with a message when ln fails" {
  source "$THEME_LIB"
  echo data > "$TMPDIR_TEST/src"
  run _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/missing-dir/dst"
  [ "$status" -eq 1 ]
  [[ "$output" == *"theme: failed to link"* ]]
}

@test "_idempotent_ln_sf: repairs broken symlink" {
  source "$THEME_LIB"
  ln -s "$TMPDIR_TEST/missing" "$TMPDIR_TEST/dst"
  echo data > "$TMPDIR_TEST/src"
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ "$(readlink "$TMPDIR_TEST/dst")" = "$TMPDIR_TEST/src" ]
}

@test "_acquire_lock: succeeds when no PID file exists" {
  source "$THEME_LIB"
  run _acquire_lock "$TMPDIR_TEST/lock.pid"
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/lock.pid" ]
}

@test "_acquire_lock: fails when live PID holds lock" {
  source "$THEME_LIB"
  echo $$ > "$TMPDIR_TEST/lock.pid"
  run _acquire_lock "$TMPDIR_TEST/lock.pid"
  [ "$status" -eq 1 ]
}

@test "_acquire_lock: reclaims stale PID file" {
  source "$THEME_LIB"
  # PID 99999 is overwhelmingly likely to be dead
  echo 99999 > "$TMPDIR_TEST/lock.pid"
  run _acquire_lock "$TMPDIR_TEST/lock.pid"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/lock.pid")" = "$$" ]
}

@test "_log: appends ISO8601-prefixed line" {
  source "$THEME_LIB"
  XDG_STATE_HOME="$TMPDIR_TEST" _log "INFO actor flipped to dark"
  [ -f "$TMPDIR_TEST/dotfiles-theme/log" ]
  grep -q 'INFO actor flipped to dark' "$TMPDIR_TEST/dotfiles-theme/log"
  grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' "$TMPDIR_TEST/dotfiles-theme/log"
}

@test "_log: rotates to 200 lines when over threshold" {
  source "$THEME_LIB"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  for i in $(seq 1 220); do _log "line $i"; done
  count=$(wc -l < "$TMPDIR_TEST/dotfiles-theme/log")
  [ "$count" -le 200 ]
  # Last line preserved
  grep -q 'line 220' "$TMPDIR_TEST/dotfiles-theme/log"
}

# Fake DOTFILES tree: palettes.d/fam/dark/app.conf only.
make_family_tree()
{
  export DOTFILES="$TMPDIR_TEST/dot"
  mkdir -p "$DOTFILES/config/theme/palettes.d/fam/dark"
  echo x > "$DOTFILES/config/theme/palettes.d/fam/dark/app.conf"
  echo fam > "$DOTFILES/config/theme/family"
}

@test "_theme_family: reads the tracked family file" {
  source "$THEME_LIB"
  make_family_tree
  unset DOTFILES_THEME_FAMILY
  run _theme_family
  [ "$status" -eq 0 ]
  [ "$output" = "fam" ]
}

@test "_theme_family: env override wins over the file" {
  source "$THEME_LIB"
  make_family_tree
  mkdir -p "$DOTFILES/config/theme/palettes.d/other"
  DOTFILES_THEME_FAMILY=other run _theme_family
  [ "$status" -eq 0 ]
  [ "$output" = "other" ]
}

@test "_theme_family: rejects traversal, empty and unknown families" {
  source "$THEME_LIB"
  make_family_tree
  # An empty override means "unset" and falls back to the file, so the
  # empty case is exercised through the file below instead.
  for bad in '../fam' 'nope' 'Fam' 'fam/dark' '-x'; do
    DOTFILES_THEME_FAMILY="$bad" run _theme_family
    [ "$status" -eq 1 ]
  done
  echo '' > "$DOTFILES/config/theme/family"
  unset DOTFILES_THEME_FAMILY
  run _theme_family
  [ "$status" -eq 1 ]
}

@test "_palette: prints an existing palette, fails for a missing one" {
  source "$THEME_LIB"
  make_family_tree
  run _palette dark app.conf
  [ "$status" -eq 0 ]
  [ "$output" = "$DOTFILES/config/theme/palettes.d/fam/dark/app.conf" ]
  run _palette light app.conf
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "_link_palette: links a palette idempotently" {
  source "$THEME_LIB"
  echo x > "$TMPDIR_TEST/src"
  _link_palette "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  _link_palette "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ "$(readlink "$TMPDIR_TEST/dst")" = "$TMPDIR_TEST/src" ]
}

@test "_link_palette: empty src removes a stale (even dangling) link" {
  source "$THEME_LIB"
  ln -s "$TMPDIR_TEST/gone" "$TMPDIR_TEST/dst"
  run _link_palette "" "$TMPDIR_TEST/dst"
  [ "$status" -eq 0 ]
  [ ! -L "$TMPDIR_TEST/dst" ]
  [[ "$output" == *"removed stale link"* ]]
}

@test "_link_palette: empty src never removes a regular file" {
  source "$THEME_LIB"
  echo "user content" > "$TMPDIR_TEST/dst"
  run _link_palette "" "$TMPDIR_TEST/dst"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/dst")" = "user content" ]
}
