# Plan: nvim — native UI2 cleanup, blink.cmp, arborist → nvim-treesitter

Date: 2026-10-17
Status: IMPLEMENTED 2026-10-17 — uncommitted; manual checks in Task 4 pending
Branch: `refactor/nvim-blink-treesitter-ui2`

Deviations found while implementing:

- Task 4 verify: the LSP client's `textDocument.completion` is a superset of
  `get_lsp_capabilities()` (Neovim adds `dynamicRegistration` and `completionItemKind`), so
  "deep-equals" was the wrong test. Checked instead that every value blink sets reached
  lua_ls and stylua unchanged — it did.
- Task 4 docs: `config/nvim/CLAUDE.md` (LSP Architecture → Stack) named the deleted
  `vim.lsp.config('*', …)` block in `init.lua`; updated to say blink sets the capabilities.
- Task 6: nvim-treesitter was added and arborist deleted with `nvim -u NONE`, so `init.lua`'s
  `install {}` could not run against arborist's parsers before they were removed.

Follow-up changes requested after implementation (these supersede the task text below):

- `<leader>tn` is back as "Dismiss Messages": it calls ui2's private
  `vim._core.ui2.messages.msg_clear()` under `pcall`, falling back to `:echo ''`.
- `<leader>sn` is back as "Message History": a snacks picker over `:messages`, newest first,
  `preview = 'preview'`, `confirm = 'close'` (the old `notifications` source's settings).
- blink.cmp uses the `default` preset: `<C-y>` accepts, `<Tab>`/`<S-Tab>` only jump snippet
  fields. The "Tab accepts" breaking change no longer applies.
- Parsers install on file open: the `FileType` autocmd installs a parser nvim-treesitter
  knows but has not built, then starts every buffer of that language. The `install {}` list
  shrank to what the autocmd cannot reach: bundled `lua`, `markdown`, `query`, `vim`,
  `vimdoc` and injection-only `luadoc`, `regex`. Parsers no longer installing on open is no
  longer a breaking change.

Sources:

- <https://tduyng.com/blog/neovim-drop-noice-ui2/>
- <https://tduyng.com/blog/neovim-auto-completions/>
- <https://tduyng.com/blog/neovim-highlight-syntax/>
- blink.cmp at tag `v1.10.2`: `doc/installation.md`, `doc/configuration/{reference,keymap,fuzzy}.md`,
  `doc/modes/cmdline.md`, `plugin/blink-cmp.lua`, `lua/blink/cmp/fuzzy/download/{init,git}.lua`
- blink.cmp `main`: `doc/configuration/signature.md` (v1.10.2 signature defaults are taken from
  that tag's `reference.md`)
- nvim-treesitter `main`: `README.md`, `lua/nvim-treesitter/{init,parsers,install,indent,config}.lua`
- Neovim 0.12.5 runtime: `doc/pack.txt`, `doc/options.txt`, `doc/lua.txt`, bundled parsers and queries

## Goal

1. Finish the noice → ui2 migration: built-in options replace per-call border settings, and ui2
    replaces the `snacks.notifier` toast UI.
2. Replace mini.completion with blink.cmp v1 (per the completions article), and let blink.cmp's
    signature help replace `lsp_signature.nvim`.
3. Replace arborist.nvim with nvim-treesitter (`main` branch) as the parser manager.

Each is taken with only the options that differ from the tool's defaults.

## Current state (checked 2026-10-17, nvim v0.12.5)

| Item                                        | State in this repo                                                              |
|---------------------------------------------|---------------------------------------------------------------------------------|
| Drop noice.nvim                             | Done — no `noice` reference anywhere in the repo (`git grep -i noice`)          |
| Enable ui2                                  | Done — `init.lua:27` `pcall(function() require('vim._core.ui2').enable {} end)` |
| `completeopt` popup                         | Done — `lua/options.lua:64` `{ 'menuone', 'noselect', 'popup' }`                |
| `winborder = "rounded"`                     | **Not set.** Two call sites hard-code `border = 'rounded'` instead              |
| LSP progress via `vim.ui.progress_status()` | Not used; statusline shows an icon from `vim.lsp.status()` (`init.lua:283-285`) |
| Message history via ui2 (`:messages`, `g<`) | Not used; `snacks.notifier` overrides `vim.notify` (`init.lua:521-522`)         |
| Completion                                  | mini.completion (`init.lua:64-67`), disabled in picker (`autogroups.lua:93-98`) |
| Signature help                              | lsp_signature.nvim (`init.lua:61`, `:385-389`) and mini.completion both         |
| LSP capabilities                            | `vim.lsp.config('*', { capabilities = make_client_capabilities() })` `:337-341` |
| Treesitter parser manager                   | arborist.nvim (`init.lua:55`, `:573-586`; `autogroups.lua:222-231`)             |
| Treesitter folds                            | Done — `lua/options.lua:75` uses the built-in `vim.treesitter.foldexpr()`       |
| Text objects                                | mini.ai (`init.lua:80`)                                                         |

## Verification log (2026-10-17)

Every claim the tasks depend on, how it was checked, and the result. ✗ marks a claim from the
previous draft that was wrong; the tasks below are already corrected.

| #  | Claim                                                                                                     | Checked by                                                                                                   | Result                                                                                                                                         |
|----|-----------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | `winborder` applies to `nvim_open_win`, diagnostic floats and LSP previews with no explicit border        | `nvim --clean --headless`, `nvim_win_get_config(w).border` on all three                                      | ✓                                                                                                                                              |
| 2  | Snacks floats "set their own border, unaffected"                                                          | `snacks/win.lua:1185-1197`                                                                                   | ✗ — `border = true` reads `vim.o.winborder`, falls back to `'rounded'`; no visible change                                                      |
| 3  | Nothing but `<leader>tn` calls the notifier API                                                           | `rg 'Snacks\.notif\|s\.notif'` over `init.lua`, `lua/`                                                       | ✓                                                                                                                                              |
| 4  | `K.nl(key, cmd, desc)` takes a string rhs                                                                 | `lua/utils.lua:41-44`                                                                                        | ✓                                                                                                                                              |
| 5  | Every keymap needs a description                                                                          | `scripts/check-keymap-desc.py`, `tests/check-keymap-desc.bats:36`                                            | ✓ — enforced in pre-commit and bats                                                                                                            |
| 6  | No bats test covers `config/nvim`                                                                         | `rg nvim tests/`                                                                                             | ✗ — `check-keymap-desc.bats`, `theme-family-resolvers.bats` (starts the full config headless), `theme-contrast.bats` (greps `init.lua`)        |
| 7  | vim.pack plugin names are the repo basename                                                               | `pack.txt:407-408`; lockfile keys; `site/pack/core/opt/`                                                     | ✓ — `arborist.nvim`, `lsp_signature.nvim`, `nvim-treesitter`, `blink.cmp`                                                                      |
| 8  | Existing `PackChanged` handler runs `:ArboristUpdate`                                                     | `autogroups.lua:226` compares `name == 'arborist'`; real name is `arborist.nvim`                             | ✗ — the handler has never matched since `0f33076d`                                                                                             |
| 9  | `vim.pack.del { 'arborist' }` removes arborist                                                            | `pack.txt:456-465`, `pack.lua:1376`                                                                          | ✗ — name must be `arborist.nvim`, and `del` skips plugins active in the session unless `force`                                                 |
| 10 | During `init.lua`, `vim.pack.add` sources `plugin/` files                                                 | `pack.txt:449-453`                                                                                           | ✗ — load defaults to `false` in `init.lua` (`packadd!`); `plugin/` runs at the load-plugins step                                               |
| 11 | `PackChanged` `install` fires before the plugin is loaded                                                 | `pack.txt:366-368`                                                                                           | ✓ — so an `install` hook cannot call `:TSUpdate`; `update` hook only                                                                           |
| 12 | blink.cmp v1 downloads its prebuilt binary when vim.pack checks out a tag                                 | `fuzzy/download/git.lua` uses `git describe --tags --exact-match`                                            | ✓                                                                                                                                              |
| 13 | blink.cmp registers LSP capabilities itself                                                               | `plugin/blink-cmp.lua:1-7`, runs after `init.lua` (row 10)                                                   | ✓ — it merges any `vim.lsp.config['*'].capabilities` already set                                                                               |
| 14 | blink.cmp skips the snacks picker input without help                                                      | `snacks/picker/core/input.lua:45`, `:55` set `buftype = 'prompt'`; blink default `enabled` excludes `prompt` | ✓ — the picker autocmd can go                                                                                                                  |
| 15 | No insert-mode `<Tab>`, `<C-k>`, `<C-f>`, `<C-b>` maps exist in the nvim config                           | `rg` over `init.lua`, `lua/`                                                                                 | ✓ — only `<C-x>`/`<C-r>` clue triggers and the `jk` combo                                                                                      |
| 16 | `vim.version.range '1.*'` is valid                                                                        | headless `vim.version.range('1.*')` → `>=1.0.0 <2.0.0`                                                       | ✓                                                                                                                                              |
| 17 | All planned parser names exist in nvim-treesitter                                                         | `parsers.lua` on `main` (323 entries)                                                                        | ✓                                                                                                                                              |
| 18 | `install()` is a no-op for installed parsers; `:wait()` works; `get_available()` exists                   | README, `init.lua` exports                                                                                   | ✓                                                                                                                                              |
| 19 | Bundled-with-Neovim parsers need not be listed                                                            | runtime `lib/nvim/parser/`, runtime `queries/lua/`, nvim-treesitter `install.lua`                            | ✗ — bundled Lua ships no `indents.scm`; nvim-treesitter links its queries only for languages it installs. Listing them is required for indent. |
| 20 | arborist wrote parsers only                                                                               | `ls ~/.local/share/nvim/site/{parser,queries}`                                                               | ✗ — also 21 query dirs under `site/queries/`                                                                                                   |
| 21 | snacks.bigfile buffers get filetype `bigfile`                                                             | `snacks/bigfile.lua:42-64`                                                                                   | ✓                                                                                                                                              |
| 22 | Tooling exists: stylua, jq, bats, graphify, `scripts/graphify-tests.py`, `mise run lint`, `mise run test` | `which`, `.mise.toml:47`, `:130`                                                                             | ✓                                                                                                                                              |
| 23 | Line anchors in README.md / CLAUDE.md                                                                     | `sed -n` on each range                                                                                       | ✓ except README completion text is `16-20`, not `16-19`                                                                                        |

Not checkable before implementing, so kept as explicit verify steps: blink's cmdline menu under
ui2, the blink signature window in a live LSP buffer, and `:checkhealth` results after install.

## Scope & constraints

- Repo files: `config/nvim/lua/options.lua`, `lua/autogroups.lua`, `lua/pack-ui.lua`,
  `lua/keymaps.lua`, `init.lua`, `nvim-pack-lock.json`, `README.md`, `CLAUDE.md`, and one
  comment in `config/vim/vimrc`.
- Local machine state outside the repo (Task 6): arborist's parsers, queries, lock and cache. Each
  deletion is shown to you before it runs.
- Keep the `pcall` around the ui2 call: `vim._core.ui2` is a private, experimental module.
- Lua is formatted by stylua (`lua-format` skill); the Stop-hook lint gate must pass.
- Every new or changed keymap carries a description (`.claude/rules/keymap-descriptions.md`).
- `vim.pack.del` runs in a fresh `nvim --headless` after the plugin's spec is gone from
  `init.lua`, so the plugin is not active and no `force` is needed.
- Plugins: +2 (blink.cmp, nvim-treesitter), −2 (lsp_signature, arborist); the notifier snack and
  mini.completion module are switched off. Keys: `<leader>sn` re-pointed, `<leader>tn` removed,
  insert-mode completion keys change to blink's `super-tab` preset.
- No commits until you ask. When asked: one commit per concern (borders; notifier; blink.cmp;
  lsp_signature; treesitter), staged with `git-hunk`.

## Tasks

1. Set the global float border — files: `config/nvim/lua/options.lua` — add
    `o.winborder = 'rounded'` next to the other UI options, with a one-line comment.
    Verify: `nvim --headless -c 'lua io.write(vim.o.winborder)' -c 'qa!'` prints `rounded`.

2. Remove the now-redundant per-call borders — files: `config/nvim/lua/autogroups.lua:103`
    (`float = { border = 'rounded', source = 'if_many' }` → `float = { source = 'if_many' }`),
    `config/nvim/lua/pack-ui.lua:639` (delete `border = 'rounded',`).
    Verify, headless with the full config: open a diagnostic float and the PackUI window and read
    `vim.api.nvim_win_get_config(win).border` — both must report the rounded characters
    (log row 1 already shows this holds with `--clean`).

3. Drop `snacks.notifier` so `vim.notify` goes through ui2 — files:
    - `config/nvim/init.lua:521-522`: remove the `notifier` entry and its comment.
    - `config/nvim/lua/keymaps.lua:159`: `K.nl('sn', '<cmd>messages<CR>', 'Messages')` replaces
      `sp.notifications()`; ui2 opens `:messages` in its pager. This matches
      `config/vim/vimrc:628`, which maps `<leader>sn` to `:messages`.
    - `config/nvim/lua/keymaps.lua:164-165`: remove `<leader>tn` (`s.notifier.hide()`), and the
      `-- Toggle (Snacks-powered)` heading keeps `<leader>tt` under it.
    - `config/vim/vimrc:471-472`: drop "and `<leader>tn` (snacks notifier)" from the list of nvim
      keys with no vim counterpart.
    - `config/nvim/README.md:172`: remove the `notifier` row.
    - `config/nvim/CLAUDE.md:38`: remove "notifier" from the Snacks row.

    Verify: headless start with no errors; `lua vim.notify('x')` then
    `lua io.write(vim.fn.execute('messages'))` contains `x`;
    `git grep -n -i notifier -- config/nvim config/vim` returns nothing;
    `python3 scripts/check-keymap-desc.py` passes.

4. Replace mini.completion with blink.cmp:
    1. `config/nvim/init.lua` plugin list: add
        `{ src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' }`.
        `1.*` is required: `main` is unreleased v2 (needs `blink.lib` and a build step), and the
        prebuilt binary is only fetched on a release tag (log row 12). Update the
        `init.lua:38-40` comment, which says snacks is the only ranged plugin.
    2. `config/nvim/init.lua:64-67`: replace the mini.completion block with

        ```lua
        require('blink.cmp').setup {
          keymap = { preset = 'super-tab' },
          completion = { documentation = { auto_show = true } },
          signature = { enabled = true },
        }
        ```

        `super-tab` is the article's choice. `auto_show = true` keeps today's behaviour (the
        article turns it off). `signature.enabled` (default `false`) replaces both
        mini.completion's and lsp_signature's signature help. The rest of the article's `setup`
        is already the default, and its `InsertEnter` lazy-load is dropped.
    3. `config/nvim/init.lua:337-341`: delete the `vim.lsp.config('*', { capabilities = … })`
        block and its comment. `plugin/blink-cmp.lua` sets blink's capabilities (a superset of
        the built-in ones) for `'*'` at the load-plugins step, before any buffer's `FileType`
        starts a client (log rows 10, 13).
    4. `config/nvim/lua/autogroups.lua:93-98`: delete the mini.completion picker autocmd. The
        picker input is `buftype = 'prompt'`, which blink skips by default (log row 14); the
        list buffer is never in insert mode.
    5. Docs: rewrite the `## Completion` section (`config/nvim/README.md:14-20`) for blink.cmp
        (keys: `<Tab>` accept / snippet forward, `<S-Tab>` snippet back, `<C-n>`/`<C-p>`
        select, `<C-Space>` show/docs, `<C-e>` hide, `<C-k>` signature, `<C-f>`/`<C-b>` scroll
        docs). In the mini.nvim module table, delete the `mini.completion` row
        (`README.md:30`) and change `README.md:26` from `19 independent modules` to
        `18 independent modules`. Update `config/nvim/CLAUDE.md:33`.

    Verify:
    - `git grep -n -i 'mini.completion\|minicompletion'` returns nothing outside `docs/plans/`.
    - Headless start with no errors; `:checkhealth blink.cmp` written to a scratchpad file has no
      ERROR and reports the Rust fuzzy library loaded.
    - With lua_ls attached to a Lua buffer (headless, wait for attach):
      `vim.lsp.get_clients()[1].capabilities.textDocument.completion` deep-equals
      `require('blink.cmp').get_lsp_capabilities().textDocument.completion`.
    - Manual: menu appears while typing, `<Tab>` accepts, docs popup appears, typing
      `vim.fn.expand(` shows the signature window with a rounded border, `:e <Tab>` completes in
      the ui2 cmdline. If blink's cmdline menu draws in the wrong place under ui2, add
      `cmdline = { enabled = false }` with a comment saying why.

5. Drop `lsp_signature.nvim` (after Task 4, so signature help is never missing):
    - `config/nvim/init.lua:61`: remove the plugin URL from the `vim.pack.add` list.
    - `config/nvim/init.lua:385-389`: remove the setup block and its comment.
    - Then, in a fresh session:
      `nvim --headless -c "lua vim.pack.del({ 'lsp_signature.nvim' })" -c 'qa'` — removes the
      checkout and the `nvim-pack-lock.json` entry. Hand-edit the JSON only if the entry stays,
      and say so.
    - Keep `<C-l>` (`keymaps.lua:68`) — it calls the built-in `vim.lsp.buf.signature_help()`.

    Verify: headless start with no errors; `git grep -n -i lsp_signature` returns nothing outside
    `docs/plans/`; `jq . config/nvim/nvim-pack-lock.json` parses; the Task 4 signature check
    still passes.

6. Replace arborist with nvim-treesitter — in this order:
    1. Pre-check: `git grep -n -i 'arborist'` (known hits: `init.lua:55`, `:573-586`,
        `autogroups.lua:226-228`, `CLAUDE.md:40`, `nvim-pack-lock.json:3-5`). Any new hit joins
        this task.
    2. `config/nvim/init.lua:55`: replace the arborist URL with
        `{ src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' }`, with a
        comment: the repo's semver tags (`v0.10.0` and older) are the frozen `master` API, so a
        range would install the wrong branch.
    3. `config/nvim/init.lua:573-586`: replace the arborist setup with
        `require('nvim-treesitter').install { … }`. The list:
        - the parsers on disk today: bash, c, cpp, css, diff, dockerfile, dtd, editorconfig,
          git_config, gitignore, go, gomod, html, ini, java, javascript, json, latex, luadoc,
          make, python, regex, ruby, rust, toml, tsx, typescript, xml, yaml;
        - Neovim's bundled ones, so nvim-treesitter also installs their indent queries (log
          row 19): lua, markdown, query, vim, vimdoc;
        - filetypes this config already targets: fish, php, terraform, templ, gotmpl, gowork.

        `hcl` and `markdown_inline` install automatically as `requires` of `terraform` and
        `markdown` (`parsers.lua`). All names exist (log row 17). `setup {}` is not called; the default `install_dir` is
        wanted.
    4. `config/nvim/lua/autogroups.lua`: add one `FileType` autocmd:
        `if pcall(vim.treesitter.start, ev.buf) then vim.bo[ev.buf].indentexpr =
        "v:lua.require'nvim-treesitter'.indentexpr()" end`. Highlight and indent are set only
        when a parser loads, so snacks.bigfile buffers (filetype `bigfile`) are untouched.
    5. `config/nvim/lua/autogroups.lua:222-231`: rewrite the `PackChanged` handler for
        `name == 'nvim-treesitter' and kind == 'update'`: `packadd` it when `not ev.data.active`,
        then `vim.cmd 'TSUpdate'` — the pattern in `pack.txt:390-397`. No `install` branch: on
        install the plugin is not loaded yet (log row 11), and the `install { … }` call in
        `init.lua` covers first-time parsers. This also fixes the never-matching name check
        (log row 8).
    6. In a fresh session: `nvim --headless -c "lua vim.pack.del({ 'arborist.nvim' })" -c 'qa'`.
    7. Clean arborist's local state, shown to you before running: everything under
        `~/.local/share/nvim/site/parser/` and `~/.local/share/nvim/site/queries/` (all
        arborist-written today, log row 20), `~/.local/share/nvim/arborist-lock.json`,
        `~/.cache/nvim/arborist/`. nvim-treesitter installs into the same two directories.
    8. Install: `nvim --headless -c "lua require('nvim-treesitter').install({...}):wait(600000)"
        -c 'qa'` with the step 3 list.
    9. Docs: rewrite `config/nvim/README.md:187-196` (explicit list, no auto-install, `:TSUpdate`
        on plugin update, `:TSInstall <lang>` for a new language, tree-sitter-cli and C compiler
        needed); update `config/nvim/CLAUDE.md:40`.

    Verify:
    - `:checkhealth nvim-treesitter` written to a scratchpad file has no ERROR lines.
    - For one file each of Lua, Python, Go, fish, YAML and Markdown, opened headless:
      `vim.treesitter.highlighter.active[buf] ~= nil`, `vim.bo.indentexpr` contains
      `nvim-treesitter`, and `vim.treesitter.query.get(lang, 'indents') ~= nil`.
      Markdown also proves `markdown_inline` injection loads.
    - Lua indent works: in a headless Lua buffer, `=` on a mis-indented `if … end` block
      re-indents it to stylua's 2 spaces.
    - A file with no parser (e.g. `.csv`): no error, `indentexpr` unchanged.
    - The update hook: `nvim_exec_autocmds('PackChanged', { data = { spec = { name =
      'nvim-treesitter' }, kind = 'update', active = true } })` runs `:TSUpdate` without error.
    - `git grep -n -i arborist` returns nothing outside `docs/plans/`.

