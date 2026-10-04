#!/usr/bin/env bats

# `dfm install imagick` downloads beside $XDG_BIN_HOME/magick and moves the
# file into place only after curl -f succeeds, so a failed download keeps the
# working binary. dfm-install normally sources config/shared.sh, which
# rebuilds PATH and would bypass the curl stub; DOTFILES points at a scratch
# tree whose shared.sh is empty, with the real msgr beside it.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/dotfiles/config" "$TMP/dotfiles/local/bin" "$TMP/bin" "$TMP/xdgbin"
  : > "$TMP/dotfiles/config/shared.sh"
  ln -s "$REPO/local/bin/msgr" "$TMP/dotfiles/local/bin/msgr"
  printf 'OLD\n' > "$TMP/xdgbin/magick"
  chmod +x "$TMP/xdgbin/magick"

  cat > "$TMP/bin/curl" << 'STUB'
#!/usr/bin/env bash
out=""
while [ $# -gt 0 ]; do
  [ "$1" = "-o" ] && out="$2"
  shift
done
# A failed download may still leave a partial file behind.
if [ -n "$CURL_FAIL" ]; then
  printf 'partial' > "$out"
  exit 22
fi
printf 'NEW\n' > "$out"
STUB
  chmod +x "$TMP/bin/curl"
}

teardown()
{
  rm -rf "$TMP"
}

imagick()
{
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" XDG_BIN_HOME="$TMP/xdgbin" \
    "$@" "$REPO/local/bin/dfm-install" imagick
}

@test "dfm install imagick: a failed download keeps the old binary" {
  imagick CURL_FAIL=1
  [ "$status" -ne 0 ]
  [[ "$output" == *"imagick download failed"* ]]
  [ "$(cat "$TMP/xdgbin/magick")" = "OLD" ]
  [ "$(find "$TMP/xdgbin" -name '.magick.*' | wc -l)" -eq 0 ]
}

@test "dfm install imagick: a good download replaces the binary" {
  imagick
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/xdgbin/magick")" = "NEW" ]
  [ -x "$TMP/xdgbin/magick" ]
  [ "$(find "$TMP/xdgbin" -name '.magick.*' | wc -l)" -eq 0 ]
}
