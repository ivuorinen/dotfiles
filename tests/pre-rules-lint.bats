#!/usr/bin/env bats
#
# Coverage for .claude/hooks/pre-rules-lint.sh and lib/rules-lint.sh — the
# PreToolUse gate on .claude/rules/*.md. It replaced a PostToolUse hook that
# printed BLOCKED after the edit had landed (agent-hooks-690ef931), and adds
# the frontmatter-key check whose absence let `globs:` and `alwaysApply:`
# recur (agent-hooks-ded55f17).

bats_require_minimum_version 1.5.0

setup()
{
  HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/pre-rules-lint.sh"
  LINT="${BATS_TEST_DIRNAME}/../.claude/hooks/lib/rules-lint.sh"
  RULES="$BATS_TEST_TMPDIR/.claude/rules"
  mkdir -p "$RULES"
  export HOOK LINT RULES
}

# write_decision PATH CONTENT — decision for a Write of CONTENT to PATH.
# No stdout is the no-decision case; jq given no input prints nothing, so the
# `// "allow"` fallback cannot cover it.
write_decision()
{
  local out
  out=$(jq -cn --arg fp "$1" --arg c "$2" '{tool_name: "Write", tool_input: {file_path: $fp, content: $c}}' \
    | bash "$HOOK")
  if [ -z "$out" ]; then
    printf 'allow'
    return 0
  fi
  printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "allow"'
}

@test "pre-rules-lint: a hedged Write is denied before it lands" {
  [ "$(write_decision "$RULES/x.md" $'# X\n\nTry to run the tests.\n')" = "deny" ]
  [ ! -e "$RULES/x.md" ]
}

@test "pre-rules-lint: each hedge word is caught" {
  for w in try consider prefer might generally 'when possible' should; do
    [ "$(write_decision "$RULES/x.md" "# X"$'\n\n'"You $w do it."$'\n')" = "deny" ]
  done
}

@test "pre-rules-lint: an unconditional rule passes" {
  [ "$(write_decision "$RULES/x.md" $'---\ndescription: "x"\npaths:\n  - "a/**"\n---\n\n# X\n\nAlways run the tests.\n')" = "allow" ]
}

@test "pre-rules-lint: quoted hedge words in backticks or fences are ignored" {
  [ "$(write_decision "$RULES/x.md" $'# X\n\nNever write `try`.\n\n```\nshould\n```\n')" = "allow" ]
}

@test "pre-rules-lint: unknown frontmatter keys and non-list paths are denied" {
  [ "$(write_decision "$RULES/x.md" $'---\nglobs: ["*.md"]\n---\n\n# X\n')" = "deny" ]
  [ "$(write_decision "$RULES/x.md" $'---\nalwaysApply: true\n---\n\n# X\n')" = "deny" ]
  [ "$(write_decision "$RULES/x.md" $'---\npaths: "*.md"\n---\n\n# X\n')" = "deny" ]
  [ "$(write_decision "$RULES/x.md" $'---\npaths: ["*.md"]\n---\n\n# X\n')" = "allow" ]
}

@test "pre-rules-lint: an Edit is checked against the resulting file" {
  printf '# X\n\nAlways run the tests.\n' > "$RULES/y.md"
  run bash -c 'jq -cn --arg fp "$1" "{tool_name: \"Edit\", tool_input: {file_path: \$fp, old_string: \"Always\", new_string: \"Try to\"}}" | bash "$2"' _ "$RULES/y.md" "$HOOK"
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "deny" ]
  run bash -c 'jq -cn --arg fp "$1" "{tool_name: \"Edit\", tool_input: {file_path: \$fp, old_string: \"tests\", new_string: \"suite\"}}" | bash "$2"' _ "$RULES/y.md" "$HOOK"
  [ -z "$output" ]
}

@test "pre-rules-lint: files outside .claude/rules are ignored" {
  [ "$(write_decision "$BATS_TEST_TMPDIR/README.md" 'You should try.')" = "allow" ]
}

@test "rules-lint: every committed rule file passes" {
  run "$LINT" "${BATS_TEST_DIRNAME}"/../.claude/rules/*.md
  [ "$status" -eq 0 ] || {
    printf '%s\n' "$output"
    return 1
  }
}
