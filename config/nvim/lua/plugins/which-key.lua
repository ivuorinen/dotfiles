-- Useful plugin to show you pending keybinds.
-- https://github.com/folke/which-key.nvim
return {
  'folke/which-key.nvim',
  lazy = false,
  version = '*',
  priority = 1001, -- Make sure to load this as soon as possible
  dependencies = {
    'nvim-lua/plenary.nvim',
    'echasnovski/mini.icons',
  },
  config = function()
    local wk = require 'which-key'
    wk.setup()

    wk.add {
      -- Better default experience
      { '<space>', '<Nop>', mode = { 'n', 'v' } },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                       With leader                       │
      -- ╰─────────────────────────────────────────────────────────╯

      -- ── Buffer ──────────────────────────────────────────────────────────
      {
        '<leader>b',
        group = '[b] Buffer',
        expand = function()
          return require('which-key.extras').expand.buf()
        end,
      },
      { '<leader>bk', ':blast<cr>', desc = 'Buffer: Last', mode = 'n' },
      { '<leader>bj', ':bfirst<cr>', desc = 'Buffer: First', mode = 'n' },
      { '<leader>bh', ':bprev<cr>', desc = 'Buffer: Prev', mode = 'n' },
      { '<leader>bl', ':bnext<cr>', desc = 'Buffer: Next', mode = 'n' },
      { '<leader>bd', ':Bdelete<cr>', desc = 'Buffer: Delete', mode = 'n' },
      { '<leader>bw', ':Bwipeout<cr>', desc = 'Buffer: Wipeout', mode = 'n' },

      -- ── Code ────────────────────────────────────────────────────────────
      { '<leader>c', group = '[c] Code' },
      -- ── Code: CommentBox ────────────────────────────────────────────────
      { '<leader>cb', group = 'CommentBox' },
      { '<leader>cbb', '<Cmd>CBccbox<CR>', desc = 'CommentBox: Box Title' },
      { '<leader>cbd', '<Cmd>CBd<CR>', desc = 'CommentBox: Remove a box' },
      { '<leader>cbl', '<Cmd>CBline<CR>', desc = 'CommentBox: Simple Line' },
      { '<leader>cbm', '<Cmd>CBllbox14<CR>', desc = 'CommentBox: Marked' },
      { '<leader>cbt', '<Cmd>CBllline<CR>', desc = 'CommentBox: Titled Line' },

      { '<leader>d', group = '[d] DAP' },
      -- See: lua/plugins/dap.lua

      { '<leader>g', group = '[g] Git' },
      -- See: lua/plugins/git.lua

      { '<leader>h', group = '[h] Harpoon' },
      -- See: lua/plugins/harpoon.lua

      { '<leader>l', group = '[l] LSP' },
      -- See: lua/plugins/lsp.lua

      -- ── Quit ────────────────────────────────────────────────────────────
      { '<leader>q', group = '[q] Quit' },
      { '<leader>qf', ':q<CR>', desc = 'Quicker close split' },
      { '<leader>qq', ':wq!<CR>', desc = 'Quit with force saving' },
      { '<leader>qw', ':wq<CR>', desc = 'Write and quit' },

      { '<leader>s', group = '[s] Search' },
      -- See: lua/plugins/telescope.lua

      -- ── Toggle ──────────────────────────────────────────────────────────
      { '<leader>t', group = '[t] Toggle' },
      { '<leader>tt', ':TransparentToggle<CR>', desc = 'Toggle Transparency' },
      { '<leader>ts', ':noh<CR>', desc = 'Toggle Search Highlighting' },

      { '<leader>w', group = '[w] Workspace' },
      { '<leader>x', group = '[x] Trouble' },
      { '<leader>z', group = '[z] FZF' },

      -- ── Help ────────────────────────────────────────────────────────────
      { '<leader>?', group = '[?] Help' },
      {
        '<leader>?w',
        function()
          wk.show { global = false }
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                     Without leader                      │
      -- ╰─────────────────────────────────────────────────────────╯
      { 'y', group = 'Yank & Surround' },

      -- ── Old habits ──────────────────────────────────────────────────────
      { '<C-s>', ':w<CR>', desc = 'Save file' },

      -- ── Text manipulation in visual mode ────────────────────────────────
      { '>', '>gv', desc = 'Indent Right', mode = 'v' },
      { '<', '<gv', desc = 'Indent Left', mode = 'v' },
      { 'J', ":m '>+1<CR>gv=gv", desc = 'Move Block Down', mode = 'v' },
      { 'K', ":m '<-2<CR>gv=gv", desc = 'Move Block Up', mode = 'v' },

      -- ── Misc keybinds ───────────────────────────────────────────────────
      { 'QQ', ':q!<CR>', desc = 'Quit without saving' },
      { 'WW', ':w!<CR>', desc = 'Force write to file' },
      { 'ss', ':noh<CR>', desc = 'Clear Search Highlighting' },
      { 'jj', '<Esc>', desc = 'Esc without touching esc in insert mode', mode = 'i' },

      -- ── Splits ──────────────────────────────────────────────────────────
      --  Use CTRL+<hjkl> to switch between windows in normal mode
      --  See `:help wincmd` for a list of all window commands
      { '<C-h>', '<C-w><C-h>', desc = 'Move focus to the left window' },
      { '<C-l>', '<C-w><C-l>', desc = 'Move focus to the right window' },
      { '<C-j>', '<C-w><C-j>', desc = 'Move focus to the lower window' },
      { '<C-k>', '<C-w><C-k>', desc = 'Move focus to the upper window' },
      --  Split resizing
      { '<C-w>,', ':vertical resize -10<CR>', desc = 'V Resize -' },
      { '<C-w>.', ':vertical resize +10<CR>', desc = 'V Resize +' },

      -- ── Disable arrow keys in normal mode ───────────────────────────────
      { '<left>', '<cmd>echo "Use h to move!!"<CR>' },
      { '<right>', '<cmd>echo "Use l to move!!"<CR>' },
      { '<up>', '<cmd>echo "Use k to move!!"<CR>' },
      { '<down>', '<cmd>echo "Use j to move!!"<CR>' },

      -- ── Terminal ────────────────────────────────────────────────────────
      -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
      -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
      -- is not what someone will guess without a bit more experience.
      --
      -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
      -- or just use <C-\><C-n> to exit terminal mode.
      { '<Esc><Esc>', '<C-\\><C-n>', desc = 'Exit terminal mode', mode = 't' },

      -- ── Search ──────────────────────────────────────────────────────────
      -- :noh if you have search highlights
      { '<Esc><Esc>', ':noh<CR>', desc = 'Clear search highlights' },
    }
  end,
}
