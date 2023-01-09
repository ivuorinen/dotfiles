-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system {
    'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  }
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  use { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    },
  }

  use { -- Autocompletion
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  }

  use { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  }

  use { -- Additional text objects via treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  }

  -- Git related plugins
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use 'lewis6991/gitsigns.nvim'

  -- Theme based off the Material Pale Night
  use 'drewtempelmeyer/palenight.vim'
  -- Fancier statusline
  use 'nvim-lualine/lualine.nvim'
  -- Add indentation guides even on blank lines.
  use 'lukas-reineke/indent-blankline.nvim'
  -- "gc" to comment visual regions/lines
  use 'numToStr/Comment.nvim'
  -- Detect tabstop and shiftwidth automatically.
  use 'tpope/vim-sleuth'

  -- Fuzzy Finder (files, lsp, etc)
  use { 'nvim-telescope/telescope.nvim',
    branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make', cond = vim.fn.executable 'make' == 1 }

  -- Add custom plugins to packer from
  -- ~/.config/nvim/lua/custom/plugins.lua
  local has_plugins, plugins = pcall(require, 'custom.plugins')
  if has_plugins then
    plugins(use)
  end

  if is_bootstrap then
    require('packer').sync()
  end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer
-- whenever you save this init.lua, or packages.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = { vim.fn.expand '$MYVIMRC' },
})
-- Automatically run PackerSync for plugins.lua files.
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerSync | PackerCompile',
  group = packer_group,
  pattern = { '~/.dotfiles/config/nvim/**/plugins.lua' },
})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default, enabled relative line numbers
vim.wo.number = true
vim.opt.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd.colorscheme('palenight')

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Configure and disable providers.
vim.g.python3_host_prog = '/opt/homebrew/bin/python3'
vim.g.loaded_ruby_provider = 0

