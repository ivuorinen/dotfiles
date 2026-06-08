# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code)
when working with code in this repository.

## Overview

Neovim configuration using **vim.pack** (Neovim 0.12+ built-in) for plugin
management, **catppuccin** as the default colorscheme, and **mini.nvim** as
the foundation for many core features.

## Load Order

All configuration runs in `init.lua` at step 7b of `:h initialization`:

1. `lua/options.lua` — vim options, leader key (Space), nerd font flag
2. `lua/autogroups.lua` — autocmds (yank highlight, close-with-q, filetype tweaks,
    PackChanged, sessions, linting trigger)
3. `lua/utils.lua` — registers K, HasConfig, Gated, TOOL_CONFIGS globals
4. `lua/keymaps.lua` — all non-plugin keybindings
5. `lua/pack.lua` — PackUpdate / PackRemove / PackList user commands (vim.pack built-in,
    no plugin dependency)
6. `vim.pack.add {}` — loads all plugins onto the rtp
7. Plugin configuration — inline sections in `init.lua` in this order:
    Completion → Editor → LSP → Navigation → QA → Snacks → Tools → Treesitter → UI

## init.lua Sections

| Section         | Content                                                         |
|-----------------|-----------------------------------------------------------------|
| `-- Completion` | blink.cmp (lsp / path / snippets / buffer / omni)               |
| `-- Editor`     | mini.nvim suite + vim-sleuth                                    |
| `-- LSP`        | mason stack + `vim.lsp.config` / `vim.lsp.enable`               |
| `-- Navigation` | trouble.nvim                                                    |
| `-- QA`         | conform.nvim (format-on-save) + nvim-lint                       |
| `-- Snacks`     | snacks.nvim: picker, notifier, terminal, input, rename, bigfile |
| `-- Tools`      | wakatime, shellspec, comment-box                                |
| `-- Treesitter` | nvim-treesitter                                                 |
| `-- UI`         | catppuccin, auto-dark-mode, colorizer, render-markdown          |

Special-buffer pinning (formerly `stickybuf.nvim`) lives in
`lua/autogroups.lua` as a `winfixbuf` autocmd. The file explorer is
`mini.files` (opened via `<leader>te` and `-`).

## Keymap Helpers (`lua/utils.lua`)

All keymaps use the global `K` table (intentionally global, not local):

```lua
K.n(key, cmd, opts)          -- Normal mode
K.nl(key, cmd, opts)         -- Normal mode with <leader> prepended
K.d(key, mode, cmd, opts)    -- Explicit mode(s): 'n', 'v', 'x', or {'n','v'}
K.ld(key, mode, cmd, opts)   -- Leader + explicit mode(s)
```

`opts` can be a string (converted to `{desc = str}`) or a table.
The description requirement is enforced by
`.claude/rules/keymap-descriptions.md` (path-scoped to lua files).

## Project Config Detection (`lua/utils.lua`)

Three globals gate tools on the presence of a project config file:

- `TOOL_CONFIGS[tool]` — marker files per logical tool name
  (e.g. `prettier`, `stylua`, `ruff`, `golangci_lint`). Extend this
  table to gate a new tool.
- `HasConfig(tool, bufnr?)` — walks upward from the buffer's file via
  `vim.fs.root`, returns true if any `TOOL_CONFIGS[tool]` marker
  is found. Returns false for unknown tool names (fail-closed).
- `Gated(tool)` — returns a conform formatter spec
  (`{ condition = ... }`) suitable for `conform.setup`'s `formatters`
  table. Shallow-merged by conform, so built-in cmd/args are preserved.

Usage in `init.lua` (QA section):

```lua
-- Formatter gating (conform)
formatters = {
  prettier = Gated 'prettier',
  stylua = Gated 'stylua',
  -- ...
}

-- Linter gating (nvim-lint has no native condition; filter inside
-- the autocmd using HasConfig)
local LINTER_GATES = { ruff = 'ruff', hadolint = 'hadolint', ... }
-- ...then in the try_lint callback, skip any name whose gate fails.
```

Always-on tools (standard / opinion-free) are intentionally omitted
from TOOL_CONFIGS: `shfmt`, `fish_indent`, `gofmt`, `goimports`,
`terraform_fmt` (formatters); `shellcheck`, `fish` (linters).

## Leader Key Groups (mini.clue)

