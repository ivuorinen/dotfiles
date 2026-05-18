#!/usr/bin/env bash
# Pre-tool guard: block edits to vendor/lock/submodule files and
# reads or edits of secrets.d fish files.
# Receives tool input JSON on stdin.

input=$(cat)
if ! fp=$(printf '%s' "$input" | jq -er '.tool_input.file_path' 2> /dev/null); then
  echo "BLOCKED: invalid hook payload (missing/invalid tool_input.file_path)" >&2
  exit 2
fi
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2> /dev/null)

# Read-only block: secrets files must not be read — they contain credentials.
if [ "$tool" = "Read" ]; then
  case "$fp" in
    */secrets.d/*.fish)
      case "$(basename "$fp")" in
        *.example.fish | *.fish.example) exit 0 ;;
      esac
      echo "BLOCKED: do not read $fp — it contains secrets. Ask the user instead." >&2
      exit 2
      ;;
  esac
  exit 0
fi

# Edit/Write block: vendor, lock, submodule, and secrets files.
case "$fp" in
  */fzf-tmux | */yarn.lock | */.yarn/*)
    echo "BLOCKED: $fp is a vendor/lock file — do not edit directly" >&2
    exit 2
    ;;
  */tools/dotbot/* | */tools/dotbot-include/* | */tools/antidote/*)
    echo "BLOCKED: $fp is inside a git submodule — do not edit" >&2
    exit 2
    ;;
  */config/cheat/cheatsheets/community/* | */config/cheat/cheatsheets/tldr/*)
    echo "BLOCKED: $fp is a cheat submodule — do not edit" >&2
    exit 2
    ;;
  */secrets.d/*.fish)
    case "$(basename "$fp")" in
      *.example.fish | *.fish.example) exit 0 ;;
    esac
    echo "BLOCKED: do not edit $fp directly — it is gitignored." >&2
    echo "Copy the matching .fish.example file and edit that locally." >&2
    exit 2
    ;;
esac

exit 0
