#!/usr/bin/env bats
# Tests for local/bin/x-organize-audiobooks.py. Every fixture is an empty file
# in a throwaway folder: the script only renames, so no audio is needed.

bats_require_minimum_version 1.5.0

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../local/bin/x-organize-audiobooks.py"
  TMPDIR_TEST="$(mktemp -d)"
  export TMPDIR_TEST
  LIB="$TMPDIR_TEST/lib"
  mkdir -p "$LIB"
}

teardown()
{
  chmod -R u+w "$TMPDIR_TEST" 2> /dev/null || true
  rm -rf "$TMPDIR_TEST"
}

book()
{
  local name
  for name in "$@"; do : > "$LIB/$name"; done
}

# A fake ffprobe that prints $STUB_TITLE and exits $STUB_STATUS. Tests pass both
# through `env` on the run line: an export inside a @test body is a subshell
# modification shellcheck reports (SC2030/SC2031).
stub_ffprobe()
{
  mkdir -p "$TMPDIR_TEST/bin"
  cat > "$TMPDIR_TEST/bin/ffprobe" << 'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$TMPDIR_TEST/ffprobe.calls"
printf '%s\n' "$STUB_TITLE"
exit "${STUB_STATUS:-0}"
EOF
  chmod +x "$TMPDIR_TEST/bin/ffprobe"
  PATH="$TMPDIR_TEST/bin:$PATH"
}

@test "x-organize-audiobooks: prints usage on --help" {
  run python3 "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage:"* ]]
}

@test "x-organize-audiobooks: exits 2 when DIR is not a directory" {
  run --separate-stderr python3 "$SCRIPT" -n "$TMPDIR_TEST/missing"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"is not a directory"* ]]
}

@test "x-organize-audiobooks: dry run applies the naming rules" {
  book "01 Live.m4b" "01 2001; A Space Odyssey.m4b" "For We Are Many [B01N17THEO].m4b" \
    "1632, Part 1.m4b" "Foo, Part 2 [B0PART0002].m4b" "1-01 Miracle Of Self Discipline.mp3" \
    "01 Rework (Unabridged).m4b" "01 Flying Saucer Tour, Vol I.m4b" \
    "A Tale of Two Cities [Tantor] [B002V08IYW].m4b" "01 Upper.M4B" 'Q? A: "B" <C>|D\E.m4b'
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  expected="$(
    cat << 'EOF'
move  01 2001; A Space Odyssey.m4b -> 2001_ A Space Odyssey/2001_ A Space Odyssey.m4b
move  01 Flying Saucer Tour, Vol I.m4b -> Flying Saucer Tour, Vol I/Flying Saucer Tour, Vol I.m4b
move  01 Live.m4b -> Live/Live.m4b
move  01 Rework (Unabridged).m4b -> Rework (Unabridged)/Rework (Unabridged).m4b
move  01 Upper.M4B -> Upper/Upper.M4B
move  1-01 Miracle Of Self Discipline.mp3 -> Miracle Of Self Discipline/Miracle Of Self Discipline.mp3
move  1632, Part 1.m4b -> 1632/1632, Part 1.m4b
move  A Tale of Two Cities [Tantor] [B002V08IYW].m4b -> A Tale of Two Cities/A Tale of Two Cities [Tantor] [B002V08IYW].m4b
move  Foo, Part 2 [B0PART0002].m4b -> Foo/Foo, Part 2 [B0PART0002].m4b
move  For We Are Many [B01N17THEO].m4b -> For We Are Many/For We Are Many [B01N17THEO].m4b
move  Q? A: "B" <C>|D\E.m4b -> Q_ A_ _B_ _C__D_E/Q_ A_ _B_ _C__D_E.m4b
dry run: would move 11, skip 0, fail 0
EOF
  )"
  [ "$output" = "$expected" ]
}

@test "x-organize-audiobooks: skips a name with no title left" {
  book "01 .m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  01 .m4b: no title left in the name" ]
  [ "${lines[1]}" = "dry run: would move 0, skip 1, fail 0" ]
}

