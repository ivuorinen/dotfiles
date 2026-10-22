#!/usr/bin/env bats
#
# The Tests workflow installs its tools from an inline mise_toml block, and no
# Renovate manager updates that block. Its pins must equal
# config/mise/config.toml, or the suite runs on versions the dotfiles never
# install: CI's uv sat at 0.12.19 while the config had moved to 0.13.1.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  WORKFLOW="$REPO/.github/workflows/tests.yml"
  CONFIG="$REPO/config/mise/config.toml"
}

# Print the `tool = "version"` lines of the workflow's inline mise_toml block.
ci_pins()
{
  awk '/mise_toml: \|/ { inside = 1; next }
    inside && /install_args:/ { exit }
    inside && /=/ { sub(/^[ \t]+/, ""); print }' "$WORKFLOW"
}

@test "ci-pins: the workflow's inline mise_toml pins at least one tool" {
  run ci_pins
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "ci-pins: every inline CI pin equals config/mise/config.toml" {
  local line tool want got drift=0
  while IFS= read -r line; do
    tool="${line%% =*}"
    want="${line#*= }"
    got=$(grep -E "^${tool} = " "$CONFIG" | head -n 1)
    got="${got#*= }"
    if [[ "$got" != "$want" ]]; then
      echo "$tool: CI $want, config.toml ${got:-missing}"
      drift=1
    fi
  done < <(ci_pins)
  [ "$drift" -eq 0 ]
}
