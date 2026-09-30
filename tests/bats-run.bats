#!/usr/bin/env bats
# scripts/bats-run.sh wraps the suite run in the pre-commit hook, CI and
# test-all.sh. It must keep bats' exit status and end with one block naming
# every failing test as file:line, plus GitHub annotations under Actions.

setup()
{
  RUN="$BATS_TEST_DIRNAME/../scripts/bats-run.sh"
  FIX="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$FIX"
  # printf, not a heredoc: bats 1.10 (Ubuntu's apt package) preprocesses any
  # line starting with `@test`, even inside a heredoc, so a heredoc fixture
  # became three extra tests of this file and a mangled sample.bats.
  printf '%s\n' \
    '#!/usr/bin/env bats' \
    'helper() { [ "$1" = ok ]; }' \
    '@test "passes" { true; }' \
    '@test "fails inline, with | pipe" {' \
    '  run echo hi' \
    '  [ "$output" = bye ]' \
    '}' \
    '@test "fails in helper" { helper nope; }' \
    > "$FIX/sample.bats"
  unset GITHUB_ACTIONS GITHUB_STEP_SUMMARY
}

# run_wrapper [NAME=VALUE...] <command> [args...] — `run` with per-call
# environment, so GitHub Actions variables reach only the call that sets them.
run_wrapper()
{
  run env "$@"
}

@test "bats-run: a red run keeps bats' non-zero exit" {
  run_wrapper "$RUN" "$FIX/sample.bats"
  [ "$status" -ne 0 ]
}

@test "bats-run: a green run exits 0 and prints no summary" {
  run_wrapper "$RUN" "$FIX/sample.bats" -f passes
  [ "$status" -eq 0 ]
  [[ "$output" != *"failing bats test"* ]]
}

@test "bats-run: the summary names every failure with file:line and assertion" {
  run_wrapper "$RUN" "$FIX/sample.bats"
  [[ "$output" == *"2 failing bats test(s)"* ]]
  [[ "$output" == *"sample.bats:6  fails inline, with | pipe"* ]]
  [[ "$output" == *'[ "$output" = bye ]'* ]]
}

@test "bats-run: a failure inside a helper points at the test's line" {
  run_wrapper "$RUN" "$FIX/sample.bats"
  # The helper is on line 2; the test that called it is on line 8.
  [[ "$output" == *"sample.bats:8  fails in helper"* ]]
  [[ "$output" != *"sample.bats:2 "* ]]
}

@test "bats-run: GitHub Actions gets escaped ::error annotations" {
  run_wrapper GITHUB_ACTIONS=true "$RUN" "$FIX/sample.bats"
  [[ "$output" == *"::error file="*"sample.bats,line=6,title=bats%3A fails inline%2C with | pipe::[ \"\$output\" = bye ]"* ]]
  [[ "$output" == *"line=8,title=bats%3A fails in helper::"* ]]
}

@test "bats-run: GitHub Actions gets a job-summary table" {
  run_wrapper GITHUB_ACTIONS=true GITHUB_STEP_SUMMARY="$BATS_TEST_TMPDIR/summary.md" "$RUN" "$FIX/sample.bats"
  grep -q '^### 2 failing bats test(s)$' "$BATS_TEST_TMPDIR/summary.md"
  grep -qF '| fails inline, with \| pipe |' "$BATS_TEST_TMPDIR/summary.md"
}

@test "bats-run: no annotations outside GitHub Actions" {
  run_wrapper "$RUN" "$FIX/sample.bats"
  [[ "$output" != *"::error"* ]]
}

@test "bats-run: a bats abort says no report was written" {
  run_wrapper "$RUN" "$FIX/does-not-exist.bats"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no TAP report written"* ]]
}
