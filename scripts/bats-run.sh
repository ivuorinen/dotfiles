#!/usr/bin/env bash
# @description Run the bats suite and finish with a summary of every failing test
#USAGE about "Run bats, then list each failing test as file:line with its failed assertion"
#USAGE arg "[bats-arg]..." help="Arguments passed to bats (default: the repo's tests/ directory)"
#
# A 1000-test run prints ~1000 lines, and a `not ok` can sit anywhere in
# them: in the pre-commit hook's output, in a CI log, in a terminal
# scrollback. This wrapper runs bats unchanged (same display, same
# --print-output-on-failure detail) and ends with one block naming every
# failure, so finding them no longer means searching the log.
#
# The summary is parsed from bats' TAP report (--report-formatter tap), not
# from the display output, so it is the same whichever formatter bats
# picks for the terminal.
#
# On GitHub Actions each failure also becomes an ::error annotation, shown
# inline on the PR diff at the test's file:line, and the list is written to
# the job summary.
#
# The exit status is bats' own: this script never turns a red run green
# or a green run red.

set -uo pipefail

root=$(cd -- "$(dirname -- "$0")/.." && pwd)
report_dir=$(mktemp -d)
trap 'rm -rf -- "$report_dir"' EXIT

[[ $# -gt 0 ]] || set -- "$root/tests/"

bats --print-output-on-failure --report-formatter tap --output "$report_dir" "$@"
rc=$?

report="$report_dir/report.tap"
if [[ ! -s "$report" ]]; then
  # bats aborted before running tests (bad flag, unparsable file, …); its own
  # error above is the whole story, so say only that no summary exists.
  ((rc != 0)) && printf '\nbats-run: no TAP report written (bats exit %d); see the output above.\n' "$rc" >&2
  exit "$rc"
fi

# One tab-separated record per failure: file, line, test name, assertion.
# For a failure inside a helper, bats reports the helper's location first and
# the test's own location on the "in test file" line; the test's line is the
# one worth jumping to, so that line wins.
failures=$(awk '
  function flush() {
    if (name != "") printf "%s\t%s\t%s\t%s\n", file, line, name, assertion
    name = ""; file = "?"; line = "0"; assertion = ""
  }
  /^(ok|not ok) [0-9]+ / { flush() }
  /^not ok [0-9]+ / { sub(/^not ok [0-9]+ /, ""); name = $0; next }
  name != "" && /in test file .*, line [0-9]+\)/ {
    s = $0
    sub(/.*in test file /, "", s)
    file = s; sub(/, line [0-9]+\).*/, "", file)
    line = s; sub(/.*, line /, "", line); sub(/\).*/, "", line)
    next
  }
  name != "" && assertion == "" && /^#   `.*'"'"' failed$/ {
    assertion = $0; sub(/^#   `/, "", assertion); sub(/'"'"' failed$/, "", assertion)
  }
  END { flush() }
' "$report")

[[ -n "$failures" ]] || exit "$rc"

count=$(printf '%s\n' "$failures" | wc -l | tr -d ' ')

# GitHub workflow-command escaping: data escapes % CR LF; property values
# (file, title) additionally escape : and ,.
gh_data()
{
  local s=${1//%/%25}
  s=${s//$'\r'/%0D}
  printf '%s' "${s//$'\n'/%0A}"
}
gh_prop()
{
  local s
  s=$(gh_data "$1")
  s=${s//:/%3A}
  printf '%s' "${s//,/%2C}"
}

{
  printf '\n━━ %d failing bats test(s) ━━\n' "$count"
  while IFS=$'\t' read -r file line name assertion; do
    file=${file#"$root"/}
    printf '  ✗ %s:%s  %s\n' "$file" "$line" "$name"
    [[ -n "$assertion" ]] && printf '      %s\n' "$assertion"
  done <<< "$failures"
  printf '━━ search the output above for "not ok" to see each failure'"'"'s full detail ━━\n'
} >&2

if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
  while IFS=$'\t' read -r file line name assertion; do
    file=${file#"$root"/}
    printf '::error file=%s,line=%s,title=%s::%s\n' \
      "$(gh_prop "$file")" "$line" "$(gh_prop "bats: $name")" \
      "$(gh_data "${assertion:-test failed}")"
  done <<< "$failures"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      printf '### %d failing bats test(s)\n\n| Test | Location | Failed assertion |\n|---|---|---|\n' "$count"
      while IFS=$'\t' read -r file line name assertion; do
        file=${file#"$root"/}
        printf '| %s | `%s:%s` | `%s` |\n' "${name//|/\\|}" "$file" "$line" "${assertion//|/\\|}"
      done <<< "$failures"
    } >> "$GITHUB_STEP_SUMMARY"
  fi
fi

exit "$rc"
