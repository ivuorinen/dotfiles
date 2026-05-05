# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code)
when working with code in this repository.

## Overview

Neovim configuration using **lazy.nvim** for plugin management,
**catppuccin** as the default colorscheme, and **mini.nvim** as
the foundation for many core features.

## Load Order

`init.lua` bootstraps lazy.nvim, then loads modules in this order:

1. `lua/options.lua` — vim options, leader key (Space), nerd font flag
2. `lua/autogroups.lua` — autocmds (yank highlight, close-with-q, filetype tweaks)
3. `lazy.setup('plugins')` — auto-discovers all `lua/plugins/*.lua` specs
4. `lua/keymaps.lua` — all non-plugin keybindings

## Plugin Files (one per concern)

| File             | Purpose                                                                      |
|------------------|------------------------------------------------------------------------------|
| `completion.lua` | blink.cmp completion engine (lsp / path / snippets / buffer / omni)          |
| `editor.lua`     | mini.nvim modules + vim-sleuth + hardtime                                    |
| `lsp.lua`        | mason + mason-tool-installer + mason-conform (servers enabled in `init.lua`) |
| `navigation.lua` | telescope, trouble                                                           |
| `qa.lua`         | conform.nvim (format-on-save) + nvim-lint                                    |
| `tools.lua`      | wakatime, shellspec, comment-box                                             |
| `treesitter.lua` | nvim-treesitter (syntax highlighting + auto_install)                         |
| `ui.lua`         | catppuccin, auto-dark-mode, colorizer, noice, render-markdown                |

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

Usage in `lua/plugins/qa.lua`:

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

| Prefix       | Group          |
|--------------|----------------|
| `<leader>b`  | Buffers        |
| `<leader>c`  | Code           |
| `<leader>cb` | CommentBox     |
| `<leader>cc` | Calls          |
| `<leader>q`  | Quit           |
| `<leader>s`  | Telescope      |
| `<leader>t`  | Toggle         |
| `<leader>tm` | Toggle Options |
| `<leader>x`  | Trouble        |
| `<leader>?`  | Help           |

Source of truth: the `clues` table in `lua/plugins/editor.lua`.

## LSP Architecture

**Stack:** mason (installs binaries via `mason-tool-installer`) +
native `lsp/*.lua` files (auto-discovered server definitions) +
`vim.lsp.config('*', ...)` and `vim.lsp.enable {...}` in `init.lua`,
with capabilities from blink.cmp.

**Server config pattern:** Each server has a `lsp/<name>.lua` file
returning `{ cmd, filetypes, root_markers, settings? }`. Neovim 0.11+
auto-loads these into `vim.lsp.config[<name>]`. Global capabilities
and the enable list live at the bottom of `init.lua` (NOT in
`lua/plugins/lsp.lua`, which only configures mason).

**Lua API completions:** `lsp/lua_ls.lua` sets `workspace.library = { vim.env.VIMRUNTIME }`
and `diagnostics.globals = { 'vim' }` directly. `lazydev.nvim` is not installed.

**Default keymaps** (nvim 0.11): `grn` (rename), `gra` (code action),
`grr` (references), `gri` (implementations) work out of the box.
`<leader>c*` keymaps in `lua/keymaps.lua` provide telescope-powered
variants. `lua/autogroups.lua` wraps `grt` and `gri` with a
capability check so unsupported servers get a friendly notification
instead of the default "… is not supported" error.

**Servers from mise (not mason):** `fish_lsp`, `taplo`. List-parity
maintenance rule: `.claude/rules/lsp-list-parity.md` (path-scoped to
the lsp config files).

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
- **Dev plugins path**: `~/Code/nvim` is configured as the lazy.nvim
  dev path — plugins there override registry versions.
- **Format toggle state**: `vim.g.autoformat_enabled` tracks
  the toggle; `_G.autoformat_status()` exposes it for statusline.

## context-mode

Mandatory MCP routing rules live in `.claude/rules/context-mode.md`.
That file is the single source of truth — do not duplicate its content
back into this file.
