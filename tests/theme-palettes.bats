#!/usr/bin/env bats
# Every theme family under config/theme/palettes.d/<family>/<mode>/ ships
# the full set of files the handlers resolve, in both modes, and every
# structured file parses. A family missing one would make its handler
# unlink that app's palette at runtime; this catches it in CI instead.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  PD="$ROOT/config/theme/palettes.d"
  # tmux.thm.conf is optional: only families that override @thm_* ship it.
  REQUIRED=(starship.toml eza.yml gitui.ron fzf
    gh-dash.theme.yml television.toml dircolors bat.theme)
}

families()
{
  local d
  for d in "$PD"/*/; do
    basename -- "$d"
  done
}

check_complete()
{
  local pd=$1 fam mode f missing=()
  for fam in $(PD="$pd" families); do
    for mode in dark light; do
      for f in "${REQUIRED[@]}"; do
        [[ -e "$pd/$fam/$mode/$f" ]] || missing+=("$fam/$mode/$f")
      done
    done
  done
  if ((${#missing[@]})); then
    printf 'missing: %s\n' "${missing[@]}"
    return 1
  fi
}

@test "palettes: at least catppuccin, kanagawa, oasis and warm-burnout exist" {
  [ -d "$PD/catppuccin" ]
  [ -d "$PD/kanagawa" ]
  [ -d "$PD/oasis" ]
  [ -d "$PD/warm-burnout" ]
}

@test "palettes: every family ships every handler file in both modes" {
  check_complete "$PD"
}

@test "palettes: the completeness check fails when a file is missing" {
  cp -R "$PD" "$BATS_TEST_TMPDIR/pd"
  rm "$BATS_TEST_TMPDIR/pd/kanagawa/light/gitui.ron"
  run check_complete "$BATS_TEST_TMPDIR/pd"
  [ "$status" -eq 1 ]
  [[ "$output" == *"kanagawa/light/gitui.ron"* ]]
}

@test "palettes: the tracked family file names an existing family" {
  run cat "$ROOT/config/theme/family"
  [ "$status" -eq 0 ]
  [ -d "$PD/$output" ]
}

@test "palettes: every TOML palette parses" {
  command -v python3 > /dev/null 2>&1 || skip "python3 not installed"
  run python3 - "$PD" << 'PY'
import pathlib, sys, tomllib
bad = []
for p in sorted(pathlib.Path(sys.argv[1]).rglob("*.toml")):
    try:
        tomllib.loads(p.read_text())
    except Exception as e:  # noqa: BLE001 - report every parse failure
        bad.append(f"{p}: {e}")
print("\n".join(bad))
sys.exit(1 if bad else 0)
PY
  [ "$status" -eq 0 ]
}

@test "palettes: every starship palette defines the colours the shared prompt uses" {
  command -v python3 > /dev/null 2>&1 || skip "python3 not installed"
  # handlers.d/starship appends one [palettes.active] table to
  # config/starship/starship.toml. Starship renders a missing role or a
  # malformed colour uncoloured, without a warning, and its schema types
  # palette entries as plain strings, so neither v8r nor starship catches
  # either; this does.
  run python3 - "$ROOT" << 'PY'
import pathlib, re, sys, tomllib

root = pathlib.Path(sys.argv[1])
base = tomllib.loads((root / "config/starship/starship.toml").read_text())
MODS = {"bold", "italic", "underline", "dimmed", "inverted", "blink", "hidden",
        "strikethrough", "none", "prev_fg", "prev_bg"}


def styles(v, key=""):
    if isinstance(v, dict):
        for k, x in v.items():
            yield from styles(x, k)
    elif isinstance(v, list):
        for x in v:
            yield from styles(x, key)
    elif isinstance(v, str):
        if "style" in key:
            yield v
        yield from re.findall(r"\]\(([^)$]+)\)", v)


used = {w.split(":", 1)[-1] for s in styles(base) for w in s.split()} - MODS
bad, checked = [], 0
for p in sorted((root / "config/theme/palettes.d").glob("*/*/starship.toml")):
    palette = tomllib.loads(p.read_text())["palettes"]["active"]
    missing = used - set(palette)
    if missing:
        bad.append(f"{p}: missing {sorted(missing)}")
    for role, value in palette.items():
        checked += 1
        if not re.fullmatch(r"#[0-9a-fA-F]{6}", value):
            bad.append(f"{p}: {role} = {value!r} is not #rrggbb")
print("\n".join(bad) if bad else f"roles used: {sorted(used)}; colours checked: {checked}")
sys.exit(1 if bad else 0)
PY
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sky"* ]]
  # Every family and mode was read: 8 palettes of 26 roles.
  [[ "$output" == *"colours checked: 208"* ]]
}

