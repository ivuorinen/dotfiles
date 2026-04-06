#!/usr/bin/env bats

setup() {
  # Create a temporary dotfiles tree for testing
  export TEST_DOTFILES="$BATS_TMPDIR/dotfiles-$$"
  mkdir -p "$TEST_DOTFILES/local/bin"
  mkdir -p "$TEST_DOTFILES/scripts"
  mkdir -p "$TEST_DOTFILES/docs"
  mkdir -p "$TEST_DOTFILES/docs/plans"
  mkdir -p "$TEST_DOTFILES/docs/superpowers"
  mkdir -p "$TEST_DOTFILES/tools/antidote"
  mkdir -p "$TEST_DOTFILES/config/tmux/plugins/tpm"
  mkdir -p "$TEST_DOTFILES/node_modules/foo"
  mkdir -p "$TEST_DOTFILES/.git/objects"

  # Included files
  echo "# x-foreach" > "$TEST_DOTFILES/local/bin/x-foreach.md"
  echo "# dfm" > "$TEST_DOTFILES/local/bin/dfm.md"
  echo "# alias" > "$TEST_DOTFILES/docs/alias.md"
  echo "# install-fonts" > "$TEST_DOTFILES/scripts/install-fonts.md"

  # Excluded files (should NOT appear)
  echo "# excluded" > "$TEST_DOTFILES/tools/antidote/README.md"
  echo "# excluded" > "$TEST_DOTFILES/docs/plans/old-plan.md"
  echo "# excluded" > "$TEST_DOTFILES/docs/superpowers/spec.md"
  echo "# excluded" > "$TEST_DOTFILES/config/tmux/plugins/tpm/README.md"
  echo "# excluded" > "$TEST_DOTFILES/node_modules/foo/README.md"
  echo "# excluded" > "$TEST_DOTFILES/.git/objects/README.md"

  export DOTFILES="$TEST_DOTFILES"
  export PATH="$BATS_TEST_DIRNAME/../local/bin:$PATH"
}

teardown() {
  rm -rf "$TEST_DOTFILES"
}

@test "x-help discover_files finds included .md files" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  [ "$status" -eq 0 ]
  [[ "$output" == *"local/bin/x-foreach.md"* ]]
  [[ "$output" == *"local/bin/dfm.md"* ]]
  [[ "$output" == *"docs/alias.md"* ]]
  [[ "$output" == *"scripts/install-fonts.md"* ]]
}

@test "x-help discover_files excludes tools/" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  [[ "$output" != *"tools/"* ]]
}

@test "x-help discover_files excludes docs/plans/" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  [[ "$output" != *"docs/plans/"* ]]
}

@test "x-help discover_files excludes docs/superpowers/" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  [[ "$output" != *"docs/superpowers/"* ]]
}

@test "x-help discover_files excludes config/tmux/plugins/" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  [[ "$output" != *"config/tmux/plugins/"* ]]
}

@test "x-help discover_files excludes node_modules/" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  [[ "$output" != *"node_modules/"* ]]
}

@test "x-help discover_files excludes .git/" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  [[ "$output" != *".git/"* ]]
}

@test "x-help discover_files output is sorted" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && discover_files"
  expected=$(echo "$output" | sort)
  [ "$output" = "$expected" ]
}

@test "x-help direct mode: exact single match" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && direct_lookup 'x-foreach'"
  [ "$status" -eq 0 ]
  [ "$output" = "local/bin/x-foreach.md" ]
}

@test "x-help direct mode: no match exits 1" {
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && direct_lookup 'nonexistent'"
  [ "$status" -eq 1 ]
}

@test "x-help direct mode: multiple matches returns all" {
  # Create a second file with the same basename in a different path
  mkdir -p "$TEST_DOTFILES/config"
  echo "# alias config" > "$TEST_DOTFILES/config/alias.md"
  run bash -c "DOTFILES='$TEST_DOTFILES' source local/bin/x-help --source-only && direct_lookup 'alias'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"docs/alias.md"* ]]
  [[ "$output" == *"config/alias.md"* ]]
}

@test "x-help require_fzf fails when fzf missing" {
  local test_script="$BATS_TMPDIR/test-require-fzf-$$"
  cat > "$test_script" <<SCRIPT
#!/usr/bin/env bash
export DOTFILES="$TEST_DOTFILES"
source local/bin/x-help --source-only
export PATH="/nonexistent"
require_fzf
SCRIPT
  chmod +x "$test_script"
  run bash "$test_script"
  rm -f "$test_script"
  [ "$status" -eq 1 ]
  [[ "$output" == *"fzf"* ]]
}

@test "x-help direct mode shows file content" {
  run env DOTFILES="$TEST_DOTFILES" bash local/bin/x-help x-foreach
  [ "$status" -eq 0 ]
  [[ "$output" == *"# x-foreach"* ]]
}

@test "x-help direct mode with unknown name exits 1" {
  run env DOTFILES="$TEST_DOTFILES" bash local/bin/x-help nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"No documentation found"* ]]
}

@test "x-help warns when no docs found" {
  local empty_dir="$BATS_TMPDIR/empty-$$"
  mkdir -p "$empty_dir"
  run env DOTFILES="$empty_dir" bash local/bin/x-help
  [ "$status" -eq 0 ]
  [[ "$output" == *"No documentation"* ]]
  rm -rf "$empty_dir"
}
