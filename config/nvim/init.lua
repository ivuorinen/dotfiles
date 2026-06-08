-- ╭─────────────────────────────────────────────────────────╮
-- │            ivuorinen's Neovim configuration             │
-- ╰─────────────────────────────────────────────────────────╯

-- Cache compiled Lua modules for faster startup on subsequent launches.
vim.loader.enable()

-- ── Add mise shims and ~/.local/bin to the PATH ─────────────────────
-- Guarded so `:source $MYVIMRC` doesn't duplicate entries each time.
local function _path_prepend(p)
  local path = vim.env.PATH or ''
  if not (':' .. path .. ':'):find(':' .. p .. ':', 1, true) then
    vim.env.PATH = p .. (path ~= '' and ':' .. path or '')
  end
end
_path_prepend(vim.env.HOME .. '/.local/bin')
_path_prepend(vim.env.HOME .. '/.local/share/mise/shims')

-- nvim 0.12+ niceness (private API — pcall so a future rename doesn't break startup)
pcall(function() require('vim._core.ui2').enable {} end)

require 'options'
require 'autogroups'
require 'utils' -- registers K + HasConfig/Gated/TOOL_CONFIGS globals

require 'keymaps'
require 'pack'

-- ── Plugins ─────────────────────────────────────────────────────────
-- version = vim.version.range '*' is set only on plugins that publish
-- semver-tagged releases (blink.cmp, snacks.nvim). The remaining plugins
-- have no tags vim.pack can constrain, so they track their default branch.
vim.pack.add {
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '*' },
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/tpope/vim-sleuth',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/folke/trouble.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/zapling/mason-conform.nvim',
  { src = 'https://github.com/folke/snacks.nvim', version = vim.version.range '*' },
  'https://github.com/wakatime/vim-wakatime',
  'https://github.com/ivuorinen/nvim-shellspec',
  'https://github.com/LudoPinelli/comment-box.nvim',
  'https://github.com/arborist-ts/arborist.nvim',
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  'https://github.com/f-person/auto-dark-mode.nvim',
  'https://github.com/catgoose/nvim-colorizer.lua',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}

-- ── Completion ───────────────────────────────────────────────────────
-- Performant, batteries-included completion plugin for Neovim
-- https://github.com/saghen/blink.cmp

---@module 'blink.cmp'
require('blink.cmp').setup {
  keymap = {
    ['<C-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
  },

  completion = {
    menu = {
      draw = {
        columns = {
          { 'label', 'label_description', gap = 1 },
          { 'kind_icon', 'kind', gap = 1 },
        },
      },
    },
  },

  sources = {
    default = {
      'lsp',
      'path',
      'snippets',
      'buffer',
      -- Wraps &omnifunc via blink.cmp.sources.complete_func. Built-in
      -- `enabled` guard skips when omnifunc is the LSP handler, so no
      -- duplication with the `lsp` source. Catches filetypes without
      -- an LSP (gitcommit, help, plugin-provided completefuncs).
      'omni',
    },
  },

  -- Inline signature help while typing; disabled by default in blink.cmp.
  signature = { enabled = true },
}

-- ── Editor ───────────────────────────────────────────────────────────
-- mini.nvim suite + vim-sleuth

-- ── Text editing ─────────────────────────────────────────────────────

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

-- ── General workflow ─────────────────────────────────────────────────

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
---@module 'mini.clue'
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
    { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
    { mode = 'n', keys = '<Leader>c', desc = '+Code' },
    { mode = 'n', keys = '<Leader>cb', desc = '+CommentBox' },
    { mode = 'n', keys = '<Leader>cc', desc = '+Calls' },
    { mode = 'n', keys = '<Leader>q', desc = '+Quit' },
    { mode = 'n', keys = '<Leader>s', desc = '+Search' },
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
  autowrite = false,
  directory = vim.g.sessions_dir or vim.fn.stdpath 'data' .. '/sessions',
  file = '',
}

-- ── Appearance ───────────────────────────────────────────────────────

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

-- Icons (also mocks nvim-web-devicons for plugins that require it)
require('mini.icons').setup {
  file = {
    ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
    ['devcontainer.json'] = { hl = 'MiniIconsAzure' },
  },
  filetype = {
    dotenv = { hl = 'MiniIconsYellow' },
  },
}
-- Provide nvim-web-devicons compatibility for plugins that require it
-- (e.g. trouble.nvim). This avoids installing the actual nvim-web-devicons.
require('mini.icons').mock_nvim_web_devicons()

-- Visualize and work with indent scope
local iscope = require 'mini.indentscope'
iscope.setup {
  draw = { animation = iscope.gen_animation.none() },
}

-- Minimal and fast statusline module with opinionated default look
---@module 'mini.statusline'
local sl = require 'mini.statusline'
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
      local fmt = (vim.g.autoformat_enabled ~= false) and '󰉼' or '󰉾'
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
        {
          hl = 'MiniStatuslineDevinfo',
          strings = { fmt, lsp_status },
        },
        { hl = mode_hl, strings = { location } },
      }
    end,
  },
}

