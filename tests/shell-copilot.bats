#!/usr/bin/env bats

setup()
{
  command -v fish > /dev/null || skip "fish not installed"
  export DOTFILES_REPO="$PWD"
  # Physical path: the function also grants each match's resolved path, and
  # macOS keeps the temp dir under the /var -> /private/var link.
  TEST_HOME="$(cd "$BATS_TEST_TMPDIR" && pwd -P)/home with spaces"
  export TEST_HOME
  export COPILOT_HOME="$TEST_HOME/custom copilot"
  export COPILOT_TEST_STATUS=0
  STUB="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$STUB" "$TEST_HOME"
  printf '#!/bin/sh\nprintf "%%s\\n" "$@"\nexit "$COPILOT_TEST_STATUS"\n' > "$STUB/copilot"
  chmod +x "$STUB/copilot"
}

run_copilot()
{
  run env HOME="$TEST_HOME" PATH="$STUB:$PATH" fish --no-config -c \
    'source "$DOTFILES_REPO/config/fish/functions/copilot.fish"; copilot $argv' -- "$@"
}

@test "fish copilot grants both Nitpicker paths and preserves arguments" {
  mkdir -p "$TEST_HOME/.agents/skills/nitpicker" "$COPILOT_HOME/skills"
  ln -s "$TEST_HOME/.agents/skills/nitpicker" "$COPILOT_HOME/skills/nitpicker"

  run_copilot --prompt "review this" --add-dir "$TEST_HOME/another project"

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 8 ]
  [ "${lines[0]}" = "--add-dir" ]
  [ "${lines[1]}" = "$TEST_HOME/.agents/skills/nitpicker" ]
  [ "${lines[2]}" = "--add-dir" ]
  [ "${lines[3]}" = "$COPILOT_HOME/skills/nitpicker" ]
  [ "${lines[4]}" = "--prompt" ]
  [ "${lines[5]}" = "review this" ]
  [ "${lines[6]}" = "--add-dir" ]
  [ "${lines[7]}" = "$TEST_HOME/another project" ]
}

@test "fish copilot uses default Copilot home when no override is set" {
  unset COPILOT_HOME
  mkdir -p "$TEST_HOME/.copilot/skills/nitpicker"

  run_copilot --version

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" = "--add-dir" ]
  [ "${lines[1]}" = "$TEST_HOME/.copilot/skills/nitpicker" ]
  [ "${lines[2]}" = "--version" ]
}

@test "fish copilot grants every directory a glob matches and a link's target" {
  local skills="$TEST_HOME/.agents/skills"
  mkdir -p "$skills/alpha" "$skills/beta" "$TEST_HOME/elsewhere/gamma" "$COPILOT_HOME/skills"
  touch "$skills/README.md"
  ln -s "$TEST_HOME/elsewhere/gamma" "$COPILOT_HOME/skills/gamma"

  run_copilot --version

  [ "$status" -eq 0 ]
  [ "$output" = "$(printf '%s\n' --add-dir "$skills/alpha" --add-dir "$skills/beta" \
    --add-dir "$COPILOT_HOME/skills/gamma" --add-dir "$TEST_HOME/elsewhere/gamma" --version)" ]
}

@test "fish copilot skips missing directories and preserves command failure" {
  export COPILOT_TEST_STATUS=27

  run_copilot --version

  [ "$status" -eq 27 ]
  [ "$output" = "--version" ]
}
