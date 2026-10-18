#!/usr/bin/env bats
# The theme family is resolved outside config/theme/_lib.sh in four
# runtimes: fish (__dotfiles_theme_name), nvim (theme_family in init.lua),
# vim (s:Schemes in vimrc) and wezterm (theme_family in wezterm.lua). Each
# re-implements the same contract — DOTFILES_THEME_FAMILY, then the saved
# choice in $XDG_STATE_HOME/dotfiles-theme/choice, then config/theme/family;
# an unknown family never leaves the app unthemed — so each is exercised
# here against the same cases. Every case skips when its binary is absent.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  export DOTFILES="$ROOT"
  unset DOTFILES_THEME_FAMILY
  TMPDIR_TEST="$(mktemp -d)"
  mkdir -p "$TMPDIR_TEST/dotfiles-theme"
  # The saved family choice lives here; never read the developer's own.
  export XDG_STATE_HOME="$TMPDIR_TEST"
}

# save_choice <family> — what local/bin/theme writes.
save_choice()
{
  printf '%s\n' "$1" > "$TMPDIR_TEST/dotfiles-theme/choice"
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

@test "fish: warm-burnout resolves to its -aa theme" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  DOTFILES_THEME_FAMILY=warm-burnout run fish_theme_name
  [ "$status" -eq 0 ]
  [ "$output" = "warm-burnout-aa" ]
}

@test "fish: a non-slug or themeless family prints nothing and fails" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  for bad in '../catppuccin' 'Kanagawa' 'nosuchfamily'; do
    DOTFILES_THEME_FAMILY="$bad" run fish_theme_name
    [ "$status" -eq 1 ]
    [ -z "$output" ]
  done
}

@test "fish: the saved choice wins over the tracked family" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  save_choice kanagawa
  run fish_theme_name
  [ "$status" -eq 0 ]
  [ "$output" = "kanagawa-aa" ]
}

@test "fish: an invalid saved choice falls back to the tracked family" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  for bad in 'nope' '../kanagawa' ''; do
    save_choice "$bad"
    run fish_theme_name
    [ "$status" -eq 0 ]
    [ "$output" = "$(cat "$ROOT/config/theme/family")-aa" ]
  done
}

# --- vim --------------------------------------------------------------

# vim_colors <family> [ex-command...] — run the real vimrc headless and print
# g:colors_name. Two things keep the result deterministic:
#  - HOME is a temp dir holding a no-op vim-plug stub. Without plug.vim the
#    vimrc bootstraps it with curl (whose progress meter lands on stdout) and
#    runs PlugInstall on VimEnter, so the first vim test on a fresh machine
#    both hit the network and failed on the garbled output — only in CI.
#  - The name is written to a file with writefile(), never scraped from
#    stdout, so any message the vimrc prints cannot leak into the value.
vim_colors()
{
  local family=$1
  shift
  local home="$TMPDIR_TEST/home" out="$TMPDIR_TEST/colors_name"
  mkdir -p "$home/.config/vim/autoload"
  cat > "$home/.config/vim/autoload/plug.vim" << 'VIM'
function! plug#begin(...) abort
endfunction
function! plug#end() abort
endfunction
command! -nargs=+ -bar Plug :
VIM
  rm -f "$out"
  local cmds=()
  local c
  for c in "$@"; do cmds+=("+$c"); done
  HOME="$home" XDG_STATE_HOME="$TMPDIR_TEST" DOTFILES_THEME_FAMILY="$family" timeout 30 \
    vim -Nu "$ROOT/config/vim/vimrc" -i NONE -es --cmd "set rtp^=$ROOT/config/vim" \
    "${cmds[@]}" "+call writefile([get(g:, 'colors_name', 'UNSET')], '$out')" '+qa!' \
    > /dev/null 2>&1
  cat "$out" 2> /dev/null || echo "vim exited without writing a colors_name"
}

# vim_scheme <mode> [family] — g:colors_name after vimrc applies the mode.
vim_scheme()
{
  echo "$1" > "$TMPDIR_TEST/dotfiles-theme/mode"
  vim_colors "${2:-}"
}

