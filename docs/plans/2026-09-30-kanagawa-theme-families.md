# Plan: Kanagawa theme and per-family palettes

Date: 2026-09-30
Status: IMPLEMENTED (approved 2026-09-30; uncommitted at time of writing)
Branch: `feat/theme-kanagawa`

## Implementation deviations

Where the build departed from the tasks below, and why:

- **Task 4b: the tmux reload is asynchronous.** A full `tmux.conf` reload measured 10.7 s on the
  target machine (TPM re-runs every plugin), past `apply`'s 5 s handler budget; the first live
  flip timed out (`exit=124`). The perf lens's "well inside the budget" was wrong. The handler now
  hands the reload to the server (`tmux run-shell -b`, re-invoking itself with `--now`) and
  returns at once. A failed background reload shows a tmux message instead of reaching
  `apply`'s log.
- **Task 4b tests start tmux panes with `sleep`, not a shell.** A shell pane runs shell init,
  which spawns the theme watcher with the test's environment. A manual check did exactly that
  and applied `catppuccin` to the real state once; it was re-applied and the tests were fixed.
- **Task 9: the vendored `kanagawa.vim` was fixed.** Upstream sets `g:colors_name` before
  `hi clear`, which unsets it, so the scheme loaded nameless. The Wave copy sets it after.
- **Task 9: accent fills get base-coloured text.** Wave's dark-ink-on-accent groups (`IncSearch`,
  `Todo`) inverted to about 1.9:1 in Lotus. Such pairs now use the AA-darkened accent as the fill
  and `#f2ecbc` as the text, so they are ≥4.5:1 by construction. The contrast test found this.
- **Task 10: the WezTerm schemes are inline** in `wezterm.lua`, not in `config/wezterm/colors/`.
  That avoids relying on WezTerm's `require` path, which was not verified.
- **Wave→Lotus pairing** for vim, bat and fish comes from upstream `lua/kanagawa/themes.lua`
  (wave vs lotus slot by slot), not only from the Catppuccin role map. `#54546d` (line numbers)
  maps to the muted overlay2 instead of upstream's 2.2:1 `lotusViolet1`.
- **Post-implementation audit fixes** (`/nitpicker audit changed-files`, 14 findings):
  - The Wave AA pass now covers every upstream Wave foreground below 4.5:1 on `#1f1f28`, not only
    the terminal red: autumnRed `#c34043` → `#cf6769`, samuraiRed `#e82424` → `#ed4f4f`, dragonBlue
    `#658594` → `#6b8b9a`, in nvim, vim, bat and wezterm. `tests/theme-contrast.bats` checks all Wave
    files the way it checks Lotus.
  - The muted comment/overlay greys (3:1) are documented as a deliberate exception below WCAG 1.4.3,
    not as AA compliance; the a11y lens line above overstated it.
  - The kanagawa lightline schemes were dropped (vim loads airline) and `palettes.d/.gitkeep` removed,
    reversing task 2's "keep" note.
  - vim follows a family switch within 3 s; nvim needs a restart (documented).
- **The yazi tmTheme links are named after `bat.theme`** (`Kanagawa-Wave.tmTheme`,
  `Catppuccin-Mocha.tmTheme`), so the Catppuccin yazi palettes' `syntect_theme` case changed
  (`-mocha` → `-Mocha`) and `.gitignore` now ignores `config/yazi/*.tmTheme`.

## Goal

Make Kanagawa (Wave for dark, AA-hardened Lotus for light) the active theme across every themed app, and restructure
`config/theme/palettes.d/` into `palettes.d/<family>/<dark|light>/<app>.<ext>` so several theme families coexist.
A tracked selector file picks the active family. A palette that the active family does not ship is never linked,
and any link left over from a previous family is removed, so palettes never mix.

## Decisions taken (from the user, this session)

- Dark = Kanagawa **Wave**, light = Kanagawa **Lotus**.
- Selector = tracked file `config/theme/family` (one word, `kanagawa`). Catppuccin stays available by editing it and
  running `config/theme/apply "$(theme-mode)"`.
- Layout = `palettes.d/<family>/<mode>/<app>.<ext>` (user refinement: mode directories, so file names drop the variant).
- Lotus gets the same WCAG AA treatment Catppuccin Latte got, enforced by a bats contrast test.
- Scope = everything: palettes.d apps, nvim, vim, wezterm, fish, bat + yazi tmTheme, television, gitui, gh-dash, fzf,
  dircolors, COSMIC.

