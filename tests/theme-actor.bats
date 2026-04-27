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

@test "apply: forks each handler in parallel with mode arg" {
  cat > "$THEME_HANDLERS_DIR/h1" << 'STUB'
#!/usr/bin/env bash
echo "h1 $1" > "${TMPDIR_TEST}/h1.out"
STUB
  cat > "$THEME_HANDLERS_DIR/h2" << 'STUB'
#!/usr/bin/env bash
echo "h2 $1" > "${TMPDIR_TEST}/h2.out"
STUB
  chmod +x "$THEME_HANDLERS_DIR/h1" "$THEME_HANDLERS_DIR/h2"
  TMPDIR_TEST="$TMPDIR_TEST" "$APPLY" dark
  [ "$(cat "$TMPDIR_TEST/h1.out")" = "h1 dark" ]
  [ "$(cat "$TMPDIR_TEST/h2.out")" = "h2 dark" ]
}

@test "apply: continues when one handler fails" {
  cat > "$THEME_HANDLERS_DIR/ok" << 'STUB'
#!/usr/bin/env bash
echo "ok $1" > "${TMPDIR_TEST}/ok.out"
STUB
  cat > "$THEME_HANDLERS_DIR/bad" << 'STUB'
#!/usr/bin/env bash
exit 7
STUB
  chmod +x "$THEME_HANDLERS_DIR/ok" "$THEME_HANDLERS_DIR/bad"
  TMPDIR_TEST="$TMPDIR_TEST" run "$APPLY" light
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/ok.out")" = "ok light" ]
  grep -q "WARN handler 'bad' exit=7" "$TMPDIR_TEST/dotfiles-theme/log"
}

@test "apply: kills handlers that exceed 5s timeout" {
  cat > "$THEME_HANDLERS_DIR/slow" << 'STUB'
#!/usr/bin/env bash
sleep 30
STUB
  chmod +x "$THEME_HANDLERS_DIR/slow"
  start=$SECONDS
  run "$APPLY" dark
  elapsed=$((SECONDS - start))
  [ "$status" -eq 0 ]
  [ "$elapsed" -lt 10 ]
  grep -q "WARN handler 'slow' exit=124" "$TMPDIR_TEST/dotfiles-theme/log"
}
