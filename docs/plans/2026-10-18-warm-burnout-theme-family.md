# Warm Burnout Theme Family Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add [warm-burnout](https://github.com/felipefdl/warm-burnout) as a fourth switchable theme family
(`theme warm-burnout`) covering every app the other families cover. `oasis` stays the default.

**Architecture:** Data and selector tables only. No orchestrator or handler change: `_palette` already resolves by
family. Upstream files are vendored where their format fits (bat tmTheme, vim colours, wezterm colours as Lua tables,
and the nvim plugin through `vim.pack`). Everything else is derived from the Catppuccin sibling through a colour-role map,
the same way oasis was built (`docs/plans/2026-10-09-oasis-mirage-theme-family.md`).

**Tech Stack:** bash, bats, Lua (nvim, wezterm), Vim script, TOML/YAML/RON data, python3 (contrast test).

**Spec:** the user's request in chat ("add it as one of the options", 2026-10-18). Precedent: the oasis plan above.

## Global Constraints

- Family slug `warm-burnout` (passes `_theme_valid_family`: `^[a-z0-9][a-z0-9-]*$`). `config/theme/family` stays `oasis`.
- Upstream pin: `felipefdl/warm-burnout@6e1f75fd769adf2ecd45ac1e46f7c7e705b2356c`, MIT, "Copyright (c) 2026 Felipe Lima".
- Display names: `Warm Burnout Dark` and `Warm Burnout Light`, the names upstream's tmThemes declare. No `AA` suffix
    (the oasis precedent: local contrast fixes keep the upstream name and are listed in NOTICE).
- File stems: `warm-burnout-dark` / `warm-burnout-light`. Vim names use underscores (`warm_burnout_dark`), because
    airline autoload function names cannot contain `-`.
- WCAG: every non-muted foreground reaches 4.5:1 on its background (dark `#1a1510`, light `#f5ede0`). Muted greys
    (the overlay roles and terminal bright-black) need 3:1. Fixes change HSL lightness only.
- Stage and commit only through `git-hunk`, with Conventional Commits, and only when the user authorises the commit.
- `.editorconfig` applies (2-space indents, LF, final newline; markdown wraps at 120 columns).

### Colour-role map (drives every derived file)

Each Catppuccin role takes one warm-burnout key. Values are from upstream `nvim/lua/warm-burnout/palette.lua` and
`vim/colors/*.vim`. Alpha values are pre-blended onto `bg`.

| Role      | Key (source)              | Dark      | Light     |
|-----------|---------------------------|-----------|-----------|
| rosewater | cursor                    | `#f5c56e` | `#8a6600` |
| flamingo  | tag                       | `#dc9e92` | `#8e4632` |
| pink      | keyword                   | `#ff8f40` | `#924800` |
| mauve     | number                    | `#d4a8b8` | `#7e4060` |
| red       | error                     | `#f49090` | `#b03434` |
| maroon    | member                    | `#ec9878` | `#883850` |
| peach     | operator                  | `#f29668` | `#8f4418` |
| yellow    | func                      | `#ffb454` | `#855700` |
| green     | string                    | `#b4bc78` | `#4d5c1a` |
| teal      | regex                     | `#96b898` | `#286a48` |
| sky       | type                      | `#90aec0` | `#285464` |
| sapphire  | decorator                 | `#e6c08a` | `#7a5a1c` |
| blue      | modified                  | `#73b8ff` | `#2868a0` |
| lavender  | property                  | `#deb074` | `#74501c` |
| text      | fg                        | `#bfbdb6` | `#3a3630` |
| subtext1  | fg_dim                    | `#ada69c` | `#5c5750` |
| subtext0  | comment                   | `#b4a89c` | `#544c40` |
| overlay2  | fg_gutter_active          | `#a59f96` | `#6a6258` |
| overlay1  | fg_gutter (blended)       | `#746f67` | `#8a8070` |
| overlay0  | vim LineNr (light: fixed) | `#6b6860` | `#938871` |
| surface2  | bg_search                 | `#4c4126` | `#e0c890` |
| surface1  | vim Visual                | `#2e3a41` | `#cfdae2` |
| surface0  | vim CursorLine            | `#222018` | `#ece4d6` |
| base      | bg                        | `#1a1510` | `#f5ede0` |
| mantle    | bg_dim                    | `#14120f` | `#ede6da` |
| crust     | bg_dim                    | `#14120f` | `#ede6da` |

