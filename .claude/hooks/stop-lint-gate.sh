#!/usr/bin/env bash
# Stop gate: run yarn lint before Claude finishes.
# Exit 2 sends feedback back and keeps Claude working.

cd "$CLAUDE_PROJECT_DIR" || exit 0

# Ensure node/yarn are on PATH via mise
eval "$(mise activate bash --shims)" 2> /dev/null
node_dir="$(mise where node 2> /dev/null)/bin"
[ -d "$node_dir" ] && export PATH="$node_dir:$PATH"

output=$(yarn lint 2>&1)
status=$?

if [ $status -ne 0 ]; then
  echo "Lint failed — fix before finishing:" >&2
  echo "$output" >&2
  exit 2
fi

exit 0
