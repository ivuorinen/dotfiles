#!/usr/bin/env bats
# The theme family is resolved outside config/theme/_lib.sh in four
# runtimes: fish (__dotfiles_theme_name), nvim (theme_family in init.lua),
# vim (s:Schemes in vimrc) and wezterm (theme_family in wezterm.lua). Each
# re-implements the same contract — DOTFILES_THEME_FAMILY overrides
# config/theme/family, an unknown family never leaves the app unthemed —
# so each is exercised here against the same cases. Every case skips when
# its binary is absent.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  export DOTFILES="$ROOT"
  unset DOTFILES_THEME_FAMILY
  TMPDIR_TEST="$(mktemp -d)"
  mkdir -p "$TMPDIR_TEST/dotfiles-theme"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

# --- fish -------------------------------------------------------------

fish_theme_name()
{
  fish --no-config -c "source '$ROOT/config/fish/functions/__dotfiles_theme_name.fish'; __dotfiles_theme_name"
}

@test "fish: resolves the tracked family to its -aa theme" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  run fish_theme_name
  [ "$status" -eq 0 ]
  [ "$output" = "$(cat "$ROOT/config/theme/family")-aa" ]
}

@test "fish: the env override wins" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  DOTFILES_THEME_FAMILY=catppuccin run fish_theme_name
  [ "$status" -eq 0 ]
  [ "$output" = "catppuccin-aa" ]
}

@test "fish: a non-slug or themeless family prints nothing and fails" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  for bad in '../catppuccin' 'Kanagawa' 'nosuchfamily'; do
    DOTFILES_THEME_FAMILY="$bad" run fish_theme_name
    [ "$status" -eq 1 ]
    [ -z "$output" ]
  done
}

# --- vim --------------------------------------------------------------

# vim_scheme <mode> [family] — g:colors_name after vimrc applies the mode.
vim_scheme()
{
  echo "$1" > "$TMPDIR_TEST/dotfiles-theme/mode"
  XDG_STATE_HOME="$TMPDIR_TEST" DOTFILES_THEME_FAMILY="${2:-}" timeout 30 \
    vim -Nu "$ROOT/config/vim/vimrc" -i NONE -es --cmd "set rtp^=$ROOT/config/vim" \
    '+redir! > /dev/stdout' '+echo g:colors_name' '+redir END' '+qa!' 2>&1 | tr -d '\r\n '
}

@test "vim: kanagawa maps dark/light to wave/lotus" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark kanagawa)" = "kanagawa_wave" ]
  [ "$(vim_scheme light kanagawa)" = "kanagawa_lotus" ]
}

@test "vim: catppuccin maps dark/light to mocha/latte" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark catppuccin)" = "catppuccin_mocha" ]
  [ "$(vim_scheme light catppuccin)" = "catppuccin_latte" ]
}

@test "vim: an unknown family falls back to catppuccin, never unthemed" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark nosuchfamily)" = "catppuccin_mocha" ]
}

@test "vim: a running session follows a family switch at an unchanged mode" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  echo dark > "$TMPDIR_TEST/dotfiles-theme/mode"
  # Start on kanagawa, switch the family, and let the 3 s timer fire
  # (:sleep processes timers). Before the fix the mode-only change check
  # left the session on the old family forever.
  run bash -c "XDG_STATE_HOME='$TMPDIR_TEST' DOTFILES_THEME_FAMILY=kanagawa timeout 30 \
    vim -Nu '$ROOT/config/vim/vimrc' -i NONE -es --cmd 'set rtp^=$ROOT/config/vim' \
    '+let \$DOTFILES_THEME_FAMILY = \"catppuccin\"' '+sleep 4' \
    '+redir! > /dev/stdout' '+echo g:colors_name' '+redir END' '+qa!' 2>&1 | tr -d '\r\n '"
  [ "$output" = "catppuccin_mocha" ]
}

# --- nvim -------------------------------------------------------------

nvim_scheme()
{
  DOTFILES_THEME_FAMILY="${1:-}" timeout 60 nvim --headless \
    "+set background=${2:-dark}" \
    '+lua io.stdout:write(vim.g.colors_name .. "\n")' +qa 2> /dev/null | tail -1
}

@test "nvim: family selects kanagawa or catppuccin" {
  command -v nvim > /dev/null 2>&1 || skip "nvim not installed"
  # The real config loads plugins through vim.pack; without them installed
  # this would test a network install, not the resolver.
  local data
  data="$(nvim --clean --headless '+lua io.stdout:write(vim.fn.stdpath("data"))' +qa 2> /dev/null)"
  compgen -G "$data/site/pack/*/opt/kanagawa" > /dev/null || skip "kanagawa.nvim not installed"
  [ "$(nvim_scheme kanagawa)" = "kanagawa" ]
  [ "$(nvim_scheme catppuccin)" = "catppuccin-mocha" ]
  [ "$(nvim_scheme nosuchfamily)" = "catppuccin-mocha" ]
}

# --- wezterm ------------------------------------------------------------

@test "wezterm: family selects the scheme pair; unknown falls back" {
  command -v nvim > /dev/null 2>&1 || skip "nvim (used as the Lua host) not installed"
  # Load wezterm.lua under nvim's Lua with a stub `wezterm` module, then
  # call Scheme_for_appearance per family. Every scheme name it returns
  # must be a builtin (Catppuccin Mocha) or registered in color_schemes.
  cat > "$TMPDIR_TEST/stub.lua" << 'LUA'
local function any() return setmetatable({}, { __index = function() return function() return {} end end }) end
local stub = setmetatable({}, { __index = function() return any end })
stub.color = { get_builtin_schemes = function() return { ['Catppuccin Latte'] = {} } end }
stub.config_builder = function() return {} end
stub.on = function() end
stub.action = setmetatable({}, { __index = function() return function() return {} end end })
package.loaded.wezterm = stub
local cfg = dofile(arg[1])
for _, fam in ipairs { 'kanagawa', 'catppuccin', 'nosuchfamily' } do
  vim.env.DOTFILES_THEME_FAMILY = fam
  local d, l = Scheme_for_appearance 'Dark', Scheme_for_appearance 'Light'
  for _, s in ipairs { d, l } do
    assert(s == 'Catppuccin Mocha' or cfg.color_schemes[s], 'unregistered scheme ' .. s)
  end
  print(fam .. '=' .. d .. '|' .. l)
end
LUA
  run nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"kanagawa=Kanagawa Wave|Kanagawa Lotus AA"* ]]
  [[ "$output" == *"catppuccin=Catppuccin Mocha|Catppuccin Latte AA"* ]]
  [[ "$output" == *"nosuchfamily=Catppuccin Mocha|Catppuccin Latte AA"* ]]
}