## Scope & constraints

Touches: `config/theme/{_lib.sh,family,handlers.d/*,palettes.d/**}`, `config/{nvim,vim,wezterm,fish,bat,yazi,
television,cosmic-desktop}`, `tests/theme-*.bats`, and every doc and rule that names the palette path:
`.claude/rules/theme-handler-contract.md`, `.claude/skills/theme-handler-scaffold/SKILL.md`, `config/theme/CLAUDE.md`,
`docs/audit/arch-profile.md`, `.prettierignore`, `.mega-linter.yml`, `.gitignore`, `NOTICE`.

Must not change:

- The orchestrator contract. `apply` and `watcher` are not special-cased; all family logic lives in `_lib.sh` helpers
  and the handlers.
- `theme-mode`'s public output (`dark`/`light`).
- The N-021 guard: a regular file at a link destination is never removed or overwritten.
- `docs/audit/findings/resolved.jsonl` is an append-only ledger. Its historical path strings stay as they are.

### Colour role map (drives every derived file)

Derived palettes are produced by substituting Catppuccin roles in the existing, already-tuned files with Kanagawa
colours. The file structure, and every non-colour setting in it, stays unchanged. Wave values come from upstream
`lua/kanagawa/colors.lua`. Lotus values are the upstream start point; the AA pass (task 3) may darken them.

| Catppuccin role            | Wave (dark)                       | Lotus (light, pre-AA)             |
|----------------------------|-----------------------------------|-----------------------------------|
| base / mantle / crust      | `#1F1F28` / `#181820` / `#16161D` | `#f2ecbc` / `#e5ddb0` / `#dcd5ac` |
| surface0 / 1 / 2           | `#2A2A37` / `#363646` / `#54546D` | `#e7dba0` / `#d5cea3` / `#a09cac` |
| overlay0 / 1 / 2           | `#727169` / `#717C7C` / `#938AA9` | `#8a8980` / `#716e61` / `#766b90` |
| text / subtext1 / subtext0 | `#DCD7BA` / `#C8C093` / `#A6A69C` | `#545464` / `#43436c` / `#716e61` |
| red / maroon               | `#E46876` / `#FF5D62`             | `#c84053` / `#d7474b`             |
| peach / yellow             | `#FFA066` / `#E6C384`             | `#cc6d00` / `#77713f`             |
| green / teal               | `#98BB6C` / `#7AA89F`             | `#6f894e` / `#597b75`             |
| sky / sapphire / blue      | `#7FB4CA` / `#A3D4D5` / `#7E9CD8` | `#4e8ca2` / `#5a7785` / `#4d699b` |
| lavender / mauve / pink    | `#9CABCA` / `#957FB8` / `#D27E99` | `#5d57a3` / `#624c83` / `#b35b79` |
| flamingo / rosewater       | `#E46876` / `#C8C093`             | `#d7474b` / `#e98a00`             |

Measured this session: on `#f2ecbc`, Lotus red, maroon, peach, yellow, green, teal, sky, sapphire, pink, flamingo,
rosewater, subtext0 and overlay1 all fall below 4.5:1, with rosewater lowest at 2.16. Every Wave accent clears
4.5:1 on `#1F1F28`, except upstream's terminal ANSI red `autumnRed #C34043` at 3.22:1.

## Tasks

1. **Selector and resolver helpers.** Files: `config/theme/family` (new, content `kanagawa`) and
    `config/theme/_lib.sh`. Add `_theme_family` (reads `$DOTFILES_THEME_FAMILY`, the test seam, else the file; accepts
    only `^[a-z0-9][a-z0-9-]*$` naming an existing `palettes.d/<family>/` dir, returns 1 otherwise), and
    `_palette <mode> <file>` (prints `palettes.d/<family>/<mode>/<file>`, returns 1 when absent). Add `_link_palette
    <src|""> <dst>`: with a src, call `_idempotent_ln_sf`. With none, remove `dst` **only if it is a symlink**, log
    `theme: <family> ships no <file>; removed stale link <dst>` to stderr, and return 0. A regular file is left alone,
    as the existing guard requires.
    Verify: new `tests/theme-lib.bats` cases. An invalid family (`../x`, empty, a missing dir) returns 1. `_palette`
    finds and misses. `_link_palette` removes a stale symlink, leaves a regular file untouched, and is idempotent.

