-- https://github.com/echasnovski/mini.nvim
-- https://github.com/echasnovski/mini.nvim/tree/main?tab=readme-ov-file#modules
return {
  -- Presets for common options and mappings
  { 'echasnovski/mini.basics',    version = '*' },

  -- Extend and create a/i textobjects
  { 'echasnovski/mini.ai',        version = '*' },

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
        window = {
          config = {
            width = 'auto',
          },
        },
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

        -- These mark the sections in the popup
        clues = {
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
          { mode = 'n', keys = '<Leader>b',  desc = '+Buffers' },
          { mode = 'n', keys = '<Leader>c',  desc = '+Code' },
          { mode = 'n', keys = '<Leader>cb', desc = '+CommentBox' },
          { mode = 'n', keys = '<Leader>cc', desc = '+Calls' },
          { mode = 'n', keys = '<Leader>q',  desc = '+Quit' },
          { mode = 'n', keys = '<Leader>s',  desc = '+Telescope' },
          { mode = 'n', keys = '<Leader>t',  desc = '+Toggle' },
          { mode = 'n', keys = '<Leader>x',  desc = '+Trouble' },
          { mode = 'n', keys = '<leader>z',  desc = '+TreeSitter' },
          { mode = 'n', keys = '<leader>zg', desc = '+Goto' },
          { mode = 'n', keys = '<Leader>?',  desc = '+Help' },
          { mode = 'n', keys = 'd',          desc = '+Diagnostics' },
          { mode = 'n', keys = 'y',          desc = '+Yank' },
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

  -- Git integration
  { 'echasnovski/mini-git',        version = '*', opts = {}, main = 'mini.git' },

  -- Highlight patterns in text
  -- Replaced folke/todo-comments.nvim
  {
    'echasnovski/mini.hipatterns',
    version = '*',
    opts = {
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE', 'BUG', 'PERF' words
        fixme = {
          pattern = '%f[%w]()FIXME:?%s*()%f[%W]',
          group = 'MiniHipatternsFixme',
        },
        hack = {
          pattern = '%f[%w]()HACK:?%s*()%f[%W]',
          group = 'MiniHipatternsHack',
        },
        todo = {
          pattern = '%f[%w]()NOTE:?%s*()%f[%W]',
          group = 'MiniHipatternsTodo',
        },
        note = {
          pattern = '%f[%w]()NOTE()%f[%W]',
          group = 'MiniHipatternsNote',
        },
        bug = {
          pattern = '%f[%w]()BUG:?%s*()%f[%W]',
          group = 'MiniHipatternsBug',
        },
        perf = {
          pattern = '%f[%w]()PERF:?%s*()%f[%W]',
          group = 'MiniHipatternsPerf',
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

  -- Session management (read, write, delete)
  {
    'echasnovski/mini.sessions',
    version = '*',
    opts = {
      autoread = true,
      autowrite = true,
    }
  },

  -- Split and join arguments, lists, and other sequences
  -- Replaced Wansmer/treesj
  { 'echasnovski/mini.splitjoin',  version = '*', opts = {} },

  -- Fast and flexible start screen
  -- Replaced glepnir/dashboard-nvim
  {
    'echasnovski/mini.starter',
    version = '*',
    config = function()
      local starter = require('mini.starter')
      starter.setup({
        items = {
          starter.sections.telescope(),
          starter.sections.builtin_actions(),
          starter.sections.sessions(5, true),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing('all', { 'Builtin actions' }),
          starter.gen_hook.aligning('center', 'center'),
        },
      })
    end
  },

  -- Minimal and fast statusline module with opinionated default look
  -- Replaced nvim-lualine/lualine.nvim
  {
    'echasnovski/mini.statusline',
    version = '*',
    opts = {
      use_icons = true,
      set_vim_settings = true,
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local git = MiniStatusline.section_git({ trunc_width = 75 })
          local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local filename = MiniStatusline.section_filename({ trunc_width = 50 })
          -- local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
          local location = MiniStatusline.section_location({ trunc_width = 75 })
          return MiniStatusline.combine_groups({
            { hl = mode_hl,                 strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            -- { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl,                  strings = { location } },
          })
        end,
      },
    }
  },

  -- Fast and feature-rich surround actions
  -- Replaced kylechui/nvim-surround
  { 'echasnovski/mini.surround',   version = '*', opts = {} },

  -- Work with trailing whitespace
  { 'echasnovski/mini.trailspace', version = '*', opts = {} },
}