7. Quality gate:
    - `stylua --check` on the touched Lua files; `mise run lint`.
    - `bats tests/check-keymap-desc.bats tests/theme-family-resolvers.bats
      tests/theme-contrast.bats` — the suites that read or start this config (log row 6).
    - Clean headless start: `nvim --headless -c 'qa!'` with stderr captured; empty means pass.

8. Refresh the knowledge graph per `.claude/rules/graphify-first.md`:
    `graphify update .`, `scripts/graphify-tests.py`, `graphify export html`.

## Adversarial hardening

- complexity:
  - Cut from the ui2 article: re-enabling ui2 (done), `completeopt` (set),
    `vim.ui.progress_status()` (a look change, not a simplification), explicit ui2 defaults.
  - Cut from the completions article: `nerd_font_variant`, `documentation.auto_show = false`,
    `sources.default`, `fuzzy.implementation` (defaults), `use_nvim_cmp_as_default` (documented
    "will be removed"), the `InsertEnter` lazy-load. Its ~25-line setup becomes 5 lines.
    Removed outright: the capabilities block (`init.lua:337-341`) and the picker autocmd
    (`autogroups.lua:93-98`).
  - Cut from the treesitter article: `nvim-treesitter-textobjects` and its ~40 lines of keymaps
    (mini.ai covers text objects, and `af`/`if`/`aa`/`ia` collide with mini.ai's `a`/`i`
    prefixes), the global `foldexpr` (already in `options.lua:75`), the `vim.notify` calls in its
    `PackChanged` handler, and its `install` branch (cannot work, log row 11).
  - Stated plainly: Task 4 swaps a mini module for a plugin with a downloaded binary, and Task 6
    adds ~25 lines over arborist's 9. Tasks 1–3 and 5 remove code. Net plugin count is unchanged.
