#!/usr/bin/env bats

setup()
{
  export DOTFILES="$PWD"
}

# ── Group 1: Main help & routing ──────────────────────────────

@test "dfm help shows usage" {
  run bash local/bin/dfm help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: dfm"* ]]
}

@test "dfm with no args shows full usage with all sections" {
  run bash local/bin/dfm
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: dfm"* ]]
  [[ "$output" == *"dfm install"* ]]
  [[ "$output" == *"dfm check"* ]]
  [[ "$output" == *"dfm helpers"* ]]
  [[ "$output" == *"dfm docs"* ]]
  [[ "$output" == *"dfm dotfiles"* ]]
  [[ "$output" == *"dfm scripts"* ]]
}

@test "dfm with invalid section shows usage" {
  run bash local/bin/dfm nonexistent
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: dfm"* ]]
}

# ── Group 2: Install menu completeness ────────────────────────

@test "dfm install menu shows all entries" {
  run bash local/bin/dfm install
  [ "$status" -eq 0 ]
  [[ "$output" == *"all"* ]]
  [[ "$output" == *"apt-packages"* ]]
  [[ "$output" == *"cheat-databases"* ]]
  [[ "$output" == *"composer"* ]]
  [[ "$output" == *"dnf-packages"* ]]
  [[ "$output" == *"fonts"* ]]
  [[ "$output" == *"gh"* ]]
  [[ "$output" == *"imagick"* ]]
  [[ "$output" == *"macos"* ]]
  [[ "$output" == *"mise"* ]]
  [[ "$output" == *"ntfy"* ]]
  [[ "$output" == *"python-libs"* ]]
  [[ "$output" == *"shellspec"* ]]
  [[ "$output" == *"xcode-cli-tools"* ]]
  [[ "$output" == *"z"* ]]
}

@test "dfm install with invalid subcommand shows menu" {
  run bash local/bin/dfm install nonexistent
  [ "$status" -eq 0 ]
  [[ "$output" == *"dfm install"* ]]
}

# ── Group 3: Other section menus ──────────────────────────────

@test "dfm helpers menu shows entries" {
  run bash local/bin/dfm helpers
  [ "$status" -eq 0 ]
  [[ "$output" == *"aliases"* ]]
  [[ "$output" == *"colors"* ]]
  [[ "$output" == *"path"* ]]
  [[ "$output" == *"env"* ]]
}

@test "dfm docs menu shows entries" {
  run bash local/bin/dfm docs
  [ "$status" -eq 0 ]
  [[ "$output" == *"all"* ]]
  [[ "$output" == *"tmux"* ]]
  [[ "$output" == *"nvim"* ]]
  [[ "$output" == *"wezterm"* ]]
}

@test "dfm dotfiles menu shows entries" {
  run bash local/bin/dfm dotfiles
  [ "$status" -eq 0 ]
  [[ "$output" == *"fmt"* ]]
  [[ "$output" == *"shfmt"* ]]
  [[ "$output" == *"yamlfmt"* ]]
}

@test "dfm check menu shows entries" {
  run bash local/bin/dfm check
  [ "$status" -eq 0 ]
  [[ "$output" == *"arch"* ]]
  [[ "$output" == *"host"* ]]
}

@test "dfm scripts menu lists install scripts" {
  run bash local/bin/dfm scripts
  [ "$status" -eq 0 ]
  [[ "$output" == *"fonts"* ]]
  [[ "$output" == *"z"* ]]
}

@test "dfm tests menu shows entries" {
  run bash local/bin/dfm tests
  [ "$status" -eq 0 ]
  [[ "$output" == *"msgr"* ]]
  [[ "$output" == *"params"* ]]
}

# ── Group 4: Check commands ───────────────────────────────────

