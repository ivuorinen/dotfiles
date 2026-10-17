# Theme Family Switcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A `theme` command that lists theme families and switches between them live, with the choice saved per
machine under `XDG_STATE_HOME`, followed by every reader, open shells and running nvim, plus a `dfm theme` section.

**Architecture:** The saved choice becomes step 2 of one family resolution order shared by `_theme_family` and the
fish, vim, nvim and wezterm readers. `config/theme/apply` keeps its own record in `applied-family` and writes a
`generation` stamp once handlers finish; bash, zsh and fish reload their colour caches when that stamp changes.
`local/bin/theme` validates, saves and runs `apply`; `local/bin/dfm-theme` wraps it.

**Tech Stack:** bash (3.2-compatible in `config/theme/` and the new shell-env file), zsh, fish, Lua (nvim,
wezterm), Vimscript, bats.

**Spec:** `docs/plans/2026-10-17-theme-switcher-design.md`

## Global Constraints

- Choice file: `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/choice`. apply's record:
  `.../dotfiles-theme/applied-family`. Refresh stamp: `.../dotfiles-theme/generation`. Tracked default:
  `${DOTFILES:-$HOME/.dotfiles}/config/theme/family` (`oasis`).
- Resolution order everywhere: non-empty `DOTFILES_THEME_FAMILY` → choice file → tracked default.
- A family is valid when it matches `^[a-z0-9][a-z0-9-]*$` and `config/theme/palettes.d/<family>/` is a directory.
- An invalid `DOTFILES_THEME_FAMILY` fails closed as today. An invalid, empty or missing choice file falls through
  to the tracked default.
- When nothing resolves, vim, nvim and wezterm fall back to `oasis` (was `catppuccin`); fish still prints nothing
  and returns 1.
- apply never writes the choice file. A switch never writes a tracked file.
- Prompt hooks start no subprocess when the stamp is unchanged, and return the `$?` they were called with.
- Every theme test's `setup()` exports `XDG_STATE_HOME` into its temp dir, so a developer's real saved choice never
  reaches a test.
- Commit with `git-hunk` (`.claude/rules/git-hunk-commits.md`), Conventional Commits. Run each touched test file with
  `bats tests/<file>.bats`; run `scripts/bats-run.sh` and `mise run lint` before the final commit.

## Review Focus

- A choice file that is empty, whitespace or names a removed family: the default applies, and `theme` warns. Tests
  in Task 1 and Task 5.
- A host with no orchestrator state (SSH host, fresh install): the prompt hook is silent and keeps `$?`. Test in
  Task 4.
- `theme <family>` before apply has ever run (no state dir): the dir is created and the switch works. Test in
  Task 5.
- `theme` piped into another command: no escape codes. Test in Task 5.
- The developer's own saved choice leaking into the existing theme tests: every theme `setup()` isolates
  `XDG_STATE_HOME`. Steps in Task 1 and Task 2.

---

### Task 1: Saved choice in `_theme_family`; apply's record and generation stamp

**Files:**

- Modify: `config/theme/_lib.sh` (`_theme_family`, new helpers)
- Modify: `config/theme/apply` (`family_file` → `applied-family`, generation stamp)
- Test: `tests/theme-lib.bats`, `tests/theme-actor.bats`, `tests/theme-handlers.bats` (setup only)
- Docs: `config/theme/CLAUDE.md` (apply and family bullets), `.claude/rules/theme-handler-contract.md`
  (active-family line)

**Interfaces:**

- Produces `_theme_choice_file` — no args; prints the choice file path. Always returns 0.
- Produces `_theme_valid_family NAME` — returns 0 when NAME passes the family rule, 1 otherwise. Prints nothing.
- Changes `_theme_family` — no args; prints the resolved family per the order above; returns 1 with a stderr note
  when nothing valid resolves.
- apply writes `$state_dir/applied-family` (record, `-` when unresolvable) and, after the handler wait in both the
  flip and the retry branch, `$state_dir/generation` with a new opaque token (`$(date +%s)-$$` is enough).

- [ ] **Step 1: Isolate state in existing setups.** In `tests/theme-lib.bats` and `tests/theme-handlers.bats`
  `setup()`, export `XDG_STATE_HOME="$TMPDIR_TEST/state"` (theme-actor already isolates it). Run both files: they
  still pass.

- [ ] **Step 2: Write the failing `_theme_family` tests** in `tests/theme-lib.bats`, using `make_family_tree` plus a
  second family dir `other`:

