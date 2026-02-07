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
  [[ "$output" == *"cargo"* ]]
  [[ "$output" == *"cheat-databases"* ]]
  [[ "$output" == *"composer"* ]]
  [[ "$output" == *"dnf-packages"* ]]
  [[ "$output" == *"fonts"* ]]
  [[ "$output" == *"gh"* ]]
  [[ "$output" == *"git-crypt"* ]]
  [[ "$output" == *"go"* ]]
  [[ "$output" == *"imagick"* ]]
  [[ "$output" == *"macos"* ]]
  [[ "$output" == *"npm-packages"* ]]
  [[ "$output" == *"ntfy"* ]]
  [[ "$output" == *"nvm-latest"* ]]
  [[ "$output" == *"nvm"* ]]
  [[ "$output" == *"python-packages"* ]]
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
  [[ "$output" == *"cargo-packages"* ]]
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
