#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# git-dirty walks a tree and reports which repositories have uncommitted work.
# The fixture is a throwaway tree of real repositories — a bare repo on disk
# stands in for the remote, so the unpushed-commit check works without a
# network. XDG_CONFIG_HOME points into the fixture as well, otherwise the
# user's own git-dirty config would be sourced and could change every result.

setup()
{
  GD="$BATS_TEST_DIRNAME/../local/bin/git-dirty"
  TMP="$(mktemp -d)"
  TREE="$TMP/tree"
  mkdir -p "$TREE" "$TMP/config"
  export GIT_CONFIG_GLOBAL=/dev/null
  export GIT_CONFIG_SYSTEM=/dev/null
  export XDG_CONFIG_HOME="$TMP/config"

  # A repository on main with one pushed commit and nothing else. Each gets
  # its own bare remote: sharing one would leave the second clone already
  # holding the first's file, and its commit would be empty.
  make_repo()
  {
    local name="$1"
    git init --quiet --bare -b main "$TMP/origin-$name"
    git init --quiet -b main "$TREE/$name"
    git -C "$TREE/$name" remote add origin "$TMP/origin-$name"
    printf 'content\n' > "$TREE/$name/tracked.txt"
    git -C "$TREE/$name" add tracked.txt
    git -C "$TREE/$name" -c user.email=t@example.com -c user.name=Test \
      commit --quiet -m "commit in $name"
    git -C "$TREE/$name" push --quiet -u origin main
  }

  make_repo clean-repo
  make_repo modified-repo
  make_repo staged-repo
  make_repo untracked-repo
  make_repo branch-repo

  printf 'changed\n' >> "$TREE/modified-repo/tracked.txt"
  printf 'changed\n' >> "$TREE/staged-repo/tracked.txt"
  git -C "$TREE/staged-repo" add tracked.txt
  printf 'new\n' > "$TREE/untracked-repo/extra.txt"
  git -C "$TREE/branch-repo" checkout --quiet -b feature/work

  mkdir -p "$TREE/plain-dir" "$TREE/node_modules"
}

teardown()
{
  rm -rf "$TMP"
}

gd()
{
  run "$GD" "$@"
}

@test "git-dirty: -h prints usage and exits 0" {
  gd -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Status indicators"* ]]
  [[ "$output" == *"-e PATTERNS"* ]]
}

@test "git-dirty: an invalid option is rejected" {
  gd -Z "$TREE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid option"* ]]
}

@test "git-dirty: an option that needs a value says so" {
  gd -d
  [ "$status" -eq 1 ]
  [[ "$output" == *"requires an argument"* ]]
}

@test "git-dirty: a directory that does not exist is an error" {
  gd "$TMP/no-such-dir"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Directory does not exist"* ]]
}

@test "git-dirty: names the directory it is checking" {
  gd "$TREE"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Checking repositories in: $TREE"* ]]
}

@test "git-dirty: a clean repository is marked clean" {
  gd "$TREE"
  printf '%s\n' "$output" | grep 'clean-repo' | grep -q '✅'
}

@test "git-dirty: a repository with modified files is marked dirty" {
  gd "$TREE"
  printf '%s\n' "$output" | grep 'modified-repo' | grep -q '❌'
}

@test "git-dirty: modified and staged changes get different letters" {
  gd "$TREE"
  printf '%s\n' "$output" | grep 'modified-repo' | grep -q 'M'
  printf '%s\n' "$output" | grep 'staged-repo' | grep -q 'S'
}

@test "git-dirty: untracked files count as dirty by default" {
  gd "$TREE"
  printf '%s\n' "$output" | grep 'untracked-repo' | grep -q '?'
}

@test "git-dirty: untracked reporting can be turned off" {
  run env GIT_DIRTY_CHECK_UNTRACKED=0 "$GD" "$TREE"
  printf '%s\n' "$output" | grep 'untracked-repo' | grep -q '✅'
}

