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

@test "eza handler: swaps ~/.config/eza/theme.yml symlink" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config/eza"
  run "$HD/eza" light
  [ "$status" -eq 0 ]
  [ -L "$HOME/.config/eza/theme.yml" ]
  target="$(readlink "$HOME/.config/eza/theme.yml")"
  [[ "$target" == *"eza.light.yml" ]]
}

@test "eza handler: refuses to clobber a regular file" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config/eza"
  echo "user content" > "$HOME/.config/eza/theme.yml"
  run "$HD/eza" dark
  [ "$status" -eq 0 ]
  [ ! -L "$HOME/.config/eza/theme.yml" ]
  [ "$(cat "$HOME/.config/eza/theme.yml")" = "user content" ]
}

@test "eza handler: rejects invalid mode" {
  run "$HD/eza" purple
  [ "$status" -eq 2 ]
}

@test "dircolors handler: writes ls-colors cache atomically" {
  if ! command -v dircolors > /dev/null 2>&1 \
    && ! command -v gdircolors > /dev/null 2>&1; then
    skip "neither dircolors nor gdircolors installed"
  fi
  run "$HD/dircolors" dark
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/ls-colors" ]
  grep -q "LS_COLORS=" "$TMPDIR_TEST/dotfiles-theme/ls-colors"
  grep -q "export LS_COLORS" "$TMPDIR_TEST/dotfiles-theme/ls-colors"
}

@test "fish handler: returns 0 with valid mode (smoke test only)" {
  if ! command -v fish > /dev/null 2>&1; then
    skip "fish not installed"
  fi
  run "$HD/fish" dark
  [ "$status" -eq 0 ]
}

@test "fish handler: rejects invalid mode" {
  run "$HD/fish" purple
  [ "$status" -eq 2 ]
}

@test "bat handler: publishes theme name to the state dir, not ~/.config" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  run "$HD/bat" dark
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/bat-theme")" = "Catppuccin Mocha" ]
  run "$HD/bat" light
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/bat-theme")" = "Catppuccin Latte" ]
  # The reorg invariant: nothing is written under ~/.config.
  [ ! -e "$HOME/.config/bat/config" ]
  [ -z "$(find "$HOME/.config" -type f 2> /dev/null)" ]
}

@test "bat handler: rejects invalid mode" {
  run "$HD/bat" purple
  [ "$status" -eq 2 ]
}

@test "gh-dash handler: composes config into the state dir, not ~/.config" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  run "$HD/gh-dash" dark
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/gh-dash-config.yml" ]
  # base.yml content + the theme palette are both present.
  grep -q "prSections" "$TMPDIR_TEST/dotfiles-theme/gh-dash-config.yml"
  grep -q "theme" "$TMPDIR_TEST/dotfiles-theme/gh-dash-config.yml"
  [ ! -e "$HOME/.config/gh-dash/config.yml" ]
  [ -z "$(find "$HOME/.config" -type f 2> /dev/null)" ]
}

@test "gh-dash handler: rejects invalid mode" {
  run "$HD/gh-dash" purple
  [ "$status" -eq 2 ]
}

@test "television handler: composes config dir in the state dir, not ~/.config" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  run "$HD/television" light
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/television/config.toml" ]
  grep -q "catppuccin-latte-mauve" "$TMPDIR_TEST/dotfiles-theme/television/config.toml"
  [ -L "$TMPDIR_TEST/dotfiles-theme/television/cable" ]
  [ -L "$TMPDIR_TEST/dotfiles-theme/television/themes" ]
  [ ! -e "$HOME/.config/television/config.toml" ]
  [ -z "$(find "$HOME/.config" -type f 2> /dev/null)" ]
}

@test "television handler: rejects invalid mode" {
  run "$HD/television" purple
  [ "$status" -eq 2 ]
}