2. **Move Catppuccin into the new layout.** `git mv` each `palettes.d/<app>.<mode>[.<ext>]` to
    `palettes.d/catppuccin/<mode>/<app>[.<ext>]` (`tmux.light.thm.conf` → `catppuccin/light/tmux.thm.conf`,
    `dircolors.dark` → `catppuccin/dark/dircolors`). Fix the self-references inside moved files: tmux.light
    `source-file` path and the `starship.light.toml` mapping comments quoted by nvim, wezterm, vim, fish and
    television. Add `catppuccin/{dark,light}/bat.theme` holding the bat theme name (`Catppuccin Mocha` /
    `Catppuccin Latte`). Keep `palettes.d/.gitkeep`.
    Verify: `git status` shows renames only, plus the two new files.
    `git grep -n 'palettes\.d/[a-z-]*\.\(dark\|light\)'` returns only `resolved.jsonl`.

3. **Kanagawa palettes (palettes.d apps) + AA pass.** Create `palettes.d/kanagawa/{dark,light}/` with `starship.toml`
    (palette block `kanagawa_wave` / `kanagawa_lotus`), `eza.yml`, `gitui.ron`, `yazi.toml`, `fzf.sh`, `fzf.fish`,
    `gh-dash.theme.yml`, `television.toml`, `dircolors` (the `38;2;R;G;B` triplets remapped), `tmux.conf`,
    `tmux.thm.conf` and `bat.theme` (`Kanagawa Wave` / `Kanagawa Lotus AA`). Each is derived from its Catppuccin
    sibling via the role map, using a throwaway script in the session scratchpad; the script is not committed. The
    AA pass lowers HSL lightness, keeping hue and saturation (the Latte method), until every foreground role reaches
    ≥4.5:1 on its background. That covers text, subtexts and accents on base; overlays must reach ≥3:1. It also
    replaces Wave ANSI red `#C34043` with the AA-passing Wave value. The final Lotus AA table goes in the header
    comment of `kanagawa/light/starship.toml`, as `starship.light.toml` does for Latte today. The tmux palettes reuse
    the catppuccin/tmux plugin as the status-bar engine: `tmux.conf` runs the options pass, then `tmux.thm.conf`
    (**all** `@thm_*` keys, including bg, fg, surfaces, overlays, mantle and crust, not just the accents), then the
    theme pass. This is the proven ordering from `tmux.light.conf`.
    Verify: `stylua`/`yamllint`/`taplo` where each applies. `yarn lint`. Task 12's contrast test.

4. **Handlers resolve through the family.** Rewrite `handlers.d/{starship,eza,gitui,yazi}` to
    `_link_palette "$(_palette "$mode" <file>)" <dst>`. For composed and state handlers:
    - `fzf` and `dircolors`: a missing palette removes the state symlink/cache. The consumers already guard with
      `test -r`; confirm `config/fzf/fzf.{bash,zsh}` and `conf.d/fzf-active.fish` do too.
    - `gh-dash` and `television`: a missing palette composes **base only**, with no theme block. `GH_DASH_CONFIG` and
      `TELEVISION_CONFIG` are exported unconditionally (`config/exports:499-500`, `exports.fish:83-84`), so deleting
      the file would break the app.
    - `bat`: read the name from `bat.theme`. When it is missing, remove `$state/bat-theme`; the exports already
      `test -r` it.
    - `tmux`: reworked by task 4b.

    Every handler exits 1 without touching anything when `_theme_family` fails (fail closed; `apply` logs it). yazi's
    tmTheme links become per family: `~/.config/yazi/<bat.theme name>.tmTheme`.
    Verify: update the `tests/theme-handlers.bats` path assertions (`*"/catppuccin/light/starship.toml"`), and add per
    handler: a family missing the file removes a stale link or artifact; a regular file survives; an invalid family
    exits 1 with the destination unchanged. Set `DOTFILES_THEME_FAMILY` in `setup()` so tests don't depend on the
    tracked default.

