#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export TMPDIR_TEST
  # Point to non-existent config so neither parse block runs
  export X_ENV_GROUPING="$TMPDIR_TEST/nonexistent.yaml"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "x-env-list: exits 0 and prints group headers without config file" {
  run bash local/bin/x-env-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"# "* ]]
}

@test "x-env-list: does not add bogus groups from YAML colon parsing" {
  local cfg="$TMPDIR_TEST/grouping.yaml"
  cat > "$cfg" << 'YAML'
custom_grouping: []
protected_keys: []
skipped_keys: []
YAML
  X_ENV_GROUPING="$cfg" run bash local/bin/x-env-list
  # "custom_grouping" should NOT appear as a group header;
  # it would if the file were re-parsed as colon-separated pairs
  [[ "$output" != *"# custom_grouping"* ]]
}