@test "x-organize-audiobooks: ignores hidden files, other types, symlinks and subfolders" {
  book "01 Live.m4b" ".hidden.m4b" "notes.txt"
  ln -s "01 Live.m4b" "$LIB/link.m4b"
  mkdir "$LIB/Sub"
  book "Sub/Inside.m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "move  01 Live.m4b -> Live/Live.m4b" ]
}

@test "x-organize-audiobooks: DIR defaults to the current folder" {
  book "01 Live.m4b"
  cd "$LIB"
  run --separate-stderr python3 "$SCRIPT" -n
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  01 Live.m4b -> Live/Live.m4b" ]
}

@test "x-organize-audiobooks: moves each book into its folder" {
  book "01 Live.m4b" "1632, Part 1.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ -f "$LIB/Live/Live.m4b" ] && [ ! -e "$LIB/01 Live.m4b" ]
  [ -f "$LIB/1632/1632, Part 1.m4b" ] && [ ! -e "$LIB/1632, Part 1.m4b" ]
  [ "${lines[2]}" = "moved 2, skipped 0, failed 0" ]
}

@test "x-organize-audiobooks: moves the file itself, never a copy" {
  # stat's flags differ between macOS and Linux; python3 is already required.
  inode='import os, sys; print(os.stat(sys.argv[1]).st_ino)'
  printf 'audio' > "$LIB/01 Live.m4b"
  before="$(python3 -c "$inode" "$LIB/01 Live.m4b")"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "$(python3 -c "$inode" "$LIB/Live/Live.m4b")" = "$before" ]
  [ "$(cat "$LIB/Live/Live.m4b")" = "audio" ]
}

@test "x-organize-audiobooks: skips a book whose folder name would be empty or hidden" {
  book "01 , Part 2.m4b" "01 ...And Ladies of the Club.m4b" "01 ...m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  01 , Part 2.m4b: folder name would be empty or hidden" ]
  [ "${lines[1]}" = "skip  01 ...And Ladies of the Club.m4b: folder name would be empty or hidden" ]
  [ "${lines[2]}" = "skip  01 ...m4b: folder name would be empty or hidden" ]
  [ "${lines[3]}" = "moved 0, skipped 3, failed 0" ]
  [ "$(ls -A "$TMPDIR_TEST")" = "lib" ]
}

@test "x-organize-audiobooks: dry run changes nothing and prints what the real run does" {
  book "01 Cat's Cradle.m4b" "Cat's Cradle.m4b" "01 Live.m4b"
  before="$(ls -AR "$LIB")"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  dry=("${lines[@]}")
  [ "$(ls -AR "$LIB")" = "$before" ]
  [ "${dry[3]}" = "dry run: would move 2, skip 1, fail 0" ]
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[3]}" = "moved 2, skipped 1, failed 0" ]
  [ "${dry[*]:0:3}" = "${lines[*]:0:3}" ]
}

@test "x-organize-audiobooks: leaves the second copy of a duplicate in place" {
  book "01 Cat's Cradle.m4b" "Cat's Cradle.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  01 Cat's Cradle.m4b -> Cat's Cradle/Cat's Cradle.m4b" ]
  [ "${lines[1]}" = "skip  Cat's Cradle.m4b: Cat's Cradle/Cat's Cradle.m4b already exists" ]
  [ -f "$LIB/Cat's Cradle.m4b" ]
}

@test "x-organize-audiobooks: treats decomposed and composed ä as the same name" {
  book "01 $(printf 'Ja\314\210niksen vuosi').m4b" "$(printf 'J\303\244niksen vuosi').m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "move  01 "* ]]
  [[ "${lines[1]}" == "skip  "*"already exists" ]]
}

@test "x-organize-audiobooks: reuses an existing book folder" {
  mkdir "$LIB/1632"
  book "1632/1632, Part 1.m4b" "1632, Part 2.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ -f "$LIB/1632/1632, Part 1.m4b" ] && [ -f "$LIB/1632/1632, Part 2.m4b" ]
}

@test "x-organize-audiobooks: skips a book whose folder name is taken by a file" {
  book "Live" "01 Live.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  01 Live.m4b: Live exists and is not a folder" ]
}

