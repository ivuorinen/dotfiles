#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  export THEME_HANDLERS_DIR="$TMPDIR_TEST/handlers.d"
  mkdir -p "$THEME_HANDLERS_DIR"
  APPLY="$BATS_TEST_DIRNAME/../config/theme/apply"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "apply: rejects unknown mode" {
  run "$APPLY" purple
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown mode 'purple'"* ]]
}

@test "apply: writes mode atomically when valid" {
  run "$APPLY" light
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "light" ]
}

@test "apply: idempotent (skip handlers on no-change)" {
  cat > "$THEME_HANDLERS_DIR/touched" << 'STUB'
#!/usr/bin/env bash
touch "$TMPDIR_TEST/handler-ran-$1"
STUB
  chmod +x "$THEME_HANDLERS_DIR/touched"
  TMPDIR_TEST="$TMPDIR_TEST" "$APPLY" light
  rm -f "$TMPDIR_TEST/handler-ran-light"
  TMPDIR_TEST="$TMPDIR_TEST" "$APPLY" light
  # Second call should NOT have re-run the handler
  [ ! -f "$TMPDIR_TEST/handler-ran-light" ]
}
