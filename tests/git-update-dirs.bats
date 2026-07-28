#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# git-update-dirs pulls every git repository one level below the current
# directory. The fixture is a bare repository on disk acting as the remote,
# with clones beside it, so the pulls are real git operations that never touch
# the network.

setup()
{
  GUD="$BATS_TEST_DIRNAME/../local/bin/git-update-dirs"
  TMP="$(mktemp -d)"
  WORK="$TMP/work"
  mkdir -p "$WORK"
  export GIT_CONFIG_GLOBAL=/dev/null
  export GIT_CONFIG_SYSTEM=/dev/null

  git init --quiet -b main "$TMP/seed"
  printf 'one\n' > "$TMP/seed/file.txt"
  git -C "$TMP/seed" add -A
  git -C "$TMP/seed" -c user.email=t@example.com -c user.name=Test \
    commit --quiet -m "first"
  # -b main on the bare repo too, or its HEAD points at a branch that is
  # never created and the clones come out with no checkout.
  git init --quiet --bare -b main "$TMP/origin"
  git -C "$TMP/seed" remote add origin "$TMP/origin"
  git -C "$TMP/seed" push --quiet -u origin main

  git clone --quiet "$TMP/origin" "$WORK/repo-a"
  git clone --quiet "$TMP/origin" "$WORK/repo-b"
  mkdir -p "$WORK/not-a-repo"

  cd "$WORK" || return 1
}

teardown()
{
  rm -rf "$TMP"
}

# Add a commit upstream so the clones have something to pull.
push_upstream()
{
  printf 'two\n' >> "$TMP/seed/file.txt"
  git -C "$TMP/seed" add -A
  git -C "$TMP/seed" -c user.email=t@example.com -c user.name=Test \
    commit --quiet -m "second"
  git -C "$TMP/seed" push --quiet origin main
}

gud()
{
  run "$GUD" "$@"
}

@test "git-update-dirs: --help prints usage and exits 0" {
  gud --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--exclude"* ]]
  [[ "$output" == *"--cleanup"* ]]
}

@test "git-update-dirs: --version prints the version and exits 0" {
  gud --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"version"* ]]
}

@test "git-update-dirs: an unknown option is rejected" {
  gud --frobnicate
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --frobnicate"* ]]
}

@test "git-update-dirs: --exclude requires a directory" {
  gud --exclude
  [ "$status" -eq 1 ]
  [[ "$output" == *"--exclude requires"* ]]
}

@test "git-update-dirs: --log requires a file" {
  gud --log
  [ "$status" -eq 1 ]
  [[ "$output" == *"--log requires"* ]]
}

@test "git-update-dirs: --config requires a file that exists" {
  gud --config "$TMP/no-such.conf"
  [ "$status" -eq 1 ]
  [[ "$output" == *"--config requires"* ]]
}

@test "git-update-dirs: counts the repositories it will update" {
  gud
  [[ "$output" == *"Found 2 git repositories"* ]]
}

@test "git-update-dirs: a directory that is not a repository is not counted" {
  # not-a-repo sits alongside the clones and must not be walked into.
  gud
  [[ "$output" != *"Found 3"* ]]
}

@test "git-update-dirs: pulls new upstream commits" {
  push_upstream
  before=$(git -C "$WORK/repo-a" rev-parse HEAD)
  gud
  after=$(git -C "$WORK/repo-a" rev-parse HEAD)
  [ "$before" != "$after" ]
  [ "$after" = "$(git -C "$TMP/seed" rev-parse HEAD)" ]
}

@test "git-update-dirs: updates every repository, not just the first" {
  push_upstream
  gud
  [ "$(git -C "$WORK/repo-b" rev-parse HEAD)" = "$(git -C "$TMP/seed" rev-parse HEAD)" ]
}

@test "git-update-dirs: reports how many repositories succeeded" {
  gud
  [[ "$output" == *"Summary: Updated 2/2 repositories"* ]]
}

@test "git-update-dirs: --exclude leaves a repository alone" {
  push_upstream
  before=$(git -C "$WORK/repo-b" rev-parse HEAD)
  gud --exclude repo-b
  [[ "$output" == *"Found 1 git repositories"* ]]
  [ "$(git -C "$WORK/repo-b" rev-parse HEAD)" = "$before" ]
}

