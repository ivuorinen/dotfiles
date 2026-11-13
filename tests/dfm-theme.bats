#!/usr/bin/env bats
# Tests for local/bin/dfm-theme (dfm theme family / reset / mode / reapply).
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
  DFM="$DOTFILES/local/bin/dfm"
  read -r DEFAULT < "$DOTFILES/config/theme/family"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

# The listing `dfm theme family` prints off a terminal, with <active> marked.
expected_list()
{
  local d f
  for d in "$DOTFILES/config/theme/palettes.d"/*/; do
    f="$(basename "$d")"
    if [ "$f" = "$1" ]; then echo "* $f"; else echo "  $f"; fi
  done
}

# Point DOTFILES at a tree whose config/theme/apply fails the way a lock
# timeout does; every other theme file is linked from the repo.
failing_apply()
{
  local fake="$TMPDIR_TEST/dotfiles" e
  mkdir -p "$fake/config/theme"
  for e in "$DOTFILES/config/theme"/*; do
    ln -s "$e" "$fake/config/theme/${e##*/}"
  done
  rm "$fake/config/theme/apply"
  printf '#!/bin/sh\necho "apply: lock still held" >&2\nexit 1\n' > "$fake/config/theme/apply"
  chmod +x "$fake/config/theme/apply"
  export DOTFILES="$fake"
}

@test "dfm theme: a help flag shows the menu" {
  run "$DFM" theme --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"dfm theme <command>"* ]]
  [[ "$output" == *"family"* ]]
}

@test "dfm theme family: rejects an option or a second name" {
  run "$DFM" theme family --nope
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage: dfm theme family"* ]]
  run "$DFM" theme family kanagawa oasis
  [ "$status" -eq 2 ]
  [ ! -e "$STATE/choice" ]
}

@test "dfm theme family: lists every family and marks the tracked default" {
  run "$DFM" theme family
  [ "$status" -eq 0 ]
  [ "$output" = "$(expected_list "$DEFAULT")" ]
}

@test "dfm theme family: switching saves the choice and applies it" {
  run "$DFM" theme family kanagawa
  [ "$status" -eq 0 ]
  [ "$(cat "$STATE/choice")" = "kanagawa" ]
  [ "$(cat "$STATE/applied-family")" = "kanagawa" ]
  run "$DFM" theme family
  [ "$output" = "$(expected_list kanagawa)" ]
}

@test "dfm theme family: switching to the active family pins it" {
  run "$DFM" theme family "$DEFAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already"* ]]
  [ "$(cat "$STATE/choice")" = "$DEFAULT" ]
}

@test "dfm theme family: an unknown or path-like family is rejected" {
  for bad in nope ../oasis Oasis ''; do
    run "$DFM" theme family "$bad"
    [ "$status" -eq 2 ]
    [[ "$output" == *"catppuccin"* ]]
    [ ! -e "$STATE/choice" ]
  done
}

@test "dfm theme reset: returns to the tracked default" {
  "$DFM" theme family kanagawa
  run "$DFM" theme reset
  [ "$status" -eq 0 ]
  [ ! -e "$STATE/choice" ]
  [ "$(cat "$STATE/applied-family")" = "$DEFAULT" ]
}

@test "dfm theme family: a failed apply is an error, not a switch" {
  failing_apply
  run "$DFM" theme family kanagawa
  [ "$status" -eq 1 ]
  [[ "$output" == *"apply: lock still held"* ]]
  [[ "$output" == *"saved kanagawa as the theme family, but applying it failed"* ]]
  [[ "$output" != *"switched to"* ]]
  [ "$(cat "$STATE/choice")" = "kanagawa" ]
}

@test "dfm theme reset: a failed apply is an error" {
  echo kanagawa > "$STATE/choice"
  failing_apply
  run "$DFM" theme reset
  [ "$status" -eq 1 ]
  [[ "$output" == *"applying the default theme family failed"* ]]
  [[ "$output" != *"back to the default"* ]]
  [ ! -e "$STATE/choice" ]
}

@test "dfm theme reset: a choice it cannot remove stops before applying" {
  [ "$(id -u)" -ne 0 ] || skip "root ignores the read-only directory"
  echo kanagawa > "$STATE/choice"
  chmod 500 "$STATE"
  run "$DFM" theme reset
  chmod 700 "$STATE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"cannot remove the saved theme choice"* ]]
  [[ "$output" != *"back to the default"* ]]
  [ "$(cat "$STATE/choice")" = "kanagawa" ]
}

@test "dfm theme family: a stale saved choice is reported and the default is marked" {
  echo gone > "$STATE/choice"
  run "$DFM" theme family
  [ "$status" -eq 0 ]
  [[ "$output" == *"gone"* ]]
  [[ "$output" == *"* $DEFAULT"* ]]
}

