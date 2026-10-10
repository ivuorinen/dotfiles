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

@test "tmux-palette: a family without a tmux palette sources nothing" {
  bare_family
  run "$BATS_TEST_DIRNAME/../config/theme/tmux-palette" dark
  [ "$status" -eq 0 ]
  [[ "$output" == *"ships no tmux palette"* ]]
}

@test "handlers: an invalid family exits 1 and leaves the link untouched" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  ln -s /somewhere "$HOME/.config/starship.toml"
  for h in starship eza gitui yazi fzf dircolors gh-dash television bat fish; do
    DOTFILES_THEME_FAMILY=../catppuccin run "$HD/$h" dark
    [ "$status" -eq 1 ] || {
      echo "$h exited $status"
      return 1
    }
  done
  [ "$(readlink "$HOME/.config/starship.toml")" = "/somewhere" ]
}

@test "symlink handlers: a family without the palette removes the stale link" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config/eza" "$HOME/.config/gitui" "$HOME/.config/yazi"
  "$HD/starship" dark
  "$HD/eza" dark
  "$HD/gitui" dark
  "$HD/yazi" dark
  [ -L "$HOME/.config/starship.toml" ]
  bare_family
  for h in starship eza gitui yazi; do
    run "$HD/$h" dark
    [ "$status" -eq 0 ]
  done
  [ ! -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]
  [ ! -L "$HOME/.config/eza/theme.yml" ]
  [ ! -L "$HOME/.config/gitui/theme.ron" ]
  [ ! -L "$HOME/.config/yazi/theme.toml" ]
}

@test "symlink handlers: a family without the palette keeps a regular file" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  echo "user content" > "$HOME/.config/starship.toml"
  bare_family
  run "$HD/starship" dark
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.config/starship.toml")" = "user content" ]
}

@test "state handlers: a family without palettes clears the stale state" {
  "$HD/fzf" dark
  "$HD/bat" dark
  [ -L "$TMPDIR_TEST/dotfiles-theme/fzf-active.sh" ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/bat-theme" ]
  bare_family
  run "$HD/fzf" dark
  [ "$status" -eq 0 ]
  run "$HD/bat" dark
  [ "$status" -eq 0 ]
  [ ! -L "$TMPDIR_TEST/dotfiles-theme/fzf-active.sh" ]
  [ ! -L "$TMPDIR_TEST/dotfiles-theme/fzf-active.fish" ]
  [ ! -e "$TMPDIR_TEST/dotfiles-theme/bat-theme" ]
}

@test "dircolors handler: a family without a palette removes the cache" {
  mkdir -p "$TMPDIR_TEST/dotfiles-theme"
  echo "LS_COLORS=stale" > "$TMPDIR_TEST/dotfiles-theme/ls-colors"
  bare_family
  run "$HD/dircolors" dark
  [ "$status" -eq 0 ]
  [ ! -e "$TMPDIR_TEST/dotfiles-theme/ls-colors" ]
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
  mkdir -p "$HOME/.config/eza" "$HOME/.config/gitui" "$HOME/.config/yazi"
  # shellcheck disable=SC2030,SC2031
  export DOTFILES_THEME_FAMILY=kanagawa
  for h in starship eza gitui yazi fzf gh-dash television bat; do
    run "$HD/$h" light
    [ "$status" -eq 0 ]
  done
  [[ "$(readlink "$HOME/.config/starship.toml")" == *"/kanagawa/light/starship.toml" ]]
  [[ "$(readlink "$HOME/.config/yazi/theme.toml")" == *"/kanagawa/light/yazi.toml" ]]
  [ -L "$HOME/.config/yazi/Kanagawa-Lotus-AA.tmTheme" ]
  [ -L "$HOME/.config/yazi/Kanagawa-Wave.tmTheme" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/bat-theme")" = "Kanagawa Lotus AA" ]
  grep -q "kanagawa-lotus-aa.toml" "$TMPDIR_TEST/dotfiles-theme/television/config.toml"
}

@test "handlers: oasis resolves every palette" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config/eza" "$HOME/.config/gitui" "$HOME/.config/yazi"
  # shellcheck disable=SC2030,SC2031
  export DOTFILES_THEME_FAMILY=oasis
  for h in starship eza gitui yazi fzf gh-dash television bat; do
    run "$HD/$h" dark
    [ "$status" -eq 0 ]
  done
  [[ "$(readlink "$HOME/.config/starship.toml")" == *"/oasis/dark/starship.toml" ]]
  [[ "$(readlink "$HOME/.config/yazi/theme.toml")" == *"/oasis/dark/yazi.toml" ]]
  [ -L "$HOME/.config/yazi/Oasis-Abyss-Dark.tmTheme" ]
  [ -L "$HOME/.config/yazi/Oasis-Abyss-Light-3.tmTheme" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/bat-theme")" = "Oasis Abyss Dark" ]
  grep -q "oasis-abyss-dark.toml" "$TMPDIR_TEST/dotfiles-theme/television/config.toml"
}

