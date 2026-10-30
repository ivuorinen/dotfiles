-- Warm Burnout for both modes: https://github.com/felipefdl/warm-burnout
-- Upstream ships warm-burnout-dark and warm-burnout-light, each forcing its
-- own 'background' and colors_name. This one picks the variant from
-- 'background' and keeps colors_name 'warm-burnout', so the flip that
-- auto-dark-mode makes reloads this file instead of the fixed variant.
--
-- Colours below WCAG AA on the background, lightness changed only (the list
-- is in NOTICE): the accent/warn #b8522e (dark 3.70:1, light 4.22:1), the
-- light ANSI brights 11, 12 and 14, the light ANSI whites 7 and 15, and the
-- dark ANSI black 0. The light ANSI black is the dark background #1a1510, so
-- black on the darkened white keeps 3:1. The light whitespace grey #a09888
-- (2.46:1) also colours NonText, ghost text and the Snacks picker's
-- directories; it is a muted colour, so it is darkened to 3:1.
local palette = require 'warm-burnout.palette'
palette.dark.accent, palette.dark.warn = '#cd5d36', '#cd5d36'
palette.light.accent, palette.light.warn = '#b04e2c', '#b04e2c'
palette.light.whitespace = '#928876'

local variant = vim.o.background == 'light' and 'light' or 'dark'
require('warm-burnout').load(variant)
vim.g.colors_name = 'warm-burnout'

if variant == 'light' then
  vim.g.terminal_color_0 = '#1a1510'
  vim.g.terminal_color_7 = '#736b5f'
  vim.g.terminal_color_15 = '#6f6c66'
  vim.g.terminal_color_11 = '#8b6507'
  vim.g.terminal_color_12 = '#286faf'
  vim.g.terminal_color_14 = '#1d7964'
else
  vim.g.terminal_color_0 = '#65635c'
end