@test "dfm theme family: an empty or whitespace saved choice is reported too" {
  local bad
  for bad in '' '   '; do
    printf '%s\n' "$bad" > "$STATE/choice"
    run "$DFM" theme family
    [ "$status" -eq 0 ]
    [[ "$output" == *"saved"* ]] || {
      echo "no warning for saved choice '$bad'"
      return 1
    }
    [[ "$output" == *"* $DEFAULT"* ]]
  done
}

@test "dfm theme family: warns when DOTFILES_THEME_FAMILY overrides the choice" {
  DOTFILES_THEME_FAMILY=catppuccin run "$DFM" theme family kanagawa
  [ "$status" -eq 0 ]
  [[ "$output" == *"DOTFILES_THEME_FAMILY"* ]]
  [ "$(cat "$STATE/choice")" = "kanagawa" ]
}

@test "dfm theme family: works before apply has ever run" {
  rm -rf "$XDG_STATE_HOME"
  # No mode file, so theme-mode would probe a terminal on stdin (bats passes
  # the developer's through); /dev/null keeps it on the dark default.
  run "$DFM" theme family kanagawa < /dev/null
  [ "$status" -eq 0 ]
  [ "$(cat "$STATE/choice")" = "kanagawa" ]
}

@test "dfm theme family: piped output carries no escape codes" {
  run "$DFM" theme family
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e'* ]]
}

# reapply runs config/theme/apply --force: every handler, even when the mode
# and family are unchanged.
@test "dfm theme reapply: re-runs the handlers at an unchanged mode" {
  cat > "$THEME_HANDLERS_DIR/count" << 'STUB'
#!/usr/bin/env bash
echo "$1" >> "$TMPDIR_TEST/handler-runs"
STUB
  chmod +x "$THEME_HANDLERS_DIR/count"
  "$DOTFILES/config/theme/apply" dark
  run "$DFM" theme reapply
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/handler-runs")" = "$(printf 'dark\ndark')" ]
  run "$DFM" theme reapply light
  [ "$status" -eq 0 ]
  [ "$(tail -1 "$TMPDIR_TEST/handler-runs")" = "light" ]
}

@test "dfm theme reapply: rejects a mode that is not dark or light" {
  run "$DFM" theme reapply dusk
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage: dfm theme reapply"* ]]
}

@test "dfm theme status: before any apply" {
  rm -rf "$XDG_STATE_HOME"
  run env -u SSH_CONNECTION "$DFM" theme status
  [ "$status" -eq 0 ]
  [[ "$output" == *"mode:     not set"* ]]
  [[ "$output" == *"family:   $DEFAULT (default, config/theme/family)"* ]]
  [[ "$output" == *"watcher:  not running"* ]]
  [[ "$output" == *"retry:    none"* ]]
  [[ "$output" == *"updated:  never"* ]]
}

@test "dfm theme status: a saved choice, an applied state and a pending retry" {
  "$DFM" theme family kanagawa
  printf 'tmux\nclaude\n' > "$STATE/retry"
  run "$DFM" theme status
  [ "$status" -eq 0 ]
  [[ "$output" == *"mode:     dark"* ]]
  [[ "$output" == *"family:   kanagawa (saved choice)"* ]]
  [[ "$output" == *"applied:  kanagawa"* ]]
  [[ "$output" == *"retry:    tmux claude"* ]]
  [[ "$output" != *"updated:  never"* ]]
}

@test "dfm theme status: DOTFILES_THEME_FAMILY is named as the source" {
  DOTFILES_THEME_FAMILY=catppuccin run "$DFM" theme status
  [ "$status" -eq 0 ]
  [[ "$output" == *"family:   catppuccin (DOTFILES_THEME_FAMILY)"* ]]
}

@test "dfm theme status: a stale pid is not reported as a running watcher" {
  # A pid that cannot be running, then one that runs but is not the watcher.
  echo 2147483646 > "$STATE/daemon.pid"
  run env -u SSH_CONNECTION "$DFM" theme status
  [[ "$output" == *"watcher:  not running"* ]]
  echo "$$" > "$STATE/daemon.pid"
  run env -u SSH_CONNECTION "$DFM" theme status
  [[ "$output" == *"watcher:  not running"* ]]
}

@test "dfm theme status: a live watcher is reported with its pid" {
  # A process whose command line names the watcher, as the real one does.
  bash -c 'exec -a config/theme/watcher sleep 30' &
  local pid=$!
  echo "$pid" > "$STATE/daemon.pid"
  run "$DFM" theme status
  kill "$pid" 2> /dev/null || true
  [[ "$output" == *"watcher:  running (pid $pid)"* ]]
}

@test "dfm theme status: takes no arguments" {
  run "$DFM" theme status extra
  [ "$status" -eq 2 ]
}

@test "dfm theme reapply: a failing handler fails the command" {
  printf '#!/usr/bin/env bash\nexit 3\n' > "$THEME_HANDLERS_DIR/broken"
  chmod +x "$THEME_HANDLERS_DIR/broken"
  run "$DFM" theme reapply dark
  [ "$status" -eq 1 ]
  [[ "$output" == *"broken"* ]]
}