-- Setup winbar
-- See :h statusline
vim.o.winbar = '%=%m %f'

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required
--  (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Misc options.
vim.o.incsearch = true

-- Keymap settings, etc.
-- ~/.config/nvim/lua/custom/keymaps.lua
local map = vim.api.nvim_set_keymap
local default_options_table = {
  expr = true,
  silent = true,
  noremap = true,
}

-- normal mode keymap setter
---@param keys string Trigger keys
---@param func string Function or command to run
---@param opts table Optional table of vim.keymap.set options.
---@param desc string Optional description
local nmap = function(keys, func, opts, desc)
  if desc then
    desc = 'keymaps.nmap: ' .. desc
  end

  local options = default_options_table

  -- If we have options, merge them to the local options table
  if opts then
    for k, v in pairs(opts) do
      options[k] = v
    end
  end

  vim.keymap.set('n', keys, func, options)
end

-- visual mode keymap setter
---@param keys string Trigger keys
---@param func string Function or command to run
---@param opts table Optional table of vim.keymap.set options.
---@param desc string Optional description
local vmap = function(keys, func, opts, desc)
  if desc then
    desc = 'keymaps.vmap: ' .. desc
  end

  local options = default_options_table

  -- If we have options, merge them to the local options table
  if opts then
    for k, v in pairs(opts) do
      options[k] = v
    end
  end

  vim.keymap.set('v', keys, func, options)
end

-- Format document
nmap("<leader>D", ":Format")

-- Deal with word wrap
nmap('k', "v:count == 0 ? 'gk' : 'k'")
nmap('j', "v:count == 0 ? 'gj' : 'j'")

-- Diagnostic keymaps
nmap('dz', vim.diagnostic.goto_prev)
nmap('dx', vim.diagnostic.goto_next)
nmap('<leader>e', vim.diagnostic.open_float)
nmap('<leader>q', vim.diagnostic.setloclist)

--
-- ThePrimeagen/refactoring.nvim
-- https://github.com/ThePrimeagen/refactoring.nvim
--

-- Remaps for the refactoring operations currently offered by the plugin
local rf = { noremap = true, silent = true, expr = false }
vmap("<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], rf)
vmap("<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]], rf)
vmap("<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], rf)
vmap("<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], rf)

-- Extract block doesn't need visual mode
nmap("<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], rf)
nmap("<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], rf)

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
nmap("<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], rf)

-- prompt for a refactor to apply when the remap is triggered
vmap("<leader>rr", ":lua require('refactoring').select_refactor()<CR>", rf)

--
--
--

-- barbar keymaps
local barbar_opts = { noremap = true, silent = true }

-- Move to previous/next
map('n', '<C-,>', '<Cmd>BufferPrevious<CR>', barbar_opts)
map('n', '<C-.>', '<Cmd>BufferNext<CR>', barbar_opts)
-- Re-order to previous/next
map('n', '<C-<>', '<Cmd>BufferMovePrevious<CR>', barbar_opts)
map('n', '<C->>', '<Cmd>BufferMoveNext<CR>', barbar_opts)
-- Goto buffer in position...
map('n', '<leader>b1', '<Cmd>BufferGoto 1<CR>', barbar_opts)
map('n', '<leader>b2', '<Cmd>BufferGoto 2<CR>', barbar_opts)
map('n', '<leader>b3', '<Cmd>BufferGoto 3<CR>', barbar_opts)
map('n', '<leader>b4', '<Cmd>BufferGoto 4<CR>', barbar_opts)
map('n', '<leader>b5', '<Cmd>BufferGoto 5<CR>', barbar_opts)
map('n', '<leader>b6', '<Cmd>BufferGoto 6<CR>', barbar_opts)
map('n', '<leader>b7', '<Cmd>BufferGoto 7<CR>', barbar_opts)
map('n', '<leader>b8', '<Cmd>BufferGoto 8<CR>', barbar_opts)
map('n', '<leader>b9', '<Cmd>BufferGoto 9<CR>', barbar_opts)
map('n', '<leader>b0', '<Cmd>BufferLast<CR>', barbar_opts)
-- Pin/unpin buffer
map('n', '<A-p>', '<Cmd>BufferPin<CR>', barbar_opts)
-- Close buffer
map('n', '<A-c>', '<Cmd>BufferClose<CR>', barbar_opts)
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
map('n', '<C-p>', '<Cmd>BufferPick<CR>', barbar_opts)
-- Sort automatically by...
map('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', barbar_opts)
map('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', barbar_opts)
map('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', barbar_opts)
map('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', barbar_opts)

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used


local highlight_group = vim.api.nvim_create_augroup(
  'YankHighlight', { clear = true }
)
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = '|',
    section_separators = '',
  },
}

-- Enable Comment.nvim
require('Comment').setup()

-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
require('indent_blankline').setup {
  -- char = '┊',
  show_trailing_blankline_indent = true,
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
}

-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

local ks = vim.keymap.set
local tl = require('telescope.builtin')

-- See `:help telescope.builtin`
ks('n', '<leader>?', tl.oldfiles, { desc = '[?] Find recently opened files' })
ks('n', '<leader><space>', tl.buffers, { desc = '[ ] Find existing buffers' })
ks('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to
  -- change theme, layout, etc.
  tl.current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer]' })

ks('n', '<leader>sf', tl.find_files, { desc = '[S]earch [F]iles' })
ks('n', '<leader>sh', tl.help_tags, { desc = '[S]earch [H]elp' })
ks('n', '<leader>sw', tl.grep_string, { desc = '[S]earch current [W]ord' })
ks('n', '<leader>sg', tl.live_grep, { desc = '[S]earch by [G]rep' })
ks('n', '<leader>sd', tl.diagnostics, { desc = '[S]earch [D]iagnostics' })

-- Add harpoon to telescope
require("telescope").load_extension('harpoon')

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want
  -- installed for treesitter
  ensure_installed = {
    'bash',
    'c', 'comment', 'cpp',
    'diff', 'dockerfile',
    'gitattributes', 'gitignore', 'go',
    'html', 'http',
    'javascript', 'jq', 'jsdoc', 'json',
    'lua',
    'markdown',
    'org',
    'php', 'phpdoc', 'python',
    'regex', 'rust',
    'scss', 'sql',
    'typescript',
    'vim', 'vue',
    'yaml',
    'help',
  },

  highlight = {
    enable = true,
    -- Required for spellcheck, some LaTex highlights and
    -- code block highlights that do not have ts grammar
    additional_vim_regex_highlighting = { 'org' },
  },

  indent = { enable = true, disable = { 'python' } },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },

  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Load custom treesitter grammar for org filetype
require('orgmode').setup_ts_grammar()
require('orgmode').setup({
  org_agenda_files = {
    vim.fn.expand '~/.local/share/_nvalt/**/*',
    vim.fn.expand '~/.dotfiles/local/org/**/*'
  },
  org_default_notes_file = vim.fn.expand '~/.local/share/_nvalt/refile.org',
})

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language,
  -- and as such it is possible to define small helper and
  -- utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more
  -- easily define mappings specific for LSP related items.
  -- It sets the mode, buffer and description for us each time.
  local nm = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  local t = require('telescope.builtin')
  local vbuf = vim.lsp.buf

  nm('<leader>rn', vbuf.rename, '[R]e[n]ame')
  nm('<leader>ca', vbuf.code_action, '[C]ode [A]ction')

  nm('gd', vbuf.definition, '[G]oto [D]efinition')
  nm('gr', t.lsp_references, '[G]oto [R]eferences')
  nm('gI', vbuf.implementation, '[G]oto [I]mplementation')
  nm('<leader>D', vbuf.type_definition, 'Type [D]efinition')
  nm('<leader>ds', t.lsp_document_symbols, '[D]ocument [S]ymbols')
  nm('<leader>ws', t.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nm('K', vbuf.hover, 'Hover Documentation')
  nm('<C-k>', vbuf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nm('gD', vbuf.declaration, '[G]oto [D]eclaration')
  nm('<leader>wa', vbuf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nm('<leader>wr', vbuf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nm('<leader>wl', function()
    print(vim.inspect(vbuf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

-- Setup mason so it can manage external tooling
require('mason').setup()
require("null-ls").setup()

-- Enable the following language servers.
-- Feel free to add/remove any LSPs that you want here.
-- They will automatically be installed.
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local servers = {
  -- a
  'angularls',
  'ansiblels',
  -- b
  'bashls',
  -- c
  'clangd',
  'cssls',
  -- d
  'dockerls',
  -- e
  'eslint',
  'emmet_ls',
  -- f
  -- g
  'gopls',
  'graphql',
  -- h
  'html',
  -- i
  -- j
  'quick_lint_js', -- js
  'jsonls',
  -- k
  -- l
  'sumneko_lua', -- lua
  -- m
  'marksman', -- markdown
  -- n
  -- o
  -- p
  'intelephense', 'phpactor', 'psalm',
  'pyright',
  -- q
  -- r
  'rust_analyzer',
  -- s
  'sqlls',
  'stylelint_lsp',
  -- t
  'tailwindcss',
  'terraformls',
  'tflint',
  'tsserver',
  -- u
  -- v / w
  'volar', -- vue
  'vuels', -- vue
  -- x / y / z
  'lemminx', -- xml
  'yamlls', -- yaml
}

-- Ensure the servers above are installed
require('mason-lspconfig').setup {
  ensure_installed = servers,
}

require("mason-lspconfig").setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name)
    -- default handler (optional)
    require("lspconfig")[server_name].setup {}
  end,
}

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

for _, lsp in ipairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Turn on lsp status information
require('fidget').setup()

-- Example custom configuration for lua.
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

require('lspconfig').sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're
        -- using (most likely LuaJIT)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized
      -- but unique identifier
      telemetry = { enable = false },
    },
  },
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}



vim.api.nvim_create_autocmd("BufWritePost",
  { pattern = "plugins.lua", command = "source <afile> | PackerSync" })
vim.api.nvim_create_autocmd("BufRead",
  { pattern = "*/node_modules/*", command = "lua vim.diagnostic.disable(0)" })
vim.api.nvim_create_autocmd("BufNewFile",
  { pattern = "*/node_modules/*", command = "lua vim.diagnostic.disable(0)" })
-- Enable spell checking for certain file types
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" },
  { pattern = { "*.txt", "*.md", "*.tex" },
    command = "setlocal spell" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
