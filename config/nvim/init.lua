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

-- ── Python 3 provider ───────────────────────────────────────────────
-- Pin the interpreter instead of letting nvim search the environment on
-- every start. The shim (not an installs/<version>/ path) keeps this valid
-- across python upgrades; pynvim is kept in that interpreter by
-- config/mise/default-python-packages.
vim.g.python3_host_prog = vim.env.HOME .. '/.local/share/mise/shims/python3'

-- nvim 0.12+ niceness (private API — pcall so a future rename doesn't break startup)
-- cmdheight = 0 (options.lua): messages go to ui2's float, which hides after 4 s
pcall(function() require('vim._core.ui2').enable { msg = { targets = 'msg' } } end)

require 'options'
require 'autogroups'
require 'utils' -- registers K + HasConfig/Gated/TOOL_CONFIGS globals

require 'keymaps'
require 'keymap-labels' -- descriptions for plugin and built-in maps that lack one
require 'pack'
require 'pack-ui'

-- ── Plugins ─────────────────────────────────────────────────────────
-- version = vim.version.range is set only on plugins that publish
-- semver-tagged releases (snacks.nvim, blink.cmp, otter.nvim, orgmode and three
-- of its add-ons). The remaining plugins have no tags vim.pack can constrain, so
-- they track their default branch.
vim.pack.add {
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
  -- 1.*: main is unreleased v2, and the prebuilt fuzzy binary is fetched only on a tag
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' },
  'https://github.com/wakatime/vim-wakatime',
  'https://github.com/ivuorinen/nvim-shellspec',
  -- Branch pin, not a range: the semver tags are the frozen `master` API
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/jmbuhr/otter.nvim', version = vim.version.range '*' },
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  { src = 'https://github.com/rebelot/kanagawa.nvim', name = 'kanagawa' },
  { src = 'https://github.com/uhs-robert/oasis.nvim', name = 'oasis' },
  { src = 'https://github.com/felipefdl/warm-burnout', name = 'warm-burnout' },
  'https://github.com/f-person/auto-dark-mode.nvim',
  'https://github.com/catgoose/nvim-colorizer.lua',
  -- orgmode stack, configured in lua/org.lua
  { src = 'https://github.com/nvim-orgmode/orgmode', version = vim.version.range '*' },
  'https://github.com/nvim-orgmode/org-bullets.nvim',
  {
    src = 'https://github.com/hugginsio/org-virtual-clocktime.nvim',
    version = vim.version.range '*',
  },
  {
    src = 'https://github.com/hamidi-dev/org-super-agenda.nvim',
    version = vim.version.range '*',
  },
  {
    src = 'https://github.com/chipsenkbeil/org-roam.nvim',
    version = vim.version.range '*',
  },
}

-- ── Completion ───────────────────────────────────────────────────────
-- https://github.com/saghen/blink.cmp
-- LSP capabilities are registered by blink's plugin/blink-cmp.lua.
require('blink.cmp').setup {
  keymap = {
    preset = 'default', -- <C-y> accepts; <Tab>/<S-Tab> jump snippet fields
    -- <C-Space> is the tmux prefix, so it never reaches Neovim inside tmux.
    ['<C-space>'] = false,
    ['<C-l>'] = { 'show', 'show_documentation', 'hide_documentation' },
  },
  cmdline = {
    keymap = {
      preset = 'cmdline',
      ['<C-space>'] = false,
      ['<C-l>'] = { 'show', 'fallback' },
    },
  },
  completion = { documentation = { auto_show = true } },
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
-- n_lines=750: look further for text-objects in long functions (default 50)
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
    { mode = 'n', keys = '<Leader>cc', desc = '+Calls' },
    { mode = 'n', keys = '<Leader>o', desc = '+Orgmode' },
    { mode = 'n', keys = '<Leader>oR', desc = '+OrgRoam' },
    { mode = 'n', keys = '<Leader>oRd', desc = '+Dailies' },
    { mode = 'n', keys = '<Leader>p', desc = '+Pack' },
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
---@module 'mini.sessions'
local sessions = require 'mini.sessions'
sessions.setup {
  autowrite = false, -- VimLeavePre in autogroups.lua writes manually; avoid double-write
  -- falls back to stdpath('data')/sessions when vim.g.sessions_dir is not set
  directory = vim.g.sessions_dir or vim.fn.stdpath 'data' .. '/sessions',
  file = '', -- '' disables per-directory Session.vim; only directory-based sessions used
}

-- ── Appearance ───────────────────────────────────────────────────────

-- Animate common Neovim actions
require('mini.animate').setup()

-- Highlight cursor word and its matches
require('mini.cursorword').setup()

-- Highlight patterns in text
---@module 'mini.hipatterns'
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
---@module 'mini.indentscope'
local iscope = require 'mini.indentscope'
iscope.setup {
  draw = { animation = iscope.gen_animation.none() },
}

-- Minimal and fast statusline module with opinionated default look
---@module 'mini.statusline'
local sl = require 'mini.statusline'
sl.setup {
  -- set_vim_settings=false: prevent mini.statusline from overriding laststatus=3
  -- (its default true hard-codes laststatus=2 and ruler=false, undoing options.lua)
  set_vim_settings = false,
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
      local search = sl.section_searchcount { trunc_width = 75 }
      -- cmdheight = 0 hides ui2's "recording @q", so the statusline carries it
      local reg = vim.fn.reg_recording()
      local recording = reg ~= '' and ('recording @' .. reg) or ''
      return sl.combine_groups {
        { hl = mode_hl, strings = { mode, recording } },
        {
          hl = 'MiniStatuslineDevinfo',
          strings = { git, lsp },
        },
        '%<', -- Mark general truncate point
        { hl = 'statuslineFilename', strings = { filename } },
        '%=', -- End left alignment
        '%S', -- Pending keys ('showcmdloc' in options.lua)
        { hl = 'statuslineFileinfo', strings = { diagnostics } },
        { hl = 'statuslineFileinfo', strings = { fileinfo } },
        {
          hl = 'MiniStatuslineDevinfo',
          strings = { fmt, lsp_status },
        },
        { hl = mode_hl, strings = { search, location } },
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

-- Mason manages LSP server binary downloads and installations
require('mason').setup {}

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
    'bash-language-server',
    'eslint-lsp',
    'gopls',
    'html-lsp',
    'json-lsp',
    'lua-language-server',
    'pyright',
    'tailwindcss-language-server',
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
vim.lsp.enable { 'fish_lsp', 'taplo', 'zizmor' }

-- otter.nvim (activated in lua/autogroups.lua) copies each embedded chunk to
-- column 0 of its hidden buffer but forwards LSP positions unchanged, so a chunk
-- that starts mid-line (every inline `run = "…"` in a mise.toml) gets hover,
-- completion and diagnostics at the wrong column. Pad the first line back out.
-- ponytail: wraps an otter internal; drop it once otter keeps the start column.
local otter_keeper = require 'otter.keeper'
local extract_code_chunks = otter_keeper.extract_code_chunks
otter_keeper.extract_code_chunks = function(...)
  local chunks = extract_code_chunks(...)
  for _, lang_chunks in pairs(chunks) do
    for _, chunk in ipairs(lang_chunks) do
      local col = chunk.range.from[2]
      if col > 0 and chunk.text[1] then
        chunk.text[1] = (' '):rep(col) .. chunk.text[1]
      end
    end
  end
  return chunks
end

-- ── Navigation ───────────────────────────────────────────────────────
-- Fuzzy finding is handled by snacks.nvim (below).

-- https://github.com/folke/trouble.nvim
require('trouble').setup {
  auto_close = true, -- close the list when no items remain
  preview = { type = 'main', scratch = true },
  keys = {
    j = 'next', -- jump to next item (skips non-item lines unlike raw j)
    k = 'prev',
  },
  modes = {
    diagnostics = {
      auto_open = false, -- don't open on :w; open explicitly with <leader>xx
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

---@module 'conform'
local conform = require 'conform'

vim.g.autoformat_enabled = true -- initial state; toggled by <leader>tf

-- Exposed to mini.statusline content function for the fmt indicator
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
    -- 'fallback': use LSP formatting if no conform formatter handles the filetype
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
}

-- Delegate gq/gw range formatting to conform (falls back to LSP)
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- ── Linting ──────────────────────────────────────────────────────────

---@module 'lint'
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

-- Toggle comments (gc operator, gcc for line)
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-comment.md
require('mini.comment').setup()

-- ── Treesitter ────────────────────────────────────────────────────────
-- Parser + query manager. The FileType autocmd in lua/autogroups.lua installs
-- a missing parser on first open and starts highlight + indent per buffer.
-- https://github.com/nvim-treesitter/nvim-treesitter
--
-- Only what that autocmd cannot reach is listed: parsers Neovim bundles (they
-- load, so it never installs them, yet Neovim ships no indents.scm and
-- nvim-treesitter links its queries only for languages it installs), and
-- languages seen only as injections. install() is a no-op once installed.
-- bash, kdl and toml back the mise injections in after/queries/.
require('nvim-treesitter').install {
  'bash',
  'kdl',
  'lua',
  'luadoc',
  'markdown',
  'query',
  'regex',
  'toml',
  'vim',
  'vimdoc',
}

-- ── UI ───────────────────────────────────────────────────────────────
-- Loads after editor setup above (mini.icons must be set up first so
-- catppuccin can resolve auto_integrations).

-- ── Colorscheme ──────────────────────────────────────────────────────
-- The theme family resolves as in config/theme/_lib.sh: DOTFILES_THEME_FAMILY,
-- then the saved choice in $XDG_STATE_HOME/dotfiles-theme/choice (skipped
-- unless it names a palettes.d family), then config/theme/family; oasis when
-- nothing does. Every family follows 'background', which auto-dark-mode below
-- flips with the OS.
local function theme_family()
  -- An empty variable counts as unset, as ${VAR:-default} does in _lib.sh.
  local dotfiles = vim.env.DOTFILES ~= '' and vim.env.DOTFILES
    or (vim.env.HOME .. '/.dotfiles')
  -- The name feeds a filesystem path, so only a plain slug naming a family.
  local function valid(name)
    return name:match '^[a-z0-9][a-z0-9%-]*$' ~= nil
      and vim.fn.isdirectory(dotfiles .. '/config/theme/palettes.d/' .. name) == 1
  end
  local env = vim.env.DOTFILES_THEME_FAMILY
  if env and env ~= '' then return valid(env) and env or 'oasis' end
  local state = vim.env.XDG_STATE_HOME ~= '' and vim.env.XDG_STATE_HOME
    or (vim.env.HOME .. '/.local/state')
  for _, file in ipairs {
    state .. '/dotfiles-theme/choice',
    dotfiles .. '/config/theme/family',
  } do
    local ok, lines = pcall(vim.fn.readfile, file, '', 1)
    local name = ok and lines[1] and vim.trim(lines[1]) or ''
    if valid(name) then return name end
  end
  return 'oasis'
end

-- ── Kanagawa ─────────────────────────────────────────────────────────
-- https://github.com/rebelot/kanagawa.nvim
-- Wave for dark, Lotus for light. Upstream Lotus accents fall to 2.0–4.3:1
-- on lotusWhite3 #f2ecbc; same hue and saturation, lightness lowered to
-- reach WCAG AA 4.5:1 (lotusGray3 to 3:1 as the muted comment colour);
-- mapping in config/theme/palettes.d/kanagawa/light/starship.toml.
require('kanagawa').setup {
  dimInactive = true,
  background = { dark = 'wave', light = 'lotus' },
  colors = {
    palette = {
      lotusGray3 = '#88877e',
      lotusGreen = '#5b7040',
      lotusGreen2 = '#56714a',
      lotusPink = '#a54c6b',
      lotusOrange = '#a15600',
      lotusOrange2 = '#9a5b00',
      lotusYellow = '#716b3c',
      lotusYellow2 = '#7a6745',
      lotusYellow3 = '#8d6100',
      lotusRed = '#c0374a',
      lotusRed2 = '#c92c30',
      lotusRed3 = '#d21616',
      lotusAqua = '#51706b',
      lotusAqua2 = '#4f7067',
      lotusTeal1 = '#3e7082',
      lotusTeal2 = '#406d99',
      lotusTeal3 = '#536e7b',
      -- Wave foregrounds below WCAG AA on sumiInk3 #1f1f28, lifted with hue
      -- and saturation kept: autumnRed (terminal red, diff delete) 3.22:1,
      -- samuraiRed (errors, diagnostics) 3.66:1, dragonBlue 4.15:1.
      autumnRed = '#cf6769',
      samuraiRed = '#ed4f4f',
      dragonBlue = '#6b8b9a',
    },
    -- The gutter (LineNr, SignColumn, FoldColumn, diagnostic signs) uses
    -- the editor background instead of Kanagawa's lighter bg_gutter.
    theme = { all = { ui = { bg_gutter = 'none' } } },
  },
}

-- ── Oasis ────────────────────────────────────────────────────────────
-- https://github.com/uhs-robert/oasis.nvim
-- Abyss for both modes; the light variant uses intensity 3 to match the
-- palettes in config/theme/palettes.d/oasis/. Two Abyss Light 3 colours
-- miss WCAG AA on #d8d8d8 (accent #31732b 4.07:1, comment #625f54
-- 4.49:1); they are darkened in lightness only, as in every other Oasis
-- light palette here.
require('oasis').setup {
  style = 'abyss',
  light_intensity = 3,
  palette_overrides = {
    abyss = {
      light_3 = {
        theme = { accent = '#2e6b28' },
        syntax = { comment = '#615e54' },
      },
    },
  },
}

-- ── Warm Burnout ─────────────────────────────────────────────────────
-- https://github.com/felipefdl/warm-burnout
-- The plugin lives in the repo's nvim/ subdirectory, which upstream asks to
-- be added to the runtimepath. colors/warm-burnout.lua (in this config) picks
-- the variant from 'background' and carries the WCAG AA fixes. vim.pack.get
-- raises when the plugin is not installed (a declined install); the family
-- then falls back to oasis in apply_family_scheme below.
local wb_ok, wb_plugins = pcall(vim.pack.get, { 'warm-burnout' }, { info = false })
for _, plugin in ipairs(wb_ok and wb_plugins or {}) do
  vim.opt.rtp:append(plugin.path .. '/nvim')
end

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
  -- Upstream Latte accents fall to 2.3–3.5:1 on base (sky is 2.47:1).
  -- Same hue and saturation, lightness lowered to reach WCAG AA 4.5:1;
  -- mapping in config/theme/palettes.d/catppuccin/light/starship.toml.
  color_overrides = {
    latte = {
      rosewater = '#bb4930',
      flamingo = '#cb3333',
      pink = '#c71f9a',
      maroon = '#d61d2d',
      peach = '#be4601',
      yellow = '#996114',
      green = '#327c21',
      teal = '#13797e',
      sky = '#0374a1',
      sapphire = '#187787',
      blue = '#1761f5',
      lavender = '#3d5afc',
    },
  },
}

-- :terminal colours the plugins leave on the background, set to the values
-- the wezterm, vim and COSMIC palettes use: dark ANSI black at 3:1 (it was
-- 1.10:1 in Kanagawa, 1.00:1 in Oasis), and Latte's black pair, which
-- catppuccin.nvim takes from overlay0/overlay1 (2.30:1 / 2.83:1). Black on
-- white (`30;47`) keeps 3:1, so Wave's white is lifted to match its raised
-- black, and Latte's black is Mocha's base over the shared AA whites
-- (catppuccin.nvim's text-coloured whites sit at 1.28:1 over subtext1). Warm
-- Burnout's own fixes live in colors/warm-burnout.lua.
local term_fixes = {
  kanagawa = { dark = { [0] = '#6a6780', [7] = '#cac295' } },
  oasis = { dark = { [0] = '#5a5a5a' } },
  catppuccin = {
    light = { [0] = '#1e1e2e', [7] = '#6a6e7a', [8] = '#6c6f85', [15] = '#6a6e79' },
  },
}
-- Keyed by the name before the first '-': oasis and catppuccin set
-- g:colors_name to a variant ('oasis-abyss', 'catppuccin-latte'), and a
-- 'background' change reloads the scheme under that name.
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function(ev)
    local fixes = term_fixes[ev.match:match '^[^-]+'] or {}
    for i, hex in pairs(fixes[vim.o.background] or {}) do
      vim.g['terminal_color_' .. i] = hex
    end
  end,
})

-- Applied at startup and re-checked every 3 s, so a family switch
-- (local/bin/theme) reaches running sessions the way vim's timer does. It acts
-- only when the family's scheme changes, so a manual :colorscheme stays until
-- the next switch; 'background' stays with auto-dark-mode below.
local family_schemes = {
  kanagawa = 'kanagawa',
  oasis = 'oasis',
  catppuccin = 'catppuccin',
  ['warm-burnout'] = 'warm-burnout',
}
local applied_scheme
local function apply_family_scheme()
  local scheme = family_schemes[theme_family()] or 'oasis'
  if scheme == applied_scheme then return end
  applied_scheme = scheme
  -- A family whose plugin is not installed yet still gets a theme.
  if not pcall(vim.cmd.colorscheme, scheme) then vim.cmd.colorscheme 'oasis' end
end
apply_family_scheme()
vim.uv.new_timer():start(3000, 3000, vim.schedule_wrap(apply_family_scheme))

-- ── Auto dark mode ───────────────────────────────────────────────────
-- https://github.com/f-person/auto-dark-mode.nvim
require('auto-dark-mode').setup {
  update_interval = 1000, -- poll every 1s (default 3000)
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
    names = false, -- don't highlight CSS color names ('red', 'blue', etc.)
  },
}

-- nvim-orgmode
require 'org'

-- vim: set ts=2 sts=2 sw=2 wrap et :