@test "palettes: every fzf palette loads as fzf's options file" {
  command -v fzf > /dev/null 2>&1 || skip "fzf not installed"
  local f
  for f in "$PD"/*/*/fzf; do
    # A bad option makes fzf exit 2; a clean load filters "x" and exits 0.
    printf 'x\n' | FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE="$f" fzf --filter x > /dev/null || {
      echo "fzf rejects $f"
      return 1
    }
  done
}

@test "palettes: every YAML palette parses" {
  command -v yamllint > /dev/null 2>&1 || skip "yamllint not installed"
  run yamllint -d '{extends: relaxed, rules: {line-length: disable}}' "$PD"
  [ "$status" -eq 0 ]
}

# Private tmux socket dir under /tmp, not BATS_TEST_TMPDIR: the socket
# path must fit macOS's 104-byte sun_path, and a deep TMPDIR overflows it.
private_tmux()
{
  # shellcheck disable=SC2030,SC2031
  TMUX_TMPDIR="$(mktemp -d /tmp/tmx.XXXXXX)"
  export TMUX_TMPDIR
  unset TMUX
}

teardown()
{
  if [[ -n "${TMUX_TMPDIR:-}" && "$TMUX_TMPDIR" == /tmp/tmx.* ]]; then
    tmux kill-server 2> /dev/null || true
    rm -rf -- "$TMUX_TMPDIR"
  fi
}

@test "palettes: every tmux palette parses" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  private_tmux
  # `sleep`, not a shell: a shell pane would run shell init, which spawns
  # the theme watcher with this test's environment.
  tmux -f /dev/null new-session -d -s parse 'sleep 300'
  local f rc=0
  for f in "$PD"/*/*/tmux.thm.conf "$ROOT/config/tmux/catppuccin.conf"; do
    tmux source-file -n "$f" || {
      echo "parse error: $f"
      rc=1
    }
  done
  tmux kill-server
  [ "$rc" -eq 0 ]
}

@test "tmux.conf: server options stay idempotent across the flip-time reload" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  private_tmux
  tmux -f /dev/null new-session -d -s idem 'sleep 300'
  # handlers.d/tmux re-sources tmux.conf on every flip, so any appending
  # `set -as`/`-ag` on an array option would grow it without bound.
  grep -E '^set +-s +terminal-features' "$ROOT/config/tmux/tmux.conf" > "$BATS_TEST_TMPDIR/tf.conf"
  [ -s "$BATS_TEST_TMPDIR/tf.conf" ]
  tmux source-file "$BATS_TEST_TMPDIR/tf.conf"
  local once
  once="$(tmux show -s terminal-features | wc -l)"
  tmux source-file "$BATS_TEST_TMPDIR/tf.conf"
  tmux source-file "$BATS_TEST_TMPDIR/tf.conf"
  local thrice
  thrice="$(tmux show -s terminal-features | wc -l)"
  tmux kill-server
  [ "$once" -eq "$thrice" ]
  run grep -nE '^set(-option)? +-[a-z]*a[a-z]* +terminal-features' "$ROOT/config/tmux/tmux.conf"
  [ "$status" -eq 1 ]
}

@test "palettes: every bat.theme names a vendored tmTheme" {
  local f name
  for f in "$PD"/*/*/bat.theme; do
    read -r name < "$f"
    [ -f "$ROOT/config/bat/themes/$name.tmTheme" ] || {
      echo "$f names missing tmTheme: $name"
      return 1
    }
  done
}
