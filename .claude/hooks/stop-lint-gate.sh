#!/usr/bin/env bash
# Stop gate: run yarn lint before Claude finishes.
# Exit 2 sends feedback back and keeps Claude working.

cd "$CLAUDE_PROJECT_DIR" || exit 0

# Ensure node/yarn are on PATH via mise (if available)
if command -v mise > /dev/null 2>&1; then
  eval "$(mise activate bash --shims)" 2> /dev/null
  node_root="$(mise where node 2> /dev/null)"
  [[ -n "$node_root" && -d "$node_root/bin" ]] && export PATH="$node_root/bin:$PATH"
fi

# Fall back to corepack shim locations if yarn is still the legacy v1
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
if command -v corepack > /dev/null 2>&1; then
  corepack enable --install-directory "$HOME/.local/bin" 2> /dev/null || true
fi

# Resolve the correct yarn binary: prefer corepack yarn (v4+) over the global v1 shim
YARN_BIN="yarn"
if command -v corepack > /dev/null 2>&1; then
  yarn_version="$(yarn --version 2>/dev/null || echo "0")"
  if [[ "$yarn_version" == 1.* ]]; then
    YARN_BIN="corepack yarn"
  fi
fi

# Ensure node_modules are installed (fast no-op if already up to date).
# --no-immutable allows the lockfile to be refreshed in dev environments.
if ! $YARN_BIN install --no-immutable; then
  echo "yarn install failed — aborting lint" >&2
  exit 2
fi

output=$($YARN_BIN lint:biome 2>&1 && $YARN_BIN lint:prettier 2>&1 && $YARN_BIN lint:md-table 2>&1)
status=$?

# Run ec separately; skip if it fails due to binary download issues (network/rate-limit)
ec_output=$($YARN_BIN lint:ec 2>&1)
ec_status=$?
if [[ $ec_status -ne 0 ]]; then
  if echo "$ec_output" | grep -q "rate limit\|Failed to download\|HttpError"; then
    echo "Warning: editorconfig-checker skipped (binary download failed — GitHub rate limit)" >&2
  else
    output="$output
$ec_output"
    status=$ec_status
  fi
fi

if [ $status -ne 0 ]; then
  echo "Lint failed — fix before finishing:" >&2
  echo "$output" >&2
  exit 2
fi

exit 0