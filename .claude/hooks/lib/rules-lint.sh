#!/usr/bin/env bash
# rules-lint.sh FILE... — lint .claude/rules/*.md content.
#
# One checker for two callers: pre-rules-lint.sh (PreToolUse, which writes the
# prospective content to a temp file) and the `rules-lint` pre-commit hook
# (which catches rule files changed through Bash or the ctx sandbox, where no
# edit hook fires). Prints one line per problem; exits 1 when any exist.
#
# Checks:
#   1. Hedge words (try, consider, prefer, might, generally, when possible,
#      should) — rules must be unconditional imperatives. Fenced code blocks
#      and backtick spans are skipped so a rule can quote a forbidden word.
#      Deliberately excluded: "may", "could", "sometimes", "often",
#      "usually", "typically", "recommended" — they appear as factual
#      qualifications ("the parser may reject Y"), not normative weakening.
#      Add a word only after a regression where its absence let a weakened
#      rule land.
#   2. Frontmatter keys. Claude Code documents only `paths` for rule files
#      (code.claude.com/docs/en/memory, "Path-specific rules"); `description`
#      is this repo's own convention, present in every rule. Anything else —
#      `globs:` (N-079), `alwaysApply:` (agent-rules-894fe54d) — is a key the
#      loader ignores, so the rule silently loses its scoping. `paths` must be
#      a YAML list.

set -u

rc=0
pattern='\b(try|consider|prefer|might|generally|when possible|should)\b'

for f in "$@"; do
  label=${RULES_LINT_LABEL:-$f}

  hits=$(awk '
    /^```/ { in_code = !in_code; print ""; next }
    in_code { print ""; next }
    { gsub(/`[^`]*`/, ""); print }
  ' "$f" | grep -niE "$pattern")
  if [[ -n "$hits" ]]; then
    printf '%s: hedge words — rules must be unconditional imperatives (use must/never/always):\n%s\n' "$label" "$hits"
    rc=1
  fi

  fm=$(awk '
    NR == 1 { if ($0 != "---") exit; open = 1; next }
    open && $0 == "---" { closed = 1; exit }
    open {
      if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) {
        if (expect_list) { print "paths: must be a YAML list"; expect_list = 0 }
        key = $0; sub(/:.*/, "", key)
        val = $0; sub(/^[^:]*:[[:space:]]*/, "", val)
        if (key != "paths" && key != "description") print "unknown frontmatter key: " key
        if (key == "paths") {
          if (val == "") expect_list = 1
          else if (val !~ /^\[/) print "paths: must be a YAML list"
        }
      } else if (expect_list && $0 ~ /^[[:space:]]+-[[:space:]]/) {
        expect_list = 0
      }
    }
    END {
      if (open && !closed) print "frontmatter is not closed with ---"
      if (expect_list) print "paths: must be a YAML list"
    }
  ' "$f")
  if [[ -n "$fm" ]]; then
    printf '%s: %s\n' "$label" "$fm"
    rc=1
  fi
done

exit "$rc"
