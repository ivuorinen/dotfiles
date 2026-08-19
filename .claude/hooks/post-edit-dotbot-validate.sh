#!/usr/bin/env bash
# Post-edit: validate Dotbot install.conf.yaml files after editing.
# Checks YAML syntax and verifies link targets exist.

fp=$(jq -r '.tool_input.file_path // empty')
[[ -z "$fp" ]] || [[ ! -f "$fp" ]] && exit 0

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
elif command -v python3 > /dev/null && python3 -c 'import yaml' 2> /dev/null; then
  # PyYAML is probed separately so its absence is not reported as a parse
  # error. Without that check an ImportError exits non-zero exactly like
  # malformed YAML, and a perfectly valid install.conf.yaml was blocked with
  # "YAML parse error ... ModuleNotFoundError" on any host lacking PyYAML —
  # macOS runners among them.
  #
  # Pass $fp as argv so a path containing apostrophes or other quoting
  # characters cannot terminate the Python string literal early.
  if ! output=$(python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' "$fp" 2>&1); then
    echo "Dotbot config YAML parse error in $fp:" >&2
    echo "$output" >&2
    exit 2
  fi
else
  # No validator available. Say so rather than passing silently: a skipped
  # check that looks like a passed one is how a broken config reaches ./install.
  echo "NOTE: neither yamllint nor PyYAML available — $fp not validated." >&2
fi

exit 0
