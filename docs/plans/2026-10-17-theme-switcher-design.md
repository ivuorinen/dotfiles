# Design: `theme` family switcher

## Intent

Switching the theme family today means editing the tracked `config/theme/family` and running
`config/theme/apply "$(theme-mode)"` by hand, and every switch leaves an uncommitted change in the repo. The goal is
one command that lists the families, switches between them live, and keeps the choice per machine and out of git.
`dfm` gets a `theme` section that gathers this command with the existing `theme-mode` and `theme-reapply`.

## Goals

- `theme` with no arguments lists every family and marks the active one.
- `theme <family>` saves the choice to `$XDG_STATE_HOME/dotfiles-theme/choice` (default
  `~/.local/state/dotfiles-theme/choice`) and switches the running theme at once.
- `theme --reset` drops the saved choice, so the tracked default (`config/theme/family`, `oasis`) applies again.
- Running nvim sessions follow a family switch live, as vim already does.
- Every open bash, zsh and fish shell, including the one `theme` ran in, picks up the new `ls`, bat and fzf colours
  at its next prompt. Dark/light flips get the same, since they go through the same handlers.
- `dfm theme` exposes `theme`, the reset, `theme-mode` and `theme-reapply`.

## Non-goals

- Changing dark/light mode. Mode stays OS-driven; `theme` keeps the current mode.
- Adding, removing or editing families or palettes.
- Per-mode families (one family for dark, another for light).
- Carrying the family across SSH. Each machine follows its own saved choice (or the default), so a remote session
  can show a different family from the local terminal.

## Anti-goals

These would make the work a failure even if it ran:

- A switch changes a tracked file.
- `DOTFILES_THEME_FAMILY` (the test override) or apply's own bookkeeping ends up written into the saved choice.
- Palettes from two families mixed after a switch.
- A switch that bypasses `config/theme/apply` and its lock, racing the watcher or another shell.

## Decided

### Where the family comes from

Every reader resolves the active family in this order:

1. `DOTFILES_THEME_FAMILY`, when set (test seam, unchanged).
2. `$XDG_STATE_HOME/dotfiles-theme/choice`, the saved choice, when present.
3. `$DOTFILES/config/theme/family`, the tracked default (`oasis`).

The readers are `_theme_family` in `config/theme/_lib.sh` (used by `apply` and every handler),
`config/fish/functions/__dotfiles_theme_name.fish`, `theme_family()` in `config/nvim/init.lua`, `s:Schemes()` in
`config/vim/vimrc`, and `theme_family()` in `config/wezterm/wezterm.lua`. The name feeds a filesystem path, so every
reader keeps today's rule: a slug matching `^[a-z0-9][a-z0-9-]*$` that names a directory under
`config/theme/palettes.d/`.

### apply's own record moves

`config/theme/apply` currently writes the family it applied to `$state_dir/family` and compares against it to skip
unchanged flips. apply's record moves to its own file (`applied-family` is the working name), and the choice gets a
new name (`choice`) rather than reusing `family`: an old record there would otherwise read as a saved choice of the
then-default family and pin it. apply never writes the choice file and deletes the old `family` file. The first apply
after the change finds no record and re-runs every handler once, which is harmless.

### `local/bin/theme`

- No arguments: one family per line, every directory under `config/theme/palettes.d/` that passes the slug rule,
  sorted. The active family (resolved as above) is marked.
- `theme <family>`: validate; on failure print the valid names to stderr, exit non-zero and write nothing. On success
  atomic-write the name to the choice file (tmp + rename, as `_atomic_write` in `_lib.sh` does), then run
  `config/theme/apply "$(theme-mode)"` so the switch goes through apply's lock, retry list and logging. Exit with
  apply's status.
- `theme --reset`: remove the choice file and run apply the same way.
- `-h` / `--help`, and a `#USAGE` spec as every `local/bin` script carries.

### Live switching