`pink` is the family accent (tmux's active-window pill), as in oasis. Upstream's own `accent` is not mapped.

### Contrast fixes (computed this session; HSL lightness only)

| Colour                                 | Where                                       | Upstream  | Fixed     | Ratio        |
|----------------------------------------|---------------------------------------------|-----------|-----------|--------------|
| accent / warn, dark                    | vim, wezterm (`split`, `indexed[16]`), nvim | `#b8522e` | `#cd5d36` | 3.70 -> 4.50 |
| accent / warn, light                   | vim, wezterm, nvim                          | `#b8522e` | `#b04e2c` | 4.22 -> 4.55 |
| ANSI bright yellow (11), light         | vim, wezterm, nvim terminal colours         | `#9a7008` | `#8b6507` | 3.85 -> 4.56 |
| ANSI bright blue (12), light           | vim, wezterm, nvim terminal colours         | `#2870b0` | `#286faf` | 4.48 -> 4.54 |
| ANSI bright cyan (14), light           | vim, wezterm, nvim terminal colours         | `#208870` | `#1d7964` | 3.75 -> 4.55 |
| LineNr/NonText grey, light (muted 3:1) | vim (8 lines), overlay0                     | `#a89f8c` | `#938871` | 2.26 -> 3.01 |

Each changed vim line gets its `ctermfg`/`ctermbg` recomputed as the nearest xterm-256 index. The light ANSI whites
`#c0b8aa` (7) and `#faf6f0` (15) are fills on a light terminal and stay as they are, like oasis's dark light-mode white.

### Contrast test sets

- `WB_DARK_BG`: `#1a1510 #14120f #1f1d17 #222018 #23211b #2a2820 #2e3a41 #2e1a1c #1a242e #1e2a1c #2c3e52 #33393a
    #3a342a #4c4126`
- `WB_DARK_MUTED`: `#746f67 #6b6860 #686868`
- `WB_LIGHT_BG`: `#f5ede0 #ede6da #f0e8dc #ece4d6 #e2ecd8 #faf6f0 #dce4ec #f0d4d4 #cfdae2 #ddd6ca #c4d4e4 #e0c890
    #c0b8aa #e5e8e2 #e2dace #c5beb2 #ffffff`
- `WB_LIGHT_MUTED`: `#8a8070 #938871`

A hex the test flags may be moved into a BG set only when every use in that file is a background (`guibg`, `bg`,
`background`, a `*_bg` key). Anything else is fixed by the lightness rule and added to the fixes table.

## Review Focus

1. **`theme warm-burnout` on a host without warm-burnout's nvim plugin installed.** nvim must still start and fall back
    to oasis instead of raising "colorscheme not found". Task 4 step 4 adds the `pcall`. No bats case covers it,
    because an empty data dir would make `vim.pack` attempt a network install. The reviewer checks it by reading.
2. **An OS appearance flip in a running nvim on warm-burnout.** The scheme must follow `background` and must not stay
    on the variant it started with. Upstream sets a fixed `colors_name`, so the wrapper must own it. Pinned in Task 4
    (Normal bg asserted in both modes).
3. **A stale `~/.config/yazi/Warm-Burnout-*.tmTheme` link.** The yazi handler names the link from `bat.theme`, so the
    file name and the tmTheme `name` must agree byte for byte. Pinned in Task 1's handler test.
4. **A regression to upstream's accent through a future re-vendor.** Pinned by Task 1's planted-failure control
    (`#b8522e` must fail at 3.70:1).
5. **fish resolution silently failing.** `handlers.d/fish` needs `<family>-aa.theme`. Pinned in Task 2.

---

### Task 1: Palette tree, bat themes, tmux

**Files:**

- Create: `config/theme/palettes.d/warm-burnout/{dark,light}/` with the same 12 files as `palettes.d/oasis/<mode>/`
    (`bat.theme dircolors eza.yml fzf.fish fzf.sh gh-dash.theme.yml gitui.ron starship.toml television.toml tmux.conf
    tmux.thm.conf yazi.toml`).
- Create: `config/bat/themes/Warm Burnout Dark.tmTheme`, `config/bat/themes/Warm Burnout Light.tmTheme`, vendored
    unmodified from upstream `bat/`.
- Test: `tests/theme-palettes.bats`, `tests/theme-handlers.bats`, `tests/theme-contrast.bats`.

**Interfaces:**

- Produces: family dir `palettes.d/warm-burnout`. `bat.theme` holds `Warm Burnout Dark` / `Warm Burnout Light`.
    `television.toml` names `warm-burnout-dark.toml` / `warm-burnout-light.toml` (Task 6 creates those files).
    `tmux.thm.conf` sets all 26 `@thm_*` keys. Contrast helpers `WB_*` and `wb_palette_targets <mode>` in
    `theme-contrast.bats`, which later tasks extend.

- [ ] **Step 1: Write the failing tests**
    - `theme-palettes.bats`: extend the "at least … exist" test with `[ -d "$PD/warm-burnout" ]`.
    - `theme-handlers.bats`: `@test "handlers: warm-burnout resolves every palette"`, a copy of the oasis case with
        `DOTFILES_THEME_FAMILY=warm-burnout`, links ending `/warm-burnout/dark/starship.toml` and
        `/warm-burnout/dark/yazi.toml`, `-L` on `Warm-Burnout-Dark.tmTheme` and `Warm-Burnout-Light.tmTheme`, bat-theme
        `= "Warm Burnout Dark"`, and `grep -q "warm-burnout-dark.toml"` on the television config.
    - `theme-contrast.bats`: the `WB_*` sets above, `wb_palette_targets` (a copy of `oasis_palette_targets`), and
        `@test "warm burnout light: every non-muted foreground reaches WCAG AA on #f5ede0"` and
        `@test "warm burnout dark: every non-muted foreground reaches WCAG AA on #1a1510"` over the palette targets plus
        the matching tmTheme. Add `@test "warm burnout: the contrast check catches upstream's accent"`, which plants
        `#b8522e` and asserts status 1 with `*"#b8522e is 3.70:1"*` on `#1a1510`.

- [ ] **Step 2: Run them and confirm they fail.**
    Run: `scripts/bats-run.sh tests/theme-palettes.bats tests/theme-handlers.bats tests/theme-contrast.bats`. Expected:
    the new cases FAIL (the missing dir and files); the planted control passes.

- [ ] **Step 3: Generate the derived files** with a scratch script (in the scratchpad, not committed). For each mode,
    read `palettes.d/catppuccin/<mode>/*`. Replace each role hex (case-insensitive) with the map value, and each
    dircolors `38;2;R;G;B` triplet likewise. Exit non-zero on any hex outside the 26 roles except yazi's `#ffffff`. Then
    rewrite the header comments to the oasis wording ("Warm Burnout <Mode> — derived from ../../catppuccin/<mode>/<file>
    by the colour-role map in config/theme/palettes.d/warm-burnout/light/starship.toml."). Rename starship's palette to
    `warm_burnout_<mode>`. Point yazi's `syntect_theme` at `~/.config/yazi/Warm-Burnout-<Mode>.tmTheme`. Exceptions to
    the catppuccin source:
    - `tmux.conf` (both modes): take the oasis sibling's text and rewrite `oasis` → `warm-burnout` in its path. Its
        date/time comment becomes "Date/time uses sky, matching the other derived families".
    - `tmux.thm.conf` (both modes): oasis's key order, with values from the map.
    - `bat.theme`: the display name; `television.toml`: the oasis text with the theme file renamed.
    - `light/starship.toml` header: the role table above (role, key, light value) plus the contrast-fix lines, as in
        oasis.

- [ ] **Step 4: Vendor both tmThemes** with `cp` from the scratchpad upstream checkout. Do not modify them: both pass
    with `#746f67`/`#8a8070` muted.

- [ ] **Step 5: Run the tests and confirm they pass.** Same command. Expected: PASS. Then `mise exec --
    editorconfig-checker` on the new files.

- [ ] **Step 6: Commit** (on the user's go-ahead): `git-hunk commit … -m "feat(theme): add the warm-burnout palette
    tree"`.

### Task 2: fish

**Files:** Create `config/fish/themes/warm-burnout-aa.theme`. Test: `tests/theme-family-resolvers.bats`,
`tests/theme-contrast.bats`.

**Interfaces:** Consumes the role map. Produces the `[light]` / `[dark]` / `[unknown]` sections that `handlers.d/fish`
selects by `<family>-aa`.

- [ ] **Step 1: Failing tests.** In `theme-family-resolvers.bats`, add `@test "fish: warm-burnout resolves to its -aa
    theme"`, mirroring the env-override case and expecting `warm-burnout-aa`. In the Task 1 contrast tests, add
    `"config/fish/themes/warm-burnout-aa.theme@"$'\n'"[light]"$'\n'"@"$'\n'"[dark]"$'\n'` (light) and the
    `[dark]`…`[unknown]` slice (dark) as targets.
- [ ] **Step 2:** Run both files. Expected: the new cases FAIL.
- [ ] **Step 3: Derive** from `catppuccin-aa.theme` with the Task 1 script: `name: 'warm-burnout-aa'`, `preferred_background`
    set to `f5ede0` / `1a1510`, and a header comment in the oasis wording.
- [ ] **Step 4:** Run both files again, then `fish-validate`. Expected: PASS.
- [ ] **Step 5: Commit:** `feat(fish): add the warm-burnout theme`.

### Task 3: vim

**Files:**

- Create: `config/vim/colors/warm_burnout_dark.vim`, `warm_burnout_light.vim` (vendored from upstream `vim/colors/`).
- Create: `config/vim/autoload/airline/themes/warm_burnout_dark.vim`, `warm_burnout_light.vim` (derived from
    `catppuccin_mocha.vim` / `catppuccin_latte.vim` with the Task 1 script).
- Modify: `config/vim/vimrc` (`s:schemes`, around line 262).
- Test: `tests/theme-family-resolvers.bats`, `tests/theme-contrast.bats`.

- [ ] **Step 1: Failing tests.** `@test "vim: warm-burnout maps dark/light to warm_burnout_dark/light"`, the oasis
    case with the new names. Add the four vim files to the matching contrast tests. Run them. Expected: FAIL.
- [ ] **Step 2: Vendor the colour files.** Set `g:colors_name` to the underscore name, prepend a header naming the
    upstream path and pin, and apply the vim rows of the fixes table with recomputed cterm indices. Before
    committing, confirm the files hold only `hi`, `let`, `set`, `if`/`endif` and `syntax reset` lines:
    `rg -v '^(hi |let |set |"|\s*\\|if |endif|syntax reset|$)'` must print nothing.
- [ ] **Step 3: Wire vimrc:** `\ 'warm-burnout': {'dark': 'warm_burnout_dark', 'light': 'warm_burnout_light'},`.
- [ ] **Step 4:** Run the resolver and contrast tests. Expected: PASS.
- [ ] **Step 5: Commit:** `feat(vim): add the warm-burnout colour schemes`.

### Task 4: nvim

**Files:**

- Modify: `config/nvim/init.lua`: add `{ src = 'https://github.com/felipefdl/warm-burnout', name = 'warm-burnout' }` to
    `vim.pack.add` (line ~61), add a `-- ── Warm Burnout ──` block after Oasis, and add
    `['warm-burnout'] = 'warm-burnout'` to `family_schemes`. Update `config/nvim/nvim-pack-lock.json` by running nvim
    once, so `vim.pack` writes it.
- Create: `config/nvim/colors/warm-burnout.lua`, the wrapper.
- Test: `tests/theme-family-resolvers.bats`.

**Interfaces:** Produces the colorscheme `warm-burnout`, one `colors_name` for both modes, as kanagawa and oasis have.

- [ ] **Step 1: Failing test.** `@test "nvim: warm-burnout follows background in one colorscheme"`, a copy of the
    oasis case. Skip unless `$data/site/pack/*/opt/warm-burnout` exists. Assert `nvim_scheme warm-burnout dark` and
    `light` both equal `warm-burnout`, and assert the Normal bg is `1a1510` (dark) and `f5ede0` (light). Run it.
    Expected: FAIL. If the plugin is not installed yet, it is SKIP; install it by starting nvim once, then re-run.
- [ ] **Step 2: rtp.** Upstream keeps the plugin in its `nvim/` subdirectory (its README: "add the `nvim/` directory
    to your runtimepath"). In the Warm Burnout block, append `<plugin path>/nvim` to `runtimepath`. Take the path from
    `vim.pack.get`, and read `:h vim.pack.get()` in this session to confirm the returned field before using it.
- [ ] **Step 3: The wrapper** `colors/warm-burnout.lua`. Pick the variant from `vim.o.background`. Before
    `require('warm-burnout').load(variant)`, override `palette.dark.accent`/`warn` and `palette.light.accent`/`warn`
    with the fixed values. After the load, set `vim.g.colors_name = 'warm-burnout'`, so a `background` change reloads
    this file rather than the fixed-variant one. In light mode, also set `vim.g.terminal_color_11`, `_12` and `_14` to
    the fixed values.
- [ ] **Step 4: Fallback.** In `apply_family_scheme`, call `vim.cmd.colorscheme` through `pcall`. On failure, fall
    back to `oasis`, so a host without the plugin still gets a theme.
- [ ] **Step 5:** Run the resolver file and `lua-format`. Expected: PASS (or SKIP, reported as a skip).
- [ ] **Step 6:** Update `config/nvim/README.md` (plugin table and family list) and `config/nvim/CLAUDE.md` (UI row).
- [ ] **Step 7: Commit:** `feat(nvim): add the warm-burnout colorscheme`.

### Task 5: wezterm

**Files:** Modify `config/wezterm/wezterm.lua` (after the oasis tables, around line 236). Test:
`tests/theme-family-resolvers.bats`, `tests/theme-contrast.bats`.

- [ ] **Step 1: Failing tests.** Add `'warm-burnout'` to the stub loop and assert
    `*"warm-burnout=Warm Burnout Dark|Warm Burnout Light"*`. Add the slices
    `"config/wezterm/wezterm.lua@local warm_burnout_dark = {@"$'\n}\n'` and the light one to the contrast tests. Run
    them. Expected: FAIL.
- [ ] **Step 2:** Add `local warm_burnout_dark` / `warm_burnout_light` tables, converted from upstream
    `wezterm/*.toml` (foreground, background, cursor, selection, scrollbar_thumb, split, ansi, brights, indexed). Drop
    `tab_bar`, as oasis does. Apply the wezterm rows of the fixes table. Register them in `config.color_schemes` and
    add `['warm-burnout'] = { dark = 'Warm Burnout Dark', light = 'Warm Burnout Light' }` to `schemes`.
- [ ] **Step 3:** Run the tests and `lua-format`. Expected: PASS.
- [ ] **Step 4: Commit:** `feat(wezterm): add the warm-burnout colour schemes`.

### Task 6: television and COSMIC

**Files:**

- Create: `config/television/themes/warm-burnout-{dark,light}.toml`, derived from `catppuccin-{mocha,latte}-mauve.toml`.
- Create: `config/cosmic-desktop/themes/cosmic-term/warm-burnout-{dark,light}.ron` and
    `cosmic-settings/warm-burnout-{dark,light}+round.ron`, derived from the Catppuccin Mocha/Latte blue-accent files.
    The accent is `pink` (keyword).
- Modify: `config/cosmic-desktop/README.md`: a "Warm Burnout (repo-derived)" section like the Oasis one.
- Test: `tests/theme-contrast.bats`.

- [ ] **Step 1:** Add the television theme and the cosmic-term file to each mode's contrast test. Run. Expected: FAIL.
- [ ] **Step 2:** Derive the four files with the Task 1 script. Set `name:` to the display names.
- [ ] **Step 3:** Run the contrast tests and confirm the brackets and quotes in each RON file balance. Expected: PASS.
    The COSMIC import itself is manual and stays unverified.
- [ ] **Step 4: Commit:** `feat(theme): add warm-burnout television and COSMIC themes`.

### Task 7: Docs, NOTICE, graph, full gate

**Files:** Modify `NOTICE`, `config/theme/CLAUDE.md` (family list on line 39), and `tests/dfm.bats` (line 116).

- [ ] **Step 1:** In `tests/dfm.bats`, add `[[ "$output" == *"warm-burnout"* ]]`. Run it. Expected: PASS (it lists
    directories).
- [ ] **Step 2: NOTICE.** Add a "Warm Burnout theme assets -- MIT" block, shaped like the Oasis one: copyright, URL
    and pin. List the vendored files (two tmThemes unmodified, two vim colour files and the wezterm tables), every row
    of the fixes table, the vim rename, and the derived trees with a pointer to the role map.
- [ ] **Step 3:** `config/theme/CLAUDE.md`: list `warm-burnout` among the families.
- [ ] **Step 4: Full gate.** Run `mise run lint` and `mise run test`. Expected: zero errors, zero warnings, every
    failure fixed. Report the skips by name.
- [ ] **Step 5: Manual check.** Run `theme warm-burnout`, flip the OS appearance, and check tmux, starship, fzf, bat,
    eza, wezterm, vim and nvim in both modes. Then run `theme --reset`, which returns to oasis.
- [ ] **Step 6: Refresh the graph:** `graphify update .`, `scripts/graphify-tests.py`, `graphify export html`.
- [ ] **Step 7: Commit:** `docs(theme): document the warm-burnout family`.

## Rollback

Nothing activates by default. `theme --reset` returns a host to oasis, and reverting the branch removes the family.
A saved `choice` of `warm-burnout` left after removal is skipped by `_theme_family`, which falls back to the tracked
default.
