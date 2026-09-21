#!/usr/bin/env bash
# @description Fail when staged lines leak machine-specific values into shared config
#USAGE about "Reject host names and ~/Code paths added to shared config/, base/ or ssh/"
#USAGE arg "[file]..." help="Staged files to check (pre-commit passes them)"
#
# .claude/rules/host-specific-config.md: personal hostnames, SSH targets and
# paths under ~/Code/<org>/ belong in hosts/<hostname>/, never in the shared
# tree. Nothing enforced it, and A-001 shows it happened
# (agent-loopholes-2f346170).
#
# Only lines the staged diff ADDS are checked. The shared tree already carries
# deliberate cross-machine references (the ~/Code aliases, git includeIf
# paths, ssh/config hosts); checking whole files would fail every unrelated
# edit to them. This gate stops new leaks, it does not relitigate old ones.
#
# ponytail: host names shorter than three characters (hosts/s) are skipped —
# as whole words they match ordinary text. A host named like a common word
# (hosts/air vs the `air-verse/air` tool) can still false-positive on an added
# line. Catch the first in review; switch to an allowlist if the second bites.

set -euo pipefail

root=$(git rev-parse --show-toplevel)

names=()
for d in "$root"/hosts/*/; do
  n=$(basename "$d")
  [[ ${#n} -ge 3 ]] && names+=("$n")
done
current=$(hostname -s 2> /dev/null || true)
[[ ${#current} -ge 3 ]] && names+=("$current")

pattern='(~|\$HOME|\$\{HOME\}|/Users/[^/[:space:]]+|/home/[^/[:space:]]+)/Code/[^[:space:]]'
if [[ ${#names[@]} -gt 0 ]]; then
  pattern+="|\\b($(
    IFS='|'
    printf '%s' "${names[*]}"
  ))\\b"
fi

# Added lines only, each prefixed with its file so a hit is locatable.
hits=$(git diff --cached -U0 --no-color -- "$@" | awk '
  /^\+\+\+ / { file = substr($0, 7); next }
  /^\+/ { print file ": " substr($0, 2) }
' | grep -iE -- "$pattern" || true)

if [[ -n "$hits" ]]; then
  printf 'Machine-specific values added to the shared tree (move them under hosts/<hostname>/):\n%s\n' "$hits" >&2
  printf 'See .claude/rules/host-specific-config.md.\n' >&2
  exit 1
fi
exit 0
