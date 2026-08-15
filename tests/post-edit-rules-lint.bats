#!/usr/bin/env bats
#
# Coverage for .claude/hooks/post-edit-rules-lint.sh — the PostToolUse gate
# that keeps .claude/rules/*.md free of hedge words, so rules stay
# unconditional imperatives.
#
# The interesting half is what it does NOT flag: a rule has to be able to
# quote a forbidden word while forbidding it. Both escapes (fenced blocks and
# inline backticks) are pinned here, because a regression in the awk filter
# would make the rule files unwritable rather than merely noisy.

bats_require_minimum_version 1.5.0

setup()
{
  HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/post-edit-rules-lint.sh"
  WORK="$(mktemp -d)"
  # The guard only inspects paths matching */.claude/rules/*.md, so the
  # fixture has to reproduce that shape rather than sit in a bare tmpdir.
  mkdir -p "$WORK/.claude/rules"
  export HOOK WORK
}

teardown()
{
  rm -rf "$WORK"
}

# Write a rule file with the given body, then run the hook against it.
lint_rule()
{
  local body="$1" name="${2:-sample.md}"
  printf '%s\n' "$body" > "$WORK/.claude/rules/$name"
  jq -cn --arg fp "$WORK/.claude/rules/$name" \
    '{tool_input: {file_path: $fp}}' | bash "$HOOK"
}

@test "post-edit-rules-lint: blocks each hedge word" {
  for w in try consider prefer might generally should; do
    run -2 lint_rule "You $w to route through ctx_batch_execute."
    [[ "$output" == *"hedge words found"* ]]
  done
  run -2 lint_rule 'Use the sandbox when possible.'
}

@test "post-edit-rules-lint: reports the offending line number" {
  run -2 lint_rule "$(printf 'Always route through the sandbox.\nYou should not guess.\n')"
  [[ "$output" == *"2:"* ]]
}

@test "post-edit-rules-lint: an unconditional rule passes" {
  run -0 lint_rule "$(printf 'ALWAYS use ctx_batch_execute for shell commands.\nNever bypass the hook chain.\n')"
}

# A rule that forbids a word must be able to name it. Inline backticks are the
# documented escape.
@test "post-edit-rules-lint: a backticked hedge word is quoted, not used" {
  run -0 lint_rule 'Banned hedges: `try`, `consider`, `should`.'
}

# Same for fenced blocks — rule files carry shell and python snippets that
# legitimately contain these words.
@test "post-edit-rules-lint: hedge words inside a fenced block are ignored" {
  run -0 lint_rule "$(printf 'Run the check.\n\n```bash\n# you should run this first\ntry_again() { :; }\n```\n\nNever skip it.\n')"
}

@test "post-edit-rules-lint: a hedge after a closed fence is still caught" {
  run -2 lint_rule "$(printf '```bash\n# should is fine in here\n```\n\nYou should not do this.\n')"
}

# Scoped to the rules directory: ordinary markdown is prose and may hedge.
@test "post-edit-rules-lint: ignores markdown outside .claude/rules" {
  printf 'You should probably read this.\n' > "$WORK/README.md"
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/README.md" "$HOOK"
}

@test "post-edit-rules-lint: a missing file or empty payload passes" {
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/.claude/rules/absent.md" "$HOOK"
  run -0 bash -c 'printf "{}" | bash "$1"' _ "$HOOK"
}
