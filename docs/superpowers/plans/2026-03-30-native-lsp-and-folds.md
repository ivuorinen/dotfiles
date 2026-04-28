# Native LSP Server Definitions + Treesitter Folds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix LSP servers not starting by creating `lsp/*.lua` server definition files, fix `vim.*` API docs by correcting lua_ls config, and enable treesitter-based folding.

**Architecture:** Neovim 0.11 auto-discovers `lsp/<name>.lua` files from runtimepath. Each file returns `{ cmd, filetypes, root_markers, settings? }`. `vim.lsp.enable()` activates them. Treesitter folding uses the built-in `vim.treesitter.foldexpr()`.

**Tech Stack:** Neovim 0.11+, native LSP, treesitter, mason, lazydev.nvim, blink.cmp

---

### File Map

**Create (17 files):**
- `config/nvim/lsp/lua_ls.lua` — Lua LSP with settings (no on_init, lazydev handles vim.*)
- `config/nvim/lsp/gopls.lua` — Go LSP with hint settings
- `config/nvim/lsp/intelephense.lua` — PHP LSP with license key
- `config/nvim/lsp/yamlls.lua` — YAML LSP with schema settings
- `config/nvim/lsp/ansiblels.lua` — Ansible LSP
- `config/nvim/lsp/ast_grep.lua` — ast-grep LSP
- `config/nvim/lsp/bashls.lua` — Bash LSP
- `config/nvim/lsp/cssls.lua` — CSS LSP
- `config/nvim/lsp/dockerls.lua` — Dockerfile LSP
- `config/nvim/lsp/eslint.lua` — ESLint LSP
- `config/nvim/lsp/html.lua` — HTML LSP
- `config/nvim/lsp/jsonls.lua` — JSON LSP
- `config/nvim/lsp/pyright.lua` — Python LSP
- `config/nvim/lsp/tailwindcss.lua` — Tailwind CSS LSP
- `config/nvim/lsp/terraformls.lua` — Terraform LSP
- `config/nvim/lsp/ts_ls.lua` — TypeScript LSP
- `config/nvim/lsp/vimls.lua` — Vim LSP

**Modify (3 files):**
- `config/nvim/lua/plugins/lsp.lua` — Remove per-server `vim.lsp.config()` calls, keep global caps + enable + diagnostics + autocmds
- `config/nvim/lua/options.lua` — Add treesitter fold settings
- `config/nvim/CLAUDE.md` — Update LSP Architecture section

---

### Task 1: Create `lsp/*.lua` files for servers with custom settings

**Files:**
- Create: `config/nvim/lsp/lua_ls.lua`
- Create: `config/nvim/lsp/gopls.lua`
- Create: `config/nvim/lsp/intelephense.lua`
- Create: `config/nvim/lsp/yamlls.lua`

- [ ] **Step 1: Create `config/nvim/lsp/lua_ls.lua`**

Note: No `on_init`, no `diagnostics.globals = { 'vim' }`. lazydev.nvim handles vim API type annotations and workspace library injection. `runtime.version` is set as a static setting.

```lua
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.stylua.toml',
    'stylua.toml',
    '.git',
  },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { disable = { 'missing-fields' } },
      completion = { callSnippet = 'Replace' },
      workspace = { checkThirdParty = true },
      hint = {
        enable = true,
        arrayIndex = 'Auto',
        await = true,
        paramName = 'All',
        paramType = true,
        semicolon = 'SameLine',
        setType = false,
      },
    },
  },
}
```

- [ ] **Step 2: Create `config/nvim/lsp/gopls.lua`**

```lua
return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
```

- [ ] **Step 3: Create `config/nvim/lsp/intelephense.lua`**

Uses `GetIntelephenseLicense()` from `utils.lua` (loaded globally via `require 'utils'` in `lsp.lua`).

```lua
require 'utils'

return {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { 'composer.json', '.git' },
  init_options = {
    licenceKey = vim.env.INTELEPHENSE_LICENSE
      or GetIntelephenseLicense()
      or nil,
  },
}
```

- [ ] **Step 4: Create `config/nvim/lsp/yamlls.lua`**

```lua
return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose' },
  root_markers = { '.git' },
  settings = {
    yaml = {
      keyOrdering = false,
      schemaStore = { enable = true },
    },
  },
}
```

- [ ] **Step 5: Commit**

```bash
git add config/nvim/lsp/lua_ls.lua config/nvim/lsp/gopls.lua config/nvim/lsp/intelephense.lua config/nvim/lsp/yamlls.lua
git commit -m "feat(nvim): add native lsp/*.lua definitions for lua_ls, gopls, intelephense, yamlls"
```

---

### Task 2: Create `lsp/*.lua` files for servers with default config

