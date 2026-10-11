local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.set_environment_variables = {
  COLORTERM = 'truecolor',
}

-- Font and font size
config.font_size = 12
config.font = wezterm.font_with_fallback {
  {
    family = 'Monaspace Argon NF',
    weight = 'Regular',
  },
  {
    family = 'Operator Mono',
    weight = 'Book',
  },
  'Operator Mono',
  'JetBrainsMonoNL NFM Light',
  'JetBrains Mono',
  'Symbols Nerd Font Mono',
}
config.font_shaper = 'Harfbuzz'
config.harfbuzz_features = {
  'calt=1',
  'clig=1',
  'liga=1',
  'ss01=1',
  'ss02=1',
  'ss03=1',
  'ss04=1',
  'ss05=1',
  'ss06=1',
  'ss07=1',
  'ss08=1',
  'ss09=1',
}

config.selection_word_boundary = ' \t\n{[}]()"\'`,;:'

-- Window configuration
config.window_background_opacity = 0.99
config.window_decorations = 'RESIZE'
config.macos_window_background_blur = 10
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 5,
}

-- Don't show tab bar
config.enable_tab_bar = false

-- Fix alt on macOS
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

config.scrollback_lines = 3000

-- Catppuccin Latte with the ANSI accents darkened to reach WCAG AA
-- (4.5:1) on base #eff1f5. Hue and saturation are unchanged; the mapping
-- is in config/theme/palettes.d/catppuccin/light/starship.toml. Black and white use
-- the Catppuccin style guide's Latte mapping (black = subtext1/subtext0,
-- white = surface2/surface1). The builtin uses surface1 for black (1.61:1),
-- which leaves text printed in "black" unreadable.
local latte_aa = wezterm.color.get_builtin_schemes()['Catppuccin Latte']
latte_aa.ansi = {
  '#5c5f77',
  '#d20f39',
  '#327c21',
  '#996114',
  '#1761f5',
  '#c71f9a',
  '#13797e',
  '#acb0be',
}
latte_aa.brights = {
  '#6c6f85',
  '#d20f39',
  '#327c21',
  '#996114',
  '#1761f5',
  '#c71f9a',
  '#13797e',
  '#bcc0cc',
}
latte_aa.indexed = { [16] = '#be4601', [17] = '#bb4930' }

-- Kanagawa Wave: upstream rebelot/kanagawa.nvim extras/wezterm/kanagawa.lua
-- (@ bb85e4bf), except the two reds below WCAG AA on #1f1f28, lifted with
-- hue and saturation unchanged: ANSI red autumnRed #c34043 (3.22:1) to
-- #cf6769, bright red samuraiRed #e82424 (3.66:1) to #ed4f4f.
local kanagawa_wave = {
  foreground = '#dcd7ba',
  background = '#1f1f28',
  cursor_bg = '#c8c093',
  cursor_fg = '#c8c093',
  cursor_border = '#c8c093',
  selection_fg = '#c8c093',
  selection_bg = '#2d4f67',
  scrollbar_thumb = '#16161d',
  split = '#16161d',
  ansi = {
    '#090618',
    '#cf6769',
    '#76946a',
    '#c0a36e',
    '#7e9cd8',
    '#957fb8',
    '#6a9589',
    '#c8c093',
  },
  brights = {
    '#727169',
    '#ed4f4f',
    '#98bb6c',
    '#e6c384',
    '#7fb4ca',
    '#938aa9',
    '#7aa89f',
    '#dcd7ba',
  },
  indexed = { [16] = '#ffa066', [17] = '#ff5d62' },
}

-- Kanagawa Lotus AA: upstream extras/foot/kanagawa-lotus.ini with every
-- accent darkened (hue and saturation unchanged) to WCAG AA 4.5:1 on
-- #f2ecbc; bright black is the muted overlay0 (3:1). Mapping in
-- config/theme/palettes.d/kanagawa/light/starship.toml.
local kanagawa_lotus_aa = {
  foreground = '#545464',
  background = '#f2ecbc',
  cursor_bg = '#545464',
  cursor_fg = '#f2ecbc',
  cursor_border = '#545464',
  selection_fg = '#43436c',
  selection_bg = '#c9cbd1',
  ansi = {
    '#1f1f28',
    '#c0374a',
    '#5b7040',
    '#716b3c',
    '#4d699b',
    '#a54c6b',
    '#51706b',
    '#545464',
  },
  brights = {
    '#88877e',
    '#c92c30',
    '#56714a',
    '#7a6745',
    '#406d99',
    '#624c83',
    '#4f7067',
    '#43436c',
  },
  indexed = { [16] = '#9a5b00', [17] = '#d21616' },
}