@test "vim: kanagawa maps dark/light to wave/lotus" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark kanagawa)" = "kanagawa_wave" ]
  [ "$(vim_scheme light kanagawa)" = "kanagawa_lotus" ]
}

@test "vim: oasis maps dark/light to abyss dark/light" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark oasis)" = "oasis_abyss_dark" ]
  [ "$(vim_scheme light oasis)" = "oasis_abyss_light" ]
}

@test "vim: warm-burnout maps dark/light to warm_burnout_dark/light" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark warm-burnout)" = "warm_burnout_dark" ]
  [ "$(vim_scheme light warm-burnout)" = "warm_burnout_light" ]
}

@test "vim: catppuccin maps dark/light to mocha/latte" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark catppuccin)" = "catppuccin_mocha" ]
  [ "$(vim_scheme light catppuccin)" = "catppuccin_latte" ]
}

@test "vim: an unknown family falls back to oasis, never unthemed" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  [ "$(vim_scheme dark nosuchfamily)" = "oasis_abyss_dark" ]
}

@test "vim: the saved choice selects the scheme" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  save_choice kanagawa
  [ "$(vim_scheme dark)" = "kanagawa_wave" ]
}

@test "vim: an invalid saved choice falls back to the tracked family" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  save_choice nope
  [ "$(vim_scheme dark)" = "oasis_abyss_dark" ]
}

@test "vim: a running session follows a family switch at an unchanged mode" {
  command -v vim > /dev/null 2>&1 || skip "vim not installed"
  echo dark > "$TMPDIR_TEST/dotfiles-theme/mode"
  # Start on kanagawa, switch the family, and let the 3 s timer fire
  # (:sleep processes timers). Before the fix the mode-only change check
  # left the session on the old family forever.
  run vim_colors kanagawa 'let $DOTFILES_THEME_FAMILY = "catppuccin"' 'sleep 4'
  [ "$output" = "catppuccin_mocha" ]
}

# --- nvim -------------------------------------------------------------

# Every nvim run here sets XDG_CONFIG_HOME to the checkout: nvim would
# otherwise load ~/.config/nvim, the installed config rather than the one
# under test.
nvim_scheme()
{
  XDG_CONFIG_HOME="$ROOT/config" DOTFILES_THEME_FAMILY="${1:-}" timeout 60 nvim --headless \
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
  [ "$(nvim_scheme nosuchfamily)" = "$(nvim_scheme oasis)" ]
}

@test "nvim: the saved choice selects the scheme" {
  command -v nvim > /dev/null 2>&1 || skip "nvim not installed"
  local data
  data="$(nvim --clean --headless '+lua io.stdout:write(vim.fn.stdpath("data"))' +qa 2> /dev/null)"
  compgen -G "$data/site/pack/*/opt/kanagawa" > /dev/null || skip "kanagawa.nvim not installed"
  save_choice kanagawa
  [ "$(nvim_scheme '')" = "kanagawa" ]
  save_choice nope
  [ "$(nvim_scheme '')" = "$(nvim_scheme oasis)" ]
}

@test "nvim: a running session follows a family switch at an unchanged mode" {
  command -v nvim > /dev/null 2>&1 || skip "nvim not installed"
  local data
  data="$(nvim --clean --headless '+lua io.stdout:write(vim.fn.stdpath("data"))' +qa 2> /dev/null)"
  compgen -G "$data/site/pack/*/opt/kanagawa" > /dev/null || skip "kanagawa.nvim not installed"
  # Start on kanagawa, switch the family, and let the 3 s timer fire
  # (:sleep runs the event loop), as vim's live test does.
  # auto-dark-mode re-reads the OS appearance during the sleep, so the
  # flavour (mocha or latte) follows the host; only the family is asserted.
  run env XDG_CONFIG_HOME="$ROOT/config" DOTFILES_THEME_FAMILY=kanagawa timeout 60 nvim --headless '+set background=dark' \
    "+lua vim.env.DOTFILES_THEME_FAMILY = 'catppuccin'" '+sleep 4' \
    '+lua io.stdout:write(vim.g.colors_name .. "\n")' +qa
  [[ "${lines[${#lines[@]} - 1]}" == catppuccin-* ]]
}

