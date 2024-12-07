-- https://github.com/echasnovski/mini.nvim
-- https://github.com/echasnovski/mini.nvim/tree/main?tab=readme-ov-file#modules
return {
  -- Presets for common options and mappings
  { 'echasnovski/mini.basics',    version = '*' },

  -- Animate common Neovim actions
  -- Replaced anuvyklack/windows.nvim
  { 'echasnovski/mini.animate',   version = '*', opts = {} },

  -- Buffer removing (unshow, delete, wipeout), which saves window layout
  -- Replaced famiu/bufdelete.nvim
  { 'echasnovski/mini.bufremove', version = '*', opts = {} },

  -- Show next key clues
  -- Replaced folke/which-key.nvim
  {
    'echasnovski/mini.clue',
    version = '*',
    config = function()
      local miniclue = require 'mini.clue'

      miniclue.setup {
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },

          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },

          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },

          -- Window commands
          { mode = 'n', keys = '<C-w>' },

          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
          { mode = 'n', keys = '<Leader>b',  desc = '+Buffers' },
          { mode = 'n', keys = '<Leader>c',  desc = '+Code' },
          { mode = 'n', keys = '<Leader>cb', desc = '+CommentBox' },
          { mode = 'n', keys = '<Leader>h',  desc = '+Harpoon' },
          { mode = 'n', keys = '<Leader>l',  desc = '+LSP' },
          { mode = 'n', keys = '<Leader>q',  desc = '+Quit' },
          { mode = 'n', keys = '<Leader>s',  desc = '+Telescope' },
          { mode = 'n', keys = '<Leader>t',  desc = '+Toggle' },
          { mode = 'n', keys = '<Leader>x',  desc = '+Trouble' },
          { mode = 'n', keys = '<Leader>?',  desc = '+Help' },
          { mode = 'n', keys = 'd',          desc = '+Diagnostics' },
          { mode = 'n', keys = 'y',          desc = '+Yank' },
          -- { mode = 'n', keys = 'gp',        desc = '+' },
        },
      }
    end,
  },

  -- Comment lines
  -- Replaced numToStr/Comment.nvim
  { 'echasnovski/mini.comment',    version = '*', opts = {} },

  -- Highlight cursor word and its matches
  { 'echasnovski/mini.cursorword', version = '*' },

  -- Work with diff hunks
  -- Replaced lewis6991/gitsigns.nvim
  { 'echasnovski/mini.diff',       version = '*', opts = {} },

  -- Highlight patterns in text
  -- Replaced folke/todo-comments.nvim
  {
    'echasnovski/mini.hipatterns',
    version = '*',
    opts = {
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = {
          pattern = '%f[%w]()FIXME()%f[%W]',
          group = 'MiniHipatternsFixme',
        },
        hack = {
          pattern = '%f[%w]()HACK()%f[%W]',
          group = 'MiniHipatternsHack',
        },
        todo = {
          pattern = '%f[%w]()TODO()%f[%W]',
          group = 'MiniHipatternsTodo',
        },
        note = {
          pattern = '%f[%w]()NOTE()%f[%W]',
          group = 'MiniHipatternsNote',
        },
      },
    },
    config = function(opts)
      local hp = require 'mini.hipatterns'
      hp.setup {
        highlighters = opts.highlighters,

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hp.gen_highlighter.hex_color(),
      }
    end,
  },

  -- Icons
  {
    'echasnovski/mini.icons',
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
      },
    },
  },

  -- Visualize and work with indent scope
  -- Replaced lukas-reineke/indent-blankline.nvim
  { 'echasnovski/mini.indentscope', version = '*', opts = {} },

  -- Jump to next/previous single character
  {
    'echasnovski/mini.jump',
    version = '*',
    opts = {
      mappings = {
        forward = 'f',
        backward = 'F',
        forward_till = 't',
        backward_till = 'T',
        repeat_jump = ';',
      },
    },
  },

  -- Move lines and blocks of text
  { 'echasnovski/mini.move',        version = '*', opts = {} },

  -- Text edit operators
  { 'echasnovski/mini.operators',   version = '*', opts = {} },

  -- Split and join arguments, lists, and other sequences
  -- Replaced Wansmer/treesj
  { 'echasnovski/mini.splitjoin',   version = '*', opts = {} },

  -- Fast and flexible start screen
  -- Replaced glepnir/dashboard-nvim
  { 'echasnovski/mini.starter',     version = '*', opts = {} },

  -- Fast and feature-rich surround actions
  -- Replaced kylechui/nvim-surround
  { 'echasnovski/mini.surround',    version = '*', opts = {} },

  -- Work with trailing whitespace
  { 'echasnovski/mini.trailspace',  version = '*', opts = {} },
}