- review:
  - `winborder` is global: hover (`K`), `<C-l>` signature help, diagnostic floats, PackUI and
    blink's windows become rounded. Snacks floats with `border = true` read `winborder` and
    were already rounded (log row 2), so they look the same.
  - Completion keys change: `<Tab>`/`<S-Tab>` navigate today (README.md:19); with `super-tab`,
    `<Tab>` accepts and `<C-n>`/`<C-p>` navigate. The vim side's `<Tab>` (`vimrc:446`, coc confirm)
    also accepts, so the two match. When no menu or snippet is active, `<Tab>` falls back to a tab.
  - `<C-k>` becomes "toggle signature" in insert mode; the existing `<C-k>` (`keymaps.lua:20`) is
    normal/visual only (log row 15).
  - Signature help: lsp_signature also showed the window when moving inside an argument list
    without typing; blink opens it on trigger characters. `<C-k>` and `<C-l>` show it on demand.
  - Treesitter: a filetype not in the list gets no tree-sitter highlighting until `:TSInstall`;
    the list is seeded from everything arborist auto-installed here. `typescriptreact` → `tsx`
    and `terraform-vars` → `terraform` resolve through nvim-treesitter's `plugin/filetypes.lua`
    (`vim.treesitter.language.register`), as arborist's `registry.lua` did before; core Neovim
    has neither mapping.
  - Bundled languages: installing lua/vim/markdown/… through nvim-treesitter puts its parsers
    ahead of the bundled ones on the runtimepath; the queries and parsers then come from the same
    revision, which is what `:TSUpdate` keeps in sync.
  - First start on a new machine: parser install and blink's binary download are asynchronous;
    buffers opened before they finish lack highlighting or use the Lua matcher once. Accepted.
