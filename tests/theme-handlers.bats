#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  # handlers.d/claude must never rewrite the developer's real settings.
  export CLAUDE_CONFIG_DIR="$TMPDIR_TEST/claude"
  HD="$BATS_TEST_DIRNAME/../config/theme/handlers.d"
  export DOTFILES="$BATS_TEST_DIRNAME/.."
  # Pin the family so assertions don't follow the tracked default.
  export DOTFILES_THEME_FAMILY=catppuccin
  # Never touch the developer's real tmux server: a private socket dir,
  # and no inherited $TMUX pointing at the outer session.
  export TMUX_TMPDIR="$TMPDIR_TEST/tmux"
  mkdir -p "$TMUX_TMPDIR"
  unset TMUX
}

teardown()
{
  tmux kill-server 2> /dev/null || true
  rm -rf "$TMPDIR_TEST"
}

# A DOTFILES tree whose only family ("bare") ships no palettes at all,
# for the "missing palette ⇒ unlinked" paths.
bare_family()
{
  local real="$BATS_TEST_DIRNAME/.."
  export DOTFILES="$TMPDIR_TEST/dot"
  mkdir -p "$DOTFILES/config/theme/palettes.d/bare/dark" "$DOTFILES/config/theme/palettes.d/bare/light" \
    "$DOTFILES/config/television"
  cp "$real/config/television/base.toml" "$DOTFILES/config/television/base.toml"
  mkdir -p "$DOTFILES/config/television/cable" "$DOTFILES/config/television/themes"
  export DOTFILES_THEME_FAMILY=bare
}

@test "tmux handler: succeeds even when no tmux server is running" {
  run "$HD/tmux" dark
  [ "$status" -eq 0 ]
}

# Throwaway server whose pane runs `sleep`, not a shell: a shell pane
# would run the user's shell init, which spawns the theme watcher with
# this test's environment.
test_server()
{
  tmux -f /dev/null new-session -d -s theme-test 'sleep 300'
}

# Poll (up to ~5 s) until the tmux option $1 is set; prints its value.
wait_for_option()
{
  local _ v
  for _ in $(seq 1 50); do
    v="$(tmux show -gv "$1" 2> /dev/null)"
    [[ -n "$v" ]] && break
    sleep 0.1
  done
  printf '%s' "$v"
}

@test "tmux handler: reloads the config once (no recursion)" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  test_server
  # Stub config: records each load, and runs the same bootstrap the real
  # tmux.conf does. If the bootstrap re-entered the handler, the marker
  # would keep growing past one entry.
  cat > "$TMPDIR_TEST/tmux.conf" << STUB
set -ga @theme_test_loads x
run-shell '"$DOTFILES/config/theme/tmux-palette" dark'
STUB
  THEME_TMUX_CONF="$TMPDIR_TEST/tmux.conf" run timeout 5s "$HD/tmux" dark
  [ "$status" -eq 0 ]
  [ "$(wait_for_option @theme_test_loads)" = "x" ]
  sleep 1
  [ "$(tmux show -gv @theme_test_loads)" = "x" ]
}

@test "tmux handler: a slow config reload does not block apply's budget" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  test_server
  # The real tmux.conf takes ~10 s (TPM); the handler must hand it to the
  # server and return well inside apply's 5 s timeout.
  printf '%s\n' "run-shell 'sleep 8'" 'set -g @theme_test_done yes' > "$TMPDIR_TEST/tmux.conf"
  local start=$SECONDS
  THEME_TMUX_CONF="$TMPDIR_TEST/tmux.conf" run timeout 5s "$HD/tmux" dark
  [ "$status" -eq 0 ]
  ((SECONDS - start < 3))
}

@test "tmux handler: a missing config fails loudly" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  test_server
  THEME_TMUX_CONF="$TMPDIR_TEST/nope.conf" run "$HD/tmux" dark
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing config"* ]]
}