| Prefix       | Group                  |
|--------------|------------------------|
| `<leader>b`  | Buffers                |
| `<leader>c`  | Code                   |
| `<leader>cb` | CommentBox             |
| `<leader>cc` | Calls                  |
| `<leader>q`  | Quit                   |
| `<leader>s`  | Search (snacks.picker) |
| `<leader>t`  | Toggle                 |
| `<leader>tm` | Toggle Options         |
| `<leader>x`  | Trouble                |
| `<leader>?`  | Help                   |

Source of truth: the `clues` table in the `-- Editor` section of `init.lua`.

## LSP Architecture

**Stack:** `nvim-lspconfig` (default server definitions) +
mason (installs binaries via `mason-tool-installer`) +
`mason-lspconfig` (auto-enables all mason-installed servers via `vim.lsp.enable`) +
native `lsp/*.lua` files (customizations only) +
`vim.lsp.config('*', ...)` in the `-- LSP` section of `init.lua`, with capabilities from blink.cmp.

**How it works:** The `-- LSP` section of `init.lua` calls `require('lspconfig')` to populate
`vim.lsp.config` with nvim-lspconfig's defaults for all servers. Any
`lsp/<name>.lua` file that exists is deep-merged on top. Only servers with
genuine customizations have a `lsp/` file; the rest run on defaults.
`mason-lspconfig` with `automatic_enable = true` calls `vim.lsp.enable()` for
every server mason has installed; `fish_lsp` and `taplo` (from mise) are enabled
explicitly via a bare `vim.lsp.enable {}` call.

**Server config pattern:** `lsp/<name>.lua` files return only the fields
that differ from nvim-lspconfig's defaults — typically `settings`,
`init_options`, `cmd_env`, or narrowed `filetypes`/`root_markers`.
7 files remain: `eslint`, `fish_lsp`, `gopls`, `intelephense`, `lua_ls`,
`tailwindcss`, `yamlls`.

**Lua API completions:** `lsp/lua_ls.lua` sets `workspace.library = { vim.env.VIMRUNTIME }`
directly. Known globals are declared in `.luarc.json` (`diagnostics.globals`). `lazydev.nvim`
is not installed.

**Default keymaps** (nvim 0.11): `grn` (rename), `gra` (code action),
`grr` (references), `gri` (implementations) work out of the box.
`<leader>c*` keymaps in `lua/keymaps.lua` provide snacks.picker-powered
variants. `lua/autogroups.lua` wraps `grt` and `gri` with a
capability check so unsupported servers get a friendly notification
instead of the default "… is not supported" error.

**Servers from mise (not mason):** `fish_lsp`, `taplo`. These are excluded
from `mason-tool-installer` and enabled explicitly via `vim.lsp.enable`.
All other active servers are derived from `ensure_installed` (mason-tool-installer
installs them; mason-lspconfig auto-enables them). The rule in `.claude/rules/lsp-list-parity.md` checks that the mise-managed
exceptions (`fish_lsp`, `taplo`) are present in `vim.lsp.enable` and absent
from `ensure_installed`.

## Formatting

- **conform.nvim** formats on save (disable with `<leader>tf`)
- Formatters by filetype: bash/sh→shfmt, lua→stylua, go→golangci-lint,
  ansible→ansible-lint, docker→hadolint
- LSP formatting is used as fallback for filetypes without a
  dedicated formatter
- **stylua** is the Lua formatter — 90-char line length (`stylua.toml`
  at repo root)

## PATH Setup

`init.lua` prepends `~/.local/share/mise/shims` and `~/.local/bin`
to PATH so that LSP servers and formatters installed via mise are
found by neovim without a login shell.

## Gotchas

- **`K` is global**: `utils.lua` sets `K = {}` at module scope
  (not local) so keymaps.lua and plugins can use it after
  `require 'utils'`.
- **Intelephense license**: `GetIntelephenseLicense()` in
  `utils.lua` reads `~/intelephense/license.txt`. Falls back to
  `$INTELEPHENSE_LICENSE` env var.
- **Format toggle state**: `vim.g.autoformat_enabled` tracks
  the toggle; `_G.autoformat_status()` exposes it for statusline.

## context-mode

Mandatory MCP routing rules live in `.claude/rules/context-mode.md`.
That file is the single source of truth — do not duplicate its content
back into this file.
