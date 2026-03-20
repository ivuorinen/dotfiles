#!/usr/bin/env bash
# Stop gate: run yarn lint before Claude finishes.
# Exit 2 sends feedback back and keeps Claude working.

cd "$CLAUDE_PROJECT_DIR" || exit 0

output=$(yarn lint 2>&1)
status=$?

if [ $status -ne 0 ]; then
  echo "Lint failed — fix before finishing:" >&2
  echo "$output" >&2
  exit 2
fi

exit 0
