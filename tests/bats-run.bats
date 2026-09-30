#!/usr/bin/env bats
# scripts/bats-run.sh wraps the suite run in the pre-commit hook, CI and
# test-all.sh. It must keep bats' exit status and end with one block naming
# every failing test as file:line, plus GitHub annotations under Actions.

setup()
{
  RUN="$BATS_TEST_DIRNAME/../scripts/bats-run.sh"
  FIX="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$FIX"
  cat > "$FIX/sample.bats" << 'EOF'
#!/usr/bin/env bats
helper() { [ "$1" = ok ]; }
@test "passes" { true; }
@test "fails inline, with | pipe" {
  run echo hi
  [ "$output" = bye ]
}
@test "fails in helper" { helper nope; }
EOF
  unset GITHUB_ACTIONS GITHUB_STEP_SUMMARY
}

@test "bats-run: a red run keeps bats' non-zero exit" {
  run "$RUN" "$FIX/sample.bats"
  [ "$status" -ne 0 ]
}

@test "bats-run: a green run exits 0 and prints no summary" {
  run "$RUN" "$FIX/sample.bats" -f passes
  [ "$status" -eq 0 ]
  [[ "$output" != *"failing bats test"* ]]
}

@test "bats-run: the summary names every failure with file:line and assertion" {
  run "$RUN" "$FIX/sample.bats"
  [[ "$output" == *"2 failing bats test(s)"* ]]
  [[ "$output" == *"sample.bats:6  fails inline, with | pipe"* ]]
  [[ "$output" == *'[ "$output" = bye ]'* ]]
}

@test "bats-run: a failure inside a helper points at the test's line" {
  run "$RUN" "$FIX/sample.bats"
  # The helper is on line 2; the test that called it is on line 8.
  [[ "$output" == *"sample.bats:8  fails in helper"* ]]
  [[ "$output" != *"sample.bats:2 "* ]]
}

@test "bats-run: GitHub Actions gets escaped ::error annotations" {
  GITHUB_ACTIONS=true run "$RUN" "$FIX/sample.bats"
  [[ "$output" == *"::error file="*"sample.bats,line=6,title=bats%3A fails inline%2C with | pipe::[ \"\$output\" = bye ]"* ]]
  [[ "$output" == *"line=8,title=bats%3A fails in helper::"* ]]
}

@test "bats-run: GitHub Actions gets a job-summary table" {
  GITHUB_ACTIONS=true GITHUB_STEP_SUMMARY="$BATS_TEST_TMPDIR/summary.md" run "$RUN" "$FIX/sample.bats"
  grep -q '^### 2 failing bats test(s)$' "$BATS_TEST_TMPDIR/summary.md"
  grep -qF '| fails inline, with \| pipe |' "$BATS_TEST_TMPDIR/summary.md"
}

@test "bats-run: no annotations outside GitHub Actions" {
  run "$RUN" "$FIX/sample.bats"
  [[ "$output" != *"::error"* ]]
}

@test "bats-run: a bats abort says no report was written" {
  run "$RUN" "$FIX/does-not-exist.bats"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no TAP report written"* ]]
}