@test "git-update-dirs: --exclude can be given more than once" {
  gud --exclude repo-a --exclude repo-b
  [[ "$output" == *"Found 0 git repositories"* ]]
}

@test "git-update-dirs: EXCLUDE_DIRS works like --exclude" {
  # --help documents this, but the default assignment used to overwrite the
  # exported value before anything read it, so it did nothing.
  run env EXCLUDE_DIRS="repo-b" "$GUD"
  [[ "$output" == *"Found 1 git repositories"* ]]
}

@test "git-update-dirs: VERBOSE=1 works like --verbose" {
  run env VERBOSE=1 "$GUD"
  [ "$status" -eq 0 ]
}

@test "git-update-dirs: verbose logging does not corrupt the repository count" {
  # The skip messages come from excluded_path, which count_git_repos runs
  # inside a command substitution whose stdout is the count itself. On stdout
  # they end up inside TOTAL, and the progress bar then does arithmetic on a
  # word.
  run --separate-stderr env VERBOSE=1 "$GUD"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found 2 git repositories"* ]]
  [[ "$stderr" == *"Skipping non-git directory"* ]]
}

@test "git-update-dirs: a flag still wins over the environment" {
  run env EXCLUDE_DIRS="repo-b" "$GUD" --exclude repo-a
  [[ "$output" == *"Found 0 git repositories"* ]]
}

@test "git-update-dirs: --quiet prints no summary" {
  gud --quiet
  [ "$status" -eq 0 ]
  [[ "$output" != *"Summary:"* ]]
}

@test "git-update-dirs: --log records what happened" {
  gud --log "$TMP/run.log"
  [ -s "$TMP/run.log" ]
  grep -q 'Started git-update-dirs' "$TMP/run.log"
  grep -q 'Processing repository: repo-a/' "$TMP/run.log"
}

@test "git-update-dirs: --log creates the directory it needs" {
  gud --log "$TMP/nested/deeper/run.log"
  [ -s "$TMP/nested/deeper/run.log" ]
}

@test "git-update-dirs: --config supplies the same options as the flags" {
  printf 'exclude repo-b\n' > "$TMP/conf"
  gud --config "$TMP/conf"
  [[ "$output" == *"Found 1 git repositories"* ]]
}

@test "git-update-dirs: --config ignores comments and blank lines" {
  printf '# a comment\n\nexclude repo-b\n\n' > "$TMP/conf"
  gud --config "$TMP/conf"
  [[ "$output" == *"Found 1 git repositories"* ]]
}

@test "git-update-dirs: --config quiet behaves like --quiet" {
  printf 'quiet\n' > "$TMP/conf"
  gud --config "$TMP/conf"
  [[ "$output" != *"Summary:"* ]]
}

@test "git-update-dirs: skips a branch with no upstream" {
  # A local-only branch has nothing to pull from; pulling would error.
  git -C "$WORK/repo-a" checkout --quiet -b local-only
  gud
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipped"* ]]
}

@test "git-update-dirs: skips a repository with a detached HEAD" {
  git -C "$WORK/repo-a" -c advice.detachedHead=false checkout --quiet --detach
  gud
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipped"* ]]
}

@test "git-update-dirs: a repository with no remote is left alone" {
  git init --quiet -b main "$WORK/orphan"
  printf 'x\n' > "$WORK/orphan/f"
  git -C "$WORK/orphan" add -A
  git -C "$WORK/orphan" -c user.email=t@example.com -c user.name=Test \
    commit --quiet -m only
  gud
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found 3 git repositories"* ]]
}

@test "git-update-dirs: local changes survive the pull" {
  # The pull is --autostash, so uncommitted work is put back afterwards.
  push_upstream
  printf 'work in progress\n' >> "$WORK/repo-a/file.txt"
  gud
  grep -q 'work in progress' "$WORK/repo-a/file.txt"
}

@test "git-update-dirs: --cleanup removes a merged branch" {
  git -C "$WORK/repo-a" branch already-merged
  gud --cleanup
  run ! git -C "$WORK/repo-a" rev-parse --verify --quiet already-merged
}

@test "git-update-dirs: without --cleanup the branch stays" {
  git -C "$WORK/repo-a" branch already-merged
  gud
  git -C "$WORK/repo-a" rev-parse --verify --quiet already-merged
}

@test "git-update-dirs: leaves the caller in the directory it started in" {
  gud
  [ "$(pwd)" = "$WORK" ]
}
