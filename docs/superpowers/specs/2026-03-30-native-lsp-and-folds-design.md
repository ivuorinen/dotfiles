# Native LSP Server Definitions + Treesitter Folds

## Problem

LSP servers never start because `vim.lsp.enable()` requires server
definitions (`cmd`, `filetypes`, `root_markers`) that don't exist.
The current `vim.lsp.config()` calls only set settings overrides.
As a result, `vim.*` API docs/completions don't work in Lua files
because lua_ls never starts (and lazydev.nvim can't inject type
annotations into a server that isn't running). Additionally, folding
uses the vim default (`manual`), missing the opportunity for
automatic treesitter-based fold detection.

## Part 1: Native LSP via `lsp/*.lua` Files

### How It Works

Neovim 0.11+ auto-discovers `lsp/<name>.lua` files from runtimepath.
Each file returns a table with `cmd`, `filetypes`, `root_markers`,
and optionally `settings`. `vim.lsp.enable(<names>)` activates them.

### Files to Create

Create `config/nvim/lsp/<server>.lua` for each of the 17 servers.

**Servers with custom settings (include settings in the file):**

| File               | cmd                               | filetypes                         | root_markers                                                 |
|--------------------|-----------------------------------|-----------------------------------|--------------------------------------------------------------|
| `lua_ls.lua`       | `lua-language-server`             | `lua`                             | `.luarc.json`, `.luarc.jsonc`, `.stylua.toml`, `stylua.toml` |
| `gopls.lua`        | `gopls`                           | `go`, `gomod`, `gowork`, `gotmpl` | `go.work`, `go.mod`                                          |
| `intelephense.lua` | `intelephense`, `--stdio`         | `php`                             | `composer.json`, `.git`                                      |
| `yamlls.lua`       | `yaml-language-server`, `--stdio` | `yaml`, `yaml.docker-compose`     | `.git`                                                       |

**Servers with default config (cmd + filetypes + root_markers only):**

| File              | cmd                                        | filetypes                                                                       | root_markers                                       |
|-------------------|--------------------------------------------|---------------------------------------------------------------------------------|----------------------------------------------------|
| `ansiblels.lua`   | `ansible-language-server`, `--stdio`       | `yaml.ansible`                                                                  | `ansible.cfg`, `.ansible-lint`                     |
| `ast_grep.lua`    | `ast-grep`, `lsp`                          | `javascript`, `typescript`, `html`, `css`, `lua`, etc.                          | `sgconfig.yml`                                     |
| `bashls.lua`      | `bash-language-server`, `start`            | `sh`, `bash`                                                                    | `.git`                                             |
| `cssls.lua`       | `vscode-css-language-server`, `--stdio`    | `css`, `scss`, `less`                                                           | `package.json`, `.git`                             |
| `dockerls.lua`    | `docker-langserver`, `--stdio`             | `dockerfile`                                                                    | `Dockerfile`                                       |
| `eslint.lua`      | `vscode-eslint-language-server`, `--stdio` | `javascript`, `typescript`, `javascriptreact`, `typescriptreact`                | `.eslintrc*`, `eslint.config.*`, `package.json`    |
| `html.lua`        | `vscode-html-language-server`, `--stdio`   | `html`, `templ`                                                                 | `package.json`, `.git`                             |
| `jsonls.lua`      | `vscode-json-language-server`, `--stdio`   | `json`, `jsonc`                                                                 | `package.json`, `.git`                             |
| `pyright.lua`     | `pyright-langserver`, `--stdio`            | `python`                                                                        | `pyproject.toml`, `setup.py`, `pyrightconfig.json` |
| `tailwindcss.lua` | `tailwindcss-language-server`, `--stdio`   | `html`, `css`, `javascript`, `typescript`, `javascriptreact`, `typescriptreact` | `tailwind.config.*`, `postcss.config.*`            |
| `terraformls.lua` | `terraform-ls`, `serve`                    | `terraform`, `terraform-vars`                                                   | `.terraform`, `*.tf`                               |
| `ts_ls.lua`       | `typescript-language-server`, `--stdio`    | `javascript`, `javascriptreact`, `typescript`, `typescriptreact`                | `tsconfig.json`, `jsconfig.json`, `package.json`   |
| `vimls.lua`       | `vim-language-server`, `--stdio`           | `vim`                                                                           | `.git`                                             |

### lua_ls + vim.* API Docs

The current `lua_ls` config has an `on_init` that overwrites
`workspace.library` with just `{ vim.env.VIMRUNTIME }`. This
clobbers the library paths that `lazydev.nvim` injects dynamically.

**Fix in `lsp/lua_ls.lua`:**
- Remove the `on_init` callback entirely
- Remove `diagnostics.globals = { 'vim' }` (lazydev's type
  annotations make this unnecessary — lua_ls will know `vim` is
  a typed global, not just a suppressed warning)
- Keep `runtime.version = 'LuaJIT'` as a static setting
- lazydev.nvim + its blink.cmp source (already configured in
  `completion.lua`) handle the rest

### Changes to `lsp.lua`

- Remove all `vim.lsp.config('<server>', ...)` per-server calls
  (lines 62-143) — these move into the `lsp/*.lua` files
- Remove `vim.lsp.enable(all_servers)` call — replace with a simple
  list since servers are now self-contained
- Keep `vim.lsp.config('*', { capabilities = ... })` for global caps
- Keep `vim.lsp.enable({...})` with explicit server name list
- Keep diagnostic config and LspAttach autocmds unchanged

## Part 2: Treesitter Folds

### Changes to `options.lua`

Add fold options after the existing settings:

```lua
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldtext = ''
o.foldlevel = 99
o.foldlevelstart = 99
```

- `foldmethod=expr` + `foldexpr` uses treesitter for fold detection
- `foldtext=''` uses nvim 0.10+ native highlighted fold rendering
- `foldlevel=99` + `foldlevelstart=99` opens all folds by default

No plugin needed. Built-in since nvim 0.10.

## What Stays the Same

- `mason.nvim` and `mason-tool-installer` (server installation)
- `lazydev.nvim` (lua LSP enhancements)
- `fidget.nvim` (progress display)
- `mason-conform.nvim` (formatter bridge)
- `treesitter.lua` (no changes needed)
- All diagnostic config and LspAttach autocmds
- All keymaps

## Documentation Updates

Update `config/nvim/CLAUDE.md` LSP Architecture section to describe
the `lsp/*.lua` pattern instead of inline `vim.lsp.config()` calls.

## Verification

1. Open a `.lua` file, press `K` on `require` — should show LSP hover
2. Press `K` on `vim.api` — should show vim API docs (not "no manual entry")
3. `:lua vim.print(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients()))` — should list `lua_ls`
4. Type `vim.` in insert mode — completion should show API items
5. `:set foldmethod?` — should show `expr`
6. `zc` on a function — should fold it
7. Open a new file — all folds should be open