- security: Two download-and-run paths: blink's prebuilt binary (GitHub release of the pinned
  tag; v1.10.2 publishes a `.sha256` per asset) and nvim-treesitter's parser builds
  (`curl`/`tar` + `cc`, revisions pinned in its `parsers.lua`). arborist already cloned and built
  grammars, so the second is not new. Both plugin revisions are pinned in `nvim-pack-lock.json`.
  No user input reaches a shell.
- errors / leaks:
  - ui2 stays behind `pcall`; `vim.notify` falls back to the built-in message area if it fails.
  - blink's binary download failure falls back to the Lua matcher with a warning.
  - `vim.treesitter.start` is in `pcall`; indent is set only on success.
  - A failed parser build fails Task 6 step 8 or `:checkhealth`; either stops the task.
  - `vim.pack.del` reports "Some plugins are active and were not deleted" instead of failing
    silently; running it in a fresh session after the spec is removed avoids that path.
- migrations: Local data only. Task 6 order: spec removed (2) → arborist deleted in a fresh
  session (6) → its state deleted (7) → nvim-treesitter installs (8). Across tasks, blink.cmp
  (4) lands before lsp_signature goes (5), so signature help is never missing.
- concurrency: Parser install is asynchronous; the headless install waits on it (`:wait`).
  Capabilities: deleting `init.lua:337-341` leaves `plugin/blink-cmp.lua` as the only writer to
  `vim.lsp.config['*'].capabilities`.
