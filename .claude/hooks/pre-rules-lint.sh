#!/usr/bin/env bash
# PreToolUse on Edit|Write|MultiEdit: deny a change to .claude/rules/*.md whose
# resulting content fails lib/rules-lint.sh (hedge words, unknown frontmatter
# keys, non-list `paths:`).
#
# This replaced a PostToolUse hook that printed "BLOCKED" after the file had
# already landed — PostToolUse cannot block, so a hedged rule persisted
# whenever the feedback was ignored (agent-hooks-690ef931). Here the content
# is checked before it is written: Write's `content` as-is, Edit/MultiEdit
# applied to the current file as literal string replacements.
#
# An edit that cannot be applied (old_string absent) is passed through: the
# Edit tool rejects that call itself, so nothing unchecked reaches disk. A temp
# file that cannot be created denies.

set -u

input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2> /dev/null)
case "$fp" in
  */.claude/rules/*.md) ;;
  *) exit 0 ;;
esac

deny()
{
  jq -n --arg why "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $why
    }
  }'
  exit 0
}

tmp=$(mktemp) || deny "rules lint: could not create a temp file; refusing the edit unchecked."
trap 'rm -f "$tmp"' EXIT

current=/dev/null
[[ -f "$fp" ]] && current=$fp

# Literal replacement via split/join: jq's sub/gsub take regexes, and a rule
# file is full of regex metacharacters. A single replacement rejoins the tail
# with the old string so only the first occurrence changes, as Edit does.
if ! printf '%s' "$input" | jq -j --rawfile cur "$current" '
  def apply($s; $e):
    ($s | split($e.old_string)) as $p
    | if ($p | length) < 2 then error("old_string not found")
      elif $e.replace_all then $p | join($e.new_string)
      else $p[0] + $e.new_string + ($p[1:] | join($e.old_string))
      end;
  .tool_input as $t
  | if $t.content != null then $t.content
    elif $t.edits != null then reduce $t.edits[] as $e ($cur; apply(.; $e))
    else apply($cur; $t)
    end
' > "$tmp" 2> /dev/null; then
  exit 0
fi

if ! out=$(RULES_LINT_LABEL="$fp" "$(dirname "${BASH_SOURCE[0]}")/lib/rules-lint.sh" "$tmp"); then
  deny "$(printf '%s\n\nRewrite the flagged lines before writing: rules in .claude/rules/ are unconditional imperatives, and frontmatter takes only `paths` (a list) and `description`.' "$out")"
fi

exit 0
