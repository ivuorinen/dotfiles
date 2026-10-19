#!/usr/bin/env bats
# Tests for local/bin/deja-hook.
#
# Each test runs the launcher with PATH set to a directory of stubs only, so a
# deja installed on the machine (or in CI) can never answer in a stub's place.

setup()
{
  export DOTFILES="$PWD"
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
  SCRIPT="$DOTFILES/local/bin/deja-hook"
  STUBS="$TMPDIR_TEST/bin"
  mkdir -p "$STUBS" "$TMPDIR_TEST/empty"
  unset DEJA_HOOK_BIN DEJA_BIN

  # A stub prints its label and arguments, echoes stdin when asked to, and
  # exits with $STUB_EXIT (default 0). Only shell builtins: PATH has no tools.
  for name in deja hook-bin deja-bin; do
    cat > "$STUBS/$name" << EOF
#!/bin/sh
printf '%s:%s\n' "$name" "\$*"
if [ -n "\${STUB_STDIN:-}" ]; then
  while IFS= read -r line; do printf '%s\n' "\$line"; done
fi
exit "\${STUB_EXIT:-0}"
EOF
    chmod +x "$STUBS/$name"
  done
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "deja-hook: passes --help through to deja" {
  run env PATH="$STUBS" "$BASH" "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [ "$output" = "deja:--help" ]
}

@test "deja-hook: returns deja's exit status when deja fails" {
  run env PATH="$STUBS" STUB_EXIT=3 "$BASH" "$SCRIPT" hook-context
  [ "$status" -eq 3 ]
  [ "$output" = "deja:hook-context" ]
}

@test "deja-hook: runs DEJA_HOOK_BIN first when it is executable" {
  run env PATH="$STUBS" DEJA_HOOK_BIN="$STUBS/hook-bin" \
    DEJA_BIN="$STUBS/deja-bin" "$BASH" "$SCRIPT" hook-prompt --copilot
  [ "$status" -eq 0 ]
  [ "$output" = "hook-bin:hook-prompt --copilot" ]
}

@test "deja-hook: falls back to DEJA_BIN when DEJA_HOOK_BIN is stale" {
  run env PATH="$STUBS" DEJA_HOOK_BIN="$TMPDIR_TEST/missing" \
    DEJA_BIN="$STUBS/deja-bin" "$BASH" "$SCRIPT" hook-tool
  [ "$status" -eq 0 ]
  [ "$output" = "deja-bin:hook-tool" ]
}

@test "deja-hook: falls back to deja on PATH when both overrides are unusable" {
  touch "$TMPDIR_TEST/not-executable"
  run env PATH="$STUBS" DEJA_HOOK_BIN="$TMPDIR_TEST/not-executable" \
    DEJA_BIN="$TMPDIR_TEST/missing" "$BASH" "$SCRIPT" hook-session-end
  [ "$status" -eq 0 ]
  [ "$output" = "deja:hook-session-end" ]
}

@test "deja-hook: passes the hook payload on stdin through to deja" {
  run env PATH="$STUBS" STUB_STDIN=1 "$BASH" "$SCRIPT" hook-prompt \
    <<< '{"session_id":"s1"}'
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "deja:hook-prompt" ]
  [ "${lines[1]}" = '{"session_id":"s1"}' ]
}

@test "deja-hook: exits 0 with no output when deja is not installed" {
  run env PATH="$TMPDIR_TEST/empty" "$BASH" "$SCRIPT" hook-context --copilot
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
