#!/usr/bin/env bats
# Guards the WCAG AA light palettes of every theme family.
#
# Catppuccin: the AA-darkened Latte (4.5:1 on #eff1f5). Upstream Latte
# accents sit at 2.3-3.5:1 on base, and several of these files originate
# upstream (bat .tmTheme, eza, catppuccin/tmux, the fish theme fisher
# manages). A refresh silently restores the unreadable values, so each
# check fails naming the file that regressed. The mapping lives in
# config/theme/palettes.d/catppuccin/light/starship.toml.
#
# Kanagawa: contrast is computed, not pattern-matched. Every colour a Lotus
# file uses outside its background set must reach 4.5:1 on #f2ecbc, and
# every Wave colour 4.5:1 on #1f1f28. The muted comment/overlay greys are a
# deliberate exception held to 3:1, below WCAG 1.4.3's 4.5:1 for text. The
# mapping lives in config/theme/palettes.d/kanagawa/light/starship.toml.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  CP="config/theme/palettes.d/catppuccin"
  KP="config/theme/palettes.d/kanagawa"
  # Upstream Latte accents below 4.5:1 on base. Mauve and red already pass
  # and are kept as upstream, so they are not listed.
  UPSTREAM_HEX='(dc8a78|dd7878|ea76cb|e64553|fe640b|df8e1d|40a02b|179299|04a5e5|209fb5|1e66f5|7287fd)'
  UPSTREAM_RGB='(220;138;120|221;120;120|234;118;203|230;69;83|254;100;11|223;142;29|64;160;43|23;146;153|4;165;229|32;159;181|30;102;245|114;135;253)'
}

