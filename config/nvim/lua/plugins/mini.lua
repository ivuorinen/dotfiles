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
      -- ╭─────────────────────────────────────────────────────────╮
      -- │                      Text editing                       │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Better Around/Inside textobjects
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Comment lines
      require('mini.comment').setup()

      -- Text edit operators
      -- g= - Evaluate text and replace with output
      -- gx - Exchange text regions
      -- gm - Multiply (duplicate) text
      -- gr - Replace text with register
      -- gs - Sort text
      require('mini.operators').setup()

      -- Split and join arguments, lists, and other sequences
      require('mini.splitjoin').setup()

      -- Fast and feature-rich surround actions
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      -- - sff   - find right (`sf`) part of surrounding function call (`f`)
      require('mini.surround').setup()

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                    General workflow                     │
      -- ╰─────────────────────────────────────────────────────────╯

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

      -- Buffer removing (unshow, delete, wipeout), which saves window layout
      require('mini.bufremove').setup()

      -- Show next key clues
      local miniclue = require 'mini.clue'
      ---@modules mini.clue
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

      -- Work with diff hunks
      require('mini.diff').setup()

      -- Git integration
      require('mini.git').setup()

      -- Session management (read, write, delete)
      require('mini.sessions').setup {
        autowrite = true,
        directory = vim.g.sessions_dir or vim.fn.stdpath 'data' .. '/sessions',
        file = '',
      }

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                       Appearance                        │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Animate common Neovim actions
      require('mini.animate').setup()

      -- Highlight cursor word and its matches
      require('mini.cursorword').setup()

      -- Highlight patterns in text
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
      require('mini.indentscope').setup()

      -- Fast and flexible start screen
      local starter = require 'mini.starter'
      ---@modules mini.starter
      starter.setup {
        items = {
          starter.sections.telescope(),
          starter.sections.builtin_actions(),
          starter.sections.recent_files(5),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing('all', { 'Builtin actions' }),
          starter.gen_hook.aligning('center', 'center'),
        },
      }

      -- Minimal and fast statusline module with opinionated default look
      local sl = require 'mini.statusline'
      ---@modules mini.statusline
      sl.setup {
        use_icons = true,
        set_vim_settings = true,
        content = {
          active = function()
            local mode, mode_hl = sl.section_mode { trunc_width = 100 }
            local git = sl.section_git { trunc_width = 40 }
            local diagnostics = sl.section_diagnostics {
              trunc_width = 75,
              signs = {
                ERROR = 'E ',
                WARN = 'W ',
                INFO = 'I ',
                HINT = 'H ',
              },
            }
            local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
            local filename = sl.section_filename { trunc_width = 140 }
            local fileinfo = sl.section_fileinfo { trunc_width = 9999 }
            local location = sl.section_location { trunc_width = 9999 }
            return sl.combine_groups {
              { hl = mode_hl, strings = { mode } },
              {
                hl = 'MiniStatuslineDevinfo',
                strings = { git, lsp },
              },
              '%<', -- Mark general truncate point
              { hl = 'statuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'statuslineFileinfo', strings = { diagnostics } },
              { hl = 'statuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { location } },
            }
          end,
        },
      }

      -- Work with trailing whitespace
      require('mini.trailspace').setup()
    end,
  },
}
