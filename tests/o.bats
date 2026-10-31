#!/usr/bin/env bats
# Tests for local/bin/o.

setup()
{
  export DOTFILES="$PWD"
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
  mkdir "$TMPDIR_TEST/orgfiles"
  # stub nvim so tests observe the cwd and arguments instead of opening an editor
  printf '#!/usr/bin/env bash\necho "$PWD nvim $*"\nexit "${NVIM_STUB_EXIT:-0}"\n' > "$TMPDIR_TEST/nvim"
  chmod +x "$TMPDIR_TEST/nvim"
  PATH="$TMPDIR_TEST:$PATH"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "o: opens tasks.org in \$HOME/orgfiles with the org agenda" {
  HOME="$TMPDIR_TEST" run bash local/bin/o
  [ "$status" -eq 0 ]
  [ "$output" = "$(cd "$TMPDIR_TEST/orgfiles" && pwd) nvim tasks.org +Org agenda" ]
}

@test "o: passes nvim's exit status through" {
  HOME="$TMPDIR_TEST" NVIM_STUB_EXIT=3 run bash local/bin/o
  [ "$status" -eq 3 ]
}

@test "o: fails without starting nvim when \$HOME/orgfiles is missing" {
  rmdir "$TMPDIR_TEST/orgfiles"
  HOME="$TMPDIR_TEST" run bash local/bin/o
  [ "$status" -ne 0 ]
  [[ "$output" != *"nvim"* ]]
}