**Files:**
- Create: `config/nvim/lsp/ansiblels.lua`
- Create: `config/nvim/lsp/ast_grep.lua`
- Create: `config/nvim/lsp/bashls.lua`
- Create: `config/nvim/lsp/cssls.lua`
- Create: `config/nvim/lsp/dockerls.lua`
- Create: `config/nvim/lsp/eslint.lua`
- Create: `config/nvim/lsp/html.lua`
- Create: `config/nvim/lsp/jsonls.lua`
- Create: `config/nvim/lsp/pyright.lua`
- Create: `config/nvim/lsp/tailwindcss.lua`
- Create: `config/nvim/lsp/terraformls.lua`
- Create: `config/nvim/lsp/ts_ls.lua`
- Create: `config/nvim/lsp/vimls.lua`

- [ ] **Step 1: Create `config/nvim/lsp/ansiblels.lua`**

```lua
return {
  cmd = { 'ansible-language-server', '--stdio' },
  filetypes = { 'yaml.ansible' },
  root_markers = { 'ansible.cfg', '.ansible-lint', '.git' },
}
```

- [ ] **Step 2: Create `config/nvim/lsp/ast_grep.lua`**

```lua
return {
  cmd = { 'ast-grep', 'lsp' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'html',
    'css',
    'lua',
    'python',
    'go',
    'rust',
  },
  root_markers = { 'sgconfig.yml', '.git' },
}
```

- [ ] **Step 3: Create `config/nvim/lsp/bashls.lua`**

```lua
return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  root_markers = { '.git' },
}
```

- [ ] **Step 4: Create `config/nvim/lsp/cssls.lua`**

```lua
return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
}
```

- [ ] **Step 5: Create `config/nvim/lsp/dockerls.lua`**

```lua
return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { 'Dockerfile', '.git' },
}
```

- [ ] **Step 6: Create `config/nvim/lsp/eslint.lua`**

```lua
return {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.json',
    '.eslintrc.yml',
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.ts',
    'package.json',
  },
}
```

- [ ] **Step 7: Create `config/nvim/lsp/html.lua`**

```lua
return {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html', 'templ' },
  root_markers = { 'package.json', '.git' },
}
```

- [ ] **Step 8: Create `config/nvim/lsp/jsonls.lua`**

```lua
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { 'package.json', '.git' },
}
```

- [ ] **Step 9: Create `config/nvim/lsp/pyright.lua`**

```lua
return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'pyrightconfig.json',
    '.git',
  },
}
```

- [ ] **Step 10: Create `config/nvim/lsp/tailwindcss.lua`**

```lua
return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    'tailwind.config.js',
    'tailwind.config.ts',
    'tailwind.config.mjs',
    'postcss.config.js',
    'postcss.config.ts',
  },
}
```

- [ ] **Step 11: Create `config/nvim/lsp/terraformls.lua`**

```lua
return {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'terraform-vars' },
  root_markers = { '.terraform', '.git' },
}
```

- [ ] **Step 12: Create `config/nvim/lsp/ts_ls.lua`**

```lua
return {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    'tsconfig.json',
    'jsconfig.json',
    'package.json',
    '.git',
  },
}
```

- [ ] **Step 13: Create `config/nvim/lsp/vimls.lua`**

```lua
return {
  cmd = { 'vim-language-server', '--stdio' },
  filetypes = { 'vim' },
  root_markers = { '.git' },
}
```

- [ ] **Step 14: Commit**

```bash
git add config/nvim/lsp/ansiblels.lua config/nvim/lsp/ast_grep.lua config/nvim/lsp/bashls.lua config/nvim/lsp/cssls.lua config/nvim/lsp/dockerls.lua config/nvim/lsp/eslint.lua config/nvim/lsp/html.lua config/nvim/lsp/jsonls.lua config/nvim/lsp/pyright.lua config/nvim/lsp/tailwindcss.lua config/nvim/lsp/terraformls.lua config/nvim/lsp/ts_ls.lua config/nvim/lsp/vimls.lua
git commit -m "feat(nvim): add native lsp/*.lua definitions for 13 default servers"
```

---

### Task 3: Simplify `lsp.lua` — remove inline server configs

**Files:**
- Modify: `config/nvim/lua/plugins/lsp.lua`

- [ ] **Step 1: Remove per-server `vim.lsp.config()` calls and update `vim.lsp.enable()`**

Replace lines 51-150 (from the native LSP comment block through `vim.lsp.enable(all_servers)`) with:

```lua
      -- ╭─────────────────────────────────────────────────────────╮
      -- │     Native LSP configuration (nvim 0.11+)              │
      -- │     Server definitions live in lsp/*.lua files         │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Set global capabilities from blink.cmp for all LSP servers
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- Enable all servers (definitions in lsp/*.lua)
      vim.lsp.enable {
        'ansiblels',
        'ast_grep',
        'bashls',
        'cssls',
        'dockerls',
        'eslint',
        'gopls',
        'html',
        'intelephense',
        'jsonls',
        'lua_ls',
        'pyright',
        'tailwindcss',
        'terraformls',
        'ts_ls',
        'vimls',
        'yamlls',
      }
```

