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
-- is in config/theme/palettes.d/starship.light.toml. Black and white use
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
config.color_schemes = { ['Catppuccin Latte AA'] = latte_aa }

-- Function to detect the theme based on appearance
function Scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Catppuccin Mocha'
  else
    return 'Catppuccin Latte AA'
  end
end

-- Set the color scheme based on appearance
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
