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

# Fall back to corepack shim location only when yarn is missing or legacy v1
if ! command -v yarn > /dev/null 2>&1 || yarn --version 2> /dev/null | grep -q '^1\.'; then
  export PATH="$HOME/.local/bin:$PATH"
  if command -v corepack > /dev/null 2>&1; then
    corepack enable --install-directory "$HOME/.local/bin" 2> /dev/null || true
  fi
fi

# Resolve the correct yarn binary: prefer corepack yarn (v4+) over the global v1 shim
YARN_BIN="yarn"
if command -v corepack > /dev/null 2>&1; then
  yarn_version="$(yarn --version 2> /dev/null || echo "0")"
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

# Run the full lint chain defined in package.json's "lint" script.
# Network-aware special-case: editorconfig-checker's first invocation
# downloads a binary from GitHub; on rate-limit we record a non-zero
# status (no silent skip) and surface the error to the user.
output=$($YARN_BIN lint 2>&1)
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