@test "nvim: oasis selects abyss in both modes" {
  command -v nvim > /dev/null 2>&1 || skip "nvim not installed"
  local data
  data="$(nvim --clean --headless '+lua io.stdout:write(vim.fn.stdpath("data"))' +qa 2> /dev/null)"
  compgen -G "$data/site/pack/*/opt/oasis" > /dev/null || skip "oasis.nvim not installed"
  [ "$(nvim_scheme oasis dark)" = "oasis-abyss" ]
  [ "$(nvim_scheme oasis light)" = "oasis-abyss" ]
  # One colors_name serves both modes, so check the mode reached the
  # palette: Abyss Dark and Abyss Light 3 (intensity 3) backgrounds.
  local bg
  for bg in dark:000000 light:d8d8d8; do
    run env XDG_CONFIG_HOME="$ROOT/config" DOTFILES_THEME_FAMILY=oasis timeout 60 nvim --headless \
      "+set background=${bg%%:*}" \
      '+lua io.stdout:write(string.format("%06x\n", vim.api.nvim_get_hl(0, { name = "Normal" }).bg))' \
      +qa
    [ "${lines[${#lines[@]} - 1]}" = "${bg#*:}" ]
  done
}

@test "nvim: warm-burnout follows background in one colorscheme" {
  command -v nvim > /dev/null 2>&1 || skip "nvim not installed"
  local data
  data="$(nvim --clean --headless '+lua io.stdout:write(vim.fn.stdpath("data"))' +qa 2> /dev/null)"
  compgen -G "$data/site/pack/*/opt/warm-burnout" > /dev/null || skip "warm-burnout not installed"
  [ "$(nvim_scheme warm-burnout dark)" = "warm-burnout" ]
  [ "$(nvim_scheme warm-burnout light)" = "warm-burnout" ]
  # Upstream ships one colorscheme per variant; the wrapper must reach the
  # mode's palette (Normal bg) and carry the AA fixes: warn (DiagnosticWarn),
  # accent (MatchParen) and the light terminal bright yellow (colour 11).
  local want
  for want in dark:1a1510:cd5d36:#ffb454 light:f5ede0:b04e2c:#8b6507; do
    IFS=: read -r mode bg fix ansi11 <<< "$want"
    run env XDG_CONFIG_HOME="$ROOT/config" DOTFILES_THEME_FAMILY=warm-burnout timeout 60 nvim --headless \
      "+set background=$mode" \
      '+lua local function fg(n) return vim.api.nvim_get_hl(0, { name = n, link = false }).fg end io.stdout:write(string.format("%06x %06x %06x %s\n", vim.api.nvim_get_hl(0, { name = "Normal" }).bg, fg "DiagnosticWarn", fg "MatchParen", vim.g.terminal_color_11))' \
      +qa
    [ "${lines[${#lines[@]} - 1]}" = "$bg $fix $fix $ansi11" ]
  done
}

