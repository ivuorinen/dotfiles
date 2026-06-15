# Neovim Plugin Reference

Plugin manager: **vim.pack** (Neovim 0.12+ built-in). All plugins are loaded via a single
`vim.pack.add {}` call in `init.lua` at step 7b of `:h initialization`. Plugin configuration
lives inline in `init.lua` in named sections (`-- Completion`, `-- Editor`, `-- LSP`, etc.).

User commands (`PackUpdate`, `PackRemove`, `PackList`) live in `lua/pack.lua`.

## Completion

**mini.completion** — part of `https://github.com/nvim-mini/mini.nvim`

LSP-aware completion via `completefunc`. `<C-Space>` triggers manually;
completion fires automatically after a short delay. `<Tab>`/`<S-Tab>` navigate,
`<CR>` confirms, `<C-e>` dismisses.

## Editor

### mini.nvim — `https://github.com/nvim-mini/mini.nvim`

19 independent modules from a single plugin:

| Module           | Role                                                                  |
|------------------|-----------------------------------------------------------------------|
| mini.completion  | LSP-aware completion via `completefunc`; auto-trigger + `<C-Space>`   |
| mini.comment     | `gc` toggle comment operator; `gcc` for current line                  |
| mini.ai          | Textobjects: `va)`, `yinq`, `ci'`; 750-line lookahead                 |
| mini.operators   | `g=` evaluate, `gx` exchange, `gm` duplicate, `gR` replace, `gs` sort |
| mini.splitjoin   | Split/join arguments and lists (`gS`)                                 |
| mini.surround    | `sa` add, `sd` delete, `sr` replace surrounding delimiters            |
| mini.bufremove   | Delete/wipeout buffer without disrupting the window layout            |
| mini.files       | Column-based file explorer (`<leader>te`, `-`); preview pane enabled  |
| mini.clue        | Key clue popup for `<leader>`, `g`, marks, registers, `<C-w>`, `z`    |
| mini.diff        | Inline git diff signs in the sign column                              |
| mini.sessions    | Per-directory sessions; auto-read on start, auto-write on exit        |
| mini.animate     | Smooth animations for scroll, cursor, and resize                      |
| mini.cursorword  | Highlight all occurrences of the word under the cursor                |
| mini.hipatterns  | Highlight `FIXME`, `HACK`, `TODO`, `NOTE`, `BUG`, `PERF`, hex colors  |
| mini.icons       | Icon provider; mocks `nvim-web-devicons` for plugins that require it  |
| mini.indentscope | Indent scope indicator; animation disabled                            |
| mini.statusline  | Mode, git, LSP status, diagnostics, format-on-save indicator          |
| mini.trailspace  | Highlights and trims trailing whitespace                              |
| mini.keymap      | `jk`/`kj` → Escape in insert, command, visual, select, terminal       |

### vim-sleuth — `https://github.com/tpope/vim-sleuth`

Auto-detects `tabstop` and `shiftwidth` from file content and sibling files.

## LSP

| Plugin                    | Role                                                                     |
|---------------------------|--------------------------------------------------------------------------|
| nvim-lspconfig            | Populates `vim.lsp.config` with default server definitions               |
| mason.nvim                | Downloads and manages LSP server binaries                                |
| mason-lspconfig.nvim      | `automatic_enable = true` calls `vim.lsp.enable()` for all mason servers |
| mason-tool-installer.nvim | `auto_install`/`auto_update` for all `ensure_installed` tools            |

URLs: `github.com/neovim/nvim-lspconfig` · `github.com/williamboman/mason.nvim` ·
`github.com/williamboman/mason-lspconfig.nvim` ·
`github.com/WhoIsSethDaniel/mason-tool-installer.nvim`

`vim.lsp.protocol.make_client_capabilities()` is registered on `vim.lsp.config('*', ...)`
before mason-lspconfig enables servers. `fish_lsp` and `taplo` are mise-managed and
enabled explicitly via `vim.lsp.enable { 'fish_lsp', 'taplo' }`.

### LSP Servers

Mason-managed (auto-enabled by mason-lspconfig):

| Server                      | Language                |
|-----------------------------|-------------------------|
| ansible-language-server     | Ansible playbooks       |
| bash-language-server        | Bash / sh               |
| css-lsp                     | CSS                     |
| dockerfile-language-server  | Dockerfile              |
| eslint-lsp                  | JavaScript / TypeScript |
| gopls                       | Go                      |
| html-lsp                    | HTML                    |
| intelephense                | PHP                     |
| json-lsp                    | JSON / JSONC            |
| lua-language-server         | Lua                     |
| pyright                     | Python                  |
| tailwindcss-language-server | Tailwind CSS            |
| terraform-ls                | Terraform / HCL         |
| typescript-language-server  | TypeScript / JavaScript |
| vim-language-server         | Vimscript               |
| yaml-language-server        | YAML                    |

Mise-managed (enabled explicitly via `vim.lsp.enable`):

| Server   | Language   |
|----------|------------|
| fish_lsp | Fish shell |
| taplo    | TOML       |

