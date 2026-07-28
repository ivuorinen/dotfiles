#!/usr/bin/env bats

# gh-set-profile picks a git profile from the repo path. It runs automatically,
# so the paths that must NOT act are as important as the ones that must: a
# wrong profile silently commits under the wrong identity.
#
# `git` is stubbed so the tests control the reported repo root and can observe
# whether `git profile use` was called.

setup()
{
  SETPROFILE="$BATS_TEST_DIRNAME/../local/bin/gh-set-profile"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
}

teardown()
{
  rm -rf "$TMP"
}

# $1 = value for --show-toplevel, $2 = exit status for --is-inside-work-tree
stub_git()
{
  cat > "$TMP/bin/git" << STUB
#!/usr/bin/env bash
case "\$*" in
  *--is-inside-work-tree*) exit $2 ;;
  *--show-toplevel*) echo "$1"; exit 0 ;;
  "profile use"*) echo "\$*" >> "$CALLS"; exit 0 ;;
esac
exit 0
STUB
  chmod +x "$TMP/bin/git"
}

@test "gh-set-profile: selects work under Code/s" {
  stub_git "$HOME/Code/s/some-repo" 0
  run env PATH="$TMP/bin:$PATH" "$SETPROFILE"
  [ "$status" -eq 0 ]
  grep -q 'profile use work' "$CALLS"
}

@test "gh-set-profile: selects home under Code/ivuorinen" {
  stub_git "$HOME/Code/ivuorinen/dotfiles" 0
  run env PATH="$TMP/bin:$PATH" "$SETPROFILE"
  [ "$status" -eq 0 ]
  grep -q 'profile use home' "$CALLS"
}

@test "gh-set-profile: selects masf under Code/masf-fi" {
  stub_git "$HOME/Code/masf-fi/thing" 0
  run env PATH="$TMP/bin:$PATH" "$SETPROFILE"
  [ "$status" -eq 0 ]
  grep -q 'profile use masf' "$CALLS"
}

@test "gh-set-profile: sets nothing for an unrecognised path" {
  stub_git "$HOME/Code/elsewhere/repo" 0
  run env PATH="$TMP/bin:$PATH" "$SETPROFILE"
  [ "$status" -eq 0 ]
  [ ! -s "$CALLS" ]
}

@test "gh-set-profile: sets nothing outside a repository" {
  stub_git "" 1
  run env PATH="$TMP/bin:$PATH" "$SETPROFILE"
  [ "$status" -eq 0 ]
  [ ! -s "$CALLS" ]
}

@test "gh-set-profile: does not match a prefix collision" {
  # Code/svelte-thing must not be read as the Code/s profile.
  stub_git "$HOME/Code/svelte-thing/repo" 0
  run env PATH="$TMP/bin:$PATH" "$SETPROFILE"
  [ "$status" -eq 0 ]
  [ ! -s "$CALLS" ]
}
