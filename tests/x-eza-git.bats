#!/usr/bin/env bats
# Tests for local/bin/x-eza-git.

setup()
{
  export DOTFILES="$PWD"
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
  # stub eza so tests observe the flags instead of real output
  printf '#!/usr/bin/env bash\necho "eza $*"\n' > "$TMPDIR_TEST/eza"
  chmod +x "$TMPDIR_TEST/eza"
  PATH="$TMPDIR_TEST:$PATH"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "x-eza-git: adds --git inside a git work tree" {
  run bash local/bin/x-eza-git -l
  [ "$status" -eq 0 ]
  [[ "$output" == *"--git"* ]]
  [[ "$output" == *"-l"* ]]
}

@test "x-eza-git: omits --git outside a git work tree" {
  mkdir "$TMPDIR_TEST/nowhere"
  cd "$TMPDIR_TEST/nowhere"
  run bash "$DOTFILES/local/bin/x-eza-git"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--smart-group"* ]]
  [[ "$output" != *"--git"* ]]
}

@test "x-eza-git: falls back to system ls when eza is missing" {
  touch "$TMPDIR_TEST/marker-file"
  cd "$TMPDIR_TEST"
  # /usr/bin:/bin has bash, git, and ls but no eza (mise-managed)
  PATH="/usr/bin:/bin" run bash "$DOTFILES/local/bin/x-eza-git" -l
  [ "$status" -eq 0 ]
  [[ "$output" == *"marker-file"* ]]
}