- Handled apps (tmux, starship and the rest that read their config on each use): through apply, immediately.
- Open shells: `LS_COLORS`, `BAT_THEME` and the fzf colours live in each shell's environment, loaded at startup from
  the caches the handlers write under `$XDG_STATE_HOME/dotfiles-theme/` (`ls-colors`, `bat-theme`,
  `fzf-active.sh`, `fzf-active.fish`). Each shell reloads them at its next prompt when a cache has changed since it
  last loaded: a new prompt hook in bash (`PROMPT_COMMAND`) and zsh (`precmd`), and fzf added to fish's existing
  `conf.d/theme-switch.fish` refresh. The shell `theme` ran in updates at the prompt that follows the command, so
  `theme` needs no shell-function wrapper. The hooks run on every prompt, so the unchanged case must cost no
  subprocess: builtin file tests or a cheap stamp comparison only.
- vim: its existing 3-second timer re-resolves the family; only its resolver changes.
- nvim: a timer like vim's re-resolves the family and runs `colorscheme` for the new one when it changes. All three
  colourscheme plugins are already added and set up at startup, and `background` keeps following auto-dark-mode.
- wezterm: reloads its config when the family changes, so a switch reaches open windows without a manual reload.

### `dfm theme`

A new `local/bin/dfm-theme` section, added to `DFM_SECTIONS` in `local/bin/dfm`, with a `#USAGE cmd "theme"` block
that matches its menu (`tests/dfm-sections.bats` checks that parity):

- `dfm theme family [name]` runs `theme` (list, or switch).
- `dfm theme reset` runs `theme --reset`.
- `dfm theme mode` runs `theme-mode`.
- `dfm theme reapply [dark|light]` runs the `theme-reapply` shell function, which dfm's full bootstrap defines by
  sourcing `config/exports`. Its `LS_COLORS` / `BAT_THEME` refresh reaches only dfm's own process.

## My calls

Decided without asking; easy to change:

- The reset is a `--reset` flag rather than a `reset` argument, so it can never clash with a family named `reset`.
- Listing style: an arrow plus bold colour on a terminal, a plain `*` marker when output is not a terminal.
- A saved choice that no longer passes the rule (family removed, file edited by hand) is skipped and the tracked
  default applies; `theme` with no arguments warns about it. `DOTFILES_THEME_FAMILY` keeps failing closed as today.
- vim, nvim and wezterm fall back to `oasis` instead of `catppuccin` when no family resolves, matching the default.
- On machines set up before this change, the old `family` record (apply's last family) is read as a saved choice.
  It names the family already in use, so nothing changes on screen; `theme --reset` returns to following the
  default. A record of `-` (unresolvable) fails the rule and is skipped.
- nvim polls on a timer, as vim does, rather than watching the file.
- `theme <family>` writes the choice before apply takes its lock; apply resolves the family under the lock, so
  concurrent switches settle on the last write.
- With `DOTFILES_THEME_FAMILY` exported (tests only), `theme` still saves the choice and warns that the override wins.
- nvim's resolver gains the slug rule the other readers already apply.
- Existing machines run `./install --links` once so `theme` and `dfm-theme` are linked into `~/.local/bin`.

## Left to the builder

- The exact output text, colours and exit codes, following `local/bin` conventions (`msgr` only if `theme` prints
  messages beyond the list).
- How wezterm learns of a family change: watching the choice file, or relying on apply rewriting a file already on
  its watch list. A choice file that does not exist yet must not break the watch.
- The change-detection mechanism in the prompt hooks (cache mtimes, a stamp file written by apply, or similar),
  within the no-subprocess constraint above, and how the hooks coexist with the existing `PROMPT_COMMAND` entries
  and zsh `precmd` functions.
- Test layout: a new `tests/theme.bats`, plus updates to the resolver, actor and dfm tests for the new order and
  the moved record.
- Doc updates: `config/theme/CLAUDE.md`, `.claude/rules/theme-handler-contract.md`, `config/nvim/CLAUDE.md` and
  `README.md`, and the dfm command list in `local/bin/CLAUDE.md`.