@test "x-organize-audiobooks: reports a failed move on stderr and exits 1" {
  [ "$(id -u)" -ne 0 ] || skip "root ignores folder permissions"
  mkdir "$LIB/Live"
  chmod 555 "$LIB/Live"
  book "01 Live.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 1 ]
  [[ "$stderr" == "fail  01 Live.m4b -> Live/Live.m4b: [Errno "* ]]
  [ -f "$LIB/01 Live.m4b" ]
  [ "${lines[0]}" = "moved 0, skipped 0, failed 1" ]
}

@test "x-organize-audiobooks: a second run only reports the copies left behind" {
  book "01 Cat's Cradle.m4b" "Cat's Cradle.m4b" "01 Live.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "skip  Cat's Cradle.m4b: Cat's Cradle/Cat's Cradle.m4b already exists" ]
  [ "${lines[1]}" = "moved 0, skipped 1, failed 0" ]
}

@test "x-organize-audiobooks: completes a title cut short without a space before [...]" {
  stub_ffprobe
  title="Scrum: A Step-by-Step Guide to Managing Product Development: Lean Six, Book 7"
  src="Scrum_ A Step-by-Step Guide to Managing Product De[...] [B07Q76B9SB].m4b"
  folder="Scrum_ A Step-by-Step Guide to Managing Product Development_ Lean Six, Book 7"
  book "$src"
  run --separate-stderr env STUB_TITLE="$title" python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  $src -> $folder/$folder [B07Q76B9SB].m4b" ]
}

@test "x-organize-audiobooks: completes a title cut short with a space before [...]" {
  stub_ffprobe
  title="The Conception of Terror: Tales Inspired by M. R. James - Volume 1: An Audible Original Drama"
  src="The Conception of Terror_ Tales Inspired by M. R. [...] [B07MR6RY3T].m4b"
  folder="The Conception of Terror_ Tales Inspired by M. R. James - Volume 1_ An Audible Original Drama"
  book "$src"
  run --separate-stderr env STUB_TITLE="$title" python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  $src -> $folder/$folder [B07MR6RY3T].m4b" ]
}

@test "x-organize-audiobooks: reads stored titles only for truncated names" {
  stub_ffprobe
  book "01 Live.m4b" "For We Are Many [B01N17THEO].m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ ! -e "$TMPDIR_TEST/ffprobe.calls" ]
}

@test "x-organize-audiobooks: skips a truncated title when ffprobe is missing" {
  # The empty PATH goes through env so it reaches only the script: bats' own
  # `run --separate-stderr` calls mktemp and needs the normal PATH.
  py="$(python3 -c 'import sys; print(sys.executable)')"
  mkdir "$TMPDIR_TEST/empty"
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr env PATH="$TMPDIR_TEST/empty" "$py" "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  Cut[...] [B0TEST0001].m4b: no stored title (ffprobe not found)" ]
}

@test "x-organize-audiobooks: skips a truncated title when the stored title is empty" {
  stub_ffprobe
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr env STUB_TITLE="" python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  Cut[...] [B0TEST0001].m4b: no stored title (empty)" ]
}

@test "x-organize-audiobooks: skips a truncated title when ffprobe fails" {
  stub_ffprobe
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr env STUB_TITLE="ignored" STUB_STATUS=1 python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  Cut[...] [B0TEST0001].m4b: no stored title (ffprobe exited 1)" ]
}

@test "x-organize-audiobooks: skips a name over the length limit" {
  stub_ffprobe
  title="$(printf 'A%.0s' {1..300})"
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr env STUB_TITLE="$title" python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "skip  Cut[...] [B0TEST0001].m4b: "*"too long"* ]]
  [ -f "$LIB/Cut[...] [B0TEST0001].m4b" ]
}

@test "x-organize-audiobooks: counts the length limit in bytes, not characters" {
  stub_ffprobe
  # 130 × ä: 130 characters, 260 bytes.
  title="$(printf '\303\244%.0s' {1..130})"
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr env STUB_TITLE="$title" python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "skip  Cut[...] [B0TEST0001].m4b: "*"too long"* ]]
  [ -f "$LIB/Cut[...] [B0TEST0001].m4b" ]
}
