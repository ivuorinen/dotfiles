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
      'r',
      mode = 'o',
      function() require('flash').remote() end,
      desc = 'Remote Flash',
    },
    {
      'R',
      mode = { 'o', 'x' },
      function() require('flash').treesitter_search() end,
      desc = 'Treesitter Search',
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
