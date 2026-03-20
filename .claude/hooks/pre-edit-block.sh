#!/usr/bin/env bash
# Pre-edit guard: block vendor/lock files and secrets.d real fish files.
# Receives tool input JSON on stdin.

fp=$(jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] && exit 0

case "$fp" in
  */fzf-tmux | */yarn.lock | */.yarn/*)
    echo "BLOCKED: $fp is a vendor/lock file — do not edit directly" >&2
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
