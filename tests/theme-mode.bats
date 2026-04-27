#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  THEME_MODE="$BATS_TEST_DIRNAME/../local/bin/theme-mode"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "theme-mode: prints state file content when present" {
  mkdir -p "$TMPDIR_TEST/dotfiles-theme"
  echo "light" > "$TMPDIR_TEST/dotfiles-theme/mode"
  run "$THEME_MODE"
  [ "$status" -eq 0 ]
  [ "$output" = "light" ]
}

@test "theme-mode: defaults to dark when no state file and no TTY" {
  # bats run() captures stdin from /dev/null, so [ -t 0 ] is false
  run "$THEME_MODE"
  [ "$status" -eq 0 ]
  [ "$output" = "dark" ]
}

@test "theme-mode: trims trailing newline from state file" {
  mkdir -p "$TMPDIR_TEST/dotfiles-theme"
  printf 'dark\n' > "$TMPDIR_TEST/dotfiles-theme/mode"
  run "$THEME_MODE"
  [ "$output" = "dark" ]
}
