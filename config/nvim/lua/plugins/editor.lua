return {
  -- Library of 40+ independent Lua modules improving overall Neovim
  -- (version 0.8 and higher) experience with minimal effort
  --
  -- https://github.com/nvim-mini/mini.nvim
  -- https://github.com/nvim-mini/mini.nvim?tab=readme-ov-file#modules
  --
  -- YouTube: Text editing with 'mini.nvim' - Neovimconf 2024 - Evgeni Chasnovski
  -- https://www.youtube.com/watch?v=cNK5kYJ7mrs
  {
    'nvim-mini/mini.nvim',
    version = false,
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
      require('mini.ai').setup { n_lines = 750 }

      -- Text edit operators
      -- g= - Evaluate text and replace with output
      -- gx - Exchange text regions
      -- gm - Multiply (duplicate) text
      -- gR - Replace text with register (gr reserved for LSP)
      -- gs - Sort text
      require('mini.operators').setup {
        replace = { prefix = 'gR' },
      }

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

      -- Buffer removing (unshow, delete, wipeout), which saves window layout
      require('mini.bufremove').setup()

      -- File explorer (column-based, Finder-style)
      require('mini.files').setup {
        content = {
          filter = function(entry)
            return entry.name ~= '.DS_Store'
              and entry.name ~= '.git'
              and entry.name ~= 'node_modules'
          end,
        },
        mappings = {
          go_in_plus = '<CR>',
          close = '<Esc>',
        },
        windows = { preview = true },
      }

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
          { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
          { mode = 'n', keys = '<Leader>c', desc = '+Code' },
          { mode = 'n', keys = '<Leader>cb', desc = '+CommentBox' },
          { mode = 'n', keys = '<Leader>cc', desc = '+Calls' },
          { mode = 'n', keys = '<Leader>q', desc = '+Quit' },
          { mode = 'n', keys = '<Leader>s', desc = '+Telescope' },
          { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
          { mode = 'n', keys = '<Leader>tm', desc = '+Toggle Options' },
          { mode = 'n', keys = '<Leader>x', desc = '+Trouble' },
          { mode = 'n', keys = '<Leader>?', desc = '+Help' },
        },
      }

      -- Work with diff hunks
      require('mini.diff').setup()

      -- Session management (auto per-directory)
      local sessions = require 'mini.sessions'
      sessions.setup {
        autowrite = true,
        directory = vim.g.sessions_dir or vim.fn.stdpath 'data' .. '/sessions',
        file = '',
      }

      -- Auto-read session for cwd on startup (no file args)
      vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('auto-session', { clear = true }),
        nested = true,
        callback = function()
          if vim.fn.argc() > 0 then return end
          local cwd = vim.fn.getcwd()
          local name = cwd:gsub('[/\\]', '%%')
          local ok = pcall(sessions.read, name, { force = true })
          if not ok then
            -- No session yet — will be created on exit
            vim.g.mini_sessions_current = name
          end
        end,
      })

      -- Auto-write session for cwd on exit
      vim.api.nvim_create_autocmd('VimLeavePre', {
        group = vim.api.nvim_create_augroup('auto-session-write', { clear = true }),
        callback = function()
          local cwd = vim.fn.getcwd()
          local name = cwd:gsub('[/\\]', '%%')
          sessions.write(name, { force = true })
        end,
      })

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
            pattern = '%f[%w]()NOTE:?%s*()%f[%W]',
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
          ['devcontainer.json'] = { hl = 'MiniIconsAzure' },
        },
        filetype = {
          dotenv = { hl = 'MiniIconsYellow' },
        },
      }

      -- Visualize and work with indent scope
      local iscope = require 'mini.indentscope'
      iscope.setup {
        draw = { animation = iscope.gen_animation.none() },
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
            local lsp = sl.section_lsp { trunc_width = 75 }
            local lsp_status = #vim.lsp.get_clients { bufnr = 0 } > 0
                and (vim.lsp.status() ~= '' and '󰔚' or '󰄬')
              or ''
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
              { hl = 'MiniStatuslineDevinfo', strings = { lsp_status } },
              { hl = mode_hl, strings = { location } },
            }
          end,
        },
      }

      -- Work with trailing whitespace
      require('mini.trailspace').setup()
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  -- https://github.com/tpope/vim-sleuth
  { 'tpope/vim-sleuth', event = 'BufReadPre' },

  -- Break bad habits, master Vim motions
  -- https://github.com/m4xshen/hardtime.nvim
  {
    'm4xshen/hardtime.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      restriction_mode = 'hint',
      disabled_keys = {
        ['<Up>'] = { '', 'n' },
        ['<Down>'] = { '', 'n' },
        ['<Left>'] = { '', 'n' },
        ['<Right>'] = { '', 'n' },
        ['<C-Up>'] = { '', 'n' },
        ['<C-Down>'] = { '', 'n' },
        ['<C-Left>'] = { '', 'n' },
        ['<C-Right>'] = { '', 'n' },
      },
      disabled_filetypes = {
        'TelescopePrompt',
        'Trouble',
        'lazy',
        'mason',
        'help',
        'notify',
        'dashboard',
        'alpha',
      },
      hints = {
        ['[dcyvV][ia][%(%)]'] = {
          message = function(keys)
            return 'Use ' .. keys:sub(1, 2) .. 'b instead of ' .. keys
          end,
          length = 3,
        },
        ['[dcyvV][ia][%{%}]'] = {
          message = function(keys)
            return 'Use ' .. keys:sub(1, 2) .. 'B instead of ' .. keys
          end,
          length = 3,
        },
        ['<Esc><Esc>'] = {
          -- stylua: ignore
          message = function() return 'Use single <Esc> to clear hlsearch (0.11)' end,
          length = 2,
        },
      },
    },
  },
}
