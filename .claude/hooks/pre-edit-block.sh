#!/usr/bin/env bash
# Pre-tool guard: block edits to vendor/lock/submodule files and
# reads or edits of real secrets.d files (fish and bash/zsh trees).
# Receives tool input JSON on stdin.
#
# Tools and the path fields read (Claude Code hooks reference, tool input
# tables; NotebookEdit from its tool schema):
#   Edit, Write, MultiEdit, Read — file_path (required; fails closed)
#   NotebookEdit                 — notebook_path (required; an edit)
#   Grep                         — path and glob (both optional; a read)
#   Glob                         — path and pattern (path optional; a read)
# Grep and Glob were outside the matcher, so one Grep call with
# `path: config/fish/secrets.d` dumped credentials (agent-loopholes-9168e487).
# Grep's own `pattern` is a content regex, not a path, so searching for the
# text "secrets.d" stays allowed. Without a glob, Grep searches through
# ripgrep, which skips the gitignored secrets trees. A `glob` overrides
# ripgrep's ignore rules, though, and `**/github.fish` names no secrets.d
# text, so a glob over a directory that contains a secrets tree is refused
# unless it can only match a committed template (agent-loopholes-85be385e).
# Read deny rules in permissions are the first-class control for this, but the
# docs call their application to Grep "best-effort", so the hook stays.
#
# Path normalisation (case, `./`, `//`, `..`) happens inside the shared
# predicates, so `./YARN.LOCK` and `tools//dotbot/x` are the protected files
# they name on case-insensitive APFS (agent-loopholes-88c3bb49).

# shellcheck source=lib/protected-paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/protected-paths.sh"

# grep_root_holds_secrets ROOT — succeed when the search root ROOT (empty: the
# project root) is a secrets tree's ancestor. Relative roots resolve against
# CLAUDE_PROJECT_DIR; the comparison is lexical and case-folded (APFS).
grep_root_holds_secrets()
{
  local proj root tree
  proj=${CLAUDE_PROJECT_DIR:-$PWD}
  root=${1:-$proj}
  [[ "$root" == /* ]] || root="$proj/$root"
  root=$(_pp_normalise "$root/" parsed)
  root=${root%/}
  for tree in config/secrets.d config/fish/secrets.d; do
    tree=$(_pp_normalise "$proj/$tree" parsed)
    [[ "$tree/" == "$root/"* ]] && return 0
  done
  return 1
}

# glob_only_templates GLOB — succeed when GLOB can only match the committed
# `*.example` templates or README.md.
glob_only_templates()
{
  local g
  g=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  [[ "$g" == *.example || "$g" == readme.md || "$g" == */readme.md ]]
}

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2> /dev/null)

case "$tool" in
  Grep | Glob)
    # Read-only tools: only the secrets check applies.
    paths=$(printf '%s' "$input" | jq -r '
      [.tool_input.path, (if .tool_name == "Grep" then .tool_input.glob else .tool_input.pattern end)]
      | map(select(type == "string" and . != "")) | join("\n")
    ' 2> /dev/null)
    if [[ -n "$paths" ]] && secrets_referenced "$paths"; then
      echo "BLOCKED: do not search $paths — a secrets.d tree holds credentials. Ask the user instead." >&2
      exit 2
    fi
    if [[ "$tool" == Grep ]]; then
      glob=$(printf '%s' "$input" | jq -r '.tool_input.glob // empty' 2> /dev/null)
      root=$(printf '%s' "$input" | jq -r '.tool_input.path // empty' 2> /dev/null)
      if [[ -n "$glob" ]] && grep_root_holds_secrets "$root" && ! glob_only_templates "$glob"; then
        echo "BLOCKED: a Grep glob overrides ripgrep's ignore rules, and ${root:-the project root} contains a gitignored secrets.d tree. Narrow path to a directory without one." >&2
        exit 2
      fi
    fi
    exit 0
    ;;
esac

if ! fp=$(printf '%s' "$input" | jq -er '.tool_input.file_path // .tool_input.notebook_path' 2> /dev/null); then
  echo "BLOCKED: invalid hook payload (missing/invalid tool_input.file_path)" >&2
  exit 2
fi

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

if protected_referenced "$fp"; then
  echo "BLOCKED: $fp is vendored, a lock file, or inside a submodule — do not edit it in place." >&2
  echo "Each group's refresh procedure is in .claude/rules/vendored-files.md." >&2
  exit 2
fi

exit 0
