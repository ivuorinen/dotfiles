#!/usr/bin/env bash
# Async Bats runner: run matching test file when a script is edited.
# Runs in background (async: true) — output appears on next turn.

fp=$(jq -r '.tool_input.file_path // empty')
[[ -z "$fp" ]] && exit 0

name=$(basename "$fp")
test_file="$CLAUDE_PROJECT_DIR/tests/${name}.bats"
[[ ! -f "$test_file" ]] && exit 0

command -v bats > /dev/null || exit 0
echo "Running $test_file ..."
bats "$test_file"
