#!/usr/bin/env bats

# git-fsck-dirs walks one level of a tree and runs git fsck in each entry.
#
# The scratch files it takes as arguments are deleted before it returns, so
# they are not an observable surface — the contract is the summary counts and
# the exit code. An earlier draft of this file asserted on those files and
# "passed" three tests only because grep failed on a missing path.
#
# git is stubbed to force a fsck verdict without building corrupt object
# stores. The script is standalone, so a prepended PATH is honoured.

setup()
{
  FSCK="$BATS_TEST_DIRNAME/../local/bin/git-fsck-dirs"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  # fsck fails only for a repository whose path contains "bad".
  cat > "$TMP/bin/git" << 'STUB'
#!/usr/bin/env bash
target=""
for arg in "$@"; do
  case "$arg" in /*) target="$arg" ;; esac
done
case "$*" in
  *fsck*)
    case "$target" in
      *bad*) echo "error: broken link"; exit 1 ;;
      *) echo "notice: harmless chatter"; exit 0 ;;
    esac
    ;;
esac
exit 0
STUB
  chmod +x "$TMP/bin/git"
}

teardown()
{
  rm -rf "$TMP"
}

fsck()
{
  run env PATH="$TMP/bin:$PATH" "$FSCK" "$1" "$TMP/err.txt" "$TMP/repos.txt"
}

@test "git-fsck-dirs: a tree of healthy repositories passes" {
  mkdir -p "$TMP/tree/repo-a/.git" "$TMP/tree/repo-b/.git"
  fsck "$TMP/tree"
  [ "$status" -eq 0 ]
  [[ "$output" == *"All repositories passed"* ]]
}

@test "git-fsck-dirs: counts the repositories it checked" {
  mkdir -p "$TMP/tree/repo-a/.git" "$TMP/tree/repo-b/.git"
  fsck "$TMP/tree"
  [[ "$output" == *"Checked 2 repositories from 2 directories"* ]]
}

@test "git-fsck-dirs: notice lines alone do not fail a repository" {
  # The stub emits `notice:` for healthy repos; the script filters those out.
  # Without that filter every repository would be reported as broken.
  mkdir -p "$TMP/tree/repo-a/.git"
  fsck "$TMP/tree"
  [ "$status" -eq 0 ]
}

@test "git-fsck-dirs: a repository failing fsck is reported and exits 1" {
  mkdir -p "$TMP/tree/repo-bad/.git"
  fsck "$TMP/tree"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Found issues in 1 repositories"* ]]
}

@test "git-fsck-dirs: a failing repository is still counted as checked" {
  mkdir -p "$TMP/tree/repo-bad/.git"
  fsck "$TMP/tree"
  [[ "$output" == *"Checked 1 repositories"* ]]
}

@test "git-fsck-dirs: a directory with no .git counts as an issue" {
  mkdir -p "$TMP/tree/plain"
  fsck "$TMP/tree"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Found issues in 1 repositories"* ]]
}

@test "git-fsck-dirs: a directory with no .git is not counted as a repository" {
  mkdir -p "$TMP/tree/plain" "$TMP/tree/repo-a/.git"
  fsck "$TMP/tree"
  [[ "$output" == *"Checked 1 repositories from 2 directories"* ]]
}

@test "git-fsck-dirs: does not descend past one level" {
  mkdir -p "$TMP/tree/repo-a/.git" "$TMP/tree/repo-a/nested/.git"
  fsck "$TMP/tree"
  [[ "$output" == *"from 1 directories"* ]]
}

@test "git-fsck-dirs: VERBOSE names each directory processed" {
  mkdir -p "$TMP/tree/repo-a/.git"
  run env PATH="$TMP/bin:$PATH" VERBOSE=1 "$FSCK" "$TMP/tree" "$TMP/err.txt" "$TMP/repos.txt"
  [[ "$output" == *"Processing:"* ]]
}

@test "git-fsck-dirs: quiet by default" {
  mkdir -p "$TMP/tree/repo-a/.git"
  fsck "$TMP/tree"
  [[ "$output" != *"Processing:"* ]]
}

@test "git-fsck-dirs: a missing starting directory is refused" {
  fsck "$TMP/no-such-tree"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "git-fsck-dirs: cleans up its scratch files" {
  mkdir -p "$TMP/tree/repo-a/.git"
  fsck "$TMP/tree"
  [ ! -f "$TMP/err.txt" ]
  [ ! -f "$TMP/repos.txt" ]
}
