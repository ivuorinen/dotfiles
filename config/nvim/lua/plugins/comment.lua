-- Commenting
-- "gc" to comment visual regions/lines
-- https://github.com/numToStr/Comment.nvim
return {
  'numToStr/Comment.nvim',
  version = '*',
  event = { 'BufRead', 'BufNewFile' },
  opts = {},
}
