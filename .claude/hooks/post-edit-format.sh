#!/usr/bin/env bash
# Post-edit formatter: auto-format file based on extension.
# Receives tool output JSON on stdin.

fp=$(jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] || [ ! -f "$fp" ] && exit 0

case "$fp" in
  *.sh | */bin/*)
    head -1 "$fp" | grep -qE '^#!.*(ba)?sh' \
      && command -v shfmt > /dev/null \
      && shfmt -i 2 -bn -ci -sr -fn -w "$fp"
    ;;
  *.fish)
    command -v fish_indent > /dev/null && fish_indent -w "$fp"
    ;;
  *.lua)
    command -v stylua > /dev/null && stylua "$fp"
    ;;
  *.md)
    command -v biome > /dev/null && biome format --write "$fp" 2> /dev/null
    command -v markdown-table-formatter > /dev/null \
      && markdown-table-formatter "$fp" 2> /dev/null
    ;;
  *.yml | *.yaml)
    command -v prettier > /dev/null && prettier --write "$fp" 2> /dev/null
    ;;
esac

exit 0
