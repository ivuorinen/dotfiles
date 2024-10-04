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
      -- ╭─────────────────────────────────────────────────────────╮
      -- │                       With leader                       │
      -- ╰─────────────────────────────────────────────────────────╯

      -- ── Buffer ──────────────────────────────────────────────────────────
      {
        '<leader>b',
        group = '[b] Buffer',
        -- Add the current buffers to the menu
        expand = function() return require('which-key.extras').expand.buf() end,
      },
      {
        { '<leader>bk', '<cmd>blast<cr>', desc = 'Buffer: Last' },
        { '<leader>bj', '<cmd>bfirst<cr>', desc = 'Buffer: First' },
        { '<leader>bh', '<cmd>bprev<cr>', desc = 'Buffer: Prev' },
        { '<leader>bl', '<cmd>bnext<cr>', desc = 'Buffer: Next' },
        { '<leader>bd', '<cmd>Bdelete<cr>', desc = 'Buffer: Delete' },
        { '<leader>bw', '<cmd>Bwipeout<cr>', desc = 'Buffer: Wipeout' },
      },

      -- ── Code ────────────────────────────────────────────────────────────
      { '<leader>c', group = '[c] Code' },
      {
        '<leader>ca',
        '<cmd>lua vim.lsp.buf.code_action()<CR>',
        desc = 'LSP: Code Action',
      },
      {
        '<leader>cg',
        '<cmd>lua require("neogen").generate()<CR>',
        desc = 'Generate annotations',
      },

      -- Code: treesj
      { '<leader>cc', group = 'Code Split/Join' },
      -- see: lua/plugins/treesj.lua
      { '<leader>cct', '<cmd>TSJToggle<CR>', desc = 'Split/Join: Toggle' },
      { '<leader>ccs', '<cmd>TSJSplit<CR>', desc = 'Split/Join: Split' },
      { '<leader>ccj', '<cmd>TSJJoin<CR>', desc = 'Split/Join: Join' },

      -- ── Code: CommentBox ────────────────────────────────────────────────
      { '<leader>cb', group = 'CommentBox' },
      { '<leader>cbb', '<Cmd>CBccbox<CR>', desc = 'CommentBox: Box Title' },
      { '<leader>cbd', '<Cmd>CBd<CR>', desc = 'CommentBox: Remove a box' },
      { '<leader>cbl', '<Cmd>CBline<CR>', desc = 'CommentBox: Simple Line' },
      { '<leader>cbm', '<Cmd>CBllbox14<CR>', desc = 'CommentBox: Marked' },
      { '<leader>cbt', '<Cmd>CBllline<CR>', desc = 'CommentBox: Titled Line' },

      -- ── Code: Refactoring ───────────────────────────────────────────────
      { '<leader>cx', group = '[x] Refactoring' },
      {
        mode = { 'x' },
        -- Extract function supports only visual mode
        {
          '<leader>cxe',
          "<cmd>lua require('refactoring').refactor('Extract Function')<cr>",
          desc = 'Extract Function',
        },
        {
          '<leader>cxf',
          "<cmd>lua require('refactoring').refactor('Extract Function To File')<cr>",
          desc = 'Extract Function to File',
        },
        -- Extract variable supports only visual mode
        {
          '<leader>cxv',
          "<cmd>lua require('refactoring').refactor('Extract Variable')<cr>",
          desc = 'Extract Variable',
        },
      },
      -- Inline func supports only normal
      {
        '<leader>cxif',
        "<cmd>lua require('refactoring').refactor('Inline Function')<cr>",
        desc = 'Inline Function',
      },
      -- Extract block supports only normal mode
      {
        '<leader>cxb',
        "<cmd>lua require('refactoring').refactor('Extract Block')<cr>",
        desc = 'Extract Block',
      },
      {
        '<leader>cxbf',
        "<cmd>lua require('refactoring').refactor('Extract Block To File')<cr>",
        desc = 'Extract Block to File',
      },
      {
        mode = { 'n', 'x' },
        -- Inline var supports both normal and visual mode
        {
          '<leader>cxiv',
          "<cmd>lua require('refactoring').refactor('Inline Variable')<cr>",
          desc = 'Inline Variable',
        },
      },

      -- ── Code: LSPSaga ───────────────────────────────────────────────────
      -- See: lua/plugins/lsp.lua
      {
        '<C-a>',
        '<cmd>Lspsaga term_toggle<cr>',
        desc = 'LSPSaga: Open Floaterm',
      },
      {
        '<leader>ca',
        '<cmd>Lspsaga code_action<cr>',
        desc = 'LSPSaga: Code Actions',
      },
      {
        '<leader>cci',
        '<cmd>Lspsaga incoming_calls<cr>',
        desc = 'LSPSaga: Incoming Calls',
      },
      {
        '<leader>cco',
        '<cmd>Lspsaga outgoing_calls<cr>',
        desc = 'LSPSaga: Outgoing Calls',
      },
      {
        '<leader>cd',
        '<cmd>Lspsaga show_line_diagnostics<cr>',
        desc = 'LSPSaga: Show Line Diagnostics',
      },
      {
        '<leader>cf',
        '<cmd>lua require("conform").format({ async = true, lsp_fallback = true })<cr>',
        mode = { 'n', 'v' },
        desc = 'Format buffer',
      },
      {
        '<leader>ci',
        '<cmd>Lspsaga implement<cr>',
        desc = 'LSPSaga: Implementations',
      },
      {
        '<leader>cl',
        '<cmd>Lspsaga show_cursor_diagnostics<cr>',
        desc = 'LSPSaga: Show Cursor Diagnostics',
      },
      {
        '<leader>cp',
        '<cmd>Lspsaga peek_definition<cr>',
        desc = 'LSPSaga: Peek Definition',
      },
      { '<leader>cr', '<cmd>Lspsaga rename<cr>', desc = 'LSPSaga: Rename' },
      {
        '<leader>cR',
        '<cmd>Lspsaga rename ++project<cr>',
        desc = 'LSPSaga: Rename Project wide',
      },
      {
        '<leader>cs',
        '<cmd>Lspsaga signature_help<cr>',
        desc = 'LSPSaga: Signature Documentation',
      },
      {
        '<leader>ct',
        '<cmd>Lspsaga peek_type_definition<cr>',
        desc = 'LSPSaga: Peek Type Definition',
      },
      {
        '<leader>cu',
        '<cmd>Lspsaga preview_definition<cr>',
        desc = 'LSPSaga: Preview Definition',
      },
      {
        '<leader>cv',
        '<cmd>Lspsaga diagnostic_jump_prev<cr>',
        desc = 'LSPSaga: Diagnostic Jump Prev',
      },
      {
        '<leader>cw',
        '<cmd>Lspsaga diagnostic_jump_next<cr>',
        desc = 'LSPSaga: Diagnostic Jump Next',
      },

      -- ── DAP ─────────────────────────────────────────────────────────────
      { '<leader>d', group = '[d] DAP' },
      {
        {
          '<leader>db',
          '<cmd>DapToggleBreakpoint',
          desc = 'DAP: Toggle Breakpoint',
        },
        { '<leader>dc', '<cmd>DapContinue', desc = 'DAP: Continue' },
        {
          '<leader>do',
          '<cmd>lua vim.diagnostic.open_float()<CR>',
          desc = 'Diagnostic: Open float',
        },
        {
          '<leader>dq',
          '<cmd>lua vim.diagnostic.setloclist()<CR>',
          desc = 'Diagnostic: Set loc list',
        },
        {
          '<leader>dr',
          "<cmd>lua require('dapui').open({reset = true})<CR>",
          desc = 'DAP: Reset',
        },
        {
          '<leader>ds',
          '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>',
          desc = 'LSP: Document Symbols',
        },
        { '<leader>dt', '<cmd>DapUiToggle', desc = 'DAP: Toggle UI' },
      },

      -- ── Harpoon ─────────────────────────────────────────────────────────
      -- See: lua/plugins/telescope.lua
      { '<leader>h', group = '[h] Harpoon' },
      {
        {
          '<leader>ha',
          '<cmd>lua require("harpoon"):list():add()<cr>',
          desc = 'harpoon file',
        },
        {
          '<leader>hn',
          '<cmd>lua require("harpoon"):list():next()<cr>',
          desc = 'harpoon to next file',
        },
        {
          '<leader>hp',
          '<cmd>lua require("harpoon"):list():prev()<cr>',
          desc = 'harpoon to previous file',
        },
        {
          '<leader>ht',
          "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>",
          desc = 'DAP: Harpoon UI',
        },
      },

      -- ── LSP ─────────────────────────────────────────────────────────────
      { '<leader>l', group = '[l] LSP' },
      -- See: lua/plugins/lsp.lua

      -- ── Quit ────────────────────────────────────────────────────────────
      { '<leader>q', group = '[q] Quit' },
      {
        { '<leader>qf', '<cmd>q<CR>', desc = 'Quicker close split' },
        { '<leader>qq', '<cmd>wq!<CR>', desc = 'Quit with force saving' },
        { '<leader>qw', '<cmd>wq<CR>', desc = 'Write and quit' },
      },

      -- ── Search ──────────────────────────────────────────────────────────
      { '<leader>s', group = '[s] Search' },
      -- See: lua/plugins/telescope.lua
      {
        '<leader><space>',
        "<cmd>lua require('telescope.builtin').buffers()<cr>",
        desc = 'Find existing buffers',
      },
      {
        '<leader><tab>',
        "<cmd>lua require('telescope.builtin').commands()<CR>",
        desc = 'Telescope: Commands',
      },
      {
        '<leader>sd',
        "<cmd>lua require('telescope.builtin').diagnostics()<cr>",
        desc = 'Search Diagnostics',
      },
      {
        '<leader>sg',
        "<cmd>lua require('telescope.builtin').live_grep()<cr>",
        desc = 'Search by Grep',
      },
      {
        '<leader>sm',
        '<cmd>Telescope harpoon marks<CR>',
        desc = 'Harpoon Marks',
      },
      {
        '<leader>sn',
        "<cmd>lua require('telescope').extensions.notify.notify()<CR>",
        desc = 'Show Notifications',
      },
      {
        '<leader>so',
        "<cmd>lua require('telescope.builtin').oldfiles()<cr>",
        desc = 'Find recently Opened files',
      },
      {
        '<leader>sp',
        "<cmd>lua require('telescope').extensions.lazy_plugins.lazy_plugins()<cr>",
        desc = 'Find neovim/lazy configs',
      },
      { '<leader>st', '<cmd>TodoTelescope<CR>', desc = 'Telescope: Show Todo' },
      {
        '<leader>sw',
        "<cmd>lua require('telescope.builtin').grep_string()<cr>",
        desc = 'Search current Word',
      },

      -- ── Toggle ──────────────────────────────────────────────────────────
      { '<leader>t', group = '[t] Toggle' },
      {
        { '<leader>tc', '<cmd>CloakToggle<cr>', desc = 'Toggle Cloak' },
        { '<leader>tn', '<cmd>Noice dismiss<CR>', desc = 'Noice dismiss' },
        { '<leader>ts', '<cmd>noh<CR>', desc = 'Toggle Search Highlighting' },
        {
          '<leader>tt',
          '<cmd>TransparentToggle<CR>',
          desc = 'Toggle Transparency',
        },
        { '<leader>tw', '<cmd>Twilight<cr>', desc = 'Toggle Twilight' },
      },

      -- ── Workspace ───────────────────────────────────────────────────────
      { '<leader>w', group = '[w] Workspace' },
      {
        {
          '<leader>wa',
          '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
          desc = 'LSP: Workspace Add Folder',
        },
        {
          '<leader>wl',
          '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
          desc = 'LSP: Workspace List Folders',
        },
        {
          '<leader>wr',
          '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
          desc = 'LSP: Workspace Remove Folder',
        },
        {
          '<leader>ws',
          '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>',
          desc = 'LSP: Workspace Symbols',
        },
      },

      -- ── Trouble ─────────────────────────────────────────────────────────
      { '<leader>x', group = '[x] Trouble' },
      {
        {
          '<leader>xx',
          '<cmd>Trouble diagnostics<cr>',
          desc = 'Toggle Trouble Diagnostics',
        },
        {
          '<leader>xw',
          '<cmd>Trouble workspace_diagnostics<cr>',
          desc = 'Toggle Workspace Diagnostics',
        },
        {
          '<leader>xd',
          '<cmd>Trouble document_diagnostics<cr>',
          desc = 'Toggle Document Diagnostics',
        },
        { '<leader>xl', '<cmd>Trouble loclist<cr>', desc = 'Toggle Loclist' },
        { '<leader>xq', '<cmd>Trouble quickfix<cr>', desc = 'Toggle Quickfix' },
      },

      -- ── Help ────────────────────────────────────────────────────────────
      { '<leader>?', group = '[?] Help & Cheat sheets' },
      {
        {
          '<leader>?w',
          '<cmd>lua require("which-key").show({global = true})<cr>',
          desc = 'Buffer Local Keymaps (which-key)',
        },
      },

      -- ── Misc ────────────────────────────────────────────────────────────
      {
        '<leader>D',
        '<cmd>lua vim.lsp.buf.type_definition()<CR>',
        desc = 'LSP: Type Definition',
      },
      { '<leader>e', '<cmd>Neotree reveal<CR>', desc = 'NeoTree reveal' },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                     Without leader                      │
      -- ╰─────────────────────────────────────────────────────────╯
      { 'y', group = 'Yank & Surround' },

      { 'gp', group = 'Goto Preview' },
      {
        {
          'gpd',
          '<cmd>lua require("goto-preview").goto_preview_definition()<CR>',
          desc = 'Goto: Preview Definition',
        },
        {
          'gpi',
          '<cmd>lua require("goto-preview").goto_preview_implementation()<CR>',
          desc = 'Goto: Preview Implementation',
        },
        {
          'gpP',
          '<cmd>lua require("goto-preview").close_all_windows()<CR>',
          desc = 'Goto: Close All Preview Windows',
        },
      },

      -- ── tmux navigation ─────────────────────────────────────────────────
      {
        {
          '<c-h>',
          '<cmd><C-U>TmuxNavigateLeft<cr>',
          desc = 'tmux: Navigate Left',
        },
        {
          '<c-j>',
          '<cmd><C-U>TmuxNavigateDown<cr>',
          desc = 'tmux: Navigate Down',
        },
        { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>', desc = 'tmux: Navigate Up' },
        {
          '<c-l>',
          '<cmd><C-U>TmuxNavigateRight<cr>',
          desc = 'tmux: Navigate Right',
        },
        {
          '<c-\\>',
          '<cmd><C-U>TmuxNavigatePrevious<cr>',
          desc = 'tmux: Navigate Previous',
        },
      },

      -- ── Old habits ──────────────────────────────────────────────────────
      { '<C-s>', '<cmd>w<CR>', desc = 'Save file' },

      -- ── Text manipulation in visual mode ────────────────────────────────
      {
        mode = 'v',
        { '>', '>gv', desc = 'Indent Right' },
        { '<', '<gv', desc = 'Indent Left' },
        { 'J', "<cmd>m '>+1<CR>gv=gv", desc = 'Move Block Down' },
        { 'K', "<cmd>m '<-2<CR>gv=gv", desc = 'Move Block Up' },
      },

      -- ── LSP ─────────────────────────────────────────────────────────────
      {
        '<C-k>',
        '<cmd>lua vim.lsp.buf.signature_help()<CR>',
        desc = 'LSP: Signature Documentation',
      },
      {
        'K',
        '<cmd>Lspsaga hover_doc<cr>',
        desc = 'LSPSaga: Hover Documentation',
      },

      { 'd', group = 'Diagnostics' },
      {
        {
          'dn',
          '<cmd>lua vim.diagnostic.goto_next()<CR>',
          desc = 'Diagnostic: Goto Next',
        },
        {
          'dp',
          '<cmd>lua vim.diagnostic.goto_prev()<CR>',
          desc = 'Diagnostic: Goto Prev',
        },
      },
      {
        { 'g', group = 'Goto' },
        {
          'gD',
          '<cmd>lua vim.lsp.buf.declaration()<CR>',
          desc = 'LSP: Goto Declaration',
        },
        {
          'gI',
          '<cmd>lua vim.lsp.buf.implementation()<CR>',
          desc = 'LSP: Goto Implementation',
        },
        {
          'gR',
          '<cmd>Trouble lsp_references<cr>',
          desc = 'Toggle LSP References',
        },
        {
          'gd',
          '<cmd>lua vim.lsp.buf.definition()<CR>',
          desc = 'LSP: Goto Definition',
        },
        {
          'gr',
          '<cmd>lua require("telescope.builtin").lsp_references()<CR>',
          desc = 'LSP: Goto References',
        },
      },

      -- ── Misc keybinds ───────────────────────────────────────────────────
      -- Sublime-like shortcut 'go to file' ctrl+p.
      {
        '<C-p>',
        '<cmd>Telescope find_files<CR>',
        desc = 'Search for files starting at current directory.',
      },
      { 'QQ', '<cmd>q!<CR>', desc = 'Quit without saving' },
      { 'WW', '<cmd>w!<CR>', desc = 'Force write to file' },
      { 'ss', '<cmd>noh<CR>', desc = 'Clear Search Highlighting' },
      {
        'jj',
        '<Esc>',
        desc = 'Esc without touching esc in insert mode',
        mode = 'i',
      },

      -- ── Splits ──────────────────────────────────────────────────────────
      --  Use CTRL+<hjkl> to switch between windows in normal mode
      --  See `:help wincmd` for a list of all window commands
      { '<C-h>', '<C-w><C-h>', desc = 'Move focus to the left window' },
      { '<C-l>', '<C-w><C-l>', desc = 'Move focus to the right window' },
      { '<C-j>', '<C-w><C-j>', desc = 'Move focus to the lower window' },
      { '<C-k>', '<C-w><C-k>', desc = 'Move focus to the upper window' },
      --  Split resizing
      { '<C-w>,', '<cmd>vertical resize -10<CR>', desc = 'V Resize -' },
      { '<C-w>.', '<cmd>vertical resize +10<CR>', desc = 'V Resize +' },

      -- ── Disable arrow keys in normal mode ───────────────────────────────
      { '<left>', '<cmd>echo "Use h to move!!"<CR>' },
      { '<right>', '<cmd>echo "Use l to move!!"<CR>' },
      { '<up>', '<cmd>echo "Use k to move!!"<CR>' },
      { '<down>', '<cmd>echo "Use j to move!!"<CR>' },

      -- ── Terminal ────────────────────────────────────────────────────────
      -- Exit terminal mode in the builtin terminal with a shortcut that is
      -- a bit easier for people to discover. Otherwise, you normally need
      -- to press <C-\><C-n>, which is not what someone will guess without
      -- a bit more experience.
      --
      -- NOTE: This won't work in all terminal emulators/tmux/etc.
      -- Try your own mapping or just use <C-\><C-n> to exit terminal mode.
      { '<Esc><Esc>', '<C-\\><C-n>', desc = 'Exit terminal mode', mode = 't' },

      -- ── Search ──────────────────────────────────────────────────────────
      -- :noh if you have search highlights
      { '<Esc><Esc>', '<cmd>noh<CR>', desc = 'Clear search highlights' },
    }
  end,
}
