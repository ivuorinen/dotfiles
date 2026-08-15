#!/usr/bin/env bats
#
# Coverage for .claude/hooks/stop-lint-gate.sh — the Stop hook that runs
# `yarn lint` before a turn may finish, and returns exit 2 to push failures
# back into the conversation.
#
# yarn, mise and corepack are all stubbed. Running the real chain here would
# take minutes and would test yarn rather than the gate, and the branches
# worth pinning are the failure paths: a gate that exits 0 on a broken lint is
# indistinguishable from a passing one until something ships.

bats_require_minimum_version 1.5.0

setup()
{
  HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/stop-lint-gate.sh"
  WORK="$(mktemp -d)"
  mkdir -p "$WORK/bin" "$WORK/repo"
  export HOOK WORK
}

teardown()
{
  rm -rf "$WORK"
}

# Build a yarn stub whose `lint` prints $1 and exits $2. `install` always
# succeeds unless install_rc is set. PATH holds only the stub dir, so the
# hook's mise and corepack probes both miss and it falls through to plain
# `yarn` — the path a CI box without mise would take.
stub_yarn()
{
  local lint_output="$1" lint_rc="$2" install_rc="${3:-0}"
  cat > "$WORK/bin/yarn" << EOF
#!/usr/bin/env bash
case "\$1" in
  --version) echo "4.17.1" ;;
  install) exit $install_rc ;;
  lint) printf '%s\n' "$lint_output"; exit $lint_rc ;;
  *) exit 0 ;;
esac
EOF
  chmod +x "$WORK/bin/yarn"
}

gate()
{
  env -i PATH="$WORK/bin:/usr/bin:/bin" HOME="$WORK" \
    CLAUDE_PROJECT_DIR="$WORK/repo" bash "$HOOK"
}

@test "stop-lint-gate: passes a clean lint" {
  stub_yarn "No issues found." 0
  run -0 gate
}

# Exit 2 is the contract: it feeds the output back and keeps Claude working.
# Any other non-zero would end the turn with the failure unaddressed.
@test "stop-lint-gate: fails a dirty lint with exit 2 and the output" {
  stub_yarn "src/foo.ts:1:1 lint/style/useConst  FIXABLE" 1
  run -2 gate
  [[ "$output" == *"Lint failed"* ]]
  [[ "$output" == *"useConst"* ]]
}

# editorconfig-checker downloads its binary on first run; a GitHub rate limit
# is an environment failure, not a code failure, and the message has to say so
# or the reader hunts a lint error that does not exist.
@test "stop-lint-gate: names the rate limit as the cause when that is the cause" {
  stub_yarn "ec: Failed to download binary: HttpError: API rate limit exceeded" 1
  run -2 gate
  [[ "$output" == *"rate-limited"* ]]
  [[ "$output" != *"Lint failed — fix before finishing"* ]]
}

@test "stop-lint-gate: a failed install aborts before linting" {
  stub_yarn "unreachable" 0 1
  run -2 gate
  [[ "$output" == *"yarn install failed"* ]]
  # The lint must not have run — its output would be misleading noise.
  [[ "$output" != *"unreachable"* ]]
}

# The hook cd's to CLAUDE_PROJECT_DIR and exits 0 if that fails, rather than
# blocking every turn on a misconfigured environment.
@test "stop-lint-gate: an unusable project dir does not wedge the turn" {
  run -0 env -i PATH="$WORK/bin:/usr/bin:/bin" HOME="$WORK" \
    CLAUDE_PROJECT_DIR="$WORK/nonexistent" bash "$HOOK"
}
