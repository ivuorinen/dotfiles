#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# git-attributes reports tracked files that only match a catch-all
# .gitattributes rule and suggests specific ones. The tests build a throwaway
# repository rather than running against this one, so the expected output is
# fixed instead of following whatever this repo currently tracks.
#
# "Missing" means git check-attr reports `text: auto` for a file — it matched
# `* text=auto` and nothing more specific.

setup()
{
  GA="$BATS_TEST_DIRNAME/../local/bin/git-attributes"
  TMP="$(mktemp -d)"
  REPO="$TMP/repo"
  mkdir -p "$REPO"
  export GIT_CONFIG_GLOBAL=/dev/null
  export GIT_CONFIG_SYSTEM=/dev/null
  git -C "$REPO" init --quiet
  printf 'print("hi")\n' > "$REPO/main.py"
  printf '# Notes\n' > "$REPO/notes.md"
  printf '#!/usr/bin/env bash\necho hi\n' > "$REPO/deploy"
  cat > "$REPO/.gitattributes" << 'EOF'
* text=auto
*.py text eol=lf
EOF
  git -C "$REPO" add -A
  git -C "$REPO" -c user.email=t@example.com -c user.name=Test \
    commit --quiet -m "initial"
  cd "$REPO" || return 1
}

teardown()
{
  rm -rf "$TMP"
}

ga()
{
  run "$GA" "$@"
}

@test "git-attributes: --help prints usage and exits 0" {
  ga --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--write"* ]]
  [[ "$output" == *"--no-suggest"* ]]
}

@test "git-attributes: an unknown option is rejected" {
  ga --frobnicate
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --frobnicate"* ]]
}

@test "git-attributes: --format-width requires a number" {
  ga --format-width wide
  [ "$status" -eq 1 ]
  [[ "$output" == *"requires a numeric argument"* ]]
}

@test "git-attributes: refuses to run outside a repository" {
  cd "$TMP" || return 1
  ga
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not inside a git repository"* ]]
}

@test "git-attributes: refuses to run outside the repository root" {
  # The suggestions it writes are anchored at the root, so running from a
  # subdirectory would put them in the wrong place.
  mkdir -p "$REPO/src"
  cd "$REPO/src" || return 1
  ga
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not in git repository root"* ]]
  [[ "$output" == *"$REPO"* ]]
}

@test "git-attributes: refuses to run without a .gitattributes" {
  rm "$REPO/.gitattributes"
  ga
  [ "$status" -eq 1 ]
  [[ "$output" == *".gitattributes file not found"* ]]
}

@test "git-attributes: reports files that only match the catch-all rule" {
  ga
  [[ "$output" == *"Missing .gitattributes rules detected"* ]]
}

@test "git-attributes: says nothing is missing when every file is covered" {
  printf '* text\n' > "$REPO/.gitattributes"
  git -C "$REPO" add .gitattributes
  ga
  [ "$status" -eq 0 ]
  [[ "$output" == *"All files have a corresponding rule"* ]]
}

@test "git-attributes: a file with its own rule is not reported" {
  # main.py matches "*.py text eol=lf", so it is covered.
  ga --no-suggest
  [[ "$output" != *"main.py"* ]]
}

@test "git-attributes: --no-suggest lists the files instead of rules" {
  ga --no-suggest
  [[ "$output" == *"rule missing for the following files"* ]]
  [[ "$output" == *"notes.md"* ]]
}

@test "git-attributes: suggests a rule for the extension it found" {
  ga
  [[ "$output" == *"*.md"* ]]
}

@test "git-attributes: suggests a rule for an extensionless shell script" {
  # deploy has no extension; only its shebang says what it is.
  ga
  [[ "$output" == *"deploy"* ]]
}

@test "git-attributes: exits 0 by default even with findings" {
  # Reporting is the default; failing the shell is opt-in, so this stays
  # usable interactively without `|| true`.
  ga
  [ "$status" -eq 0 ]
}

@test "git-attributes: --exit fails the shell when something is missing" {
  ga --exit
  [ "$status" -ne 0 ]
}

@test "git-attributes: --exit still succeeds when nothing is missing" {
  printf '* text\n' > "$REPO/.gitattributes"
  git -C "$REPO" add .gitattributes
  ga --exit
  [ "$status" -eq 0 ]
}

@test "git-attributes: --write appends the suggestions to .gitattributes" {
  before=$(wc -l < "$REPO/.gitattributes")
  ga --write
  after=$(wc -l < "$REPO/.gitattributes")
  [ "$after" -gt "$before" ]
  grep -q '\*\.md' "$REPO/.gitattributes"
}

@test "git-attributes: --write writes rules, not log output" {
  # The suggestions are read through a command substitution, so anything the
  # logging helpers put on stdout is appended to the file verbatim — colour
  # escapes and progress lines included.
  ga --write
  run ! grep -q $'\033' "$REPO/.gitattributes"
  run ! grep -q 'Detecting shell scripts' "$REPO/.gitattributes"
  run ! grep -q 'Suggested .gitattributes rules' "$REPO/.gitattributes"
}

@test "git-attributes: --write does not need --verbose to do anything" {
  # check_gitattributes logs a debug line just before calling the writer. A
  # quiet msg_debug returns non-zero, and under `set -e` that ended the run
  # there, so the file was only ever written when --verbose was also passed.
  ga --write
  [ "$status" -eq 0 ]
  grep -q '\*\.md' "$REPO/.gitattributes"
}

@test "git-attributes: --write keeps the rules that were already there" {
  ga --write
  grep -q '^\* text=auto' "$REPO/.gitattributes"
  grep -q '\*\.py text eol=lf' "$REPO/.gitattributes"
}

@test "git-attributes: without --write the file is left alone" {
  before=$(cat "$REPO/.gitattributes")
  ga
  [ "$(cat "$REPO/.gitattributes")" = "$before" ]
}

@test "git-attributes: --verbose explains what it is doing" {
  ga --verbose
  [ "${#output}" -gt 0 ]
  [[ "$output" == *"Checking for pattern"* ]]
}

@test "git-attributes: --pattern changes what counts as missing" {
  # With a pattern no check-attr line can contain, nothing is ever reported.
  ga --pattern "no-such-attribute: value"
  [ "$status" -eq 0 ]
  [[ "$output" == *"All files have a corresponding rule"* ]]
}
