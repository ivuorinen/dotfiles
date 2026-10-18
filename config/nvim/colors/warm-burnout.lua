-- Warm Burnout for both modes: https://github.com/felipefdl/warm-burnout
-- Upstream ships warm-burnout-dark and warm-burnout-light, each forcing its
-- own 'background' and colors_name. This one picks the variant from
-- 'background' and keeps colors_name 'warm-burnout', so the flip that
-- auto-dark-mode makes reloads this file instead of the fixed variant.
--
-- Colours below WCAG AA on the background, lightness changed only (the list
-- is in NOTICE): the accent/warn #b8522e (dark 3.70:1, light 4.22:1) and the
-- light ANSI brights 11, 12 and 14.
local palette = require 'warm-burnout.palette'
palette.dark.accent, palette.dark.warn = '#cd5d36', '#cd5d36'
palette.light.accent, palette.light.warn = '#b04e2c', '#b04e2c'

local variant = vim.o.background == 'light' and 'light' or 'dark'
require('warm-burnout').load(variant)
vim.g.colors_name = 'warm-burnout'

if variant == 'light' then
  vim.g.terminal_color_11 = '#8b6507'
  vim.g.terminal_color_12 = '#286faf'
  vim.g.terminal_color_14 = '#1d7964'
end