@test "dfm check arch returns current arch" {
  run bash local/bin/dfm check arch
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "dfm check arch with matching value exits 0" {
  local current_arch
  current_arch="$(uname)"
  run bash local/bin/dfm check arch "$current_arch"
  [ "$status" -eq 0 ]
}

@test "dfm check arch with non-matching value exits 1" {
  run bash local/bin/dfm check arch FakeArch
  [ "$status" -eq 1 ]
}

@test "dfm check host returns current hostname" {
  run bash local/bin/dfm check host
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "dfm check host with non-matching value exits 1" {
  run bash local/bin/dfm check host fakehostname
  [ "$status" -eq 1 ]
}

# ── Group 5: Secrets ──────────────────────────────────────────

# Build a minimal fake DOTFILES tree so `dfm secrets create` writes
# into a throwaway dir instead of the real repo. Only shared.sh and
# msgr are needed for dfm to start.
fake_dotfiles()
{
  local dir="$1"
  mkdir -p "$dir/local/bin" "$dir/config"
  cp local/bin/msgr "$dir/local/bin/"
  : > "$dir/config/shared.sh"
}

@test "dfm secrets menu lists create and github" {
  run bash local/bin/dfm secrets
  [ "$status" -eq 0 ]
  [[ "$output" == *"create"* ]]
  [[ "$output" == *"github"* ]]
}

@test "dfm secrets create with no env name errors" {
  run bash local/bin/dfm secrets create
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "dfm secrets create rejects invalid env var name" {
  run bash local/bin/dfm secrets create 1BAD
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid environment variable name"* ]]
}

@test "dfm secrets create rejects path-traversing filename" {
  run bash local/bin/dfm secrets create GITHUB_TOKEN ../evil
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid secrets filename"* ]]
}

@test "dfm secrets create derives filename from env name and writes both shells" {
  local tmp
  tmp="$(mktemp -d)"
  fake_dotfiles "$tmp"
  run bash -c "printf 'secretvalue\n' | DOTFILES='$tmp' bash local/bin/dfm secrets create GITHUB_TOKEN"
  [ "$status" -eq 0 ]
  [ -f "$tmp/config/fish/secrets.d/github.fish" ]
  [ -f "$tmp/config/secrets.d/github.sh" ]
  [[ "$(cat "$tmp/config/fish/secrets.d/github.fish")" == *"set -x GITHUB_TOKEN 'secretvalue'"* ]]
  [[ "$(cat "$tmp/config/secrets.d/github.sh")" == *"export GITHUB_TOKEN='secretvalue'"* ]]
  rm -rf "$tmp"
}

@test "dfm secrets create stores special characters verbatim in both shells" {
  local tmp value
  tmp="$(mktemp -d)"
  fake_dotfiles "$tmp"
  # A value with $, ", \, ', backtick and a space — chars that would be
  # expanded or break the file if written inside double quotes. Pass it
  # via stdin and positional args so the test harness never re-quotes it.
  value=$'a$b"c\\d\'e f`g'
  printf '%s\n' "$value" > "$tmp/in"

  run bash -c 'DOTFILES="$1" bash local/bin/dfm secrets create MY_SECRET < "$2"' _ "$tmp" "$tmp/in"
  [ "$status" -eq 0 ]

  # sh: sourcing must yield the original value unchanged.
  run bash -c '. "$1"; printf "%s" "$MY_SECRET"' _ "$tmp/config/secrets.d/my.sh"
  [ "$output" = "$value" ]

  # fish: sourcing must yield the original value unchanged.
  if command -v fish > /dev/null 2>&1; then
    run fish -c 'source $argv[1]; printf "%s" $MY_SECRET' "$tmp/config/fish/secrets.d/my.fish"
    [ "$output" = "$value" ]
  fi
  rm -rf "$tmp"
}

@test "dfm secrets create writes files readable only by owner" {
  local tmp perms
  tmp="$(mktemp -d)"
  fake_dotfiles "$tmp"
  run bash -c "printf 'tok\n' | DOTFILES='$tmp' bash local/bin/dfm secrets create GITHUB_TOKEN"
  [ "$status" -eq 0 ]
  perms="$(stat -f '%Lp' "$tmp/config/secrets.d/github.sh" 2> /dev/null \
    || stat -c '%a' "$tmp/config/secrets.d/github.sh")"
  [ "$perms" = "600" ]
  rm -rf "$tmp"
}

@test "dfm secrets create honors an explicit filename" {
  local tmp
  tmp="$(mktemp -d)"
  fake_dotfiles "$tmp"
  run bash -c "printf 'tok\n' | DOTFILES='$tmp' bash local/bin/dfm secrets create SONAR_TOKEN sonarcloud"
  [ "$status" -eq 0 ]
  [ -f "$tmp/config/fish/secrets.d/sonarcloud.fish" ]
  [ -f "$tmp/config/secrets.d/sonarcloud.sh" ]
  [[ "$(cat "$tmp/config/fish/secrets.d/sonarcloud.fish")" == *'set -x SONAR_TOKEN'* ]]
  rm -rf "$tmp"
}

@test "dfm secrets create with empty value errors" {
  local tmp
  tmp="$(mktemp -d)"
  fake_dotfiles "$tmp"
  run bash -c "printf '\n' | DOTFILES='$tmp' bash local/bin/dfm secrets create GITHUB_TOKEN"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No value provided"* ]]
  [ ! -f "$tmp/config/secrets.d/github.sh" ]
  rm -rf "$tmp"
}

@test "dfm secrets github delegates to create with github filename" {
  local tmp
  tmp="$(mktemp -d)"
  fake_dotfiles "$tmp"
  run bash -c "printf 'ghtok\n' | DOTFILES='$tmp' bash local/bin/dfm secrets github"
  [ "$status" -eq 0 ]
  [ -f "$tmp/config/fish/secrets.d/github.fish" ]
  [ -f "$tmp/config/secrets.d/github.sh" ]
  [[ "$(cat "$tmp/config/secrets.d/github.sh")" == *"export GITHUB_TOKEN='ghtok'"* ]]
  rm -rf "$tmp"
}