```bash
@test "_theme_family: a saved choice wins over the tracked file" {
  source "$THEME_LIB"; make_family_tree; unset DOTFILES_THEME_FAMILY
  mkdir -p "$DOTFILES/config/theme/palettes.d/other" "$XDG_STATE_HOME/dotfiles-theme"
  echo other > "$XDG_STATE_HOME/dotfiles-theme/choice"
  run _theme_family
  [ "$status" -eq 0 ] && [ "$output" = "other" ]
}

@test "_theme_family: env override wins over a saved choice" {
  # saved choice "other", DOTFILES_THEME_FAMILY=fam → prints "fam"
}

@test "_theme_family: an empty or invalid saved choice falls back to the tracked file" {
  # for each of '' '  ' 'nope' '../fam' '-': write it to the choice file, run _theme_family,
  # expect status 0 and output "fam"
}
```

- [ ] **Step 3: Write the failing apply tests** in `tests/theme-actor.bats`. Rename "apply: records the family next
  to the mode" to "apply: records the applied family" and assert `applied-family` holds `catppuccin` and
  `dotfiles-theme/choice` does not exist. Change the family-switch test's assertion to `applied-family`, and the
  unresolvable-family test's `-` assertion likewise. Add:

```bash
@test "apply: a saved choice switches the family" {
  # unset DOTFILES_THEME_FAMILY; echo kanagawa > "$TMPDIR_TEST/dotfiles-theme/choice"; apply dark
  # → applied-family is kanagawa and the choice file still says kanagawa
}

@test "apply: writes a new generation after the handlers finish" {
  # handler stub copies the current generation (or "none") into "$TMPDIR_TEST/seen";
  # after apply dark: generation exists and differs from the content of seen.
  # Repeat with apply light: the generation differs from the first run's.
}

@test "apply: a skipped apply leaves the generation unchanged" {
  # apply dark twice; generation after the second equals the first
}
```

- [ ] **Step 4: Run the tests to verify they fail.** `bats tests/theme-lib.bats tests/theme-actor.bats` — the new
  and changed cases fail.

- [ ] **Step 5: Implement** `_theme_choice_file`, `_theme_valid_family` and the new `_theme_family` in
  `config/theme/_lib.sh` (read the choice with `read -r`, trim surrounding whitespace, validate with
  `_theme_valid_family`, fall through on failure). In `config/theme/apply`, point the record at `applied-family`
  and write the generation after the handlers return, in both branches; a skipped apply writes nothing. Resolve
  the family again once the lock is held, so two `theme` runs racing each other settle on the last saved choice
  (the pre-lock resolve still serves the cheap no-op exit).

- [ ] **Step 6: Run the tests to verify they pass.** `bats tests/theme-lib.bats tests/theme-actor.bats
  tests/theme-handlers.bats` — all pass.

- [ ] **Step 7: Update the docs** listed above to the new order, the `applied-family` record and the stamp.

- [ ] **Step 8: Commit** — `git-hunk list`, then `git-hunk commit <hashes> -m "feat(theme): resolve the family from
  a saved per-machine choice"`.

### Task 2: fish, vim, nvim and wezterm follow the saved choice

**Files:**

- Modify: `config/fish/functions/__dotfiles_theme_name.fish`, `config/fish/config.fish` (comment),
  `config/vim/vimrc` (`s:Schemes`), `config/nvim/init.lua` (`theme_family`), `config/wezterm/wezterm.lua`
  (`theme_family`, fallback)
- Test: `tests/theme-family-resolvers.bats`

**Interfaces:**

- Consumes: the resolution order and family rule from Global Constraints. Each runtime keeps its own copy, as today.
- nvim's `theme_family()` gains the slug check and returns `'oasis'` when nothing resolves.
- wezterm needs no new watch entry: apply rewrites the mode file on every flip, family-only ones included, and
  that file is already on wezterm's reload list.

- [ ] **Step 1: Isolate state.** In `setup()`, export `XDG_STATE_HOME="$TMPDIR_TEST"` (the `dotfiles-theme` dir is
  already created there). The wezterm test's `XDG_STATE_HOME="$TMPDIR_TEST/state"` stays.

- [ ] **Step 2: Write the failing tests.** Per runtime, with `DOTFILES_THEME_FAMILY` unset and the tracked default
  `oasis`:

```bash
@test "fish: the saved choice wins over the tracked family" {
  # echo kanagawa > "$TMPDIR_TEST/dotfiles-theme/choice" → __dotfiles_theme_name prints kanagawa-aa
}
@test "fish: an invalid saved choice falls back to the tracked family" { }  # 'nope' → oasis-aa
@test "vim: the saved choice selects the scheme" { }    # kanagawa saved, family arg '' → kanagawa_wave
@test "nvim: the saved choice selects the scheme" { }   # kanagawa saved → $(nvim_scheme '') = kanagawa
@test "wezterm: the saved choice selects the scheme pair" { }  # choice under $TMPDIR_TEST/state/dotfiles-theme
```

