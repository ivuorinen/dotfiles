#!/usr/bin/env bats
#
# check-exclusion-drift is the only thing keeping the five third-party
# exclusion lists (.grype.yaml, .codacy.yml, [tool.ruff], [tool.bandit],
# .mega-linter.yml) in step -- .codacy.yml states the requirement in prose but
# nothing enforced it before this gate. The tests that matter are the failing
# ones: a checker that always exits 0 reports green forever and is worse than
# no checker at all.
#
# Each test builds a throwaway fixture repo and points the script at it with
# EXCLUSION_CHECK_ROOT, so nothing here depends on the live config files.

setup()
{
  CHECK="$BATS_TEST_DIRNAME/../scripts/check-exclusion-drift.py"
  export EXCLUSION_CHECK_ROOT="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$EXCLUSION_CHECK_ROOT"

  cat > "$EXCLUSION_CHECK_ROOT/.grype.yaml" << 'EOF'
exclude:
  - "./tools/**"
  - "./node_modules/**"
EOF

  cat > "$EXCLUSION_CHECK_ROOT/.codacy.yml" << 'EOF'
exclude_paths:
  - "tools/**"
  - "node_modules/**"
EOF

  cat > "$EXCLUSION_CHECK_ROOT/pyproject.toml" << 'EOF'
[tool.ruff]
extend-exclude = ["tools"]

[tool.bandit]
exclude_dirs = ["./tools", "./node_modules"]
EOF

  cat > "$EXCLUSION_CHECK_ROOT/.mega-linter.yml" << 'EOF'
FILTER_REGEX_EXCLUDE: >
  (node_modules|tools)
EOF
}

@test "check-exclusion-drift: --update writes a baseline" {
  run "$CHECK" --update
  [ "$status" -eq 0 ]
  [ -f "$EXCLUSION_CHECK_ROOT/.exclusion-baseline.json" ]
}

@test "check-exclusion-drift: passes when nothing has moved" {
  "$CHECK" --update
  run "$CHECK"
  [ "$status" -eq 0 ]
  [[ "$output" == *"OK"* ]]
}

@test "check-exclusion-drift: fails when a tree is missing a baseline" {
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no baseline"* ]]
}

@test "check-exclusion-drift: catches a tree added to only one gate" {
  "$CHECK" --update
  # The drift this whole gate exists to catch: a new vendored tree lands in
  # .codacy.yml and nobody mirrors it into the other four.
  printf '  - "config/fzf/**"\n' >> "$EXCLUSION_CHECK_ROOT/.codacy.yml"
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"NEW"* ]]
  [[ "$output" == *"config/fzf"* ]]
  [[ "$output" == *"absent from"* ]]
}

@test "check-exclusion-drift: catches a tree dropped from every gate" {
  "$CHECK" --update
  cat > "$EXCLUSION_CHECK_ROOT/.grype.yaml" << 'EOF'
exclude:
  - "./tools/**"
EOF
  cat > "$EXCLUSION_CHECK_ROOT/.codacy.yml" << 'EOF'
exclude_paths:
  - "tools/**"
EOF
  cat > "$EXCLUSION_CHECK_ROOT/pyproject.toml" << 'EOF'
[tool.ruff]
extend-exclude = ["tools"]

[tool.bandit]
exclude_dirs = ["./tools"]
EOF
  cat > "$EXCLUSION_CHECK_ROOT/.mega-linter.yml" << 'EOF'
FILTER_REGEX_EXCLUDE: >
  (tools)
EOF
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DROPPED"* ]]
  [[ "$output" == *"node_modules"* ]]
}

@test "check-exclusion-drift: catches coverage changing for an existing tree" {
  "$CHECK" --update
  # tools loses its ruff entry but stays everywhere else -- the matrix changes
  # even though no tree appears or disappears.
  cat > "$EXCLUSION_CHECK_ROOT/pyproject.toml" << 'EOF'
[tool.ruff]
extend-exclude = []

[tool.bandit]
exclude_dirs = ["./tools", "./node_modules"]
EOF
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"CHANGED"* ]]
  [[ "$output" == *"no longer in"* ]]
  [[ "$output" == *"ruff"* ]]
}

@test "check-exclusion-drift: normalises ./ prefixes and glob suffixes" {
  # ./tools/** and tools must be recognised as the same tree, otherwise every
  # gate looks like it covers something different and the check is noise.
  "$CHECK" --update
  baseline="$EXCLUSION_CHECK_ROOT/.exclusion-baseline.json"
  run grep -c '"tools"' "$baseline"
  [ "$status" -eq 0 ]
  run grep -c 'tools/\*\*' "$baseline"
  [ "$output" = "0" ]
}

@test "check-exclusion-drift: real repo config is in step with its baseline" {
  # Guards the committed .exclusion-baseline.json against being stale.
  unset EXCLUSION_CHECK_ROOT
  run "$CHECK"
  [ "$status" -eq 0 ]
}