4a. **`apply` notices a family change.** Files: `config/theme/apply`. Today it exits early when the requested mode
    equals the stored mode (`apply:32-38`). A family-only change (kanagawa ↔ catppuccin at the same mode) is therefore
    a silent no-op, and the rollback story below could not work. Store the family next to the mode
    (`$state_dir/family`, written with `_atomic_write` after `_theme_family` succeeds), and skip only when **both**
    are unchanged. This is not app special-casing: `apply` stays app-agnostic, and the contract rule holds. When
    `_theme_family` fails, `apply` logs a WARN and still runs the handlers; they fail closed on their own (task 4).
    Verify: `tests/theme-actor.bats` cases. Same mode with the same family skips the handlers (a counting stub
    handler). Same mode with a new family runs them. The state `family` file matches afterwards.

4b. **tmux reloads its full config on every flip (user request).** The user asked for this line in `apply`. It goes in
    `handlers.d/tmux` instead, because `.claude/rules/theme-handler-contract.md` forbids special-casing an app in
    `apply`. `apply` already forks that handler on every flip, so the reload is still automatic. The naive form would
    loop: `config/tmux/tmux.conf:196` runs `handlers.d/tmux` at startup, so a handler that sources `tmux.conf` would
    re-trigger itself. Split the roles to break the loop:
    - New `config/theme/tmux-palette <mode>`, outside `handlers.d/` so `apply` never forks it. It resolves
      `_palette "$mode" tmux.conf` and runs `tmux source-file` on it. A missing palette is logged to stderr and
      nothing is sourced.
    - `tmux.conf:196` bootstrap calls `tmux-palette` instead of the handler.
    - `handlers.d/tmux` becomes: when a server is running (`tmux list-sessions` succeeds), `tmux source-file
      ~/.config/tmux/tmux.conf` (the same thing the `prefix r` binding at `tmux.conf:76` does), then `tmux
      refresh-client -S` for every attached client, so the status bar repaints at once instead of on the next
      `status-interval`. `tmux.conf`'s bootstrap line applies the new palette, because `apply` writes the mode (and
      family) before forking handlers, so `theme-mode` already returns the new value.
    - Stop discarding tmux's stderr (`2> /dev/null` today). `apply` captures it into the log, so a failed reload is
      visible instead of silently leaving the old colours.

    The config path the handler sources is overridable (`THEME_TMUX_CONF`, a test seam defaulting to
    `~/.config/tmux/tmux.conf`). Sourcing the real config in a test would run its TPM auto-install (a network clone).
    Verify: `tests/theme-handlers.bats`. With no server, the handler exits 0 and sources nothing. With a throwaway
    server (`TMUX_TMPDIR` in the temp dir, `tmux -f /dev/null new -d`) and a stub `THEME_TMUX_CONF` that only runs
    `tmux-palette` and sets a marker option, the handler completes within the 5s budget (no recursion), the marker is
    set exactly once, and `@thm_bg` matches the requested mode. Manual check:
    flip the OS appearance with a tmux session attached, and the status bar recolours within about a second, with no
    `prefix r`.

5. **Palette completeness test.** New `tests/theme-palettes.bats`: every family under `palettes.d/` ships the full
    handler file set in both `dark/` and `light/` (`tmux.thm.conf` optional), and every `.conf`/`.toml`/`.yml` it
    ships parses (`tmux -f /dev/null source-file -n` when tmux is present, else skip with reason; `python3 tomllib`;
    `yamllint`).
    Verify: remove one file in a temp copy and the test fails.

6. **bat + yazi syntax themes.** Vendor upstream `extras/tmTheme/kanagawa.tmTheme` as `config/bat/themes/Kanagawa
    Wave.tmTheme`, with the name field set to match `bat.theme`. Derive `Kanagawa Lotus AA.tmTheme` from it via the
    Wave→Lotus AA map. Update the `.gitignore` yazi tmTheme glob to cover `Kanagawa-*`/the new names.
    Verify: `bat --list-themes` after `bat cache --build` lists both. `BAT_THEME="Kanagawa Lotus AA" bat` renders.

7. **fish.** New `config/fish/themes/kanagawa-aa.theme` with `[dark]` from upstream `extras/fish/kanagawa.fish`
    (converted to fish_config theme syntax, with ANSI red AA-fixed) and `[light]` from Lotus AA. `handlers.d/fish`,
    `conf.d/theme-switch.fish` and `config.fish` use `"$family-aa"`, read via `${DOTFILES:-$HOME/.dotfiles}/config/
    theme/family`. When that theme file is missing, skip the save and leave the current theme.
    Verify: `fish -n`, the `fish-validate` skill, a manual `fish_config theme choose kanagawa-aa` in both modes.

