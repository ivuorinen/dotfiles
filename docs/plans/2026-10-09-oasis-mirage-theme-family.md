# Plan: Oasis Mirage theme family

Date: 2026-10-09
Status: Implemented (approved 2026-10-09); upstream pinned at `a3ef178f`

> **Style switched to Abyss (2026-10-09).** The family now uses Oasis **Abyss** (dark and light intensity 3) in place
> of Mirage, built by the same role map and process at the same upstream commit. Abyss Dark's tmTheme carries the same
> diff-foreground fix. Two Abyss Light 3 keys miss AA on `#d8d8d8` and are darkened in lightness only: `theme_accent`
> `#31732b` → `#2e6b28` and `syntax_comment` `#625f54` → `#615e54` (NOTICE lists every local change). The rest of this
> plan describes the original Mirage build.

## Implementation deviations

- **Role map.** The table below is the draft. The final map gives each Catppuccin role one
    upstream `lua-theme` key, the same in both modes. It lives in the header of
    `config/theme/palettes.d/oasis/light/starship.toml`. Changes from the draft: rosewater is `syntax_func`
    (upstream's cursor `#817613` is 3.94:1 on light). Flamingo is `syntax_regex` and maroon `syntax_string`, so
    the reds stay distinct. Peach is `bright_yellow` and lavender `syntax_builtin_const`. Subtext1/0 are
    `syntax_bracket`/`syntax_comment` (dark subtext0 at 4.97:1). Overlays are `fg_inlay`/`fg_dim`/`fg_muted`,
    and surface2 is `hint_bg`.
- **Derivation source.** Palette files take their text from the kanagawa sibling and each colour's role from the
    catppuccin sibling at the same position, because kanagawa reuses hexes across roles. `tmux.thm.conf` maps
    by `@thm_<role>` key, and starship by palette key.
- **fzf** is derived through the role map like every other palette, not copied from upstream. Upstream's
    `hl+` (`#666666` dark, `#9fe0d7` light) would fail the contrast test.
- **Vim** schemes and airline themes derive from the catppuccin ones. Those use only the 26 role colours and
    no hard-coded cterm numbers, so no cterm recompute was needed.
- **WezTerm** uses inline Lua tables (task 7's fallback), not `color_scheme_dirs`. The resolver test asserts
    that every returned scheme is registered in `config.color_schemes`, which a scheme directory cannot
    satisfy. Upstream's `tab_bar` block is dropped because the tab bar is disabled.
- **bat tmThemes** are re-indented from tabs to spaces for `.editorconfig`. The dark one's three diff
    foregrounds (upstream: background shades at 1.32–1.48:1) use Mirage Dark green/red/blue. The user chose
    patching over exempting. NOTICE lists the values.
- **Tests.** The kanagawa Lotus wezterm contrast section now ends at its table's closing brace. The oasis
    tables sit between it and the old end marker.

## Goal

Add [oasis.nvim](https://github.com/uhs-robert/oasis.nvim) **Mirage** as a third theme family (`oasis`) beside
`catppuccin` and `kanagawa`, covering every app kanagawa covers. Dark mode uses Mirage Dark and light mode uses Mirage
Light at intensity 3. Then make `oasis` the active family.

## Decisions taken (from the user, this session)

- Family name `oasis`, style **Mirage** for both modes.
- Light intensity **3** (upstream default). Every derived and vendored light file uses the `light/3` variant.
- `config/theme/family` becomes `oasis`. Kanagawa and Catppuccin stay switchable.
- **Full parity** with kanagawa: use upstream `extras/` where its format fits this repo, and derive the rest from a
    colour role map, the way kanagawa did.

## Scope & constraints

The family layer already exists (`_theme_family`, `_palette`, `_link_palette`, the per-family `palettes.d` tree, and
family-aware readers in nvim, vim, wezterm and fish). This change adds data and branches only; no orchestrator code
changes.

Touches: `config/theme/{family,palettes.d/oasis/**,CLAUDE.md}`, `config/bat/themes/`, `config/fish/themes/`,
`config/nvim/{init.lua,nvim-pack-lock.json,README.md,CLAUDE.md}`, `config/vim/{vimrc,colors,autoload/airline/themes}`,
`config/wezterm/{wezterm.lua,colors/}`, `config/television/themes/`, `config/cosmic-desktop/{themes,README.md}`,
`tests/theme-{palettes,handlers,family-resolvers,contrast}.bats`, `NOTICE`, `graphify-out/`.

Must not change:

- `config/theme/{apply,watcher,_lib.sh}` and every `handlers.d/*`. Handlers resolve through `_palette`, so a new family
    needs no handler edits. If one turns out to need an edit, that is a defect in the family layer: stop and report it.
- `theme-mode`'s public output.
- The kanagawa and catppuccin files.
- `docs/audit/findings/resolved.jsonl` (append-only).

### What upstream `extras/` supplies, per app

| App                                                           | Upstream extra                         | Use                                                            |
|---------------------------------------------------------------|----------------------------------------|----------------------------------------------------------------|
| bat, yazi syntax                                              | `bat/themes/{dark,light/3}/*.tmTheme`  | **Vendor** unmodified except the `name` field                  |
| wezterm                                                       | `wezterm/themes/{dark,light/3}/*.toml` | **Vendor** into `config/wezterm/colors/` (see task 7)          |
| fzf                                                           | `fzf/themes/{dark,light/3}/*.sh`       | **Copy colours** into the repo's `fzf.sh`/`fzf.fish` shape     |
| nvim                                                          | the plugin itself                      | `vim.pack` + `setup { style = 'mirage', light_intensity = 3 }` |
| starship, tmux, yazi                                          | present, different key schema          | **Derive** from the catppuccin sibling via the role map        |
| eza, gitui, gh-dash, television, dircolors, fish, vim, COSMIC | none                                   | **Derive** via the role map                                    |

Upstream tmux uses `@thm_core`/`@thm_orange`/`@thm_indigo`. The repo's tmux palettes drive the catppuccin/tmux plugin's
`@thm_bg`/`@thm_peach`/`@thm_mauve`… keys. The starship and yazi extras are palette-only or flavour files, not the
repo's full configs. So none of these three can be dropped in as-is.

### Colour role map (drives every derived file)

Source of truth: upstream `extras/lua-theme/themes/dark/oasis_mirage.lua` and `…/light/3/oasis_mirage.lua`. Values
below were read from those files this session. The neutral ramp (surface0–2, overlay0–2, subtext0–1) is filled in task 1
from the same files plus the upstream tmux extra's surface/overlay keys, and is not guessed here.

| Catppuccin role         | Oasis role                                    | Mirage Dark                       | Mirage Light 3                    |
|-------------------------|-----------------------------------------------|-----------------------------------|-----------------------------------|
| base / mantle / crust   | `bg_core` / `bg_crust` / `bg_shadow`          | `#111C22` / `#0D161C` / `#0B1318` | `#d8f2ef` / `#d2f0ed` / `#cdeeea` |
| text                    | `fg_core`                                     | `#F5F5DC`                         | `#181811`                         |
| red / maroon / flamingo | `red` / `bright_red` / `bright_red`           | `#FF7979` / `#FFA0A0` / `#FFA0A0` | `#b61212` (all three)             |
| peach / yellow          | `theme_secondary` / `yellow`                  | `#F8B471` / `#F0E68C`             | `#703c08` / `#635c21`             |
| green / teal            | `green` / `bright_cyan`                       | `#7FCF78` / `#8AD3BE`             | `#396535` / `#366356`             |
| sky / sapphire / blue   | `bright_blue` / `theme_primary` / `blue`      | `#87CEEB` / `#69C3AA` / `#81C0FF` | `#23617a` / `#235547` / `#145ca3` |
| lavender / mauve / pink | `bright_magenta` / `magenta` / `theme_accent` | `#D2ADFF` / `#C695FF` / `#D2ADFF` | `#7725db` / `#7824db` / `#48039b` |

Oasis has fewer distinct hues than Catppuccin's fourteen, so several roles share a value (accepted risk below).

## Tasks

1. **Role map + scratch generator.** Fetch both upstream `lua-theme` files and the tmux extras. Complete the neutral
    ramp in the table above, then write a throwaway substitution script in the session scratchpad (not committed) that
    maps each catppuccin hex to its oasis value, case-insensitively, and fails on any catppuccin hex left unmapped. Put
    the final table in the header comment of `palettes.d/oasis/light/starship.toml`, as kanagawa does.
    Verify: the script reports zero unmapped catppuccin colours across all inputs.

2. **`palettes.d/oasis/{dark,light}/`.** Generate `starship.toml` (palette `oasis_mirage_dark` /
    `oasis_mirage_light_3`), `eza.yml`, `gitui.ron`, `yazi.toml`, `gh-dash.theme.yml`, `television.toml`, `dircolors`
    (`38;2;R;G;B` triplets remapped), `tmux.conf` and `tmux.thm.conf` (**all** `@thm_*` keys, same ordering as kanagawa).
    `fzf.sh` and `fzf.fish` take upstream's fzf colours verbatim. `bat.theme` holds `Oasis Mirage Dark` /
    `Oasis Mirage Light 3`. Each file keeps its sibling's structure and gets the "derived from … by the colour-role map
    in docs/plans/2026-10-09-oasis-mirage-theme-family.md" header.
    Verify: `tests/theme-palettes.bats` (completeness, TOML/YAML/tmux parse, bat.theme → vendored tmTheme).

3. **bat + yazi tmTheme.** Vendor upstream `oasis_mirage_dark.tmTheme` and `light/3/oasis_mirage_light_3.tmTheme` as
    `config/bat/themes/Oasis Mirage Dark.tmTheme` / `Oasis Mirage Light 3.tmTheme`, editing only the `name` field to
    match `bat.theme`. The yazi handler links them by that name automatically, and `.gitignore`'s
    `config/yazi/*.tmTheme` already covers the links.
    Verify: `bat cache --build && bat --list-themes` lists both. The palettes test's "bat.theme names a vendored
    tmTheme" passes.

4. **fish.** `config/fish/themes/oasis-aa.theme` with `[dark]` and `[light]` sections derived from
    `kanagawa-aa.theme` via the role map. The `-aa` suffix is required: `__dotfiles_theme_name` and `handlers.d/fish`
    resolve `<family>-aa.theme`.
    Verify: `fish-validate` skill. `fish -c 'DOTFILES_THEME_FAMILY=oasis __dotfiles_theme_name'` prints `oasis-aa`.

5. **Neovim.** Add `{ src = 'https://github.com/uhs-robert/oasis.nvim', name = 'oasis' }` to `vim.pack`. Add
    `require('oasis').setup { style = 'mirage', light_intensity = 3 }`, with the keys quoted from upstream's README
    default-options block. Replace the binary at `init.lua:676` with a family → colorscheme table
    (`{ kanagawa = 'kanagawa', oasis = 'oasis' }`, defaulting to `catppuccin`). Mode switching stays with
    auto-dark-mode, because oasis follows `vim.o.background`. `nvim-pack-lock.json` is updated by `vim.pack`, not by
    hand.
    Verify: `stylua --check`. `DOTFILES_THEME_FAMILY=oasis nvim --headless '+lua print(vim.g.colors_name)' +q` prints
    an `oasis` name in both `bg=dark` and `bg=light`.

6. **Vim.** Derive `config/vim/colors/oasis_mirage_dark.vim` / `oasis_mirage_light.vim` from `kanagawa_wave.vim` /
    `kanagawa_lotus.vim` by remapping the colours (kanagawa value → role → oasis value), with cterm numbers recomputed
    as the nearest xterm-256. Derive the airline themes the same way. Add
    `'oasis': {'dark': 'oasis_mirage_dark', 'light': 'oasis_mirage_light'}` to the `s:schemes` dict in `vimrc`.
    Verify: `tests/theme-family-resolvers.bats` new case. `vim -Nu config/vim/vimrc` per mode shows no `E185`.

7. **WezTerm.** Vendor the two upstream TOML schemes into `config/wezterm/colors/` and point `config.color_scheme_dirs`
    there. This is WezTerm's documented mechanism, confirmed this session at wezterm.org/config/appearance.html.
    Add `oasis = { dark = …, light = … }` to the `schemes` table. Before relying on the scheme name, confirm how WezTerm
    names a TOML scheme that has no `[metadata] name`. Upstream files carry only a `## name:` comment. If WezTerm names
    it by something other than the file stem, fall back to inline Lua tables in `color_schemes`, as kanagawa does.
    Verify: `tests/theme-family-resolvers.bats` wezterm case extended with
    `oasis=<dark>|<light>`, and a manual appearance flip.

8. **Television + COSMIC.** `config/television/themes/oasis-mirage-{dark,light-3}.toml` derived from the kanagawa pair.
    `config/cosmic-desktop/themes/cosmic-term/oasis-mirage-{dark,light-3}.ron` and
    `cosmic-settings/oasis-mirage-{dark,light-3}+round.ron` derived from the kanagawa files, with the accent set to
    `theme_primary`. Add an Oasis line to the README's "repo-derived, not vendored" section.
    Verify: the handlers test that checks the television config names the oasis theme. RON bracket and quote balance.
    COSMIC import is manual (Linux only), recorded as unverified on macOS.

9. **Tests.** `theme-palettes.bats`: assert `oasis` exists. `theme-handlers.bats`: add "oasis resolves every palette",
    mirroring the kanagawa case. `theme-family-resolvers.bats`: vim, nvim and wezterm oasis cases, with nvim skipping
    when `oasis.nvim` is not installed, the same as kanagawa. `theme-contrast.bats`: add
    "oasis mirage light: every non-muted foreground reaches WCAG AA on #d8f2ef" and the dark counterpart on `#111C22`,
    reusing the existing helper over the oasis light/dark file lists. Add a planted-failure control for each.
    Verify: each new test fails when its target file is removed, or when a low-contrast hex is planted.

10. **Contrast remediation (conditional).** Upstream light styles target 5.8:1 for syntax and terminal colours, but
    `fg_muted`/`fg_dim`/`fg_inlay` and derived UI roles are not covered by that target. Any foreground the task 9 test
    fails is darkened by HSL lightness only (the Latte/Lotus method) in the derived files, and recorded in the
    starship header table. Vendored files (tmTheme, wezterm TOML) that fail are recorded instead of edited, so they
    stay byte-comparable with upstream. If any fail, stop and ask.
    Verify: task 9's contrast tests pass.

11. **Docs + NOTICE.** `config/theme/CLAUDE.md`: list `oasis` in the family list and the family file example.
    `config/nvim/{README,CLAUDE}.md`: the plugin and the selector table. `NOTICE`: an "Oasis theme assets — MIT,
    Copyright (c) 2025 Robert" block (licence read this session), listing vendored files and derived trees.
    Verify: `yarn lint` (includes `lint:ec`, markdown 120-col).

12. **Activate + refresh.** Write `oasis` to `config/theme/family`. Run `config/theme/apply dark` then `light`, and
    check that `~/.config/{starship.toml,eza/theme.yml,gitui/theme.ron,yazi/theme.toml}` resolve into `oasis/<mode>/`.
    Refresh the graph: `graphify update .`, `scripts/graphify-tests.py`, `graphify export html`.
    Verify: `yarn test` and `yarn lint` pass with zero warnings. The theme log shows no handler errors.

Commits, grouped with `git-hunk`: `feat(theme): add oasis mirage palettes` (tasks 1–2, 10),
`feat(bat): vendor oasis mirage tmThemes`, `feat(fish): …`, `feat(nvim): …`, `feat(vim): …`, `feat(wezterm): …`,
`feat(theme): oasis television and cosmic themes`, `test(theme): cover the oasis family`,
`docs(theme): …` + NOTICE, then `feat(theme): switch active family to oasis`, so a revert of the last commit restores
kanagawa alone.

## Adversarial hardening

- **complexity:** Examined whether any orchestrator or handler change is needed. None is, because `_palette` already
    resolves by family, so tasks touch data and selector tables only. Cut the kanagawa-style AA pass as a default task:
    upstream already targets 5.8:1. It stays as conditional task 10, driven by the test. Rejected yazi's native
    `[flavor] dark/light` mechanism because it would change the yazi handler for one family. WezTerm uses the
    first-class `color_scheme_dirs` instead of hand-converting TOML to Lua, with a named fallback.
- **review:** Edge cases examined: a fish theme filename without `-aa` silently fails resolution (pinned in task 4). A
    bat `name` field mismatch would make the yazi link and the bat state point at a missing theme (the palettes test
    catches it). The nvim selector at `init.lua:676` is binary and would send `oasis` to catppuccin (task 5). The light
    `ansi white` is dark (`#464621`), which is correct for light terminals and must not be "fixed".
- **security:** The trust boundary is vendored third-party files. tmTheme and TOML are data. Vim colour files are
    executed by vim, so they are derived from in-repo files rather than vendored, and none come from upstream. No new
    input reaches a shell sink: the family slug is already validated by `_theme_family` (`^[a-z0-9][a-z0-9-]*$` plus
    dir existence), and `oasis` passes it.
- **errors / leaks:** No new operations. Handler failure paths are unchanged. A missing oasis file unlinks instead of
    mixing families (existing behaviour, covered by tests). No resources acquired.
- **migrations:** N/A — no schema or data store. The only state change is the `family` file. Rollback is below.
- **concurrency:** N/A — no new shared state. `apply` already serialises family switches under `apply.lock`.
- **contract:** `config/theme/family` values are an informal public surface (the env seam). Adding `oasis` is
    additive. `theme-mode` output is unchanged.
- **arch:** Checked against `config/theme/CLAUDE.md` and `.claude/rules/theme-handler-contract.md`. The layout
    `palettes.d/<family>/<mode>/<app>` holds. Vendored files sit in their app dirs (bat, wezterm), as kanagawa's do.
- **perf:** One extra plugin load in nvim (`oasis.setup` runs every start, like kanagawa's). `bat cache --build` already
    rebuilds only when a tmTheme is newer. Negligible.
- **tests:** Every new test has a planted-failure control (task 9), so none is tautological. The nvim test skips without
    the plugin, the same as kanagawa; that skip is reported, not counted as a pass.
- **a11y:** Contrast is enforced by the computed WCAG test, not trusted from upstream's claim (tasks 9–10).
- **config / privacy / i18n / observability:** config — the `family` value change only. Privacy and i18n are N/A (no
    personal data, no locale text). Observability is N/A (the existing apply log covers handler failures).

## Rollback / abort

Before task 12, nothing is active: the oasis files are inert while `family` says `kanagawa`. After task 12, write
`kanagawa` back to `config/theme/family` and run `config/theme/apply "$(theme-mode)"`. Handlers relink to kanagawa and
remove oasis-only links. The activation is its own commit, so `git revert` of that commit does the same. Restart nvim.

## Open questions & accepted risks

- **Hue collisions:** Oasis has about 11 distinct accents against Catppuccin's 14, so lavender/pink (dark) and
    red/maroon/flamingo (light) share values. Accepted: the result is visually faithful to Mirage.
- **WezTerm TOML scheme naming** is unconfirmed (task 7). The fallback is defined, so this does not block.
- **COSMIC** cannot be verified on this macOS host. Accepted, as it was for kanagawa.
- **Upstream drift:** vendored files are pinned to the upstream commit read at implementation time. Record that SHA in
    NOTICE so a later refresh is a diff, not a guess.
- **nvim restart:** nvim reads the family only at startup (existing, documented behaviour).
