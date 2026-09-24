#!/usr/bin/env bats
# Guards the AA-darkened Catppuccin Latte palette (WCAG 4.5:1 on #eff1f5).
# Upstream Latte accents sit at 2.3-3.5:1 on base, and several of these
# files originate upstream (bat .tmTheme, eza, catppuccin/tmux, the fish
# theme fisher manages). A refresh silently restores the unreadable
# values, so each check fails naming the file that regressed. The mapping
# lives in config/theme/palettes.d/starship.light.toml.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  # Upstream Latte accents below 4.5:1 on base. Mauve and red already pass
  # and are kept as upstream, so they are not listed.
  UPSTREAM_HEX='(dc8a78|dd7878|ea76cb|e64553|fe640b|df8e1d|40a02b|179299|04a5e5|209fb5|1e66f5|7287fd)'
  UPSTREAM_RGB='(220;138;120|221;120;120|234;118;203|230;69;83|254;100;11|223;142;29|64;160;43|23;146;153|4;165;229|32;159;181|30;102;245|114;135;253)'
}

@test "light palettes carry no upstream low-contrast Latte accents" {
  local files=(
    "config/theme/palettes.d/starship.light.toml"
    "config/theme/palettes.d/eza.light.yml"
    "config/theme/palettes.d/gitui.light.ron"
    "config/theme/palettes.d/fzf.light.fish"
    "config/theme/palettes.d/fzf.light.sh"
    "config/theme/palettes.d/yazi.light.toml"
    "config/theme/palettes.d/gh-dash.light.theme.yml"
    "config/theme/palettes.d/tmux.light.thm.conf"
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
  run grep -En "38;2;$UPSTREAM_RGB([;[:space:]]|$)" "$ROOT/config/theme/palettes.d/dircolors.light"
  [ "$status" -eq 1 ]
}

@test "AA overrides stay wired into each app" {
  grep -q 'color_overrides' "$ROOT/config/nvim/init.lua"
  grep -q "return 'Catppuccin Latte AA'" "$ROOT/config/wezterm/wezterm.lua"
  grep -q 'tmux.light.thm.conf' "$ROOT/config/theme/palettes.d/tmux.light.conf"
  grep -q 'theme save catppuccin-aa' "$ROOT/config/theme/handlers.d/fish"
  grep -q 'theme save catppuccin-aa' "$ROOT/config/fish/conf.d/theme-switch.fish"
  grep -q 'theme choose catppuccin-aa' "$ROOT/config/fish/config.fish"
  grep -q "'catppuccin_latte'" "$ROOT/config/vim/vimrc"
}