Change the fallback expectations: "vim: an unknown family falls back to catppuccin" becomes "... falls back to
oasis" (expect `oasis_abyss_dark`); nvim's `nosuchfamily` line expects `"$(nvim_scheme oasis)"`; wezterm's expects
`nosuchfamily=Oasis Abyss Dark|Oasis Abyss Light 3`. `vim_colors` and `nvim_scheme` pass an empty family as
"unset" (an empty override already falls through).

- [ ] **Step 3: Run the tests to verify they fail.** `bats tests/theme-family-resolvers.bats`.

- [ ] **Step 4: Implement** the order in the four readers. Each reads the choice from
  `($XDG_STATE_HOME or $HOME/.local/state)/dotfiles-theme/choice` and applies the family rule before using it.
  vim, nvim and wezterm fall back to `oasis`.

- [ ] **Step 5: Run the tests to verify they pass**, then `stylua --check config/nvim/init.lua
  config/wezterm/wezterm.lua` and `fish_indent --check config/fish/functions/__dotfiles_theme_name.fish`.

- [ ] **Step 6: Commit** — `git-hunk commit <hashes> -m "feat(theme): follow the saved family in fish, vim, nvim
  and wezterm"`.

### Task 3: Running nvim follows a family switch

**Files:**

- Modify: `config/nvim/init.lua` (colourscheme section)
- Test: `tests/theme-family-resolvers.bats`
- Docs: `config/nvim/CLAUDE.md`, `config/nvim/README.md`, `config/theme/CLAUDE.md` (drop "nvim … needs a restart")

**Interfaces:**

- Produces local `apply_family_scheme()` in `init.lua`: resolves the family, maps it through `family_schemes`
  (`oasis` when unmapped), and runs `vim.cmd.colorscheme` only when the result differs from the last one it
  applied. Called once at startup (replacing the bare `vim.cmd.colorscheme` line) and from a repeating
  `vim.uv` timer every 3000 ms, wrapped with `vim.schedule_wrap`. `background` stays with auto-dark-mode.

- [ ] **Step 1: Write the failing test**, mirroring vim's live test and the plugin-installed skip guard:

```bash
@test "nvim: a running session follows a family switch at an unchanged mode" {
  # DOTFILES_THEME_FAMILY=kanagawa nvim --headless '+set background=dark'
  #   "+lua vim.env.DOTFILES_THEME_FAMILY = 'catppuccin'" '+sleep 4'
  #   '+lua io.stdout:write(vim.g.colors_name)' +qa
  # → catppuccin-mocha
}
```

- [ ] **Step 2: Run it to verify it fails** (prints `kanagawa`).

- [ ] **Step 3: Implement** `apply_family_scheme()` and the timer.

- [ ] **Step 4: Run `bats tests/theme-family-resolvers.bats` to verify it passes**, then `stylua --check
  config/nvim/init.lua`.

- [ ] **Step 5: Update the docs** listed above.

- [ ] **Step 6: Commit** — `git-hunk commit <hashes> -m "feat(nvim): follow a theme family switch live"`.

### Task 4: Open shells refresh their colours at the next prompt

**Files:**

- Create: `config/theme/shell-env.sh` (bash/zsh, `# shellcheck shell=bash`, side-effect-free on source)
- Modify: `config/exports` (source `shell-env.sh`; replace the startup `ls-colors` / `bat-theme` loaders with
  `_theme_refresh_env`; replace the env refresh at the end of `theme-reapply` with `_theme_refresh_env`)
- Modify: `base/bashrc` (add `_theme_prompt_check` to `PROMPT_COMMAND` once, the way `_gpg_ssh_updatetty` is
  guarded against re-sourcing), `base/zshrc` (`add-zsh-hook precmd _theme_prompt_check`)
- Modify: `config/fish/conf.d/theme-switch.fish` (trigger on the generation stamp, reload fzf too),
  `config/fish/conf.d/fzf-active.fish` (comment: live shells now follow)
- Test: create `tests/theme-shell-env.bats`; extend `tests/shell-entry-dotfiles.bats` for hook registration

**Interfaces:**

- Produces `_theme_refresh_env` — no args. Sets `LS_COLORS` by evaluating the `ls-colors` cache, or unsets it when
  the cache is gone; sets and exports `BAT_THEME` from `bat-theme`, or unsets it; sources `fzf-active.sh` when
  readable (it assigns `FZF_DEFAULT_OPTS` whole, so re-sourcing is safe) and leaves it alone otherwise; stores the
  current stamp in `_THEME_GENERATION`.
