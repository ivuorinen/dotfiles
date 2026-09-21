#!/usr/bin/env bash
# Pre-tool guard: block edits to vendor/lock/submodule files and
# reads or edits of real secrets.d files (fish and bash/zsh trees).
# Receives tool input JSON on stdin.

# shellcheck source=lib/protected-paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/protected-paths.sh"

input=$(cat)
if ! fp=$(printf '%s' "$input" | jq -er '.tool_input.file_path' 2> /dev/null); then
  echo "BLOCKED: invalid hook payload (missing/invalid tool_input.file_path)" >&2
  exit 2
fi
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2> /dev/null)

# Secrets: reading is as forbidden as editing — the files hold credentials.
# Only the committed `*.example` templates and README.md are exempt.
if secrets_referenced "$fp"; then
  if [[ "$tool" = "Read" ]]; then
    echo "BLOCKED: do not read $fp — it contains secrets. Ask the user instead." >&2
  else
    echo "BLOCKED: do not edit $fp directly — it is gitignored and holds credentials." >&2
    echo "Copy the matching .example file and edit that locally." >&2
  fi
  exit 2
fi

# Everything else is readable; only edits are restricted below.
[[ "$tool" = "Read" ]] && exit 0

if [[ "$fp" =~ $PROTECTED_RE ]]; then
  echo "BLOCKED: $fp is vendored, a lock file, or inside a submodule — do not edit it in place." >&2
  echo "Each group's refresh procedure is in .claude/rules/vendored-files.md." >&2
  exit 2
fi

exit 0
