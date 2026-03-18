#!/usr/bin/env bats

setup()
{
  export DOTFILES="$PWD"
  # Pre-set CURRENT_SHELL so config/shared.sh's x-path-prepend works
  # even in environments where `ps` is unavailable.
  export CURRENT_SHELL="bash"
  # Use a temporary directory to isolate all XDG data operations
  export XDG_DATA_HOME="$BATS_TMPDIR/share"
  export XDG_BIN_HOME="$BATS_TMPDIR/bin"
  export XDG_CONFIG_HOME="$BATS_TMPDIR/config"
  export XDG_CACHE_HOME="$BATS_TMPDIR/cache"
  export XDG_STATE_HOME="$BATS_TMPDIR/state"
  mkdir -p "$XDG_DATA_HOME"
  mkdir -p "$XDG_BIN_HOME"
}

teardown()
{
  rm -rf "$BATS_TMPDIR/share" "$BATS_TMPDIR/bin" \
         "$BATS_TMPDIR/config" "$BATS_TMPDIR/cache" "$BATS_TMPDIR/state"
}

# ── Group 1: Argument validation ──────────────────────────────────────

@test "cleanup script rejects unknown arguments" {
  run bash scripts/cleanup-old-version-managers.sh --unknown-flag
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "cleanup script rejects positional argument" {
  run bash scripts/cleanup-old-version-managers.sh some-arg
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "cleanup script accepts --dry-run flag" {
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
}

@test "cleanup script runs successfully with no arguments" {
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
}

# ── Group 2: Dry-run does not remove directories ───────────────────────

@test "dry-run does not remove nvm data directory" {
  mkdir -p "$XDG_DATA_HOME/nvm"
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [ -d "$XDG_DATA_HOME/nvm" ]
}

@test "dry-run does not remove fnm data directory" {
  mkdir -p "$XDG_DATA_HOME/fnm"
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [ -d "$XDG_DATA_HOME/fnm" ]
}

@test "dry-run does not remove pyenv data directory" {
  mkdir -p "$XDG_DATA_HOME/pyenv"
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [ -d "$XDG_DATA_HOME/pyenv" ]
}

@test "dry-run does not remove goenv data directory" {
  mkdir -p "$XDG_DATA_HOME/goenv"
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [ -d "$XDG_DATA_HOME/goenv" ]
}

@test "dry-run does not remove bob-nvim data directory" {
  mkdir -p "$XDG_DATA_HOME/bob"
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [ -d "$XDG_DATA_HOME/bob" ]
}

@test "dry-run output mentions DRY RUN for each existing directory" {
  mkdir -p "$XDG_DATA_HOME/nvm"
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
}

# ── Group 3: Dry-run does not remove files ─────────────────────────────

@test "dry-run does not remove cargo-installed tool binaries" {
  mkdir -p "$XDG_DATA_HOME/cargo/bin"
  touch "$XDG_DATA_HOME/cargo/bin/bkt"
  touch "$XDG_DATA_HOME/cargo/bin/eza"
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [ -f "$XDG_DATA_HOME/cargo/bin/bkt" ]
  [ -f "$XDG_DATA_HOME/cargo/bin/eza" ]
}

# ── Group 4: Live run removes directories ──────────────────────────────

@test "live run removes nvm data directory when it exists" {
  mkdir -p "$XDG_DATA_HOME/nvm"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -d "$XDG_DATA_HOME/nvm" ]
}

@test "live run removes fnm data directory when it exists" {
  mkdir -p "$XDG_DATA_HOME/fnm"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -d "$XDG_DATA_HOME/fnm" ]
}

@test "live run removes pyenv data directory when it exists" {
  mkdir -p "$XDG_DATA_HOME/pyenv"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -d "$XDG_DATA_HOME/pyenv" ]
}

@test "live run removes goenv data directory when it exists" {
  mkdir -p "$XDG_DATA_HOME/goenv"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -d "$XDG_DATA_HOME/goenv" ]
}

@test "live run removes bob-nvim data directory when it exists" {
  mkdir -p "$XDG_DATA_HOME/bob"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -d "$XDG_DATA_HOME/bob" ]
}

@test "live run removes all version manager directories in one pass" {
  mkdir -p "$XDG_DATA_HOME/nvm"
  mkdir -p "$XDG_DATA_HOME/fnm"
  mkdir -p "$XDG_DATA_HOME/pyenv"
  mkdir -p "$XDG_DATA_HOME/goenv"
  mkdir -p "$XDG_DATA_HOME/bob"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -d "$XDG_DATA_HOME/nvm" ]
  [ ! -d "$XDG_DATA_HOME/fnm" ]
  [ ! -d "$XDG_DATA_HOME/pyenv" ]
  [ ! -d "$XDG_DATA_HOME/goenv" ]
  [ ! -d "$XDG_DATA_HOME/bob" ]
}

# ── Group 5: Live run removes cargo-installed files ────────────────────

@test "live run removes cargo-installed bkt binary" {
  mkdir -p "$XDG_DATA_HOME/cargo/bin"
  touch "$XDG_DATA_HOME/cargo/bin/bkt"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -f "$XDG_DATA_HOME/cargo/bin/bkt" ]
}

@test "live run removes cargo-installed eza binary" {
  mkdir -p "$XDG_DATA_HOME/cargo/bin"
  touch "$XDG_DATA_HOME/cargo/bin/eza"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -f "$XDG_DATA_HOME/cargo/bin/eza" ]
}

@test "live run removes cargo-installed rg binary" {
  mkdir -p "$XDG_DATA_HOME/cargo/bin"
  touch "$XDG_DATA_HOME/cargo/bin/rg"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -f "$XDG_DATA_HOME/cargo/bin/rg" ]
}

@test "live run is idempotent when directories do not exist" {
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
}

# ── Group 6: Go bin skipped when equal to XDG_BIN_HOME ────────────────

@test "go binaries are not removed when GO_BIN equals XDG_BIN_HOME" {
  # When $XDG_DATA_HOME/go/bin == $XDG_BIN_HOME the script skips removal
  export XDG_BIN_HOME="$XDG_DATA_HOME/go/bin"
  mkdir -p "$XDG_DATA_HOME/go/bin"
  touch "$XDG_DATA_HOME/go/bin/fzf"
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ -f "$XDG_DATA_HOME/go/bin/fzf" ]
}

@test "go binaries are removed when GO_BIN differs from XDG_BIN_HOME" {
  mkdir -p "$XDG_DATA_HOME/go/bin"
  touch "$XDG_DATA_HOME/go/bin/fzf"
  # XDG_BIN_HOME is $BATS_TMPDIR/bin which differs from $XDG_DATA_HOME/go/bin
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [ ! -f "$XDG_DATA_HOME/go/bin/fzf" ]
}

# ── Group 7: Output messages ───────────────────────────────────────────

@test "cleanup script prints completion message on success" {
  run bash scripts/cleanup-old-version-managers.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"Cleanup complete"* ]]
}

@test "dry-run prints completion message on success" {
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Cleanup complete"* ]]
}

@test "cleanup script notes Mason binaries will not be touched" {
  run bash scripts/cleanup-old-version-managers.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Mason"* ]]
}