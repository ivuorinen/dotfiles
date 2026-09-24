#!/usr/bin/env bats
#
# Parity between .claude/rules/vendored-files.md and the three hooks that
# enforce it. The rule's `paths:` frontmatter is the source; each entry must be
# refused by pre-edit-block.sh (Edit), pre-ctx-write-guard.sh (sandbox rm) and
# pre-bash-route.sh (Bash rm).
#
# The lists were hand-kept in four places and drifted repeatedly — one of six
# fzf files blocked (N-091), five fish helpers unprotected (audit-2631ff95),
# graphify protected by no rule (audit-19fe64a4) — with nothing comparing them
# (agent-hooks-0ed7c6cb). Adding a path to the rule without the hooks, or
# dropping one from lib/protected-paths.sh, now fails here.

bats_require_minimum_version 1.5.0

setup()
{
  HOOKS="${BATS_TEST_DIRNAME}/../.claude/hooks"
  RULE="${BATS_TEST_DIRNAME}/../.claude/rules/vendored-files.md"
  REPO=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
  export HOOKS REPO
}

# Print one concrete sample path per `paths:` glob: `**` and `*` become a
# plain file name so the hook sees a real-looking target.
rule_paths()
{
  awk '
    NR == 1 && $0 == "---" { fm = 1; next }
    fm && $0 == "---" { exit }
    fm && /^paths:/ { inpaths = 1; next }
    fm && inpaths && /^[[:space:]]+-/ {
      p = $0
      sub(/^[[:space:]]+-[[:space:]]*/, "", p)
      gsub(/"/, "", p)
      gsub(/\*\*/, "sub/file", p)
      gsub(/\*/, "file", p)
      print p
      next
    }
    fm && /^[^[:space:]]/ { inpaths = 0 }
  ' "$RULE"
}

# Floor at the rule's current size (the graphify skill plus five fish
# functions): a parser that silently drops entries reports fewer and fails.
@test "protected-paths-parity: the rule lists paths to check" {
  [ "$(rule_paths | wc -l)" -ge 6 ]
}

@test "protected-paths-parity: every vendored path is refused by all three hooks" {
  local p failed=""
  while IFS= read -r p; do
    jq -cn --arg fp "$REPO/$p" '{tool_name: "Edit", tool_input: {file_path: $fp}}' \
      | bash "$HOOKS/pre-edit-block.sh" 2> /dev/null && failed+="pre-edit-block: $p"$'\n'

    jq -cn --arg c "rm $p" '{tool_input: {code: $c}}' \
      | bash "$HOOKS/pre-ctx-write-guard.sh" 2> /dev/null && failed+="pre-ctx-write-guard: $p"$'\n'

    jq -cn --arg c "rm $p" '{tool_input: {command: $c}}' \
      | bash "$HOOKS/pre-bash-route.sh" \
      | jq -e '.hookSpecificOutput.permissionDecision == "deny"' > /dev/null \
      || failed+="pre-bash-route: $p"$'\n'
  done < <(rule_paths)
  if [ -n "$failed" ]; then
    printf 'not refused:\n%s' "$failed"
    return 1
  fi
}
