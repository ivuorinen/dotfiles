#!/usr/bin/env bash
# Stop gate: run `mise run lint` before Claude finishes.
# Exit 2 sends feedback back and keeps Claude working.

cd "$CLAUDE_PROJECT_DIR" || exit 0

# The lint chain is the `lint` task in .mise.toml; mise puts its pinned tools
# on PATH itself. Without mise there is no gate to run, and saying so beats a
# silent pass.
if ! command -v mise > /dev/null 2>&1; then
  echo "mise not found — cannot run the lint gate (mise run lint)" >&2
  exit 2
fi

# Network-aware special-case: editorconfig-checker's first invocation
# downloads a binary from GitHub; on rate-limit we record a non-zero
# status (no silent skip) and surface the error to the user.
output=$(mise run lint 2>&1)
status=$?

if [[ $status -ne 0 ]]; then
  if echo "$output" | grep -Eq "rate limit|Failed to download|HttpError"; then
    echo "Lint failed — editorconfig-checker binary download was rate-limited." >&2
    echo "Retry after the rate-limit window, or cache the ec binary locally." >&2
  else
    echo "Lint failed — fix before finishing:" >&2
  fi
  echo "$output" >&2
  exit 2
fi

exit 0
