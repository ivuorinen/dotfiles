#!/usr/bin/env bats

# x-git-root backs the `cdgr` alias as cd "$(x-git-root)". A silent failure
# would cd to the home directory, so the non-repo path must exit non-zero and
# print nothing on stdout.

setup()
{
  X_GIT_ROOT="$BATS_TEST_DIRNAME/../local/bin/x-git-root"
  TMP="$(mktemp -d)"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-git-root: prints the repository top level from inside a repo" {
  run bash -c "cd '$BATS_TEST_DIRNAME/..' && '$X_GIT_ROOT'"
  [ "$status" -eq 0 ]
  [ -d "$output/.git" ]
}

@test "x-git-root: prints the top level from a subdirectory, not the cwd" {
  run bash -c "cd '$BATS_TEST_DIRNAME' && '$X_GIT_ROOT'"
  [ "$status" -eq 0 ]
  [ "$output" != "$BATS_TEST_DIRNAME" ]
  [ -d "$output/.git" ]
}

@test "x-git-root: exits 1 outside a repository" {
  run bash -c "cd '$TMP' && '$X_GIT_ROOT'"
  [ "$status" -eq 1 ]
}

@test "x-git-root: writes nothing to stdout outside a repository" {
  # cd "$(x-git-root)" would land in \$HOME if the error leaked to stdout.
  run bash -c "cd '$TMP' && '$X_GIT_ROOT' 2>/dev/null"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "x-git-root: reports the failure on stderr" {
  run bash -c "cd '$TMP' && '$X_GIT_ROOT' 2>&1 >/dev/null"
  [[ "$output" == *"Not in a git repository"* ]]
}
