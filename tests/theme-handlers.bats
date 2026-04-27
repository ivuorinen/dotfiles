#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  HD="$BATS_TEST_DIRNAME/../config/theme/handlers.d"
  export DOTFILES="$BATS_TEST_DIRNAME/.."
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "tmux handler: succeeds even when no tmux server is running" {
  run "$HD/tmux" dark
  [ "$status" -eq 0 ]
}