-- Work with trailing whitespace
require('mini.trailspace').setup()

-- ── mini.keymap ───────────────────────────────────────────────────────

local map_combo = require('mini.keymap').map_combo

-- Escape to Normal mode by pressing jk or kj in sequence.
-- Covers insert, command, visual, and select modes.
local esc_modes = { 'i', 'c', 'x', 's' }
map_combo(esc_modes, 'jk', '<BS><BS><Esc>')
map_combo(esc_modes, 'kj', '<BS><BS><Esc>')
-- Terminal mode needs a different escape sequence.
map_combo('t', 'jk', '<BS><BS><C-\\><C-n>')
map_combo('t', 'kj', '<BS><BS><C-\\><C-n>')

-- ── LSP ──────────────────────────────────────────────────────────────
-- Server definitions live in lsp/*.lua files.

-- Populate vim.lsp.config with nvim-lspconfig's default server definitions.
-- The local lsp/*.lua files merge on top, so only customizations live there.
require 'lspconfig'

require('mason').setup {}

-- blink.cmp is loaded by vim.pack.add earlier in this file.
-- Set capabilities before mason-lspconfig enables servers so the config store
-- is fully populated regardless of enable timing.
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Automatically calls vim.lsp.enable() for every server mason has installed.
-- Servers from mise (fish_lsp, taplo) are not visible to mason so they are
-- enabled explicitly below.
require('mason-lspconfig').setup {
  automatic_enable = true,
}

require('mason-tool-installer').setup {
  auto_install = true,
  auto_update = true,
  -- fish_lsp and taplo are managed by mise, not mason, so they are absent here
  -- and enabled explicitly via vim.lsp.enable below.
  ensure_installed = {
    -- LSP servers (mason package names)
    'ansible-language-server',
    'bash-language-server',
    'css-lsp',
    'dockerfile-language-server',
    'eslint-lsp',
    'gopls',
    'html-lsp',
    'intelephense',
    'json-lsp',
    'lua-language-server',
    'pyright',
    'tailwindcss-language-server',
    'terraform-ls',
    'typescript-language-server',
    'vim-language-server',
    'yaml-language-server',
    -- Tools
    'actionlint',
    'ansible-lint',
    'goimports',
    'golangci-lint',
    'hadolint',
    'prettier',
    'shfmt',
    'stylua',
    'shellcheck',
  },
}

-- mason-lspconfig (above) auto-enables all mason-installed servers.
-- Enable mise-managed servers that mason cannot see.
vim.lsp.enable { 'fish_lsp', 'taplo' }

-- ── Navigation ───────────────────────────────────────────────────────
-- Fuzzy finding is handled by snacks.nvim (below).

-- https://github.com/folke/trouble.nvim
require('trouble').setup {
  auto_close = true,
  preview = { type = 'main', scratch = true },
  keys = {
    j = 'next',
    k = 'prev',
  },
  modes = {
    diagnostics = {
      auto_open = false,
    },
    test = {
      mode = 'diagnostics',
      preview = {
        type = 'split',
        relative = 'win',
        position = 'right',
        size = 0.25,
      },
    },
    cascade = {
      mode = 'diagnostics',
      filter = function(items)
        local severity = vim.diagnostic.severity.HINT
        for _, item in ipairs(items) do
          severity = math.min(severity, item.severity)
        end
        return vim.tbl_filter(function(item) return item.severity == severity end, items)
      end,
    },
  },
}

-- ── QA ───────────────────────────────────────────────────────────────
-- Formatting (conform) and Linting
-- Project-gated tools use HasConfig()/Gated() from utils.lua.
-- Tools not gated here run unconditionally (opinion-free defaults).

-- ── Formatting ───────────────────────────────────────────────────────

local conform = require 'conform'

vim.g.autoformat_enabled = true

function _G.autoformat_status() return vim.g.autoformat_enabled and 'fmt' or '' end

conform.setup {
  formatters_by_ft = {
    ['yaml.ansible'] = { 'ansible-lint' },
    bash = { 'shfmt' },
    fish = { 'fish_indent' },
    go = { 'goimports', 'gofmt' },
    lua = { 'stylua' },
    python = { 'ruff_format' },
    sh = { 'shfmt' },
    terraform = { 'terraform_fmt' },
    toml = { 'taplo' },
    yaml = { 'prettier' },
  },
  -- Always-on formatters (standard/opinion-free): shfmt,
  -- fish_indent, gofmt, goimports, terraform_fmt.
  formatters = {
    ['ansible-lint'] = Gated 'ansible_lint',
    prettier = Gated 'prettier',
    ruff_format = Gated 'ruff',
    stylua = Gated 'stylua',
    taplo = Gated 'taplo',
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
  format_on_save = function(bufnr)
    if not vim.g.autoformat_enabled then return end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match '/node_modules/' then return end
    if bufname:match '/vendor/' then return end
    if bufname:match '/dist/' then return end

    return { timeout_ms = 500 }
  end,
  notify_on_error = true,
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- ── Linting ──────────────────────────────────────────────────────────

local lint = require 'lint'

lint.linters_by_ft = {
  bash = { 'shellcheck' },
  dockerfile = { 'hadolint' },
  fish = { 'fish' },
  go = { 'golangci_lint' },
  python = { 'ruff' },
  sh = { 'shellcheck' },
  terraform = { 'tflint' },
  yaml = { 'yamllint' },
  ['yaml.ansible'] = { 'ansible_lint' },
}

-- Loaded after conform.setup() since mason-conform requires conform.
require('mason-conform').setup {}

-- ── Snacks ───────────────────────────────────────────────────────────
-- https://github.com/folke/snacks.nvim

---@module 'snacks'
require('snacks').setup {
  -- Automatically disables treesitter/LSP for files above the size limit
  bigfile = { enabled = true },

  -- Inline image rendering (requires terminal with graphics protocol support:
  -- Kitty, WezTerm, iTerm2, or similar). force=false (default) means it degrades
  -- silently when the terminal does not support graphics.
  -- PDF/SVG/math preview additionally requires imagemagick in $PATH.
  image = { enabled = true },

  -- Replaces vim.ui.input with a styled floating prompt
  input = { enabled = true },

  -- Notification UI: replaces nvim-notify and noice's notification routing
  notifier = { enabled = true },

  -- Fuzzy picker: replaces telescope
  picker = {
    enabled = true,
    sources = {
      -- Mirror the rg flags from the old telescope vimgrep_arguments:
      -- search hidden files, respect .gitignore, skip the heavy dirs.
      files = {
        hidden = true,
        exclude = { '.git', 'node_modules', 'vendor', '.DS_Store' },
      },
      grep = {
        hidden = true,
        exclude = { '.git', 'node_modules', 'vendor', '.DS_Store' },
      },
    },
    win = {
      input = {
        keys = {
          -- Send all current picker results to trouble
          ['<C-t>'] = { 'trouble_open', mode = { 'n', 'i' } },
        },
      },
    },
  },

  -- LSP-aware file rename (updates all import references via the LSP)
  rename = { enabled = true },

  -- Floating terminal
  terminal = { enabled = true },
}

-- ── Tools ─────────────────────────────────────────────────────────────
-- Vim plugin for automatic time tracking and metrics
-- https://github.com/wakatime/vim-wakatime
-- Auto-initialises via plugin/wakatime.vim — no setup call needed.

-- ShellSpec filetype support
-- https://github.com/ivuorinen/nvim-shellspec
require('shellspec').setup {
  auto_format = true,
  indent_size = 2,
  indent_comments = true,
}

-- Clarify and beautify your comments using boxes and lines.
-- https://github.com/LudoPinelli/comment-box.nvim
require('comment-box').setup {}

-- ── Treesitter ────────────────────────────────────────────────────────
-- Parser manager for Neovim 0.12+ (highlight, indent, folds via built-in API)
-- https://github.com/arborist-ts/arborist.nvim

require('arborist').setup {
  -- install_popular covers lua, markdown, markdown_inline, html, yaml and more.
  install_popular = true,

  -- Parsers not in the popular set but needed for injection queries.
  ensure_installed = {
    'luadoc',
    'regex',
  },
}

-- ── UI ───────────────────────────────────────────────────────────────
-- Loads after editor setup above (mini.icons must be set up first so
-- catppuccin can resolve auto_integrations).

-- ── Catppuccin ───────────────────────────────────────────────────────
-- https://github.com/catppuccin/nvim
require('catppuccin').setup {
  term_colors = true,
  dim_inactive = { enabled = true },
  -- auto_integrations = false is the default; enable it to pick up mini.nvim.
  auto_integrations = true,
  integrations = {
    -- indentscope_color defaults to 'overlay2'; clear it to suppress the tint.
    mini = { indentscope_color = '' },
  },
}

vim.cmd.colorscheme 'catppuccin'

-- ── Auto dark mode ───────────────────────────────────────────────────
-- https://github.com/f-person/auto-dark-mode.nvim
require('auto-dark-mode').setup {
  update_interval = 1000,
  -- stylua: ignore
  set_dark_mode = function()
    vim.api.nvim_set_option_value('background', 'dark', {})
  end,
  -- stylua: ignore
  set_light_mode = function()
    vim.api.nvim_set_option_value('background', 'light', {})
  end,
}

-- ── Colorizer ────────────────────────────────────────────────────────
-- The fastest Neovim colorizer
-- https://github.com/catgoose/nvim-colorizer.lua
require('colorizer').setup {
  user_default_options = {
    names = false,
  },
}

-- ── Render Markdown ──────────────────────────────────────────────────
-- Render markdown inline (tables, headings, code blocks)
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
require('render-markdown').setup {
  -- html and yaml parsers are in treesitter ensure_installed; latex is not.
  latex = { enabled = false },
}

-- vim: set ts=2 sts=2 sw=2 wrap et :