-- Oasis Abyss Dark and Light 3: upstream uhs-robert/oasis.nvim
-- extras/wezterm/themes/{dark,light/3}/*.toml (@ a3ef178f), unchanged.
-- The tab_bar block is left out because the tab bar is disabled above.
local oasis_abyss_dark = {
  foreground = '#f5f5dc',
  background = '#000000',
  cursor_bg = '#f0e68c',
  cursor_border = '#f0e68c',
  cursor_fg = '#000000',
  selection_bg = '#666666',
  selection_fg = '#f5f5dc',
  split = '#e26e6e',
  compose_cursor = '#ff9633',
  scrollbar_thumb = '#1c1c1c',
  visual_bell = '#141414',
  ansi = {
    '#000000',
    '#ff7979',
    '#7fcf78',
    '#f0e68c',
    '#81c0ff',
    '#c695ff',
    '#69c3aa',
    '#f5f5dc',
  },
  brights = {
    '#605c4d',
    '#ffa0a0',
    '#a3e39a',
    '#f8b471',
    '#87ceeb',
    '#d2adff',
    '#8ad3be',
    '#fffff0',
  },
  indexed = { [16] = '#ff9633', [17] = '#ff7979' },
}

local oasis_abyss_light_3 = {
  foreground = '#181811',
  background = '#d8d8d8',
  cursor_bg = '#635c28',
  cursor_border = '#635c28',
  cursor_fg = '#d8d8d8',
  selection_bg = '#e1c99d',
  selection_fg = '#4e370e',
  split = '#575333',
  compose_cursor = '#875221',
  scrollbar_thumb = '#b9b9b9',
  visual_bell = '#cdcdcd',
  ansi = {
    '#383838',
    '#9e1010',
    '#31572e',
    '#554f1c',
    '#11508d',
    '#691fbe',
    '#31554c',
    '#3a3a1b',
  },
  brights = {
    '#3f3731',
    '#9e1010',
    '#2f5829',
    '#744211',
    '#1e546a',
    '#671fc0',
    '#2f564a',
    '#3a3a0c',
  },
  indexed = { [16] = '#875221', [17] = '#9e1116' },
}

config.color_schemes = {
  ['Catppuccin Latte AA'] = latte_aa,
  ['Kanagawa Wave'] = kanagawa_wave,
  ['Kanagawa Lotus AA'] = kanagawa_lotus_aa,
  ['Oasis Abyss Dark'] = oasis_abyss_dark,
  ['Oasis Abyss Light 3'] = oasis_abyss_light_3,
}

-- Theme family from config/theme/family (DOTFILES_THEME_FAMILY overrides
-- it, as in config/theme/_lib.sh). Unreadable means catppuccin.
local function theme_family()
  local env = os.getenv 'DOTFILES_THEME_FAMILY'
  if env and env ~= '' then
    return env
  end
  local dotfiles = os.getenv 'DOTFILES' or ((os.getenv 'HOME' or '') .. '/.dotfiles')
  local f = io.open(dotfiles .. '/config/theme/family', 'r')
  if not f then
    return 'catppuccin'
  end
  local family = (f:read '*l' or ''):gsub('%s+', '')
  f:close()
  return family
end

local schemes = {
  kanagawa = { dark = 'Kanagawa Wave', light = 'Kanagawa Lotus AA' },
  oasis = { dark = 'Oasis Abyss Dark', light = 'Oasis Abyss Light 3' },
  catppuccin = { dark = 'Catppuccin Mocha', light = 'Catppuccin Latte AA' },
}

-- The orchestrator's mode, from the file local/bin/theme-mode reads
-- ($XDG_STATE_HOME/dotfiles-theme/mode). The file is on the reload watch
-- list, so `config/theme/apply` re-runs this config and every window picks
-- the new scheme. nil when the file is missing or holds anything else.
local mode_file = (
  os.getenv 'XDG_STATE_HOME' or ((os.getenv 'HOME' or '') .. '/.local/state')
) .. '/dotfiles-theme/mode'
wezterm.add_to_config_reload_watch_list(mode_file)

local function theme_mode()
  local f = io.open(mode_file, 'r')
  if not f then
    return nil
  end
  local mode = (f:read '*l' or ''):gsub('%s+', '')
  f:close()
  if mode == 'dark' or mode == 'light' then
    return mode
  end
  return nil
end

-- Scheme for the orchestrator's mode; without one (no orchestrator on this
-- host yet), fall back to the window's OS appearance.
function Scheme_for_appearance(appearance)
  local s = schemes[theme_family()] or schemes.catppuccin
  local mode = theme_mode() or (appearance:find 'Dark' and 'dark' or 'light')
  return s[mode]
end

-- Set the color scheme on every config reload (including the ones the
-- mode file triggers)
---@diagnostic disable-next-line: unused-local
wezterm.on('window-config-reloaded', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  if not appearance then
    return
  end
  local scheme = Scheme_for_appearance(appearance)
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

return config