@test "git-dirty: a stash is only reported with -a" {
  printf 'wip\n' >> "$TREE/clean-repo/tracked.txt"
  git -C "$TREE/clean-repo" -c user.email=t@example.com -c user.name=Test \
    stash --quiet
  gd "$TREE"
  printf '%s\n' "$output" | grep 'clean-repo' | grep -q '✅'
  gd -a "$TREE"
  printf '%s\n' "$output" | grep 'clean-repo' | grep -q '\$'
}

@test "git-dirty: an unpushed commit is reported" {
  printf 'more\n' >> "$TREE/clean-repo/tracked.txt"
  git -C "$TREE/clean-repo" add -A
  git -C "$TREE/clean-repo" -c user.email=t@example.com -c user.name=Test \
    commit --quiet -m "not pushed"
  gd "$TREE"
  printf '%s\n' "$output" | grep 'clean-repo' | grep -q '↑'
}

@test "git-dirty: a non-main branch name is shown" {
  gd "$TREE"
  printf '%s\n' "$output" | grep 'branch-repo' | grep -q 'feature/work'
}

@test "git-dirty: a main branch name is not shown" {
  # Every repository would otherwise be annotated with the same word.
  gd "$TREE"
  printf '%s\n' "$output" | grep 'clean-repo' | grep -qv '(main)'
}

@test "git-dirty: -b turns the branch name off" {
  gd -b "$TREE"
  printf '%s\n' "$output" | grep 'branch-repo' | grep -qv 'feature/work'
}

@test "git-dirty: node_modules is not walked into" {
  gd "$TREE"
  [[ "$output" != *"node_modules"* ]]
}

@test "git-dirty: -e excludes an extra directory" {
  mkdir -p "$TREE/scratch"
  git init --quiet -b main "$TREE/scratch/inner"
  gd -e scratch "$TREE"
  [[ "$output" != *"scratch"* ]]
}

@test "git-dirty: a directory holding an .ignore file is skipped" {
  mkdir -p "$TREE/skipme"
  touch "$TREE/skipme/.ignore"
  git init --quiet -b main "$TREE/skipme/inner"
  gd "$TREE"
  [[ "$output" != *"skipme"* ]]
}

@test "git-dirty: GIT_DIRTY_DIR is used when no directory is given" {
  run env GIT_DIRTY_DIR="$TREE" "$GD"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Checking repositories in: $TREE"* ]]
}

@test "git-dirty: an argument beats GIT_DIRTY_DIR" {
  mkdir -p "$TMP/other"
  run env GIT_DIRTY_DIR="$TMP/other" "$GD" "$TREE"
  [[ "$output" == *"Checking repositories in: $TREE"* ]]
}

@test "git-dirty: the config file can change the defaults" {
  mkdir -p "$XDG_CONFIG_HOME/git-dirty"
  printf 'GIT_DIRTY_CHECK_UNTRACKED=0\n' > "$XDG_CONFIG_HOME/git-dirty/config"
  gd "$TREE"
  printf '%s\n' "$output" | grep 'untracked-repo' | grep -q '✅'
}

@test "git-dirty: writes no colour codes when the output is not a terminal" {
  # Redirected output is read by other programs as often as by people.
  gd "$TREE"
  run ! grep -q $'\033' <<< "$output"
}

@test "git-dirty: reports every repository in the tree" {
  gd "$TREE"
  for repo in clean-repo modified-repo staged-repo untracked-repo branch-repo; do
    [[ "$output" == *"$repo"* ]] || {
      echo "missing repository: $repo"
      return 1
    }
  done
}

@test "git-dirty: finds a repository nested below the top level" {
  mkdir -p "$TREE/group"
  git init --quiet -b main "$TREE/group/nested-repo"
  gd "$TREE"
  [[ "$output" == *"nested-repo"* ]]
}

@test "git-dirty: -m limits how deep it goes" {
  mkdir -p "$TREE/a/b/c"
  git init --quiet -b main "$TREE/a/b/c/deep-repo"
  gd -m 2 "$TREE"
  [[ "$output" != *"deep-repo"* ]]
}