@test "nvim: a missing warm-burnout plugin leaves the rest of the config running" {
  command -v nvim > /dev/null 2>&1 || skip "nvim not installed"
  local data
  data="$(nvim --clean --headless '+lua io.stdout:write(vim.fn.stdpath("data"))' +qa 2> /dev/null)"
  compgen -G "$data/site/pack/*/opt/oasis" > /dev/null || skip "oasis.nvim not installed"
  # vim.pack.get raises for a plugin that is not installed (an install the
  # user declined); init.lua must survive it and still theme every family.
  local fam
  for fam in oasis warm-burnout; do
    run env XDG_CONFIG_HOME="$ROOT/config" DOTFILES_THEME_FAMILY="$fam" timeout 60 nvim --headless \
      "+lua io.stdout:write(tostring(vim.g.colors_name) .. '\n')" +qa \
      --cmd "lua local get = vim.pack.get; vim.pack.get = function(n, o) if n and vim.tbl_contains(n, 'warm-burnout') then error(\"Plugin 'warm-burnout' is not installed\") end return get(n, o) end"
    [[ "${lines[${#lines[@]} - 1]}" == oasis* ]]
  done
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
for _, fam in ipairs { 'kanagawa', 'oasis', 'catppuccin', 'nosuchfamily' } do
  vim.env.DOTFILES_THEME_FAMILY = fam
  local d, l = Scheme_for_appearance 'Dark', Scheme_for_appearance 'Light'
  for _, s in ipairs { d, l } do
    assert(s == 'Catppuccin Mocha' or cfg.color_schemes[s], 'unregistered scheme ' .. s)
  end
  print(fam .. '=' .. d .. '|' .. l)
end
LUA
  # An empty state dir: no mode file, so the appearance decides.
  run env XDG_STATE_HOME="$TMPDIR_TEST/state" \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"kanagawa=Kanagawa Wave|Kanagawa Lotus AA"* ]]
  [[ "$output" == *"oasis=Oasis Abyss Dark|Oasis Abyss Light 3"* ]]
  [[ "$output" == *"catppuccin=Catppuccin Mocha|Catppuccin Latte AA"* ]]
  [[ "$output" == *"nosuchfamily=Oasis Abyss Dark|Oasis Abyss Light 3"* ]]
}

@test "wezterm: the saved choice selects the scheme pair" {
  command -v nvim > /dev/null 2>&1 || skip "nvim (used as the Lua host) not installed"
  cat > "$TMPDIR_TEST/stub.lua" << 'LUA'
local function any() return setmetatable({}, { __index = function() return function() return {} end end }) end
local stub = setmetatable({}, { __index = function() return any end })
stub.color = { get_builtin_schemes = function() return { ['Catppuccin Latte'] = {} } end }
stub.config_builder = function() return {} end
stub.on = function() end
stub.action = setmetatable({}, { __index = function() return function() return {} end end })
package.loaded.wezterm = stub
dofile(arg[1])
print('pair=' .. Scheme_for_appearance 'Dark' .. '|' .. Scheme_for_appearance 'Light')
LUA
  mkdir -p "$TMPDIR_TEST/state/dotfiles-theme"
  local choice="$TMPDIR_TEST/state/dotfiles-theme/choice"
  echo kanagawa > "$choice"
  run env XDG_STATE_HOME="$TMPDIR_TEST/state" \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pair=Kanagawa Wave|Kanagawa Lotus AA"* ]]
  # A stale choice falls through to the tracked default (oasis).
  echo nope > "$choice"
  run env XDG_STATE_HOME="$TMPDIR_TEST/state" \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pair=Oasis Abyss Dark|Oasis Abyss Light 3"* ]]
}

@test "wezterm: a saved choice must pass the shared family rule" {
  command -v nvim > /dev/null 2>&1 || skip "nvim (used as the Lua host) not installed"
  cat > "$TMPDIR_TEST/stub.lua" << 'LUA'
local function any() return setmetatable({}, { __index = function() return function() return {} end end }) end
local stub = setmetatable({}, { __index = function() return any end })
stub.color = { get_builtin_schemes = function() return { ['Catppuccin Latte'] = {} } end }
stub.config_builder = function() return {} end
stub.on = function() end
stub.action = setmetatable({}, { __index = function() return function() return {} end end })
package.loaded.wezterm = stub
dofile(arg[1])
print('pair=' .. Scheme_for_appearance 'Dark' .. '|' .. Scheme_for_appearance 'Light')
LUA
  mkdir -p "$TMPDIR_TEST/state/dotfiles-theme"
  local choice="$TMPDIR_TEST/state/dotfiles-theme/choice"
  # Surrounding whitespace is trimmed, as read -r does in _lib.sh.
  echo '  kanagawa ' > "$choice"
  run env XDG_STATE_HOME="$TMPDIR_TEST/state" \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pair=Kanagawa Wave|Kanagawa Lotus AA"* ]]
  # Inner whitespace is not a slug, so the tracked default (oasis) wins.
  echo 'kana gawa' > "$choice"
  run env XDG_STATE_HOME="$TMPDIR_TEST/state" \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pair=Oasis Abyss Dark|Oasis Abyss Light 3"* ]]
  # A family with a scheme pair but no palettes.d dir is skipped too.
  local dots="$TMPDIR_TEST/dots"
  mkdir -p "$dots/config/theme/palettes.d/oasis"
  echo oasis > "$dots/config/theme/family"
  echo kanagawa > "$choice"
  run env XDG_STATE_HOME="$TMPDIR_TEST/state" DOTFILES="$dots" \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pair=Oasis Abyss Dark|Oasis Abyss Light 3"* ]]
}

