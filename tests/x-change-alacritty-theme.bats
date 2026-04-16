#!/usr/bin/env bats

setup()
{
  THEME_DIR="$(mktemp -d)/alacritty"
  mkdir -p "$THEME_DIR"
  touch "$THEME_DIR/alacritty.toml"
  XDG_CONFIG_HOME="$(dirname "$THEME_DIR")"
  export XDG_CONFIG_HOME
}

teardown()
{
  rm -rf "$(dirname "$THEME_DIR")"
}

@test "x-change-alacritty-theme: exits non-zero when theme file is missing" {
  run bash -c 'bash local/bin/x-change-alacritty-theme day 2>&1'
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "x-change-alacritty-theme: exits 0 and copies theme when file exists" {
  echo "theme = night" > "$THEME_DIR/theme-night.toml"
  run bash local/bin/x-change-alacritty-theme night
  [ "$status" -eq 0 ]
  [ -f "$THEME_DIR/theme-active.toml" ]
}

@test "x-change-alacritty-theme: exits 1 when no argument given" {
  run bash local/bin/x-change-alacritty-theme
  [ "$status" -eq 1 ]
}