- Produces `_theme_prompt_check` — no args. Reads `generation` with the `read` builtin; when it is missing or equals
  `_THEME_GENERATION`, returns at once; otherwise calls `_theme_refresh_env`. Always returns the incoming `$?`.
- fish: `__theme_switch_check` keys on the stamp content (builtin `read`, global `__theme_switch_last_generation`)
  instead of the mode file's mtime, and on change also sources `fzf-active.fish`.

- [ ] **Step 1: Write the failing tests** in `tests/theme-shell-env.bats`. Setup: temp `XDG_STATE_HOME` with a
  `dotfiles-theme` dir; helpers that write an `ls-colors` cache (`LS_COLORS='di=01;34'; export LS_COLORS`), a
  `bat-theme` file and an `fzf-active.sh` exporting `FZF_DEFAULT_OPTS`, and one that bumps `generation`. Each case
  runs `bash -c` (and the zsh variant under `zsh -c`, skipped when zsh is absent) sourcing only
  `config/theme/shell-env.sh`:

```bash
@test "shell-env: refresh loads LS_COLORS, BAT_THEME and the fzf palette" { }
@test "shell-env: a removed cache unsets LS_COLORS and BAT_THEME" { }
@test "shell-env: the prompt check reloads once the generation changes" { }
@test "shell-env: an unchanged generation leaves the environment alone" {
  # rewrite the caches without bumping generation → old values stay
}
@test "shell-env: no generation file is silent and keeps \$?" {
  # bash -c 'source shell-env.sh; false; _theme_prompt_check; echo "rc=$?"' → output exactly "rc=1"
}
@test "shell-env: the zsh variant passes the same checks" { }
@test "fish: theme-switch reloads the fzf palette on a new generation" {
  # fish -c: source conf.d/theme-switch.fish; write caches + bump generation; emit fish_prompt;
  # echo $FZF_DEFAULT_OPTS → the new palette. Skipped when fish is absent.
}
```

In `tests/shell-entry-dotfiles.bats`, following its existing pattern: after sourcing `base/bashrc` twice,
`PROMPT_COMMAND` names `_theme_prompt_check` exactly once; zsh's `precmd_functions` holds it once.

- [ ] **Step 2: Run them to verify they fail.** `bats tests/theme-shell-env.bats tests/shell-entry-dotfiles.bats`.

- [ ] **Step 3: Implement** `config/theme/shell-env.sh` and the wiring above. Keep `config/fzf/fzf.bash` and
  `fzf.zsh` as they are (they still source the palette last at startup).

- [ ] **Step 4: Run the tests to verify they pass**, plus `bats tests/theme-mode.bats tests/shell-entry-dotfiles.bats`,
  shellcheck and `shfmt -d` on the shell files and `fish_indent --check` on the fish files.

- [ ] **Step 5: Commit** — `git-hunk commit <hashes> -m "feat(theme): refresh open shells' colours after a theme
  switch"`.

### Task 5: `local/bin/theme`

**Files:**

- Create: `local/bin/theme` (new-script skill), `tests/theme.bats` (bats-test-scaffold skill)
- Docs: `config/theme/CLAUDE.md` (family bullet: switch with `theme`), `AGENTS.md` (Theme Orchestrator paragraph
  names `theme` beside `theme-mode`); run `scripts/install-completions.sh` for the generated docs

**Interfaces:**

- Consumes from Task 1: `_theme_family`, `_theme_valid_family`, `_theme_choice_file`, `_atomic_write`, sourced
  from `$DOTFILES/config/theme/_lib.sh`.
- Produces the CLI `theme [<family> | --reset | -h | --help]`:
    - No args: valid families from `palettes.d`, sorted, one per line. Active line `* <name>`, others `  <name>`
      when stdout is not a terminal; on a terminal an arrow plus bold for the active line. Warns (stderr) when the
      choice file holds an invalid name, and when `DOTFILES_THEME_FAMILY` is set.
    - `<family>`: invalid → exit 2, stderr names the valid families, nothing written. Already active → exit 0 with
      a note, apply not run. Otherwise `_atomic_write` the choice, run
      `"$DOTFILES/config/theme/apply" "$("$DOTFILES/local/bin/theme-mode")"`, exit with its status.
    - `--reset`: remove the choice file, run apply the same way.
    - Unknown option → exit 2 with usage.

