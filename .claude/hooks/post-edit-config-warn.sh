#!/usr/bin/env bash
# Post-edit: warn when formatter/linter configs are changed,
# since they affect the entire repo's code style.

fp=$(jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] || [ ! -f "$fp" ] && exit 0

case "$(basename "$fp")" in
  .editorconfig | biome.json | .prettierrc.json | .shellcheckrc | stylua.toml | .yamllint.yml)
    echo "NOTE: Formatter/linter config changed ($fp)." >&2
    echo "Run 'pre-commit run --all-files' to verify consistency." >&2
    ;;
esac

exit 0