@test "starship handler: swaps ~/.config/starship.toml symlink" {
  # shellcheck disable=SC2030,SC2031
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  run "$HD/starship" light
  [ "$status" -eq 0 ]
  [ -L "$HOME/.config/starship.toml" ]
  target="$(readlink "$HOME/.config/starship.toml")"
  [[ "$target" == *"/catppuccin/light/starship.toml" ]]
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
  [[ "$target" == *"/catppuccin/light/eza.yml" ]]
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

@test "fish handler: saves the mode's section of the theme headlessly" {
  if ! command -v fish > /dev/null 2>&1; then
    skip "fish not installed"
  fi
  # Private fish config dir: the save writes universal variables, which
  # must never land in the developer's real fish_variables.
  export XDG_CONFIG_HOME="$TMPDIR_TEST/cfg"
  mkdir -p "$XDG_CONFIG_HOME/fish/themes"
  cp "$DOTFILES/config/fish/themes/catppuccin-aa.theme" "$XDG_CONFIG_HOME/fish/themes/"
  run "$HD/fish" dark
  [ "$status" -eq 0 ]
  local dark light
  dark="$(fish -c 'echo $fish_color_command')"
  run "$HD/fish" light
  [ "$status" -eq 0 ]
  light="$(fish -c 'echo $fish_color_command')"
  [ -n "$dark" ]
  # fish 3.x has no --color-theme and ignores the theme's sections, so
  # only fish 4 can save a different palette per mode.
  # shellcheck disable=SC2016
  if ! fish -c 'functions fish_config' 2> /dev/null | grep -q -- 'color-theme='; then
    skip "fish_config has no --color-theme (fish $(fish -c 'echo $version'))"
  fi
  [ "$dark" != "$light" ]
}

@test "fish theme-switch: an in-session flip saves the mode file's section" {
  if ! command -v fish > /dev/null 2>&1; then
    skip "fish not installed"
  fi
  # shellcheck disable=SC2016
  if ! fish -c 'functions fish_config' 2> /dev/null | grep -q -- 'color-theme='; then
    skip "fish_config has no --color-theme (fish $(fish -c 'echo $version'))"
  fi
  # The terminal's OSC 11 answer can lag a flip (WezTerm keeps the old
  # background in panes open across it), and here there is no terminal at
  # all: only the mode file can pick the section.
  local cfg="$TMPDIR_TEST/cfg" expected
  mkdir -p "$cfg/fish/themes" "$TMPDIR_TEST/dotfiles-theme"
  cp "$DOTFILES/config/fish/themes/catppuccin-aa.theme" "$cfg/fish/themes/"
  echo dark > "$TMPDIR_TEST/dotfiles-theme/mode"
  expected="$(awk '/^\[/ { s = $0 } s == "[dark]" && $1 == "fish_color_command" { print $2 }' \
    "$DOTFILES/config/fish/themes/catppuccin-aa.theme")"
  XDG_CONFIG_HOME="$cfg" run fish --no-config -i -c "
    source '$DOTFILES/config/fish/functions/__dotfiles_theme_name.fish'
    source '$DOTFILES/config/fish/conf.d/theme-switch.fish'
    set -e __theme_switch_last_mtime
    emit fish_prompt
    echo \$fish_color_command"
  [ "$status" -eq 0 ]
  [ -n "$expected" ]
  # Read in-session: --no-config keeps universal variables off disk.
  [ "$output" = "$expected" ]
}

# Fake fish: answers the fish_config source probe as fish 4 (with
# --color-theme) or fish 3 (without), and records every other -c command.
stub_fish()
{
  mkdir -p "$TMPDIR_TEST/bin"
  cat > "$TMPDIR_TEST/bin/fish" << EOF
#!/usr/bin/env bash
if [[ "\$2" == "functions fish_config" ]]; then
  if [[ "$1" == 4 ]]; then
    echo '    argparse h/help color-theme= no-override -- \$argv'
  else
    echo '    argparse h/help -- \$argv'
  fi
  exit 0
fi
printf '%s\n' "\$2" >> "$TMPDIR_TEST/fish.log"
EOF
  chmod +x "$TMPDIR_TEST/bin/fish"
}

@test "fish handler: fish 4 saves with --color-theme=<mode>" {
  stub_fish 4
  PATH="$TMPDIR_TEST/bin:$PATH" run "$HD/fish" light
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/fish.log")" = "fish_config theme save --color-theme=light catppuccin-aa" ]
}

