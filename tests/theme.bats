#!/usr/bin/env bats
# Tests for local/bin/theme.
#
# apply runs for real against an empty THEME_HANDLERS_DIR, so a switch
# records its state without touching any app, and XDG_STATE_HOME keeps the
# developer's own saved choice out of reach.

setup()
{
  export DOTFILES="$BATS_TEST_DIRNAME/.."
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
  export XDG_STATE_HOME="$TMPDIR_TEST/state"
  STATE="$XDG_STATE_HOME/dotfiles-theme"
  mkdir -p "$STATE"
  # A mode on record, so theme-mode never probes the terminal.
  echo dark > "$STATE/mode"
  export THEME_HANDLERS_DIR="$TMPDIR_TEST/handlers.d"
  mkdir -p "$THEME_HANDLERS_DIR"
  unset DOTFILES_THEME_FAMILY
  THEME="$DOTFILES/local/bin/theme"
  read -r DEFAULT < "$DOTFILES/config/theme/family"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

# The listing theme prints off a terminal, with <active> marked.
expected_list()
{
  local d f
  for d in "$DOTFILES/config/theme/palettes.d"/*/; do
    f="$(basename "$d")"
    if [ "$f" = "$1" ]; then echo "* $f"; else echo "  $f"; fi
  done
}

@test "theme: prints usage on --help" {
  run "$THEME" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "theme: rejects an unknown option with usage" {
  run "$THEME" --nope
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage"* ]]
}

@test "theme: lists every family and marks the tracked default" {
  run "$THEME"
  [ "$status" -eq 0 ]
  [ "$output" = "$(expected_list "$DEFAULT")" ]
}

@test "theme: switching saves the choice and applies it" {
  run "$THEME" kanagawa
  [ "$status" -eq 0 ]
  [ "$(cat "$STATE/family")" = "kanagawa" ]
  [ "$(cat "$STATE/applied-family")" = "kanagawa" ]
  run "$THEME"
  [ "$output" = "$(expected_list kanagawa)" ]
}

@test "theme: switching to the active family pins it" {
  run "$THEME" "$DEFAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already"* ]]
  [ "$(cat "$STATE/family")" = "$DEFAULT" ]
}

@test "theme: an unknown or path-like family is rejected" {
  for bad in nope ../oasis Oasis ''; do
    run "$THEME" "$bad"
    [ "$status" -eq 2 ]
    [[ "$output" == *"catppuccin"* ]]
    [ ! -e "$STATE/family" ]
  done
}

@test "theme: --reset returns to the tracked default" {
  "$THEME" kanagawa
  run "$THEME" --reset
  [ "$status" -eq 0 ]
  [ ! -e "$STATE/family" ]
  [ "$(cat "$STATE/applied-family")" = "$DEFAULT" ]
}

@test "theme: a stale saved choice is reported and the default is marked" {
  echo gone > "$STATE/family"
  run "$THEME"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gone"* ]]
  [[ "$output" == *"* $DEFAULT"* ]]
}

@test "theme: an empty or whitespace saved choice is reported too" {
  local bad
  for bad in '' '   '; do
    printf '%s\n' "$bad" > "$STATE/family"
    run "$THEME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"saved"* ]] || {
      echo "no warning for saved choice '$bad'"
      return 1
    }
    [[ "$output" == *"* $DEFAULT"* ]]
  done
}

@test "theme: warns when DOTFILES_THEME_FAMILY overrides the choice" {
  DOTFILES_THEME_FAMILY=catppuccin run "$THEME" kanagawa
  [ "$status" -eq 0 ]
  [[ "$output" == *"DOTFILES_THEME_FAMILY"* ]]
  [ "$(cat "$STATE/family")" = "kanagawa" ]
}

@test "theme: works before apply has ever run" {
  rm -rf "$XDG_STATE_HOME"
  # No mode file, so theme-mode would probe a terminal on stdin (bats passes
  # the developer's through); /dev/null keeps it on the dark default.
  run "$THEME" kanagawa < /dev/null
  [ "$status" -eq 0 ]
  [ "$(cat "$STATE/family")" = "kanagawa" ]
}

@test "theme: piped output carries no escape codes" {
  run "$THEME"
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e'* ]]
}