8. **Neovim.** Add `{ src = 'https://github.com/rebelot/kanagawa.nvim', name = 'kanagawa' }` to `vim.pack` (keep
    catppuccin). At the colourscheme block, read the family file. For `kanagawa`, call `require('kanagawa').setup {
    background = { dark = 'wave', light = 'lotus' }, colors = { palette = <Lotus AA overrides> } }` and then
    `colorscheme kanagawa`; otherwise run the existing catppuccin block. auto-dark-mode stays as is (Kanagawa follows
    `'background'`). Upstream README keys were confirmed this session (`theme`, `background.dark/light`,
    `colors.palette`). `nvim-pack-lock.json` updates via `vim.pack`, not by hand.
    Verify: `stylua --check`, `nvim --headless '+lua print(vim.g.colors_name)' +q` prints `kanagawa`, and
    `:set bg=light` switches to Lotus.

9. **Vim.** Vendor `menisadi/kanagawa.vim` `colors/kanagawa.vim` as `config/vim/colors/kanagawa_wave.vim`
    (`g:colors_name` renamed). Derive `kanagawa_lotus.vim` (`background=light`, Wave→Lotus AA substitution, cterm
    numbers recomputed as nearest xterm-256). Derive the `airline/themes/kanagawa_{wave,lotus}.vim` and
    `lightline/colorscheme/kanagawa_{wave,lotus}.vim` from the catppuccin mocha/latte ones via the role map. In
    `vimrc`, replace the hardcoded `catppuccin_latte`/`catppuccin_mocha` pair with a family→`{dark, light}` dict (the
    family is read like `s:ThemeMode()`). `ToggleBackground` and the `g:vim_bootstrap_theme`/`airline_theme` defaults
    use it. When the family is unknown, fall back to catppuccin, because vim has no "unlinked" state (accepted risk
    below).
    Verify: `vim -Nu config/vim/vimrc +'echo g:colors_name' +q` per mode, with no `E185`.

10. **WezTerm.** Add `config/wezterm/colors/kanagawa_wave.lua` (upstream `extras/wezterm/kanagawa.lua`, with ANSI red
    AA-fixed) and `kanagawa_lotus_aa.lua` (from upstream foot/kitty Lotus, AA-hardened). Register them in
    `config.color_schemes`. `Scheme_for_appearance` picks by family, read via `io.open` on
    `(os.getenv('DOTFILES') or wezterm.home_dir .. '/.dotfiles') .. '/config/theme/family'`. When the file is
    unreadable, fall back to the current Catppuccin behaviour.
    Verify: `stylua --check`, `wezterm --config-file config/wezterm/wezterm.lua ls-fonts` exits 0 (loads the config),
    and a manual appearance flip.

11. **COSMIC.** Add repo-derived `config/cosmic-desktop/themes/cosmic-term/kanagawa-{wave,lotus-aa}.ron` and
    `cosmic-settings/kanagawa-{wave,lotus-aa}+round.ron` (accent crystalBlue / Lotus AA blue), derived from
    catppuccin mocha/latte blue by the role map. The README gets a "Kanagawa files are repo-derived, not vendored;
    regenerate by role map" section, because it currently says "don't hand-edit".
    Verify: RON parses (`python3` bracket/quote balance check at minimum), then a manual COSMIC import.

12. **Contrast test.** Generalise `tests/theme-latte-contrast.bats` into `tests/theme-contrast.bats`. Keep the
    existing Latte assertions (paths updated). Add a **computed** WCAG check: extract every `#rrggbb` in
    `palettes.d/kanagawa/light/*`, `kanagawa-aa.theme [light]`, `kanagawa_lotus*.vim`, `Kanagawa Lotus AA.tmTheme` and
    `kanagawa_lotus_aa.lua` that is used as a foreground, and assert ≥4.5:1 on `#f2ecbc`. Assert the Wave ANSI red is
    ≥4.5:1 on `#1F1F28`. Keep the "AA overrides stay wired" greps for the kanagawa names.
    Verify: temporarily reinsert `#de9800` into a Lotus file and the test fails.

