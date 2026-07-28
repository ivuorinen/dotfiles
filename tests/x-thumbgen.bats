#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-thumbgen walks a directory and shells out to ImageMagick for each image.
# magick and mimetype are stubbed: no image is decoded, and the MIME type is
# decided by file extension so the fixture needs no real image data. The stub
# still creates the output file, so the naming and directory-mirroring rules
# can be asserted from the filesystem.

setup()
{
  TG="$BATS_TEST_DIRNAME/../local/bin/x-thumbgen"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/src/nested"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env find mkdir rm cat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done

  # Records the invocation and creates the output file, which is the last
  # argument. Nothing is decoded.
  cat > "$TMP/bin/magick" << STUB
#!/usr/bin/env bash
printf 'magick %s\n' "\$*" >> "$CALLS"
[ -n "\$MAGICK_FAIL" ] && exit 1
for last; do :; done
printf 'THUMB\n' > "\$last"
STUB

  cat > "$TMP/bin/mimetype" << 'STUB'
#!/usr/bin/env bash
f="${2:-$1}"
case "$f" in
  *.jpg | *.jpeg) printf 'image/jpeg\n' ;;
  *.png) printf 'image/png\n' ;;
  *.txt) printf 'text/plain\n' ;;
  *) printf 'application/octet-stream\n' ;;
esac
STUB
  chmod +x "$TMP/bin/magick" "$TMP/bin/mimetype"

  printf 'x\n' > "$TMP/src/photo.jpg"
  printf 'x\n' > "$TMP/src/notes.txt"
  printf 'x\n' > "$TMP/src/nested/deep.png"
}

teardown()
{
  rm -rf "$TMP"
}

tg()
{
  run env PATH="$TMP/bin" "$TG" "$@"
}

@test "thumbgen: -h prints usage and exits 0" {
  tg -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "thumbgen: --help prints usage and exits 0" {
  tg --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "thumbgen: an unknown long option is rejected" {
  tg --frobnicate "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option --frobnicate"* ]]
}

@test "thumbgen: an invalid short option is rejected" {
  tg -z "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid option"* ]]
}

@test "thumbgen: -o without a value is rejected" {
  tg -o
  [ "$status" -eq 1 ]
  [[ "$output" == *"requires an argument"* ]]
}

@test "thumbgen: no source directory is an error" {
  tg
  [ "$status" -eq 1 ]
  [[ "$output" == *"Source directory not specified"* ]]
}

@test "thumbgen: a source directory that does not exist is an error" {
  tg "$TMP/nope"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "thumbgen: refuses to run without ImageMagick" {
  rm "$TMP/bin/magick"
  tg "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"'magick' command not found"* ]]
}

@test "thumbgen: refuses to run without mimetype" {
  rm "$TMP/bin/mimetype"
  tg "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"'mimetype' command not found"* ]]
}

@test "thumbgen: writes the thumbnail next to the source by default" {
  tg "$TMP/src"
  [ "$status" -eq 0 ]
  [ -f "$TMP/src/photo_thumb.jpg" ]
}

@test "thumbgen: -o sends thumbnails to another directory" {
  tg -o "$TMP/out" "$TMP/src"
  [ -f "$TMP/out/photo_thumb.jpg" ]
  [ ! -f "$TMP/src/photo_thumb.jpg" ]
}

@test "thumbgen: mirrors the source subdirectories under the output" {
  tg -o "$TMP/out" "$TMP/src"
  [ -f "$TMP/out/nested/deep_thumb.png" ]
}

@test "thumbgen: -s sets the suffix" {
  tg -s -small -o "$TMP/out" "$TMP/src"
  [ -f "$TMP/out/photo-small.jpg" ]
}

@test "thumbgen: skips a file ImageMagick cannot read" {
  tg -o "$TMP/out" "$TMP/src"
  [[ "$output" == *"Skipping unsupported MIME type 'text/plain'"* ]]
  [ ! -f "$TMP/out/notes_thumb.txt" ]
}

@test "thumbgen: does not make thumbnails of its own thumbnails" {
  # Running twice against the source directory is the normal case, since the
  # output defaults to the source.
  tg "$TMP/src"
  tg "$TMP/src"
  [ ! -f "$TMP/src/photo_thumb_thumb.jpg" ]
}

@test "thumbgen: passes the resize, background and extent settings to magick" {
  run env PATH="$TMP/bin" THUMB_BACKGROUND=black THUMB_RESIZE=100x100 \
    THUMB_EXTENT=200x200 "$TG" -o "$TMP/out" "$TMP/src"
  grep -q -- '-resize 100x100' "$CALLS"
  grep -q -- '-background black' "$CALLS"
  grep -q -- '-extent 200x200' "$CALLS"
}

@test "thumbgen: THUMB_SOURCE is used when no directory is given" {
  run env PATH="$TMP/bin" THUMB_SOURCE="$TMP/src" THUMB_OUTPUT="$TMP/out" "$TG"
  [ "$status" -eq 0 ]
  [ -f "$TMP/out/photo_thumb.jpg" ]
}

@test "thumbgen: a positional directory overrides THUMB_SOURCE" {
  mkdir -p "$TMP/other"
  printf 'x\n' > "$TMP/other/only.jpg"
  run env PATH="$TMP/bin" THUMB_SOURCE="$TMP/src" "$TG" -o "$TMP/out" "$TMP/other"
  [ -f "$TMP/out/only_thumb.jpg" ]
  [ ! -f "$TMP/out/photo_thumb.jpg" ]
}

@test "thumbgen: one failed conversion does not stop the run" {
  run env PATH="$TMP/bin" MAGICK_FAIL=1 "$TG" -o "$TMP/out" "$TMP/src"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Failed to generate thumbnail"* ]]
  # Both images were still attempted.
  [ "$(grep -c '^magick ' "$CALLS")" -eq 2 ]
}
