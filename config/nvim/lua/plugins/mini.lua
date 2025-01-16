return {
  -- Library of 40+ independent Lua modules improving overall Neovim
  -- (version 0.8 and higher) experience with minimal effort
  --
  -- https://github.com/echasnovski/mini.nvim
  -- https://github.com/echasnovski/mini.nvim/tree/main?tab=readme-ov-file#modules
  --
  -- YouTube: Text editing with 'mini.nvim' - Neovimconf 2024 - Evgeni Chasnovski
  -- https://www.youtube.com/watch?v=cNK5kYJ7mrs
  {
    'echasnovski/mini.nvim',
    version = '*',
    priority = 1001,
    config = function()
      -- Presets for common options and mappings
      -- h: MiniBasics.config
      require('mini.basics').setup {
        options = {
          basics = true,
          extra_ui = true,
        },
        mappings = {
          basic = true,
          option_toggle_prefix = [[<leader>tm]],
        },
      }

      -- Animate common Neovim actions
      -- Replaced anuvyklack/windows.nvim
      require('mini.animate').setup()

      -- Buffer removing (unshow, delete, wipeout), which saves window layout
      -- Replaced famiu/bufdelete.nvim
      require('mini.bufremove').setup()

      -- Show next key clues
      -- Replaced folke/which-key.nvim
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
          { mode = 'n', keys = '<Leader>a', desc = '+Automation' },
          { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
          { mode = 'n', keys = '<Leader>c', desc = '+Code' },
          { mode = 'n', keys = '<Leader>cb', desc = '+CommentBox' },
          { mode = 'n', keys = '<Leader>cc', desc = '+Calls' },
          { mode = 'n', keys = '<Leader>q', desc = '+Quit' },
          { mode = 'n', keys = '<Leader>s', desc = '+Telescope' },
          { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
          { mode = 'n', keys = '<Leader>tm', desc = '+Mini' },
          { mode = 'n', keys = '<Leader>x', desc = '+Trouble' },
          { mode = 'n', keys = '<leader>z', desc = '+TreeSitter' },
          { mode = 'n', keys = '<leader>zg', desc = '+Goto' },
          { mode = 'n', keys = '<Leader>?', desc = '+Help' },
          { mode = 'n', keys = 'd', desc = '+Diagnostics' },
          { mode = 'n', keys = 'y', desc = '+Yank' },
        },
      }

      -- Comment lines
      -- Replaced numToStr/Comment.nvim
      require('mini.comment').setup()

      -- Highlight cursor word and its matches
      require('mini.cursorword').setup()

      -- Work with diff hunks
      -- Replaced lewis6991/gitsigns.nvim
      require('mini.diff').setup()

      -- Git integration
      require('mini.git').setup()

      -- Highlight patterns in text
      -- Replaced folke/todo-comments.nvim
      local hp = require 'mini.hipatterns'
      hp.setup {
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
            pattern = '%f[%w]()TODO:?%s*()%f[%W]',
            group = 'MiniHipatternsNote',
          },
          note = {
            pattern = '%f[%w]()NOTE()%f[%W]',
            group = 'MiniHipatternsNote',
          },
          bug = {
            pattern = '%f[%w]()BUG:?%s*()%f[%W]',
            group = 'MiniHipatternsHack',
          },
          perf = {
            pattern = '%f[%w]()PERF:?%s*()%f[%W]',
            group = 'MiniHipatternsNote',
          },
        },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hp.gen_highlighter.hex_color(),
      }

      -- Icons
      require('mini.icons').setup {
        file = {
          ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
          ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        },
        filetype = {
          dotenv = { glyph = '', hl = 'MiniIconsYellow' },
        },
      }

      -- Visualize and work with indent scope
      -- Replaced lukas-reineke/indent-blankline.nvim
      require('mini.indentscope').setup()

      -- Jump to next/previous single character
      require('mini.jump').setup {
        mappings = {
          forward = 'f',
          backward = 'F',
          forward_till = 't',
          backward_till = 'T',
          repeat_jump = ';',
        },
      }

      -- Move lines and blocks of text
      require('mini.move').setup()

      -- Text edit operators
      -- g= - Evaluate text and replace with output
      -- gx - Exchange text regions
      -- gm - Multiply (duplicate) text
      -- gr - Replace text with register
      -- gs - Sort text
      require('mini.operators').setup()

      -- Session management (read, write, delete)
      require('mini.sessions').setup {
        autowrite = true,
        directory = vim.g.sessions_dir or vim.fn.stdpath 'data' .. '/sessions',
        file = '',
      }

      -- Split and join arguments, lists, and other sequences
      -- Replaced Wansmer/treesj
      require('mini.splitjoin').setup()

      -- Fast and flexible start screen
      -- Replaced glepnir/dashboard-nvim
      local starter = require 'mini.starter'
      starter.setup {
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
      }

      -- Minimal and fast statusline module with opinionated default look
      -- Replaced nvim-lualine/lualine.nvim
      local sl = require 'mini.statusline'
      sl.setup {
        use_icons = true,
        set_vim_settings = true,
        content = {
          active = function()
            local mode, mode_hl = sl.section_mode { trunc_width = 120 }
            local git = sl.section_git { trunc_width = 75 }
            local diagnostics = sl.section_diagnostics { trunc_width = 75 }
            local filename = sl.section_filename { trunc_width = 9999 }
            local fileinfo = sl.section_fileinfo { trunc_width = 120 }
            local location = sl.section_location { trunc_width = 75 }
            return sl.combine_groups {
              { hl = mode_hl, strings = { mode } },
              { hl = 'statuslineDevinfo', strings = { git, diagnostics } },
              '%<', -- Mark general truncate point
              { hl = 'statuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'statuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { location } },
            }
          end,
        },
      }

      -- Fast and feature-rich surround actions
      -- Replaced kylechui/nvim-surround
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Work with trailing whitespace
      require('mini.trailspace').setup()
    end,
  },
}
