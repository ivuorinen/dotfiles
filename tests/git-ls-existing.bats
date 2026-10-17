#!/usr/bin/env bats
# Tests for local/bin/git-ls-existing.
#
# The fixture only stages files: git ls-files reads the index, so no commit
# (and no signing key) is needed.

setup()
{
  # See tests/claude-hooks-misc.bats: keeps fixture repos off the git
  # environment a commit hook inherits (GIT_INDEX_FILE and friends).
  unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE GIT_OBJECT_DIRECTORY GIT_COMMON_DIR GIT_PREFIX
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

  SCRIPT="$BATS_TEST_DIRNAME/../local/bin/git-ls-existing"
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST

  mkdir "$TMPDIR_TEST/repo"
  cd "$TMPDIR_TEST/repo" || return 1
  git init -q
  touch kept.md gone.md 'with space.md' other.txt
  git add .
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "git-ls-existing: prints usage on --help" {
  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "git-ls-existing: exits non-zero outside a git work tree" {
  cd "$TMPDIR_TEST"
  run "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a git repository"* ]]
}

@test "git-ls-existing: omits a tracked file deleted from the work tree" {
  rm gone.md
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf '%s\n' kept.md other.txt 'with space.md')" ]
}

@test "git-ls-existing: passes pathspecs to git ls-files" {
  run "$SCRIPT" '*.txt'
  [ "$status" -eq 0 ]
  [ "$output" = "other.txt" ]
}

@test "git-ls-existing: passes git ls-files options through" {
  touch new.md
  run "$SCRIPT" --cached --others --exclude-standard '*.md'
  [ "$status" -eq 0 ]
  [[ "$output" == *"new.md"* && "$output" == *"kept.md"* ]]
}

@test "git-ls-existing: -z ends each path with NUL" {
  rm gone.md
  run bash -c '"$1" -z "*.md" | tr "\0" "|"' _ "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "kept.md|with space.md|" ]
}
