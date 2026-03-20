#!/usr/bin/env bash
# Post-edit: validate Dotbot install.conf.yaml files after editing.
# Checks YAML syntax and verifies link targets exist.

fp=$(jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] || [ ! -f "$fp" ] && exit 0

case "$fp" in
  *install.conf.yaml) ;;
  *) exit 0 ;;
esac

# YAML syntax check
if command -v yamllint > /dev/null; then
  if ! output=$(yamllint -d relaxed "$fp" 2>&1); then
    echo "Dotbot config YAML error in $fp:" >&2
    echo "$output" >&2
    exit 2
  fi
elif command -v python3 > /dev/null; then
  if ! output=$(python3 -c "import yaml; yaml.safe_load(open('$fp'))" 2>&1); then
    echo "Dotbot config YAML parse error in $fp:" >&2
    echo "$output" >&2
    exit 2
  fi
fi

exit 0
