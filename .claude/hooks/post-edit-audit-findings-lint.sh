#!/usr/bin/env bash
# PostToolUse on Edit|Write: validate the structure of
# docs/audit/*-findings.md files. The auditor skills mandate exactly
# one ## Open Findings, ## Fixed, and ## Invalid h2 each. Duplicate
# h2s break tooling that walks the structure (the issue surfaced as
# nitpicker N-064 in this repo).
# Skips fenced code blocks so a finding body can quote a literal
# h2 header without tripping the duplicate detector.
# Receives tool input JSON on stdin.

set -euo pipefail

fp=$(jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] && exit 0

case "$fp" in
  */docs/audit/*-findings.md) ;;
  *) exit 0 ;;
esac

[ -f "$fp" ] || exit 0

# Strip fenced code blocks before counting headers so quoted section
# names inside ``` ... ``` are ignored.
filtered=$(awk '
  /^```/ { in_code = !in_code; next }
  in_code { next }
  { print }
' "$fp")

dups=$(printf '%s\n' "$filtered" | awk '/^## (Open Findings|Fixed|Invalid)$/{print $0}' | sort | uniq -c | awk '$1 > 1 {print}')

if [ -n "$dups" ]; then
  printf 'BLOCKED: duplicate top-level section in %s — each of "## Open Findings", "## Fixed", "## Invalid" must appear at most once.\n' "$fp" >&2
  printf 'Duplicates:\n%s\n' "$dups" >&2
  printf 'Sub-divide passes with "### Pass N — YYYY-MM-DD" h3 headers under a single h2.\n' >&2
  exit 2
fi

exit 0
