#!/usr/bin/env bats
#
# Tests for base/claude/statusline-command.sh — the Claude Code statusline.
# Feeds the script its stdin JSON and asserts on the rendered row: context-bar
# percentage math, the green/yellow/red ramp and its boundaries, model-name
# trimming, and the graceful skip when context_window is absent.
#
# The ponytail badge is neutralised by pointing CLAUDE_CONFIG_DIR at an empty
# directory so the plugin glob matches nothing — output stays deterministic
# whether or not the ponytail plugin is installed on the test host.

setup()
{
  export DOTFILES="$PWD"
  SL="$DOTFILES/base/claude/statusline-command.sh"
  export SL
  ESC=$(printf '\033')
  export ESC
}

# Render the statusline for the given JSON, badge disabled. Raw (keeps colours).
render()
{
  printf '%s' "$1" | CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/none" bash "$SL"
}

# Same, with ANSI colour escapes stripped — for structure assertions.
render_plain()
{
  render "$1" | sed "s/${ESC}\[[0-9;]*m//g"
}

# Build a JSON payload: $1 = total_input_tokens, $2 = context_window_size.
ctx()
{
  printf '{"cwd":"/tmp","model":{"display_name":"Opus 4.8"},"context_window":{"context_window_size":%s,"total_input_tokens":%s}}' "$2" "$1"
}

@test "context percentage is tokens / size" {
  run render_plain "$(ctx 50000 200000)"
  [ "$status" -eq 0 ]
  [[ "$output" == *"] 25%"* ]]
}

@test "bar fills proportionally to usage" {
  run render_plain "$(ctx 50000 200000)" # 25% -> 2 of 8 cells
  [[ "$output" == *"[██░░░░░░]"* ]]
}

@test "ramp is green below 75%" {
  run render "$(ctx 100000 200000)" # 50%
  [[ "$output" == *"${ESC}[38;5;70m"* ]]
}

@test "ramp is yellow from 75%" {
  run render "$(ctx 160000 200000)" # 80%
  [[ "$output" == *"${ESC}[38;5;178m"* ]]
}

@test "ramp turns red at 95%" {
  run render "$(ctx 190000 200000)" # 95%
  [[ "$output" == *"${ESC}[38;5;196m"* ]]
}

@test "94% is still yellow, not red" {
  run render "$(ctx 188000 200000)" # 94%
  [[ "$output" == *"${ESC}[38;5;178m"* ]]
  [[ "$output" != *"${ESC}[38;5;196m"* ]]
}

@test "colour wraps only the bar, brackets stay plain" {
  run render "$(ctx 190000 200000)"
  # '[' immediately precedes the colour escape; reset immediately precedes ']'
  [[ "$output" == *"[${ESC}[38;5;"* ]]
  [[ "$output" == *"${ESC}[0m]"* ]]
}

@test "model name has ' (1M context)' stripped" {
  run render_plain '{"cwd":"/tmp","model":{"display_name":"Opus 4.8 (1M context)"}}'
  [[ "$output" == "Opus 4.8 "* ]]
  [[ "$output" != *"(1M context)"* ]]
}

@test "model name without the suffix is left intact" {
  run render_plain '{"cwd":"/tmp","model":{"display_name":"Sonnet 4.5"}}'
  [[ "$output" == "Sonnet 4.5"* ]]
}

@test "context segment is skipped when context_window is absent" {
  run render_plain '{"cwd":"/tmp","model":{"display_name":"Opus"}}'
  [ "$status" -eq 0 ]
  [[ "$output" != *"%"* ]]
  [[ "$output" != *"["* ]]
}

@test "order is model, then context bar" {
  run render_plain "$(ctx 50000 200000)"
  # badge disabled -> the row starts with the model name, bar follows
  [[ "$output" == "Opus 4.8 ["* ]]
}
