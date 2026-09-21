#!/usr/bin/env bash
# PostToolUse on Edit|Write: validate the edited file and feed failures back.
#
# The shell-validate, fish-validate and yaml-validate skills say "after
# editing, validate", but a skill runs only when the agent chooses to invoke
# it (agent-hooks-5c0be1dd). This hook runs the same checks every time.
# Also enforces the 200-line CLAUDE.md guideline that overran three times
# with no guard (agent-hooks-87e53452; the pre-commit `claude-md-length` hook
# is the commit-time twin).
#
# PostToolUse cannot block — the edit has landed. Exit 2 puts the failure in
# front of the agent to fix; it is feedback, not a gate. A missing linter is
# reported, never skipped silently. Vendored paths are left alone.
# Receives tool output JSON on stdin.

# shellcheck source=lib/protected-paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/protected-paths.sh"

fp=$(jq -r '.tool_input.file_path // empty')
[[ -z "$fp" ]] || [[ ! -f "$fp" ]] && exit 0
[[ "$fp" =~ $PROTECTED_RE ]] && exit 0

problems=""

# run_check TOOL CMD... — append CMD's output to $problems when it fails, or
# a "not available" line when TOOL is absent.
run_check()
{
  local tool=$1 out
  shift
  if ! command -v "$tool" > /dev/null 2>&1; then
    problems+="$tool not available — $fp not checked by it."$'\n'
    return 0
  fi
  if ! out=$("$@" 2>&1); then
    problems+="$out"$'\n'
  fi
  return 0
}

case "$fp" in
  */CLAUDE.md)
    lines=$(wc -l < "$fp")
    ((lines > 200)) && problems+="$fp: $lines lines > 200 — move detail into .claude/rules/ or a subdirectory CLAUDE.md."$'\n'
    ;;
  *.fish)
    run_check fish fish --no-execute "$fp"
    ;;
  *.yml | *.yaml)
    run_check yamllint yamllint -f parsable "$fp"
    case "$fp" in
      */.github/workflows/*) run_check actionlint actionlint "$fp" ;;
      *) ;;
    esac
    ;;
  *)
    # Shell by shebang or directive, wherever it lives: local/bin scripts
    # carry no extension. zsh is excluded — shellcheck does not parse it.
    if head -1 "$fp" | grep -qE '^#!.*(/|env )(bash|sh)( |$)' \
      || grep -qE '^# shellcheck shell=(bash|sh)' "$fp"; then
      run_check shellcheck shellcheck -f gcc "$fp"
    fi
    ;;
esac

if [[ -n "$problems" ]]; then
  printf '%s' "$problems" >&2
  exit 2
fi

exit 0