13. **Docs, rules, lint config.** Update `theme-handler-contract.md` (new path grammar plus the "missing ⇒ unlink"
    rule), the `theme-handler-scaffold` SKILL (template uses `_palette`/`_link_palette`), `config/theme/CLAUDE.md`,
    `docs/audit/arch-profile.md` rule 2 (the dircolors no-ext exception now reads `<family>/<mode>/dircolors`),
    `config/nvim/{CLAUDE,README}.md`, `docs/tv.md`, and the `.mega-linter.yml` regex (still matches the subtree;
    re-check it). `.prettierignore` already covers the whole `palettes.d` tree. Add Kanagawa (MIT, rebelot) and
    kanagawa.vim (menisadi, licence checked at vendoring time) to `NOTICE`.
    Verify: `yarn lint`, `yarn lint:ec`, and `git grep -n 'palettes\.d/<app>\.<'` returns no stale grammar.

14. **Switch and refresh.** Run `config/theme/apply dark` and then `light` on this machine; check `~/.config/
    {starship.toml,eza/theme.yml,gitui/theme.ron,yazi/theme.toml}` point into `kanagawa/<mode>/`. Refresh the graph:
    `graphify update .`, `scripts/graphify-tests.py`, `graphify export html`.
    Verify: `yarn test` (full bats) and `yarn lint` pass. `tail ~/.local/state/dotfiles-theme/*.log` shows no handler
    errors.

Commits are grouped by concern with `git-hunk` (for example `refactor(theme): move palettes into family dirs`,
`feat(theme): add kanagawa palettes`, `feat(nvim): kanagawa colorscheme`, …).

## Adversarial hardening

- **complexity**: Examined the selector options. Cut the CLI `--family` switch and the state-file selector; kept a
  tracked one-word file. Cut a committed generator script: derivation is a one-shot, and its reproducible part (the
  role map plus the AA table) is documented in the plan and in palette headers. Rejected a `current ->
  palettes.d/<family>/<mode>` indirection symlink: it would leave dangling app links instead of removing them, which
  violates the "missing ⇒ unlinked" requirement. Kept the catppuccin/tmux plugin as the tmux status engine rather
  than rewriting the status bar, since the `@thm_*` override slot is already proven by `tmux.light.thm.conf`.
- **review** (edge cases): The family file can be missing, empty, carry a trailing newline, or contain `../`, so the
  task 1 regex and dir-exists check apply. A family can ship only one mode (the completeness test fails CI; at
  runtime `_link_palette` unlinks). A destination can be a regular file (the N-021 guard is kept, and so is the
  unlink path). A stale link can point at a *deleted* old path after the `git mv` (`-e` is false for a dangling
  link; `_link_palette` tests `-L`, not `-e`). A yazi tmTheme with spaces in its name is quoted.
- **security**: One new trust boundary: `DOTFILES_THEME_FAMILY` and `config/theme/family` feed a filesystem path. The
  strict name regex and the requirement that the dir exist under `palettes.d/` close traversal. The deletion
  primitive only ever removes a symlink at a handler-fixed destination, never a path derived from input.
- **errors / leaks**: Every new handler branch is covered. An unresolvable family exits 1 (logged by `apply`) and
  changes nothing. A missing palette is logged to stderr, which `apply` captures and labels. Composed handlers keep
  their atomic write, so no partial config survives a crash. No new long-lived resources are acquired.
- **migrations**: Not a DB migration; examined the on-disk migration instead. Existing `~/.config/*` symlinks point at
  the old flat paths and dangle after task 2 until the next flip. Task 14 runs `apply` for both modes, the watcher
  re-applies on the next OS flip, and `_link_palette` replaces dangling links because `readlink` differs. Rollback
  is below.
- **concurrency**: Handlers already run in parallel, and each owns a distinct destination. The new helpers add no
  shared state; the family file is read-only at runtime. Task 4b relies on one ordering: `apply` writes `mode` and
  `family` **before** forking handlers (already true at `apply:40`; task 4a keeps the family write there too), so the
  reloaded `tmux.conf` reads the new values. The reload recursion is broken by construction: `tmux.conf` calls
  `tmux-palette`, never `handlers.d/tmux`. Task 4b's marker-set-once test guards it.
