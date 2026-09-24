#!/usr/bin/env bats
#
# --prune deletes files, so the guards are the whole point of these tests.
# install-completions only ever created artifacts before this flag existed,
# which is how finding N-147 happened: a deleted script left three orphans
# behind and the cleanup removed one of them.
#
# The dangerous failure is the opposite one — pruning something that is not
# generated here. Two trees contain tracked files (config/fish/completions is
# the hand-curated whitelist that *drives* the third-party list, and
# local/man/man1 holds the vendored fzf manpages), so the "never delete a
# tracked file" guard is asserted directly.
#
# Each test builds a throwaway git repo as DOTFILES. Prune mode exits before
# the `usage` CLI check, so the fixture needs no tooling beyond git.

setup()
{
  # See tests/claude-hooks-misc.bats: keeps the fixture repo off the git
  # environment a commit hook inherits (GIT_INDEX_FILE and friends).
  unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE GIT_OBJECT_DIRECTORY GIT_COMMON_DIR GIT_PREFIX

  SCRIPT="$BATS_TEST_DIRNAME/../scripts/install-completions.sh"
  export DOTFILES="$BATS_TEST_TMPDIR/repo"

  mkdir -p "$DOTFILES"/{scripts,local/bin,local/md,local/man/man1} \
    "$DOTFILES"/config/{fish/completions,bash/completions.d,zsh/completions.d}

  # Minimal stand-in for the real shared.sh: the script only needs the logger
  # helpers and the LIB_E_* exit codes.
  cat > "$DOTFILES/scripts/shared.sh" << 'EOF'
LIB_E_SUCCESS=0
LIB_E_INVALID_ARGUMENT=1
LIB_E_COMMAND_NOT_FOUND=2
LIB_E_EXECUTION_FAILED=4
logger::info() { echo "INFO: $*"; }
logger::warn() { echo "WARN: $*"; }
logger::error() { echo "ERROR: $*" >&2; }
EOF

  # A live spec: its artifacts must survive.
  printf '#!/usr/bin/env bash\n#USAGE about "live tool"\n' > "$DOTFILES/local/bin/toolx"
  : > "$DOTFILES/config/bash/completions.d/toolx.bash"
  : > "$DOTFILES/config/zsh/completions.d/_toolx"
  : > "$DOTFILES/local/md/toolx.md"

  # A whitelisted third-party tool: expected because it is in fish, whether or
  # not the binary exists on this host.
  : > "$DOTFILES/config/fish/completions/mytool.fish"
  : > "$DOTFILES/config/bash/completions.d/mytool.bash"

  # Orphans: nothing regenerates these.
  : > "$DOTFILES/config/bash/completions.d/gone.sh.bash"
  : > "$DOTFILES/config/zsh/completions.d/_gone.sh"
  : > "$DOTFILES/local/md/gone.sh.md"
  : > "$DOTFILES/local/man/man1/gone.sh.1"

  # A tracked, hand-vendored manpage with no spec — the fzf case.
  : > "$DOTFILES/local/man/man1/vendored.1"

  # See tests/claude-hooks-misc.bats: keeps fixture commits off the
  # 1Password-backed signing key, which costs 60s and fails when locked.
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false

  git -C "$DOTFILES" init -q
  git -C "$DOTFILES" config user.email t@example.com
  git -C "$DOTFILES" config user.name t
  git -C "$DOTFILES" add -A -f config/fish/completions local/man/man1/vendored.1
  git -C "$DOTFILES" commit -qm fixture
}

@test "install-completions: --prune-list reports orphans" {
  run bash "$SCRIPT" --prune-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"gone.sh.bash"* ]]
  [[ "$output" == *"_gone.sh"* ]]
  [[ "$output" == *"gone.sh.md"* ]]
  [[ "$output" == *"gone.sh.1"* ]]
}

@test "install-completions: --prune-list deletes nothing" {
  run bash "$SCRIPT" --prune-list
  [ "$status" -eq 0 ]
  [ -f "$DOTFILES/config/bash/completions.d/gone.sh.bash" ]
  [ -f "$DOTFILES/local/man/man1/gone.sh.1" ]
}

@test "install-completions: --prune-list keeps artifacts that have a live spec" {
  run bash "$SCRIPT" --prune-list
  [[ "$output" != *"toolx"* ]]
}

@test "install-completions: a whitelisted fish tool is not stale even if uninstalled" {
  # mytool is certainly not installed in the test env; it must still survive
  # because it is whitelisted in config/fish/completions.
  run bash "$SCRIPT" --prune-list
  [[ "$output" != *"mytool"* ]]
}

@test "install-completions: tracked files are never pruned" {
  run bash "$SCRIPT" --prune
  [ "$status" -eq 0 ]
  [ -f "$DOTFILES/local/man/man1/vendored.1" ]
  [[ "$output" == *"keeping tracked file"* ]]
}

@test "install-completions: the fish whitelist is never pruned" {
  run bash "$SCRIPT" --prune
  [ "$status" -eq 0 ]
  [ -f "$DOTFILES/config/fish/completions/mytool.fish" ]
}

@test "install-completions: --prune removes exactly the orphans" {
  run bash "$SCRIPT" --prune
  [ "$status" -eq 0 ]
  [ ! -f "$DOTFILES/config/bash/completions.d/gone.sh.bash" ]
  [ ! -f "$DOTFILES/config/zsh/completions.d/_gone.sh" ]
  [ ! -f "$DOTFILES/local/md/gone.sh.md" ]
  [ ! -f "$DOTFILES/local/man/man1/gone.sh.1" ]
  # and nothing else went with them
  [ -f "$DOTFILES/config/bash/completions.d/toolx.bash" ]
  [ -f "$DOTFILES/config/bash/completions.d/mytool.bash" ]
}

@test "install-completions: --prune is idempotent" {
  bash "$SCRIPT" --prune > /dev/null
  run bash "$SCRIPT" --prune
  [ "$status" -eq 0 ]
  [[ "$output" == *"no stale generated artifacts"* ]]
}

@test "install-completions: an unknown argument is rejected" {
  run bash "$SCRIPT" --nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown argument"* ]]
}
