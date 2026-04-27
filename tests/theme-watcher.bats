#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  export THEME_HANDLERS_DIR="$TMPDIR_TEST/handlers.d"
  mkdir -p "$THEME_HANDLERS_DIR"
  WATCHER="$BATS_TEST_DIRNAME/../config/theme/watcher"
}

teardown()
{
  if [[ -f "$TMPDIR_TEST/dotfiles-theme/daemon.pid" ]]; then
    pid=$(cat "$TMPDIR_TEST/dotfiles-theme/daemon.pid" 2> /dev/null)
    [[ -n "$pid" && "$pid" != "$$" ]] && kill "$pid" 2> /dev/null || true
  fi
  rm -rf "$TMPDIR_TEST"
}

@test "watcher: --source stub reads modes from a file and applies each" {
  tmo="$(command -v timeout 2> /dev/null || command -v gtimeout 2> /dev/null || true)"
  [ -n "$tmo" ] || skip "no timeout(1) on PATH"
  cat > "$THEME_HANDLERS_DIR/recorder" << 'STUB'
#!/usr/bin/env bash
echo "$1" >> "${TMPDIR_TEST}/recorded"
STUB
  chmod +x "$THEME_HANDLERS_DIR/recorder"
  printf 'dark\nlight\ndark\n' > "$TMPDIR_TEST/source-stub"
  export TMPDIR_TEST
  run "$tmo" 3 "$WATCHER" --source stub --stub-input "$TMPDIR_TEST/source-stub"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$TMPDIR_TEST/recorded")" -ge 3 ]
}

@test "watcher: second invocation exits 1 when first holds the lock" {
  echo $$ > "$TMPDIR_TEST/dotfiles-theme/daemon.pid" 2> /dev/null || {
    mkdir -p "$TMPDIR_TEST/dotfiles-theme"
    echo $$ > "$TMPDIR_TEST/dotfiles-theme/daemon.pid"
  }
  run "$WATCHER" --source stub --stub-input /dev/null
  [ "$status" -eq 1 ]
}