@test "fish handler: fish 3 saves without --color-theme" {
  stub_fish 3
  PATH="$TMPDIR_TEST/bin:$PATH" run "$HD/fish" dark
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/fish.log")" = "fish_config theme save catppuccin-aa" ]
}

@test "fish handler: fish not in PATH is a skip, not a failure" {
  mkdir -p "$TMPDIR_TEST/bin"
  ln -s "$(command -v bash)" "$TMPDIR_TEST/bin/bash"
  ln -s "$(command -v dirname)" "$TMPDIR_TEST/bin/dirname"
  PATH="$TMPDIR_TEST/bin" run "$HD/fish" dark
  [ "$status" -eq 0 ]
  [[ "$output" == *"fish not in PATH; skipping"* ]]
}

@test "fish handler: a failed theme save exits 1 with a message" {
  mkdir -p "$TMPDIR_TEST/bin"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$TMPDIR_TEST/bin/fish"
  chmod +x "$TMPDIR_TEST/bin/fish"
  PATH="$TMPDIR_TEST/bin:$PATH" run "$HD/fish" dark
  [ "$status" -eq 1 ]
  [[ "$output" == *"fish handler: fish_config theme save catppuccin-aa failed"* ]]
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

@test "bat handler: a failed cache build exits 1 with a message" {
  # Fake bat: an empty cache dir (so the build is due) and a failing build.
  mkdir -p "$TMPDIR_TEST/bin" "$TMPDIR_TEST/batcache"
  cat > "$TMPDIR_TEST/bin/bat" << STUB
#!/usr/bin/env bash
case "\$1" in
  --cache-dir) echo "$TMPDIR_TEST/batcache" ;;
  --config-dir) echo "$TMPDIR_TEST/batconfig" ;;
  cache) exit 1 ;;
esac
STUB
  chmod +x "$TMPDIR_TEST/bin/bat"
  PATH="$TMPDIR_TEST/bin:$PATH" run "$HD/bat" dark
  [ "$status" -eq 1 ]
  [[ "$output" == *"bat handler: bat cache --build failed"* ]]
}

@test "bat handler: an unwritable state dir exits 1 with a message" {
  # Fake bat with no cache dir, so the build block is skipped and the
  # exit status can only come from the state write.
  mkdir -p "$TMPDIR_TEST/bin"
  printf '#!/usr/bin/env bash\n' > "$TMPDIR_TEST/bin/bat"
  chmod +x "$TMPDIR_TEST/bin/bat"
  : > "$TMPDIR_TEST/file"
  XDG_STATE_HOME="$TMPDIR_TEST/file" PATH="$TMPDIR_TEST/bin:$PATH" run "$HD/bat" dark
  [ "$status" -eq 1 ]
  [[ "$output" == *"bat handler: cannot write"* ]]
}

@test "bat handler: rejects invalid mode" {
  run "$HD/bat" purple
  [ "$status" -eq 2 ]
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
