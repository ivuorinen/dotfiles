#!/usr/bin/env bats
#
# Coverage for `dfm check perms` and its --fix action.
#
# This check exists because dotbot cannot enforce anything: its create plugin
# applies `mode:` only when it creates a path, and logs "Path exists" forever
# after. ./install can therefore establish a mode but never restore one, which
# is how eleven directories drifted to 0777/0775 while dotbot-links.yaml
# declared 0700/0755.
#
# Every fixture points DOTFILES at a temp tree, so no test touches the real
# repo or the real home directory.

# SC2088 (tilde does not expand in quotes) is exactly the point here: these
# fixtures write a literal `~/...` into the YAML, because expanding the tilde
# is the checker's job — `path="${path/#\~/$HOME}"` — and substituting $HOME at
# fixture-writing time would test a path the parser never sees.
# shellcheck disable=SC2088

bats_require_minimum_version 1.5.0

setup()
{
  CHECK="${BATS_TEST_DIRNAME}/../local/bin/dfm-check"
  WORK="$(mktemp -d)"
  HOMEDIR="$WORK/home"
  mkdir -p "$WORK/tools" "$WORK/config/secrets.d" "$WORK/config/fish/secrets.d" "$HOMEDIR"
  # mkdir honours the caller's umask (0002 here), so the secrets directories
  # would start drifted and every test would report the same two fixes on top
  # of whatever it is actually asserting. Start them compliant.
  chmod 0700 "$WORK/config/secrets.d" "$WORK/config/fish/secrets.d"
  printf -- '---\n- defaults:\n    create:\n      mode: 0755\n' > "$WORK/tools/dotbot-defaults.yaml"
  export CHECK WORK HOMEDIR
}

teardown()
{
  rm -rf "$WORK"
}

# Run the check against the fixture tree. HOME is redirected too, so the
# security table's ~-relative entries resolve inside the fixture.
perms()
{
  env DOTFILES="$WORK" HOME="$HOMEDIR" bash "$CHECK" perms "$@"
}

# Declare a create: block with one entry at the given mode.
declare_dir()
{
  printf -- '---\n- create:\n    %s:\n      mode: %s\n' "$1" "$2" > "$WORK/dotbot-links.yaml"
}

@test "dfm check perms: reports drift and exits non-zero" {
  mkdir -p "$HOMEDIR/.local/state"
  chmod 0777 "$HOMEDIR/.local/state"
  declare_dir '~/.local/state' 0700
  run -1 perms
  [[ "$output" == *"mode drift"* ]]
  [[ "$output" == *"0777"* ]]
  # The printed repair must be the command the user can paste.
  [[ "$output" == *"chmod 0700"* ]]
}

@test "dfm check perms: a matching mode passes" {
  mkdir -p "$HOMEDIR/.local/state"
  chmod 0700 "$HOMEDIR/.local/state"
  declare_dir '~/.local/state' 0700
  run -0 perms
  [[ "$output" == *"match their declared mode"* ]]
}

# --fix is the half dotbot cannot do.
@test "dfm check perms --fix: repairs a drifted directory" {
  mkdir -p "$HOMEDIR/.local/state"
  chmod 0777 "$HOMEDIR/.local/state"
  declare_dir '~/.local/state' 0700
  run -0 perms --fix
  [[ "$output" == *"fixed:"* ]]
  [ "$(stat -c '%a' "$HOMEDIR/.local/state")" = "700" ]
  # And the repair holds: a second pass has nothing left to do.
  run -0 perms
}

@test "dfm check perms --fix: is a no-op when nothing has drifted" {
  mkdir -p "$HOMEDIR/.local/state"
  chmod 0700 "$HOMEDIR/.local/state"
  declare_dir '~/.local/state' 0700
  run -0 perms --fix
  [[ "$output" == *"repaired 0"* ]]
}

# Files, not just directories: a secret at 0664 is the whole reason the
# security table exists, and dotbot has no directive for file modes at all.
@test "dfm check perms --fix: tightens a world-readable secret to 0600" {
  declare_dir '~/.cache' 0755
  mkdir -p "$HOMEDIR/.cache"
  chmod 0755 "$HOMEDIR/.cache"
  printf 'set -x TOKEN secret\n' > "$WORK/config/fish/secrets.d/github.fish"
  chmod 0664 "$WORK/config/fish/secrets.d/github.fish"
  printf 'export TOKEN=secret\n' > "$WORK/config/secrets.d/github.sh"
  chmod 0664 "$WORK/config/secrets.d/github.sh"

  run -0 perms --fix
  [ "$(stat -c '%a' "$WORK/config/fish/secrets.d/github.fish")" = "600" ]
  [ "$(stat -c '%a' "$WORK/config/secrets.d/github.sh")" = "600" ]
}

# The committed templates are not secrets and must keep their normal mode —
# the globs are written to exclude them, and a change that widened those globs
# would start rewriting tracked files.
@test "dfm check perms --fix: leaves the .example templates alone" {
  declare_dir '~/.cache' 0755
  mkdir -p "$HOMEDIR/.cache"
  chmod 0755 "$HOMEDIR/.cache"
  printf 'set -x TOKEN placeholder\n' > "$WORK/config/fish/secrets.d/github.fish.example"
  printf '# readme\n' > "$WORK/config/fish/secrets.d/README.md"
  printf 'export TOKEN=placeholder\n' > "$WORK/config/secrets.d/github.sh.example"
  chmod 0664 "$WORK/config/fish/secrets.d/github.fish.example" \
    "$WORK/config/fish/secrets.d/README.md" \
    "$WORK/config/secrets.d/github.sh.example"

  run -0 perms --fix
  [ "$(stat -c '%a' "$WORK/config/fish/secrets.d/github.fish.example")" = "664" ]
  [ "$(stat -c '%a' "$WORK/config/fish/secrets.d/README.md")" = "664" ]
  [ "$(stat -c '%a' "$WORK/config/secrets.d/github.sh.example")" = "664" ]
}

@test "dfm check perms --fix: tightens the secrets directories themselves" {
  declare_dir '~/.cache' 0755
  mkdir -p "$HOMEDIR/.cache"
  chmod 0755 "$HOMEDIR/.cache"
  # setup() starts these compliant, so drift them deliberately here.
  chmod 0775 "$WORK/config/secrets.d" "$WORK/config/fish/secrets.d"
  run -0 perms --fix
  [ "$(stat -c '%a' "$WORK/config/secrets.d")" = "700" ]
  [ "$(stat -c '%a' "$WORK/config/fish/secrets.d")" = "700" ]
}

# A path in the table that does not exist on this host is skipped, so entries
# for uninstalled tools cost nothing.
@test "dfm check perms: absent paths are skipped, not failed" {
  declare_dir '~/.cache' 0755
  mkdir -p "$HOMEDIR/.cache"
  chmod 0755 "$HOMEDIR/.cache"
  [ ! -e "$HOMEDIR/.aws" ]
  run -0 perms
}

# Fail-closed behaviour inherited from the parser hardening: a declaration the
# checker cannot trust must stop the run rather than be normalised away.
@test "dfm check perms: an invalid declared mode aborts" {
  declare_dir '~/.cache' invalid
  mkdir -p "$HOMEDIR/.cache"
  run -1 perms
}

@test "dfm check perms: a missing defaults file aborts" {
  declare_dir '~/.cache' 0755
  rm -f "$WORK/tools/dotbot-defaults.yaml"
  run -1 perms
}