- **contract**: Public surfaces are `theme-mode` (unchanged), the handler contract rule and the scaffold skill (both
  updated in task 13), and the palette path grammar (changed; every in-repo consumer is updated in tasks 2–4 and 13,
  and `git grep` confirms). This is a dotfiles repo, so there is no version bump.
- **arch**: Family logic sits in `_lib.sh` and the handlers. `watcher` is untouched. `apply` gains only the
  app-agnostic family change check (task 4a). The user asked for the tmux reload in `apply`; it lives in
  `handlers.d/tmux` instead (task 4b), because contract rule 1 forbids app special-cases in `apply` and the handler
  path is already automatic. nvim, vim, wezterm and fish read the family file directly, the same way they read `mode`
  today.
- **perf**: Each flip adds one file read and one regex per handler. The tmux flip now re-sources the full
  `tmux.conf`, the same work as `prefix r`. TPM's `run` only sources the installed plugins; the auto-install clone
  fires only when TPM is missing. It stays well inside the 5s handler timeout, and the task 4b test measures it.
  The bat cache rebuild still triggers only when a
  tmTheme is newer than the cache; adding two themes triggers exactly one rebuild. vim's 3s timer reads one extra
  small file per tick, the same order as today.
- **tests**: Every task names a check that can fail. The handler tests assert link targets and the unlink behaviour,
  not just exit 0. The contrast test is computed, and the plan includes a planted-positive check (task 12). The
  completeness test also has a planted negative (task 5). The existing "tmux handler succeeds" test stays a smoke
  test, recorded as such.
- **config**: New config: `config/theme/family`, plus the `DOTFILES_THEME_FAMILY` test seam, documented in the handler
  contract and `config/theme/CLAUDE.md`. No secrets.
- **a11y**: This is the core of the change. AA ≥4.5:1 for every Lotus foreground role and for the Wave ANSI red is
  enforced by task 12.
- **privacy / i18n / observability**: privacy N/A (no personal data is touched). i18n N/A (no user-facing strings
  beyond log lines). observability: the new unlink and skip paths log through the existing stderr→`apply` log
  channel, so a missing palette is visible in `dotfiles-theme` logs, not silent.

## Rollback / abort

Each task lands as its own commit(s). To roll back, set `config/theme/family` back to `catppuccin` and run `apply` for
the current mode. This relies on task 4a: before it, a same-mode `apply` is a no-op. The Catppuccin assets remain
intact, only moved, so this restores the old look without a revert. tmux follows automatically via task 4b.
To abort the whole restructure, `git revert` the commits in reverse order and run `config/theme/apply "$(theme-mode)"`
to repoint the `~/.config` links at the flat paths. If aborting mid-way after task 2, the app links dangle until that
`apply` runs.

## Open questions & accepted risks

- **Derived, not upstream, assets.** Every Lotus file, the Lotus tmTheme, the vim Lotus colorscheme, all airline and
  lightline themes, the COSMIC RONs, gitui, eza, yazi, dircolors, gh-dash and television palettes are derived by role
  map; upstream only ships Wave for most of them. Accepted: that is what was asked, and the contrast test pins the
  one objective property. Subjective look is verified manually in task 14.
- **Role mapping is a judgement.** Catppuccin has 26 roles and Kanagawa's are not one-to-one (flamingo and red share
  `#E46876` in Wave). Accepted; the map lives in this plan so it can be revised in one place.
- **The tmux status bar still runs the catppuccin/tmux plugin as its engine.** The colours are Kanagawa and the plugin
  name is not. Accepted, to avoid a status-bar rewrite; a native tmux theme can come later.
- **vim falls back to catppuccin for an unknown family** instead of "unlinking", because a colourscheme cannot be
  absent. Accepted and documented in `vimrc`.
- **Live apps keep old colours until restart** (fzf and gh-dash already behave this way). Unchanged behaviour.
- **kanagawa.vim licence** is checked when it is vendored in task 9. If it is incompatible, task 9 derives
  `kanagawa_wave.vim` from the kanagawa.nvim palette (MIT) instead of vendoring, with the same verification.
- **A tmux flip resets runtime-only tmux options** (anything set by hand in a live session and not in `tmux.conf`),
  because it re-sources the whole config. This is identical to pressing `prefix r`. Accepted: the user asked for a
  full reload.
- **wezterm builtin Kanagawa schemes** were not relied on (not verified this session); the schemes are defined inline.
