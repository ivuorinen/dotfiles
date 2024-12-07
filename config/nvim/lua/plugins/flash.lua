-- Navigate your code with search labels, enhanced
-- character motions and Treesitter integration
-- https://github.com/folke/flash.nvim
return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    {
      'zk',
      mode = { 'n', 'x', 'o' },
      function() require('flash').jump() end,
      desc = 'Flash',
    },
    {
      'Zk',
      mode = { 'n', 'x', 'o' },
      function() require('flash').treesitter() end,
      desc = 'Flash Treesitter',
    },
    {
      '<m-s>',
      mode = { 'c' },
      function() require('flash').toggle() end,
      desc = 'Toggle Flash Search',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