# check_contrast <bg> <min> <muted-hexes> <bg-hexes> <label=path[@start@end]>...
# Every #rrggbb (and dircolors 38;2;R;G;B) outside comment lines and outside
# the background set must reach <min> on <bg>; muted hexes need 3:1. With
# @start@end, only the text between the first <start> and the next <end>
# after it is checked (one section of a mixed file).
check_contrast()
{
  python3 - "$ROOT" "$@" << 'PY'
import pathlib, re, sys

root, bg, need, muted, bgset, *targets = sys.argv[1:]
need = float(need)
muted = set(muted.split())
bgset = set(bgset.split()) | {bg}


def lum(h):
    c = [int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    c = [x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4 for x in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def ratio(a, b):
    la, lb = sorted([lum(a), lum(b)], reverse=True)
    return (la + 0.05) / (lb + 0.05)


bad = []
for spec in targets:
    rel, *cut = spec.split("@")
    text = (pathlib.Path(root) / rel).read_text()
    if cut:
        start = text.index(cut[0])
        text = text[start:text.index(cut[1], start + len(cut[0]))]
    for n, line in enumerate(text.splitlines(), 1):
        if re.match(r'\s*(#(?![0-9a-fA-F]{6})|//|--|")', line):
            continue
        found = [h.lower() for h in re.findall(r"#[0-9a-fA-F]{6}\b", line)]
        found += ["#%02x%02x%02x" % tuple(map(int, t)) for t in re.findall(r"38;2;(\d+);(\d+);(\d+)", line)]
        # fish themes carry bare hex values after the key
        m = re.match(r"(fish_\w+) (?!--)([0-9a-fA-F]{6})\b", line)
        if m:
            found.append("#" + m.group(2).lower())
        for h in found:
            if h in bgset:
                continue
            floor = 3.0 if h in muted else need
            r = ratio(h, bg)
            if r < floor:
                bad.append(f"{rel}:{n}: {h} is {r:.2f}:1 on {bg} (needs {floor})")
print("\n".join(bad))
sys.exit(1 if bad else 0)
PY
}

@test "light palettes carry no upstream low-contrast Latte accents" {
  local files=(
    "$CP/light/starship.toml"
    "$CP/light/eza.yml"
    "$CP/light/gitui.ron"
    "$CP/light/fzf.fish"
    "$CP/light/fzf.sh"
    "$CP/light/yazi.toml"
    "$CP/light/gh-dash.theme.yml"
    "$CP/light/tmux.thm.conf"
    "config/bat/themes/Catppuccin Latte.tmTheme"
    "config/fish/themes/catppuccin-aa.theme"
    "config/television/themes/catppuccin-latte-mauve.toml"
    "config/cosmic-desktop/themes/cosmic-term/catppuccin-latte.ron"
    "config/vim/colors/catppuccin_latte.vim"
    "config/vim/autoload/airline/themes/catppuccin_latte.vim"
    "config/vim/autoload/lightline/colorscheme/catppuccin_latte.vim"
    "config/nvim/init.lua"
    "config/wezterm/wezterm.lua"
  )
  local f
  for f in "${files[@]}"; do
    [ -f "$ROOT/$f" ] || {
      echo "missing: $f"
      return 1
    }
    if grep -Eiq "$UPSTREAM_HEX" "$ROOT/$f"; then
      echo "upstream Latte accent in $f:"
      grep -Ein "$UPSTREAM_HEX" "$ROOT/$f" | head -5
      return 1
    fi
  done
}

@test "dircolors light carries no upstream Latte RGB triplets" {
  run grep -En "38;2;$UPSTREAM_RGB([;[:space:]]|$)" "$ROOT/$CP/light/dircolors"
  [ "$status" -eq 1 ]
}

@test "AA overrides stay wired into each app" {
  grep -q 'color_overrides' "$ROOT/config/nvim/init.lua"
  grep -q "light = 'Catppuccin Latte AA'" "$ROOT/config/wezterm/wezterm.lua"
  grep -q 'light/tmux.thm.conf' "$ROOT/$CP/light/tmux.conf"
  grep -q "'catppuccin_latte'" "$ROOT/config/vim/vimrc"
  # Kanagawa
  grep -q "lotusYellow3 = '#8d6100'" "$ROOT/config/nvim/init.lua"
  grep -q "light = 'Kanagawa Lotus AA'" "$ROOT/config/wezterm/wezterm.lua"
  grep -q 'kanagawa/light/tmux.thm.conf' "$ROOT/$KP/light/tmux.conf"
  grep -q 'kanagawa/dark/tmux.thm.conf' "$ROOT/$KP/dark/tmux.conf"
  grep -q "'kanagawa_lotus'" "$ROOT/config/vim/vimrc"
  # The fish theme name is resolved per family, never hardcoded.
  grep -q '__dotfiles_theme_name' "$ROOT/config/fish/conf.d/theme-switch.fish"
  grep -q '__dotfiles_theme_name' "$ROOT/config/fish/config.fish"
  grep -q 'theme="${family}-aa"' "$ROOT/config/theme/handlers.d/fish"
}

# Lotus background inks (surfaces, selection, diff/search fills), plus
# #ffffff: yazi's progress label, drawn on the gauge fill rather than on
# the page background (the Catppuccin palettes use it the same way).
LOTUS_BG='#e5ddb0 #dcd5ac #e7dba0 #d5cea3 #a09cac #e4d794 #c7d7e0 #b5cbd2 #d7e3d8 #b7d0ae #d9a594 #f9d791 #c9cbd1 #dcd7ba #ffffff'
# Lotus overlays: muted by design, 3:1. They render text — comments, fish
# autosuggestions and pager descriptions, vim line numbers — so this is a
# deliberate exception below WCAG 1.4.3's 4.5:1, not AA compliance.
LOTUS_MUTED='#88877e #716e61 #766b90'

@test "kanagawa lotus: every non-muted foreground reaches WCAG AA on #f2ecbc" {
  command -v python3 > /dev/null 2>&1 || skip "python3 not installed"
  local targets=()
  local f
  for f in "$ROOT/$KP"/light/*; do
    [[ "$(basename "$f")" == bat.theme ]] && continue
    # The starship header quotes the upstream values it replaced.
    if [[ "$(basename "$f")" == starship.toml ]]; then
      targets+=("$KP/light/starship.toml@palette = @[os]")
      continue
    fi
    targets+=("${f#"$ROOT/"}")
  done
  targets+=(
    "config/fish/themes/kanagawa-aa.theme@"$'\n'"[light]"$'\n'"@"$'\n'"[dark]"$'\n'
    "config/vim/colors/kanagawa_lotus.vim"
    "config/vim/autoload/airline/themes/kanagawa_lotus.vim"
    "config/bat/themes/Kanagawa Lotus AA.tmTheme"
    "config/television/themes/kanagawa-lotus-aa.toml"
    "config/cosmic-desktop/themes/cosmic-term/kanagawa-lotus-aa.ron"
    "config/wezterm/wezterm.lua@local kanagawa_lotus_aa = {@config.color_schemes"
    "config/nvim/init.lua@lotusGray3@autumnRed"
  )
  run check_contrast '#f2ecbc' 4.5 "$LOTUS_MUTED" "$LOTUS_BG" "${targets[@]}"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "kanagawa lotus: the contrast check catches a planted low-contrast accent" {
  command -v python3 > /dev/null 2>&1 || skip "python3 not installed"
  mkdir -p "$BATS_TEST_TMPDIR/p"
  printf 'color = "#de9800"\n' > "$BATS_TEST_TMPDIR/p/planted.toml"
  ROOT="$BATS_TEST_TMPDIR" run check_contrast '#f2ecbc' 4.5 "$LOTUS_MUTED" "$LOTUS_BG" "p/planted.toml"
  [ "$status" -eq 1 ]
  [[ "$output" == *"#de9800 is 2.04:1"* ]]
}

# Wave background inks (sumiInk surfaces, waveBlue selections, diff fills,
# ANSI black #090618, the tmTheme selection border #222218). #54546d is
# also nontext/line-number ink, the same role Catppuccin's surface colours
# play, so it is held to the background set, not to text contrast.
WAVE_BG='#181820 #16161d #1a1a22 #2a2a37 #363646 #54546d #223249 #2d4f67 #252535 #2b3328 #43242b #49443c #090618 #222218'
# Wave comment greys: muted by design, 3:1.
WAVE_MUTED='#727169 #717c7c'

@test "kanagawa wave: every non-muted foreground reaches WCAG AA on #1f1f28" {
  command -v python3 > /dev/null 2>&1 || skip "python3 not installed"
  local targets=()
  local f
  for f in "$ROOT/$KP"/dark/*; do
    [[ "$(basename "$f")" == bat.theme ]] && continue
    if [[ "$(basename "$f")" == starship.toml ]]; then
      targets+=("$KP/dark/starship.toml@palette = @[os]")
      continue
    fi
    targets+=("${f#"$ROOT/"}")
  done
  targets+=(
    "config/fish/themes/kanagawa-aa.theme@"$'\n'"[dark]"$'\n'"@"$'\n'"[unknown]"$'\n'
    "config/vim/colors/kanagawa_wave.vim"
    "config/vim/autoload/airline/themes/kanagawa_wave.vim"
    "config/bat/themes/Kanagawa Wave.tmTheme"
    "config/television/themes/kanagawa-wave.toml"
    "config/cosmic-desktop/themes/cosmic-term/kanagawa-wave.ron"
    "config/wezterm/wezterm.lua@local kanagawa_wave = {@local kanagawa_lotus_aa"
    "config/nvim/init.lua@autumnRed = @}"
  )
  run check_contrast '#1f1f28' 4.5 "$WAVE_MUTED" "$WAVE_BG" "${targets[@]}"
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "kanagawa wave: the contrast check catches upstream samuraiRed" {
  command -v python3 > /dev/null 2>&1 || skip "python3 not installed"
  mkdir -p "$BATS_TEST_TMPDIR/p"
  printf 'hi Error guifg=#e82424\n' > "$BATS_TEST_TMPDIR/p/planted.vim"
  ROOT="$BATS_TEST_TMPDIR" run check_contrast '#1f1f28' 4.5 "$WAVE_MUTED" "$WAVE_BG" "p/planted.vim"
  [ "$status" -eq 1 ]
  [[ "$output" == *"#e82424 is 3.66:1"* ]]
}