@test "wezterm and fish: an empty XDG_STATE_HOME counts as unset" {
  # _lib.sh reads ${XDG_STATE_HOME:-$HOME/.local/state}; an empty value
  # must not turn the choice path into /dotfiles-theme/choice.
  local home="$TMPDIR_TEST/home"
  mkdir -p "$home/.local/state/dotfiles-theme"
  echo kanagawa > "$home/.local/state/dotfiles-theme/choice"
  if command -v fish > /dev/null 2>&1; then
    run env HOME="$home" XDG_STATE_HOME= fish --no-config -c \
      "source '$ROOT/config/fish/functions/__dotfiles_theme_name.fish'; __dotfiles_theme_name"
    [ "$output" = "kanagawa-aa" ]
  fi
  command -v nvim > /dev/null 2>&1 || skip "nvim (used as the Lua host) not installed"
  cat > "$TMPDIR_TEST/stub.lua" << 'LUA'
local function any() return setmetatable({}, { __index = function() return function() return {} end end }) end
local stub = setmetatable({}, { __index = function() return any end })
stub.color = { get_builtin_schemes = function() return { ['Catppuccin Latte'] = {} } end }
stub.config_builder = function() return {} end
stub.on = function() end
stub.action = setmetatable({}, { __index = function() return function() return {} end end })
package.loaded.wezterm = stub
dofile(arg[1])
print('pair=' .. Scheme_for_appearance 'Dark' .. '|' .. Scheme_for_appearance 'Light')
LUA
  run env HOME="$home" XDG_STATE_HOME= \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pair=Kanagawa Wave|Kanagawa Lotus AA"* ]]
}

@test "wezterm: the orchestrator's mode file wins over the appearance" {
  command -v nvim > /dev/null 2>&1 || skip "nvim (used as the Lua host) not installed"
  cat > "$TMPDIR_TEST/stub.lua" << 'LUA'
local function any() return setmetatable({}, { __index = function() return function() return {} end end }) end
local stub = setmetatable({}, { __index = function() return any end })
stub.color = { get_builtin_schemes = function() return { ['Catppuccin Latte'] = {} } end }
stub.config_builder = function() return {} end
stub.on = function() end
local watched = {}
stub.add_to_config_reload_watch_list = function(p) watched[#watched + 1] = p end
stub.action = setmetatable({}, { __index = function() return function() return {} end end })
package.loaded.wezterm = stub
dofile(arg[1])
vim.env.DOTFILES_THEME_FAMILY = 'oasis'
print('light-os=' .. Scheme_for_appearance 'Light')
print('watched=' .. table.concat(watched, ','))
LUA
  mkdir -p "$TMPDIR_TEST/state/dotfiles-theme"
  echo dark > "$TMPDIR_TEST/state/dotfiles-theme/mode"
  run env XDG_STATE_HOME="$TMPDIR_TEST/state" \
    nvim --clean --headless -l "$TMPDIR_TEST/stub.lua" "$ROOT/config/wezterm/wezterm.lua"
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"light-os=Oasis Abyss Dark"* ]]
  [[ "$output" == *"watched=$TMPDIR_TEST/state/dotfiles-theme/mode"* ]]
}
