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

@test "starship handler: swaps ~/.config/starship.toml symlink" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  run "$HD/starship" light
  [ "$status" -eq 0 ]
  [ -L "$HOME/.config/starship.toml" ]
  target="$(readlink "$HOME/.config/starship.toml")"
  [[ "$target" == *"starship.light.toml" ]]
}

@test "starship handler: refuses to clobber a regular file" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  echo "user content" > "$HOME/.config/starship.toml"
  run "$HD/starship" dark
  [ "$status" -eq 0 ]
  [ ! -L "$HOME/.config/starship.toml" ]
  [ "$(cat "$HOME/.config/starship.toml")" = "user content" ]
}

@test "dircolors handler: writes ls-colors cache atomically" {
  run "$HD/dircolors" dark
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/ls-colors" ]
  grep -q "LS_COLORS=" "$TMPDIR_TEST/dotfiles-theme/ls-colors"
  grep -q "export LS_COLORS" "$TMPDIR_TEST/dotfiles-theme/ls-colors"
}