Everything after (diagnostic config, LspAttach autocmds) stays unchanged.

- [ ] **Step 2: Remove `saghen/blink.cmp` from mason-tool-installer dependencies**

The `blink.cmp` dependency was only needed because the config function called `require('blink.cmp')`. It still does (for global capabilities), so keep it.

Actually — `blink.cmp` is still required in the config function for `get_lsp_capabilities()`. Keep the dependency as-is. No change needed here.

- [ ] **Step 3: Verify the full file looks correct**

The final `lsp.lua` should have this structure:
1. `require 'utils'` (still needed — `GetIntelephenseLicense` is used in `lsp/intelephense.lua` which also does `require 'utils'`, but keeping it here is harmless)
2. `mason.nvim` spec (unchanged)
3. `mason-tool-installer.nvim` spec with:
   - `ensure_installed` list (unchanged)
   - `vim.lsp.config('*', ...)` for global capabilities
   - `vim.lsp.enable { ... }` with all 17 server names
   - Diagnostic config (unchanged)
   - LspAttach autocmds (unchanged)
4. `mason-conform.nvim` spec (unchanged)
5. `lazydev.nvim` spec (unchanged)
6. `fidget.nvim` spec (unchanged)

- [ ] **Step 4: Commit**

```bash
git add config/nvim/lua/plugins/lsp.lua
git commit -m "refactor(nvim): move LSP server configs to native lsp/*.lua files"
```

---

### Task 4: Add treesitter fold settings to `options.lua`

**Files:**
- Modify: `config/nvim/lua/options.lua`

- [ ] **Step 1: Add fold options**

Add after line 56 (`o.winblend = 10`), before the session options section:

```lua
-- Folding via treesitter
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldtext = ''
o.foldlevel = 99
o.foldlevelstart = 99
```

- [ ] **Step 2: Commit**

```bash
git add config/nvim/lua/options.lua
git commit -m "feat(nvim): enable treesitter-based folding"
```

---

### Task 5: Update `config/nvim/CLAUDE.md`

**Files:**
- Modify: `config/nvim/CLAUDE.md`

- [ ] **Step 1: Update LSP Architecture section**

Replace the current LSP Architecture section (lines 60-73) with:

```markdown
## LSP Architecture

**Stack:** mason (installs servers) + native `lsp/*.lua` files
(server definitions with cmd/filetypes/root_markers) +
`vim.lsp.enable()` (nvim 0.11), with capabilities from blink.cmp.

**Server config pattern:** Each server has a `lsp/<name>.lua` file
returning `{ cmd, filetypes, root_markers, settings? }`. Global
capabilities set via `vim.lsp.config('*', ...)` in `lsp.lua`.
`vim.lsp.enable({...})` activates all servers.

**vim.* API docs:** `lazydev.nvim` injects vim API type annotations
into lua_ls dynamically. Do not set `workspace.library` or
`diagnostics.globals` manually — lazydev handles both.

**Default keymaps** (nvim 0.11): `grn` (rename), `gra` (code action),
`grr` (references), `gri` (implementations) — work out of the box.
`<leader>c*` keymaps in keymaps.lua provide telescope-powered variants.

**lazydev** provides Lua LSP enhancements (vim API completions).
```

- [ ] **Step 2: Commit**

```bash
git add config/nvim/CLAUDE.md
git commit -m "docs(nvim): update CLAUDE.md for native lsp/*.lua architecture"
```

---

### Task 6: Manual Verification

No automated tests — this is nvim config. Verify manually in neovim.

- [ ] **Step 1: Open neovim and check lua_ls starts**

Open a Lua file in the nvim config:
```
nvim config/nvim/lua/plugins/lsp.lua
```

Run: `:lua vim.print(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients()))`

Expected: output includes `lua_ls` (and possibly `copilot`)

- [ ] **Step 2: Check `K` shows LSP hover, not man page**

Place cursor on `require` on line 5 and press `K`.

Expected: LSP hover popup with function signature, not "man.lua: no manual entry for require"

- [ ] **Step 3: Check vim.* API docs work**

Open any Lua file, type `vim.api` and press `K`.

Expected: hover popup showing vim.api documentation

- [ ] **Step 4: Check vim.* completion works**

In insert mode, type `vim.` and wait for completion.

Expected: completion menu shows vim API items (api, fn, opt, etc.)

- [ ] **Step 5: Check treesitter folding works**

Run: `:set foldmethod?`
Expected: `foldmethod=expr`

Place cursor inside a function body and press `zc`.
Expected: function body folds.

Press `zo` to unfold.
Expected: function body unfolds.

- [ ] **Step 6: Check folds open by default**

Open a new file:
```
nvim config/nvim/lua/options.lua
```

Expected: all code visible, no folds collapsed

- [ ] **Step 7: Check other LSP servers**

Open a shell script:
```
nvim local/bin/msgr
```

Run: `:lua vim.print(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients()))`

Expected: output includes `bashls`
