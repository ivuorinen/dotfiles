#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# scripts/install-cheat-purebashbible.sh clones pure-bash-bible and turns each
# manuscript chapter into a cheatsheet with YAML front matter. git, cheat and
# x-have are PATH stubs, and DOTFILES points at a scratch tree whose shared.sh
# defines only the `replaceable` helper the script borrows from
# config/exports. The script must reach the chapter step: it once called
# msg_yay, which only msgr itself defines, and died with exit 127 straight
# after the clone.

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/install-cheat-purebashbible.sh"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/dotfiles/config" "$TMP/cache" "$TMP/cheats"
  # replaceable returns 1 when the destination should be overwritten.
  printf 'replaceable() { return 1; }\n' > "$TMP/dotfiles/config/shared.sh"
  CALLS="$TMP/calls"
  : > "$CALLS"

  # clone creates a checkout holding one chapter; every call is logged.
  cat > "$TMP/bin/git" << STUB
#!/usr/bin/env bash
printf 'git %s\n' "\$*" >> "$CALLS"
if [ "\$1" = clone ]; then
  dest="\${!#}"
  mkdir -p "\$dest/.git" "\$dest/manuscript"
  printf '# Strings\n\nTrim leading and trailing white-space.\n<!-- CHAPTER END -->\n' \
    > "\$dest/manuscript/chapter1.txt"
fi
exit 0
STUB

  printf '#!/bin/sh\nprintf "pure-bash-bible: %s\\n"\n' "$TMP/cheats" > "$TMP/bin/cheat"
  printf '#!/bin/sh\n[ "$1" != "${MISSING_TOOL:-}" ]\n' > "$TMP/bin/x-have"
  printf '#!/bin/sh\nprintf "%%s\\n" "$*"\n' > "$TMP/bin/msgr"
  chmod +x "$TMP/bin/"*
}

teardown()
{
  rm -rf "$TMP"
}

# Run the script against the stubs and the scratch cache.
run_pbb()
{
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" \
    XDG_CACHE_HOME="$TMP/cache" MISSING_TOOL="${MISSING_TOOL:-}" \
    bash "$SCRIPT"
}

@test "install-cheat-purebashbible: a fresh clone produces a cheatsheet" {
  run_pbb
  [ "$status" -eq 0 ]
  [ "$(head -1 "$TMP/cheats/strings")" = "---" ]
  grep -qx 'syntax: bash' "$TMP/cheats/strings"
  grep -q 'Trim leading and trailing' "$TMP/cheats/strings"
  run ! grep -q 'CHAPTER END' "$TMP/cheats/strings"
}

@test "install-cheat-purebashbible: an existing checkout is reset and pulled" {
  mkdir -p "$TMP/cache/cheat/pbb/.git" "$TMP/cache/cheat/pbb/manuscript"
  printf '# Arrays\n\nReverse an array.\n' > "$TMP/cache/cheat/pbb/manuscript/chapter2.txt"
  run_pbb
  [ "$status" -eq 0 ]
  grep -q 'reset --hard origin/master' "$CALLS"
  grep -q 'pull -q' "$CALLS"
  [ -f "$TMP/cheats/arrays" ]
  run ! grep -q 'git clone' "$CALLS"
}

@test "install-cheat-purebashbible: a missing tool stops before cloning" {
  MISSING_TOOL=cheat
  run_pbb
  [ "$status" -eq 1 ]
  [[ "$output" == *"cheat is missing"* ]]
  run ! grep -q 'git clone' "$CALLS"
}
