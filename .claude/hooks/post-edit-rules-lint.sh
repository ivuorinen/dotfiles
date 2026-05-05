#!/usr/bin/env bash
# PostToolUse on Edit|Write: lint .claude/rules/*.md for hedge
# words that violate the rules-auditor's "unconditional imperatives"
# requirement (try, consider, prefer, might, generally, when possible).
# Skips fenced code blocks and backtick-wrapped tokens so a rule
# can quote a forbidden word without tripping the check.
# Receives tool input JSON on stdin.

set -euo pipefail

fp=$(jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] && exit 0

case "$fp" in
  */.claude/rules/*.md) ;;
  *) exit 0 ;;
esac

[ -f "$fp" ] || exit 0

pattern='\b(try|consider|prefer|might|generally|when possible)\b'

# Strip fenced code blocks (```...```) and inline backtick spans (`...`)
# so quoted forbidden words don't false-positive. Preserve original line
# numbers via blank-line replacement.
filtered=$(awk '
  /^```/ { in_code = !in_code; print ""; next }
  in_code { print ""; next }
  { gsub(/`[^`]*`/, ""); print }
' "$fp")

if hits=$(printf '%s\n' "$filtered" | grep -niE "$pattern"); then
  printf 'BLOCKED: hedge words found in %s — rules in .claude/rules/ must be unconditional imperatives.\n' "$fp" >&2
  printf '%s\n' "$hits" >&2
  printf 'Rewrite the marked lines using "must", "never", "always", or remove the qualification entirely.\n' >&2
  exit 2
fi

exit 0