- contract: Breaking commits (`!` plus a `BREAKING CHANGE:` footer):
  - notifier: `<leader>tn` removed, `<leader>sn` re-targeted;
  - blink.cmp: insert-mode `<Tab>` changes from "next item" to "accept", `<C-k>` added;
  - treesitter: `:ArboristUpdate` and friends replaced by `:TSUpdate`/`:TSInstall`, and
    parsers no longer install on file open.

  Borders and lsp_signature removal are not breaking.
- arch: Options in `lua/options.lua`, autocmds in `lua/autogroups.lua`, keymaps in
  `lua/keymaps.lua`, plugin list and setup in `init.lua`. vim/nvim parity (`vimrc:465-472`)
  improves for `<leader>sn` and `<Tab>`.
- perf: blink's Rust matcher replaces mini.completion's Lua filtering; one `FileType` autocmd
  replaces arborist's. No per-keystroke work is added by the config itself.
- tests: Three bats suites touch this config and run in Task 7. `theme-family-resolvers.bats`
  starts the full config headless, so a startup error from any task fails it. Everything else is
  checked headless where Neovim allows (window config, messages, lockfile, two `:checkhealth`
  reports, the LSP client's capabilities, highlighter/indent state, the update hook); the
  interactive checks are listed as manual.
- config: tree-sitter-cli is a global mise pin. Both arborist (whenever Neovim lacks WASM support,
  as here — every parser on disk is a native `.so`) and nvim-treesitter need a C compiler to
  build parsers, so the requirement is not new; every host this repo targets has `cc`. blink needs
  `curl` and `git`, already required by vim.pack.
- privacy / a11y / i18n: N/A — no personal data, no locale text, no UI beyond borders, menus
  and highlighting.
- observability: notifications become ui2 messages (4 s timeout, `:messages` history); ERRORs
  from `pack-ui.lua:561`/`:681` and blink's fallback warning stay visible there. Health is
  visible through `:checkhealth blink.cmp` and `:checkhealth nvim-treesitter`.

## Rollback / abort

Each concern is one commit touching only editor config. `git revert <sha>` restores it; the next
nvim start reinstalls any removed plugin from the restored `vim.pack.add` list and lockfile.
Revert in reverse landing order. For the treesitter commit, also empty
`~/.local/share/nvim/site/{parser,queries}/` so arborist rebuilds its own. Abort points: Task 4
stops if `:checkhealth blink.cmp` reports ERROR; Task 6 stops before step 9 if step 8 or
`:checkhealth` fails, reverting steps 2–5 and reporting the error. If ui2 misbehaves, deleting
`init.lua:27` disables it without touching the other tasks.

## Open questions & accepted risks

- Default chosen, say if you want otherwise: completion docs popup shows automatically
  (`auto_show = true`, today's behaviour). The article turns it off.
- Default chosen: no `friendly-snippets`. The `snippets` source then offers only LSP-provided
  snippets.
- Default chosen: blink's cmdline completion stays on; checked manually under ui2 in Task 4.
- Decision recorded: `nvim-treesitter-textobjects` is left out (duplicates mini.ai).
- Accepted risk: blink's signature help and ui2 are marked experimental upstream.
- Accepted risk: notifications lose stacking and the history picker; `:messages` is the history.
- Accepted risk: a language not in the parser list has no tree-sitter highlighting until
  `:TSInstall <lang>` is run and the list is updated.
- Accepted risk: nvim-treesitter's indent is marked experimental upstream, as arborist's was.