Server customizations (non-default config in `lsp/`): `eslint`, `fish_lsp`, `gopls`,
`intelephense`, `lua_ls`, `tailwindcss`, `yamlls`.

## Navigation

**trouble.nvim** — `https://github.com/folke/trouble.nvim`

Diagnostics list, quickfix, and LSP results UI (`auto_close = true`).

| Mode        | Description                                                   |
|-------------|---------------------------------------------------------------|
| diagnostics | Standard diagnostics list                                     |
| cascade     | Shows only the highest-severity items in the current buffer   |
| test        | Diagnostics in a right-side split (25% width) for test output |

`<C-t>` in snacks.picker sends all current picker results to trouble.

## Quality Assurance

| Plugin             | Role                                            |
|--------------------|-------------------------------------------------|
| conform.nvim       | Format-on-save; falls back to LSP formatting    |
| nvim-lint          | Async linting on write, read, and insert-leave  |
| mason-conform.nvim | Installs formatters needed by conform via mason |

URLs: `github.com/stevearc/conform.nvim` · `github.com/mfussenegger/nvim-lint` ·
`github.com/zapling/mason-conform.nvim`

`<leader>tf` toggles format-on-save. Skips `node_modules/`, `vendor/`, `dist/`.

### Formatters (conform)

| Filetype     | Formatter         | Project-gated? |
|--------------|-------------------|----------------|
| yaml.ansible | ansible-lint      | yes            |
| bash, sh     | shfmt             | no             |
| fish         | fish_indent       | no             |
| go           | goimports + gofmt | no             |
| lua          | stylua            | yes            |
| python       | ruff_format       | yes            |
| terraform    | terraform_fmt     | no             |
| toml         | taplo             | yes            |
| yaml         | prettier          | yes            |

LSP formatting is the fallback for filetypes not listed above.

### Linters (nvim-lint)

| Filetype       | Linter        | Project-gated? |
|----------------|---------------|----------------|
| bash, sh       | shellcheck    | no             |
| dockerfile     | hadolint      | yes            |
| fish           | fish          | no             |
| go             | golangci_lint | yes            |
| js / ts / json | biomejs       | yes            |
| python         | ruff          | yes            |
| terraform      | tflint        | yes            |
| yaml           | yamllint      | yes            |
| yaml.ansible   | ansible_lint  | yes            |

## Snacks

**snacks.nvim** — `https://github.com/folke/snacks.nvim`

Multi-feature plugin; each snack is independently toggleable:

| Snack    | Role                                                                     |
|----------|--------------------------------------------------------------------------|
| bigfile  | Disables treesitter/LSP for large files to prevent UI freezes            |
| image    | Inline image rendering (Kitty/WezTerm/iTerm2; silent fallback on others) |
| input    | Replaces `vim.ui.input` with a styled floating prompt                    |
| notifier | Toast notification UI; replaces `vim.notify`                             |
| picker   | Fuzzy finder replacing telescope; `<C-t>` sends results to trouble       |
| rename   | LSP-aware file rename that updates all import references                 |
| terminal | Floating terminal                                                        |

## Tools

| Plugin         | Role                                                     |
|----------------|----------------------------------------------------------|
| vim-wakatime   | Automatic coding time tracking via WakaTime              |
| nvim-shellspec | ShellSpec filetype support (auto-format, 2-space indent) |
| mini.comment   | Toggle comments via `gc`/`gcc` (from mini.nvim)          |

URLs: `github.com/wakatime/vim-wakatime` · `github.com/ivuorinen/nvim-shellspec`

## Treesitter

**nvim-treesitter** — `https://github.com/nvim-treesitter/nvim-treesitter`

Syntax highlighting, smart indentation, and incremental selection.
`auto_install = true` downloads parsers for any opened filetype. A `PackChanged`
autocmd runs `:TSUpdate` after vim.pack operations to keep parsers in sync.

Core parsers always installed: `html`, `lua`, `luadoc`, `markdown`,
`markdown_inline`, `regex`, `yaml`.

## UI

| Plugin              | Role                                                                 |
|---------------------|----------------------------------------------------------------------|
| catppuccin/nvim     | Colorscheme; `auto_integrations` picks up mini.nvim; dim_inactive on |
| auto-dark-mode.nvim | Polls OS every 1 s; syncs `background` with system dark/light state  |
| nvim-colorizer.lua  | Highlights hex color codes in-buffer; named colors disabled          |

URLs: `github.com/catppuccin/nvim` · `github.com/f-person/auto-dark-mode.nvim` ·
`github.com/catgoose/nvim-colorizer.lua`

## Installed Tools (mason-tool-installer)

Non-LSP tools installed and auto-updated by mason:

| Tool          | Purpose                  |
|---------------|--------------------------|
| actionlint    | GitHub Actions linter    |
| ansible-lint  | Ansible playbook linter  |
| goimports     | Go import organizer      |
| golangci-lint | Go meta-linter           |
| hadolint      | Dockerfile linter        |
| prettier      | Multi-language formatter |
| shfmt         | Shell script formatter   |
| shellcheck    | Shell script linter      |
| stylua        | Lua code formatter       |