@test "handlers: resolve palettes through _palette, never a hand-built path" {
  # .claude/rules/theme-handler-contract.md: a literal palettes.d path in a
  # handler bypasses the family lookup and its missing-palette cleanup.
  # Comment lines may describe the layout; only code lines count.
  run grep -lE '^[^#]*palettes\.d' "$HD"/* "$BATS_TEST_DIRNAME/../config/theme/tmux-palette"
  echo "$output"
  [ "$status" -eq 1 ]
}

@test "tmux-palette: loads the family's colours, and a flip leaves none behind" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  [[ -r "$HOME/.local/share/tmux/plugins/tmux/catppuccin_tmux.conf" ]] || skip "catppuccin/tmux not installed"
  test_server
  local tp="$BATS_TEST_DIRNAME/../config/theme/tmux-palette"
  DOTFILES_THEME_FAMILY=oasis run "$tp" dark
  [ "$status" -eq 0 ]
  [ "$(tmux show -gv @thm_bg)" = "#000000" ]
  [ "$(tmux show -gv @_win_active_bg)" = "#{@thm_pink}" ]
  # catppuccin ships no dark tmux.thm.conf: the plugin's options pass resets
  # every @thm_* and its theme pass fills in upstream Mocha.
  DOTFILES_THEME_FAMILY=catppuccin run "$tp" dark
  [ "$status" -eq 0 ]
  [ "$(tmux show -gv @thm_bg)" = "#1e1e2e" ]
  [ "$(tmux show -gv @_win_active_bg)" = "#{@thm_mauve}" ]
  # A family that ships no tmux palette at all gets the same upstream colours.
  bare_family
  run "$tp" light
  [ "$status" -eq 0 ]
  [ "$(tmux show -gv @thm_bg)" = "#eff1f5" ]
}

@test "tmux-palette: without the catppuccin/tmux plugin it is a skip" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  run "$BATS_TEST_DIRNAME/../config/theme/tmux-palette" dark
  [ "$status" -eq 0 ]
  [[ "$output" == *"catppuccin/tmux is not installed"* ]]
}

@test "handlers: an invalid family exits 1" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  for h in gh-dash television; do
    DOTFILES_THEME_FAMILY=../catppuccin run "$HD/$h" dark
    [ "$status" -eq 1 ] || {
      echo "$h exited $status"
      return 1
    }
  done
}

@test "composed handlers: a family without palettes writes no theme" {
  bare_family
  run "$HD/gh-dash" dark
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/gh-dash-config.yml")" = "{}" ]
  run "$HD/television" dark
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/television/config.toml" ]
  run grep -q "^theme = " "$TMPDIR_TEST/dotfiles-theme/television/config.toml"
  [ "$status" -ne 0 ]
}

@test "handlers: kanagawa resolves every palette" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  # shellcheck disable=SC2030,SC2031
  export DOTFILES_THEME_FAMILY=kanagawa
  for h in gh-dash television; do
    run "$HD/$h" light
    [ "$status" -eq 0 ]
  done
  grep -q "kanagawa-lotus-aa.toml" "$TMPDIR_TEST/dotfiles-theme/television/config.toml"
}

@test "handlers: oasis resolves every palette" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  # shellcheck disable=SC2030,SC2031
  export DOTFILES_THEME_FAMILY=oasis
  for h in gh-dash television; do
    run "$HD/$h" dark
    [ "$status" -eq 0 ]
  done
  grep -q "oasis-abyss-dark.toml" "$TMPDIR_TEST/dotfiles-theme/television/config.toml"
}

@test "handlers: warm-burnout resolves every palette" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  # shellcheck disable=SC2030,SC2031
  export DOTFILES_THEME_FAMILY=warm-burnout
  for h in gh-dash television; do
    run "$HD/$h" dark
    [ "$status" -eq 0 ]
  done
  grep -q "warm-burnout-dark.toml" "$TMPDIR_TEST/dotfiles-theme/television/config.toml"
}

@test "gh-dash handler: writes the theme overlay into the state dir, not ~/.config" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  run "$HD/gh-dash" dark
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/gh-dash-config.yml" ]
  # Only the palette: the sections live in the config/gh-dash/config.yml
  # base layer, which gh-dash loads underneath this overlay.
  grep -q "^theme:" "$TMPDIR_TEST/dotfiles-theme/gh-dash-config.yml"
  run grep -q "prSections" "$TMPDIR_TEST/dotfiles-theme/gh-dash-config.yml"
  [ "$status" -ne 0 ]
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

@test "television handler: a failed config write exits 1 with a message" {
  run "$HD/television" light
  [ "$status" -eq 0 ]
  # The links are already in place, so only the config write can fail.
  tvdir="$TMPDIR_TEST/dotfiles-theme/television"
  chmod 555 "$tvdir"
  run "$HD/television" dark
  chmod 755 "$tvdir"
  [ "$status" -eq 1 ]
  [[ "$output" == *"television handler: cannot write"* ]]
}

@test "television handler: rejects invalid mode" {
  run "$HD/television" purple
  [ "$status" -eq 2 ]
}

# settings.json with content $1 in the sandboxed CLAUDE_CONFIG_DIR (set in
# setup), and the orchestrator's mode file set to $2.
claude_fixture()
{
  mkdir -p "$CLAUDE_CONFIG_DIR" "$TMPDIR_TEST/dotfiles-theme"
  printf '%s\n' "$1" > "$CLAUDE_CONFIG_DIR/settings.json"
  echo "$2" > "$TMPDIR_TEST/dotfiles-theme/mode"
}

@test "claude handler: writes the theme file and selects it, keeping other keys" {
  command -v jq > /dev/null 2>&1 || skip "jq not installed"
  claude_fixture '{"theme": "auto", "hooks": {"Stop": []}, "model": "x"}' light
  run "$HD/claude" light
  [ "$status" -eq 0 ]
  [ "$(jq -r .base "$CLAUDE_CONFIG_DIR/themes/dotfiles.json")" = "light" ]
  [ "$(jq -r .theme "$CLAUDE_CONFIG_DIR/settings.json")" = "custom:dotfiles" ]
  [ "$(jq -c '.hooks' "$CLAUDE_CONFIG_DIR/settings.json")" = '{"Stop":[]}' ]
  [ "$(jq -r .model "$CLAUDE_CONFIG_DIR/settings.json")" = "x" ]
}

@test "claude handler: takes the base from theme-mode, not its argument" {
  command -v jq > /dev/null 2>&1 || skip "jq not installed"
  claude_fixture '{"theme": "custom:dotfiles"}' dark
  run "$HD/claude" light
  [ "$status" -eq 0 ]
  [ "$(jq -r .base "$CLAUDE_CONFIG_DIR/themes/dotfiles.json")" = "dark" ]
}

@test "claude handler: a flip rewrites only the theme file" {
  command -v jq > /dev/null 2>&1 || skip "jq not installed"
  claude_fixture '{"theme": "auto"}' dark
  "$HD/claude" dark
  local before
  before="$(ls -i "$CLAUDE_CONFIG_DIR/settings.json")"
  echo light > "$TMPDIR_TEST/dotfiles-theme/mode"
  run "$HD/claude" light
  [ "$status" -eq 0 ]
  [ "$(jq -r .base "$CLAUDE_CONFIG_DIR/themes/dotfiles.json")" = "light" ]
  [ "$(ls -i "$CLAUDE_CONFIG_DIR/settings.json")" = "$before" ]
}

@test "claude handler: an unchanged mode rewrites nothing" {
  command -v jq > /dev/null 2>&1 || skip "jq not installed"
  claude_fixture '{"theme": "auto"}' dark
  "$HD/claude" dark
  local before
  before="$(ls -i "$CLAUDE_CONFIG_DIR/themes/dotfiles.json")"
  run "$HD/claude" dark
  [ "$status" -eq 0 ]
  [ "$(ls -i "$CLAUDE_CONFIG_DIR/themes/dotfiles.json")" = "$before" ]
}

@test "claude handler: no settings file is a skip and creates nothing" {
  run "$HD/claude" dark
  [ "$status" -eq 0 ]
  [[ "$output" == *"skipping"* ]]
  [ ! -e "$CLAUDE_CONFIG_DIR" ]
}

@test "claude handler: without jq the theme file is still written" {
  claude_fixture '{"theme": "auto"}' dark
  mkdir -p "$TMPDIR_TEST/bin"
  local t
  for t in bash dirname cat mkdir mktemp mv rm; do
    ln -s "$(command -v "$t")" "$TMPDIR_TEST/bin/$t"
  done
  PATH="$TMPDIR_TEST/bin" run "$HD/claude" dark
  [ "$status" -eq 0 ]
  [[ "$output" == *"jq not in PATH"* ]]
  [[ "$(cat "$CLAUDE_CONFIG_DIR/themes/dotfiles.json")" == *'"base": "dark"'* ]]
  [ "$(cat "$CLAUDE_CONFIG_DIR/settings.json")" = '{"theme": "auto"}' ]
}

@test "claude handler: a symlinked settings file stays a link" {
  command -v jq > /dev/null 2>&1 || skip "jq not installed"
  claude_fixture '{"theme": "auto"}' dark
  mv "$CLAUDE_CONFIG_DIR/settings.json" "$TMPDIR_TEST/real.json"
  ln -s "$TMPDIR_TEST/real.json" "$CLAUDE_CONFIG_DIR/settings.json"
  run "$HD/claude" dark
  [ "$status" -eq 0 ]
  [[ "$output" == *"is a symlink"* ]]
  [ -L "$CLAUDE_CONFIG_DIR/settings.json" ]
  [ "$(cat "$TMPDIR_TEST/real.json")" = '{"theme": "auto"}' ]
}

@test "claude handler: unparsable settings exit 1 and stay untouched" {
  command -v jq > /dev/null 2>&1 || skip "jq not installed"
  claude_fixture '{"theme": ' dark
  run "$HD/claude" dark
  [ "$status" -eq 1 ]
  [[ "$output" == *"claude handler: cannot parse"* ]]
  [ "$(cat "$CLAUDE_CONFIG_DIR/settings.json")" = '{"theme": ' ]
  [ -z "$(find "$CLAUDE_CONFIG_DIR" -name 'settings.json.*')" ]
}

@test "claude handler: rejects invalid mode" {
  run "$HD/claude" purple
  [ "$status" -eq 2 ]
}