- [ ] **Step 1: Write the failing tests** in `tests/theme.bats`. Setup: temp `XDG_STATE_HOME` with
  `dotfiles-theme/mode` = `dark` (so `theme-mode` never probes), `DOTFILES` = repo root, `THEME_HANDLERS_DIR` an
  empty temp dir (apply runs no real handlers), `DOTFILES_THEME_FAMILY` unset.

```bash
@test "theme: lists every family and marks the tracked default" {
  run "$THEME"; [ "$status" -eq 0 ]
  [ "$output" = "$(printf '  catppuccin\n  kanagawa\n* oasis')" ]
}
@test "theme: switching saves the choice and applies it" {
  # theme kanagawa → status 0; choice file = kanagawa; applied-family = kanagawa; list marks kanagawa
}
@test "theme: switching to the active family changes nothing" { }   # status 0, no choice file written
@test "theme: an unknown or path-like family is rejected" {
  # for nope ../oasis '' : status 2; output names catppuccin; no choice file
}
@test "theme: --reset returns to the tracked default" { }          # after kanagawa: no choice file, applied oasis
@test "theme: a stale saved choice is reported and the default is marked" { }  # choice 'gone'
@test "theme: warns when DOTFILES_THEME_FAMILY overrides the choice" { }
@test "theme: works before apply has ever run" { }                 # no dotfiles-theme dir at all
@test "theme: piped output carries no escape codes" { }            # [[ "$output" != *$'\e'* ]]
@test "theme: --help prints usage" { }
```

- [ ] **Step 2: Run them to verify they fail** (`bats tests/theme.bats`, command not found).

- [ ] **Step 3: Implement `local/bin/theme`**, `chmod +x`, with the `#USAGE` spec; source msgr only for the
  switch/reset/warning messages if it is used at all (new-script skill).

- [ ] **Step 4: Run the tests to verify they pass**, then shellcheck, `shfmt -d` and `mise exec -- usage lint
  local/bin/theme`.

- [ ] **Step 5: Update the docs, regenerate** with `scripts/install-completions.sh`.

- [ ] **Step 6: Commit** — `git-hunk commit <hashes> -m "feat(theme): add a theme command to list and switch
  families"`.

### Task 6: `dfm theme` section

**Files:**

- Create: `local/bin/dfm-theme` (pattern: `local/bin/dfm-docs`, `dfm_bootstrap_for "$@"`, `menu_builder`)
- Modify: `local/bin/dfm` (`DFM_SECTIONS` gains `theme`), `local/bin/CLAUDE.md` (dfm command list)
- Test: `tests/dfm.bats`

**Interfaces:**

- Consumes: `theme` (Task 5), `theme-mode`, and the `theme-reapply` shell function that the full bootstrap defines
  by sourcing `config/exports`.
- Produces `dfm theme <command>`, with a `#USAGE cmd "theme"` block matching `MENU` (checked by
  `tests/dfm-sections.bats`):
    - `family [name]` — "List theme families, or switch to one" → `theme "$@"`
    - `reset` — "Return to the default theme family" → `theme --reset`
    - `mode` — "Print the current dark/light mode" → `theme-mode`
    - `reapply [dark|light]` — "Re-run every theme handler" → `theme-reapply "$@"`
    - anything else → the menu

- [ ] **Step 1: Write the failing tests** in `tests/dfm.bats`:

```bash
@test "dfm theme menu shows entries" {
  run bash local/bin/dfm theme
  [ "$status" -eq 0 ]
  for e in family reset mode reapply; do [[ "$output" == *"$e"* ]]; done
}
@test "dfm theme family lists the families" { }   # output contains catppuccin, kanagawa, oasis
@test "dfm theme mode prints dark or light" { }
```

- [ ] **Step 2: Run them to verify they fail.** `bats tests/dfm.bats tests/dfm-sections.bats`.

- [ ] **Step 3: Implement `local/bin/dfm-theme`** and add `theme` to `DFM_SECTIONS`.

- [ ] **Step 4: Run the tests to verify they pass**, then shellcheck and `shfmt -d` on `local/bin/dfm-theme`.

- [ ] **Step 5: Update `local/bin/CLAUDE.md`, regenerate** with `scripts/install-completions.sh`.

- [ ] **Step 6: Commit** — `git-hunk commit <hashes> -m "feat(dfm): add a theme section"`.

### Final verification

- [ ] `scripts/bats-run.sh; echo "exit=$?"` → `exit=0`.
- [ ] `mise run lint` → exit 0.
- [ ] Refresh the graph: `graphify update .`, `scripts/graphify-tests.py`, `graphify export html`.
- [ ] Manual check on this machine: `./install --links`, then `theme`, `theme kanagawa` (prompt, tmux, `ls` and
  nvim follow), `theme --reset`, `dfm theme`.
