#!/usr/bin/env bash
# PostToolUse on Edit|Write: structural validation for docs/audit/*-findings.md.
# Checks:
#   0. Header block: only Generated / Last validated / Last pass (N (YYYY-MM-DD)) allowed.
#   1. No duplicate h2 section headers (## Open Findings / ## Fixed / ## Invalid).
#   2. "## Advisory" must not appear at h2 level — it must be "### Advisory" under
#      "## Open Findings".
#   3. No h2→h4 heading gaps (every #### must have a ### parent in the same section).
#   4. Every open finding must carry all six required fields:
#      Category, Area, Problem, Evidence, Impact, Fix.
# On success: regenerates .claude/nitpicker-status.json from the file's metadata.
# Receives tool input JSON on stdin.

set -euo pipefail

fp=$(jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] && exit 0

case "$fp" in
  */docs/audit/*-findings.md) ;;
  *) exit 0 ;;
esac

[ -f "$fp" ] || exit 0

fail=0

# Strip fenced code blocks before structural checks so quoted section names
# inside ``` ... ``` do not false-positive.
filtered=$(awk '
  /^```/ { in_code = !in_code; next }
  in_code { next }
  { print }
' "$fp")

# 0. Header block must contain only Generated / Last validated / Last pass
printf '%s\n' "$filtered" | awk '
  BEGIN { in_header = 1; errors = 0 }
  /^# Nitpicker Findings/ { next }
  /^## / { in_header = 0; next }
  !in_header { next }
  /^$/ { next }
  /^Generated: [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ { has_gen = 1; next }
  /^Last validated: [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ { has_lv = 1; next }
  /^Last pass: [0-9]+ \([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)$/ { has_lp = 1; next }
  {
    printf "BLOCKED: unexpected header line %d: %s\n", NR, $0 > "/dev/stderr"
    errors++
  }
  END {
    if (!has_gen) { print "BLOCKED: header missing \"Generated: YYYY-MM-DD\"" > "/dev/stderr"; errors++ }
    if (!has_lv)  { print "BLOCKED: header missing \"Last validated: YYYY-MM-DD\"" > "/dev/stderr"; errors++ }
    if (!has_lp)  { print "BLOCKED: header missing \"Last pass: N (YYYY-MM-DD)\"" > "/dev/stderr"; errors++ }
    if (errors > 0) exit 2
  }
' || fail=1

# 1. No duplicate top-level section headers
dups=$(printf '%s\n' "$filtered" \
  | awk '/^## (Open Findings|Fixed|Invalid)$/ { print }' \
  | sort | uniq -c | awk '$1 > 1 { print }')

if [ -n "$dups" ]; then
  printf 'BLOCKED: duplicate top-level section in %s.\n' "$fp" >&2
  printf 'Each of "## Open Findings", "## Fixed", "## Invalid" must appear at most once.\n' >&2
  printf 'Sub-divide passes with "### Pass N — YYYY-MM-DD" h3 headers under a single h2.\n' >&2
  printf '%s\n' "$dups" >&2
  fail=1
fi

# 2. ## Advisory must not appear as h2
if printf '%s\n' "$filtered" | grep -q '^## Advisory'; then
  printf 'BLOCKED: "## Advisory" found at h2 level in %s.\n' "$fp" >&2
  printf 'Advisory is a severity level — use "### Advisory" under "## Open Findings".\n' >&2
  printf '%s\n' "$filtered" | grep -n '^## Advisory' >&2
  fail=1
fi

# 3. h2→h4 gap: an #### with no ### between it and the preceding ##
printf '%s\n' "$filtered" | awk '
  /^## /   { last_h2 = NR; last_h3 = 0 }
  /^### /  { last_h3 = NR }
  /^#### / {
    if (last_h2 > 0 && last_h3 < last_h2) {
      printf "BLOCKED: line %d: h4 heading has no h3 parent (## at line %d)\n  %s\n",
        NR, last_h2, $0 > "/dev/stderr"
      exit 2
    }
  }
' || fail=1

# 4. Every open finding must carry all six required fields
printf '%s\n' "$filtered" | awk '
  BEGIN { in_open = 0; id = ""; errors = 0 }

  /^## Open Findings/ { in_open = 1; next }
  /^## (Fixed|Invalid)/ {
    if (in_open && id != "") check()
    in_open = 0
    next
  }

  !in_open { next }

  /^#### \[/ {
    if (id != "") check()
    id = $0
    sub(/^#### \[/, "", id)
    sub(/\].*/, "", id)
    has_cat = has_area = has_prob = has_ev = has_imp = has_fix = 0
  }
  /^Category:/ { has_cat  = 1 }
  /^Area:/     { has_area = 1 }
  /^Problem:/  { has_prob = 1 }
  /^Evidence:/ { has_ev   = 1 }
  /^Impact:/   { has_imp  = 1 }
  /^Fix:/      { has_fix  = 1 }

  END { if (in_open && id != "") check(); if (errors > 0) exit 2 }

  function check(    missing) {
    missing = ""
    if (!has_cat)  missing = missing "Category "
    if (!has_area) missing = missing "Area "
    if (!has_prob) missing = missing "Problem "
    if (!has_ev)   missing = missing "Evidence "
    if (!has_imp)  missing = missing "Impact "
    if (!has_fix)  missing = missing "Fix "
    if (missing != "") {
      printf "BLOCKED: open finding [%s] missing field(s): %s\n", id, missing > "/dev/stderr"
      errors++
    }
  }
' || fail=1

# Regenerate .claude/nitpicker-status.json only when all checks passed
[ "$fail" -ne 0 ] && exit "$fail"

generated=$(grep '^Generated: ' "$fp" | awk '{print $2}')
last_validated=$(grep '^Last validated: ' "$fp" | awk '{print $3}')
last_pass_line=$(grep '^Last pass: ' "$fp")
last_pass_num="${last_pass_line#Last pass: }"
last_pass_num="${last_pass_num%% (*}"
last_pass_date="${last_pass_line##*(}"
last_pass_date="${last_pass_date%\)}"

summary_line=$(grep '^- Total: ' "$fp")
total=$(printf '%s\n' "$summary_line" | grep -oE 'Total: [0-9]+' | grep -oE '[0-9]+')
open=$(printf '%s\n' "$summary_line" | grep -oE 'Open: [0-9]+' | grep -oE '[0-9]+')
fixed=$(printf '%s\n' "$summary_line" | grep -oE 'Fixed: [0-9]+' | grep -oE '[0-9]+')
invalid=$(printf '%s\n' "$summary_line" | grep -oE 'Invalid: [0-9]+' | grep -oE '[0-9]+')

# Project root is three levels up from docs/audit/<file>
project_dir=$(dirname "$(dirname "$(dirname "$fp")")")
json_file="$project_dir/.claude/nitpicker-status.json"

printf '{\n  "generated": "%s",\n  "last_validated": "%s",\n  "last_pass": %s,\n  "last_pass_date": "%s",\n  "summary": {\n    "total": %s,\n    "open": %s,\n    "fixed": %s,\n    "invalid": %s\n  }\n}\n' \
  "$generated" "$last_validated" "$last_pass_num" "$last_pass_date" \
  "$total" "$open" "$fixed" "$invalid" \
  > "$json_file"

exit 0
