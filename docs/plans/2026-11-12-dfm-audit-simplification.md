# Plan: dfm audit — simplification, consistency, error tolerance, speed

Date: 2026-11-12
Status: APPROVED (revision 5, 2026-11-13) — implemented, uncommitted until the user says otherwise

## Goal

Make `dfm` smaller, consistent across its sections, honest about failure (exit status and visible messages),
and fast on menu and light paths — on macOS (stock bash 3.2), Debian/Ubuntu, Fedora and minimal Linux, whichever
shell launches it. Move package management fully onto mise (`[bootstrap.packages]`, mise's own Homebrew
support instead of the brew CLI), and make `dfm theme` the one place to switch, re-apply and inspect themes.

Decisions taken with the user on 2026-11-12:

- Remove the dead and duplicate commands; an unknown section or subcommand prints an error plus the menu and
  exits 2; the top-level listing renders in-process from the `#USAGE` blocks; `check arch` reports `uname -m`
  and a new `check os` reports what `arch` reports today.
- Revision 2: no `!` or `BREAKING CHANGE` footers on these commits (the user's explicit instruction, overriding
  `.claude/rules/commit-format.md` for this work); `reset_nvim` becomes `reset-nvim`; apt and Homebrew packages
  go through `mise bootstrap packages`, the Brewfile moves into mise config, `tools/apt.txt` is deleted; one
  `dfm packages` section replaces `dfm apt` and `dfm brew`; `dfm apt upkeep` (whole-system upgrade) is dropped;
  `dfm install all` runs `mise bootstrap`; fonts come from `brew-cask:` font casks on macOS and Linux;
  `dfm install imagick` is dropped; the theme commands move into `dfm theme` while the engine stays in
  `config/theme/`.
- Composer: nothing to remove. #807 already dropped it from `dfm install all`; only `COMPOSER_HOME` exports and
  the PHP helpers mention composer.
- Revision 3: phpenv stays as the PHP version manager; `x-set-php-aliases` and `php-switcher` are deleted; mise
  is told to leave `php` alone so it does not compete with phpenv. Teaching phpenv to install through mise is a
  change to the `ivuorinen/phpenv.fish` repo, not this one (see Open questions).
- Revision 4, found during implementation (2026-11-12):
    - Fonts: on Linux mise's `brew-cask` installs font casks only after creating a Linuxbrew prefix with sudo
      (`mise creating /home/linuxbrew/.linuxbrew (requires sudo once)`). With the user, the font casks became
      macOS-only (in `conf.d/brew/mise.macos.toml`); Linux keeps `scripts/install-fonts.sh` and
      `dfm install fonts`, and `dfm install all` runs that step on Linux only. Commit 9.3 therefore keeps them.
      `conf.d/brew/mise.toml` had no entries left and was deleted (an env-only fragment loads, tested).
    - `check host` uses `uname -n`, not `$HOSTNAME`: bash keeps an inherited `HOSTNAME`, which a parent shell had
      set to the short name.
    - The `codeql` cask was not migrated: `[tools]` already pins `codeql`.
    - The macOS check (7.4, 2026-11-13): conda `imagemagick` runs on Apple silicon; coreutils, ffmpeg, fontconfig
      and gnupg count as already installed. `antidot` (its tap needs Ruby 3 to evaluate) and `fantastical`
      (Caskroom metadata error) failed; the user dropped both, so the `antidot` init lines in `base/bashrc` and
      `base/zshrc` went too. `voikkospellservice` failed (`unsupported artifact type service`); the user dropped
      it and `libvoikko` with it. Checked one by one, every remaining cask is already installed except four, which
      the user dropped with ten more: `session-manager-plugin`, `font-fira-code`, `font-opendyslexic-nerd-font`,
      `ngrok`, `dbeaver-community`, `dbngin`, `insomnia`, `lens`, `sequel-ace`, `suspicious-package`, `thonny`,
      `todoist-app`, `ungoogled-chromium`, `visual-studio-code`. 30 casks remain, all already installed, so the
      move reinstalls nothing. Dropping a cask from config uninstalls nothing (no `prune`).
    - Order: Commits 10–15 run before 8–9 while the macOS check (7.4) is pending.
- Revision 5, the user's follow-ups (2026-11-13):
    - Fonts stay split by OS. Open Sans cannot move into `scripts/install-fonts.sh`: `googlefonts/opensans` has
      no release or tag, and the `font-open-sans` cask clones `google/fonts`. The script drops FiraCode and
      OpenDyslexic. Two bugs found on the way: its Nerd Font check glob `JetBrainsMonoNL*` matched the plain
      JetBrains Mono vendored in `local/share/fonts`, so the Nerd Font never installed on Linux; and
      `monaspace-*.zip` matched all five Monaspace builds, taking the first listed (frozen). The globs are now
      `JetBrainsMonoNerdFont*` and `monaspace-static-*.zip`, the build the `font-monaspace` cask installs.
    - `Brewfile.lock.json` left the ignore lists (`.gitignore`, `.prettierignore`, `.yamllint.yml`,
      `biome.json`, `.exclusion-baseline.json`); `scripts/cleanup-old-version-managers.sh` (`dfm cleanup
      old-vms`) deletes `$XDG_CONFIG_HOME/homebrew/Brewfile.lock.json`. `HOMEBREW_BUNDLE_MAS_SKIP` went with it:
      only `brew bundle` reads it.
    - `brew:fswatch` removed: nothing in the repo uses it, which the formula's own comment already said.
    - `.v8rrc.yml` maps `tools/dotbot-defaults.yaml` to `schemas/dotbot.schema.json`. Both v8r gates
      (`.mise/tasks/lint-v8r`, the `v8r` hook) excluded all of `^tools/`; with the user's approval they now
      exclude only the submodules, `tools/antidote/` and `tools/dotbot/`, so the gates read that entry.
    - fish 3 names the built-in theme `fish default`; `config/fish/config.fish` tries both names. The gpg and
      special-character fish tests run `fish --no-config`, and the nvim resolver tests keep stderr separate.
    - Commits: Commits 2, 4, 5 and 6 share the prelude, dispatch and fallback lines of every section, so they
      landed as one `feat(dfm): rebuild the dispatcher, menus and section scaffolding`; Commit 1's `dfm.md`
      summary went into `docs(dfm): describe the reworked dfm` with the other dfm docs. The rest kept their
      own commits, and the follow-ups above got one each.

## Scope & constraints

Touches `local/bin/dfm`, `local/bin/dfm-lib`, the `local/bin/dfm-*` sections (new `dfm-packages`; `dfm-apt` and
`dfm-brew` deleted), `local/bin/theme` (deleted), `local/bin/dfm.md`, `local/bin/CLAUDE.md`, `install`,
`tools/dotbot-defaults.yaml`, `scripts/install-completions.sh`, `scripts/install-fonts.sh` (deleted),
`tools/apt.txt` (deleted), `config/homebrew/Brewfile` (deleted), `config/mise/config.toml`,
`config/mise/conf.d/**`, `config/theme/apply`, the `theme-reapply` functions in `config/exports` and
`config/fish/functions/`, the bats files, and the docs that name any of these.

Must not change:

- The git-style dispatch (`dfm <section>` → `dfm-<section>`, sibling first, then `$PATH`) and `$DFM` re-dispatch.
- The menu and listing path keeps running on bash 3.2 (it already skips the bash-4 guard).
- `dfm check perms --fix` semantics (it runs from `install.conf.yaml`).
- Secrets handling: values are never printed by `list`; files stay 0600 in 0700 directories.
- `dfm` runs before mise, `usage` or any mise-installed tool exists; `dfm install all` bootstraps them.
- The theme engine (`config/theme/watcher`, `apply`, `_lib.sh`, `handlers.d/`, `palettes.d/`) stays where it
  is, and `local/bin/theme-mode` stays a standalone script: tmux, wezterm, television and prompts read it.
- The native brew CLI stays installed for what lives outside dfm (see Open questions); dfm stops calling it.

### Evidence gathered (this session, this machine: Linux, mise 2026.11.5, `git` through a mise shim)

| Path                                                | Measured                                        |
|-----------------------------------------------------|-------------------------------------------------|
| `dfm` (top-level listing, 12 bash processes)        | 416 ms                                          |
| `dfm ssh` menu (runs `git config` at load)          | 240 ms; 10 ms with `DFM_SSH_GITHUB_USER` preset |
| `dfm check arch`, `dfm theme mode` (full bootstrap) | 264 ms, 268 ms                                  |
| `source config/shared.sh` alone                     | 191 ms                                          |
| `dfm docs` / `dfm scripts` menus (forks per file)   | 42 ms / 38 ms                                   |
| other section menus                                 | 10–13 ms                                        |

Defects confirmed against source:

1. `install.conf.yaml` runs `dfm install all` through dotbot, which by default connects shell stderr to
    `/dev/null` (`tools/dotbot/README.md:307-309`; `tools/dotbot-defaults.yaml` sets only `stdout: true`). Every
    `msgr warn`/`msgr err` (both write to stderr) is discarded, and `install all` exits 0 after failed steps
    (`run_step` returns 0; the closing summary never sets a status). A partial install looks clean.
2. The bash-4 guard in `dfm_bootstrap` stops every action on stock macOS bash 3.2, including `dfm install all`,
    the step that installs a newer bash. Under dotbot stdin is `/dev/null`, so it prints a hint and exits 1. The
    only bash-4 code in dfm, `shared.sh`, `lib.sh` and `exports` is `secrets_list` (`dfm-lib:325`, `:344`).
3. `dfm dotfiles yamlfmt` ends with `! x-have yamlfmt && …`, which returns 1 whenever yamlfmt is installed, so
    `dfm dotfiles fmt` never reaches shfmt. `.yamlfmt` does not exist; YAML is formatted by prettier
    (`mise run fix`). Its shfmt flags duplicate the prek `shfmt` hook with one difference (`--language-dialect
    bash` forces bash parsing on the POSIX scripts).
4. `tools/apt.txt` contains only a header, so `dfm apt install` runs `sudo apt install -y` with no packages. The
    real list is already `[bootstrap.packages]` in `config/mise/conf.d/system-packages/mise.linux.toml`.
5. `scripts/install-completions.sh` hardcodes a section list that omits `theme`, so `dfm theme` gets no
    completion, markdown or manpage.
6. Failures reported as success: `dfm brew update` (prints an error, returns 0), `dfm cleanup caches|mise|docker`
    (print "complete" whatever the tools returned), `dfm install cheat-databases` (failed scripts silent),
    `dfm scripts <unknown>` (error, exit 0).
7. Every section ships its menu twice: a `MENU=( … )` array and the `#USAGE` block used for completions. Three
    bats tests exist only to keep the two in step.
8. `dfm-lib` sources `msgr` on both bootstrap paths (with an ordering workaround against `shared.sh`), but no dfm
    code calls a msgr function — every call is `msgr <verb>`, the external command. `shared.sh` defines its own
    `msg_*` fallbacks.
9. `dfm check arch` prints `uname` (the OS); `dfm check` runs `hostname` and `uname` on every invocation,
    including its menu, and `hostname` is absent on minimal Arch and Fedora images.
10. `dfm install all` re-sources `shared.sh` just before exiting (191 ms, no effect on the calling shell).
11. `dfm docs help` reports "Documentation not found" and `dfm scripts help` reports "Script not found": the two
    free-argument sections ignore the `help`/`-h`/`--help` that `dfm_bootstrap_for` treats as the menu path.
12. `theme-reapply` exists twice — a bash function in `config/exports` and a fish function — and runs the
    handlers one by one without `apply`'s timeout, lock or generation stamp. `dfm theme reapply` needs the full
    bootstrap only to reach the bash copy.
13. `dfm install all` applies packages in four steps (apt, dnf, the mise brew apply on macOS, `install macos`)
    with hand-kept ordering comments; `mise bootstrap` applies the same parts in a fixed order of its own
    (packages, then macOS defaults, then the login shell, then tools — `mise bootstrap --help`).

mise facts this plan relies on (`mise bootstrap --help`, `mise bootstrap packages * --help` on 2026.11.5, and the
mise v2026.11.0 docs fetched through Context7 this session):

- `mise bootstrap packages` has `apply` (`--manager`, `--dry-run`, `--yes`, `--update`), `status`, `upgrade`,
  `prune`, `import`, `use` and `brew` (tap URLs in `[bootstrap.brew.taps]`). Without `--manager`, an unavailable
  manager is skipped; with it, it is an error.
- `brew` and `brew-cask` install formulae and casks without the Homebrew CLI. A tap such as `doron-cohen/tap`
  resolves to `github.com/doron-cohen/homebrew-tap` without a `[bootstrap.brew.taps]` entry.
- `brew-cask` supports app, binary, font, `pkg` (when the cask lists its `pkgutil` IDs), script-installer and
  generic artifacts; services and other artifact types are not supported. On Linux it installs font casks
  without pre/postflight steps into `$XDG_DATA_HOME/fonts` and shows other casks as skipped.
- `mise registry` lists `imagemagick` (`conda:imagemagick`, then an asdf plugin).

## Tasks

Commits land in this order on `chore/dfm`. Each commit uses `git-hunk` and the conventional format without `!`
or a `BREAKING CHANGE` footer. Every task ends with `shellcheck` + `shfmt -d` +
`mise exec -- editorconfig-checker` on the files it touched; TOML and YAML also get `mise exec -- v8r`
(the mise files declare `#:schema https://mise.jdx.dev/schema/mise.json`) or `yamllint`.

### Commit 0 — no commit: baseline

1. Run `mise run test` and `mise run lint`; record `hyperfine --warmup 3` for `bash local/bin/dfm`,
    `… dfm install`, `… dfm check arch`, `… dfm theme mode`, `… dfm ssh`, `… dfm docs`. — files: none — verify:
    both gates exit 0 before any edit; the numbers are kept for the final comparison.

### Commit 1 — `docs(dfm): correct the dfm.md summary`

1. Rewrite `local/bin/dfm.md`: `docs` shows docs (it does not regenerate them); list the real sections; drop the
    "debug output" wording for `VERBOSE` (it surfaces the exports setup messages). Later commits update the
    lines their changes touch. — files: `local/bin/dfm.md` — verify: every command named in it appears in a
    `#USAGE` block (`rg -n 'cmd "' local/bin/dfm-*`).

### Commit 2 — `refactor(dfm): drop the unused msgr sourcing and collapse the section prelude`

1. In `dfm-lib`: delete both `source …/msgr` lines and the shared.sh/msgr ordering comment; with nothing left in
    `dfm_bootstrap_min` but the variable setup, merge `dfm_bootstrap_vars` into it (one function).
    `dfm_bootstrap` becomes `dfm_bootstrap_min` + `source "$DOTFILES/config/shared.sh"`. — files:
    `local/bin/dfm-lib` — verify: `rg -n -w -e msg -e 'msg_[a-z_]+' -e ask local/bin/dfm*` finds no direct calls
    (checked 2026-11-12); `dfm.bats` "does not leak exports setup messages" and "VERBOSE=1 still surfaces" pass;
    `dfm tests msgr` output is byte-identical before and after (`diff`).
2. Replace the 9-line prelude in all 13 sections with two lines:
    `_dfm_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)` and
    `source "$_dfm_dir/dfm-lib" || { echo "${0##*/}: cannot load dfm-lib (broken install?)" >&2; exit 1; }`.
    — files: `local/bin/dfm-*` — verify: full bats suite; running `dfm-install` directly through a
    `~/.local/bin` symlink still finds `dfm-lib` (manual).

### Commit 3 — `fix(install): finish the run and report failure instead of stopping`

Lands before Commit 9: once `dfm install all` can exit non-zero, `./install`'s `set -e` would otherwise skip the
host overlay and the `after.d` hooks, which run on every install today.

1. In `install`: run the main dotbot call and `run_host_config` as `… || rc=$?` (keep the first non-zero), run
    `run_host_hooks after` regardless, `exit "$rc"`. The `--links` path is unchanged. — files: `install` —
    verify: new `tests/install.bats` case runs a copy of `install` in a temp tree with a `git` stub (exit 0), a
    stub `tools/dotbot/bin/dotbot` that records calls and exits 1, a `hosts/<host>/install.conf.yaml` and an
    `after.d` hook that writes a marker → host config was called, the marker exists, exit status 1.
2. In `tools/dotbot-defaults.yaml`, add `stderr: true` under `shell:` (key and default quoted from
    `tools/dotbot/README.md:307`). — files: `tools/dotbot-defaults.yaml` — verify: `dotbot-validate` skill and
    `yamllint`; `./install --links` output unchanged (it runs no shell steps).

### Commit 4 — `perf(dfm): stop paying for the shell environment where it is not used`

1. `dfm-ssh`: resolve the `DFM_SSH_GITHUB_USER` default inside `dfm_ssh_github` (env override unchanged). —
    files: `local/bin/dfm-ssh` — verify: `hyperfine 'bash local/bin/dfm ssh'` below 30 ms; `dfm-ssh.bats` passes.
2. `dfm-check`: drop the eager `X_HOSTNAME=$(hostname)` / `X_ARCH=$(uname)`; `host` uses bash's `$HOSTNAME`
    (same `gethostname()` value, no binary needed); `arch` computes its value in its own branch. — files:
    `local/bin/dfm-check` — verify: `dfm.bats` check host/arch tests pass.
3. Remove the bash-4 guard: rewrite `secrets_list` without `local -A`/`mapfile` (names via `${f##*/}`, one
    `sort -u`), delete the guard from `dfm_bootstrap`, delete the `dfm-lib.bats` guard test. Add two tests:
    a static one that fails on bash-4-only syntax in `local/bin/dfm*` (`local -A`, `declare -A`, `mapfile`,
    `readarray`, `${v,,}`, `${v^^}`, `declare -n`, `local -n`, `|&`, `&>>`, `;;&`), and one that runs a
    full-bootstrap action with `/bin/bash` and skips when `/bin/bash` is 4+. — files: `local/bin/dfm-lib`,
    `tests/dfm-lib.bats` — verify: the static test fails on a planted `local -A x` (control), then passes on the
    tree; `dfm.bats` secrets list tests (414, 424) pass; if the `bash:3.2` image can be pulled, run
    `docker run --rm -v "$PWD":/r -w /r bash:3.2 bash local/bin/dfm secrets list` against a fake `DOTFILES`.
4. Light bootstrap: `dfm-docs`, `dfm-ssh`, `dfm-secrets` and `dfm-tests` call `dfm_bootstrap_min`; `dfm-check`
    uses `dfm_bootstrap_min` for `a|arch|h|host|hostname|perms` and `dfm_bootstrap_for` otherwise; `dfm-theme`
    uses `dfm_bootstrap` for `reapply` and `dfm_bootstrap_min` otherwise (Commit 12 makes it light throughout).
    — files: those 6 sections — verify: `dfm check arch` and `dfm theme mode` below 40 ms; full bats suite;
    `dfm check perms --fix` behaves the same (`dfm-check-perms.bats`).
5. Fork-free menus: `menu_builder` builds its rule with `printf -v` and `${rule// /─}` instead of two `seq`
    calls; `dfm-docs` reads all titles in one `awk`; `dfm-scripts` builds its menu only on the menu path, takes
    names by parameter expansion and descriptions in one `awk` (absorbing `get_script_description`, its only
    user); `dfm helpers colors` loops arithmetically instead of one `seq` per row. — files: `dfm-lib`, `dfm-docs`,
    `dfm-scripts`, `dfm-helpers` — verify: output byte-identical before/after for `dfm docs`, `dfm scripts`,
    `dfm helpers colors` and every section menu; `dfm docs` below 20 ms.

### Commit 5 — `refactor(dfm): render the menus from the #USAGE blocks`

1. Add `dfm_menu FILE` to `dfm-lib`: read the file's leading `#USAGE` lines (stop at the first other line after
    the shebang), take each depth-1 `cmd "NAME" help="HELP"`, append its nested `arg`/`flag` names, and print
    through `menu_builder` titled `dfm <section> <command>` (or `dfm <section> <args>` when the section has no
    subcommands). Column width is the longest name, at least 20. Add `dfm_fallback ARG`, which prints the menu
    for an empty argument or `help`/`-h`/`--help` and, in this commit, also for anything else (exit 0, as
    today). Bash 3.2 only: `[[ =~ ]]` and `BASH_REMATCH`, no forks. — files: `local/bin/dfm-lib` — verify:
    `dfm-lib.bats` fixture tests (name, args and help rendered; lines after the block ignored; a section
    without subcommands is titled with its args).
2. In the sections with fixed menus, replace `MENU`, `USAGE_PREFIX` and the `menu_builder` call with
    `*) dfm_fallback "${1:-}" ;;`. Move text that lived only in `MENU` into the `#USAGE` help (the exit codes of
    `check arch`/`host`, the shell list of `helpers aliases`, "write nothing" on `ssh check`); add `alias` lines
    for `ssh`'s `s`, `c` and `gh` and `arg "[user]"` on `ssh github`. `dfm-docs` and `dfm-scripts` keep their
    generated menus. — files: `local/bin/dfm-*`, `tests/dfm-ssh.bats` (expects `github [user]`) — verify:
    `mise run lint-usage`; every section menu lists the same commands as before.
3. Delete the three parity tests (`dfm-sections.bats` "every USAGE-declared subcommand appears in its menu",
    `dfm-ssh.bats` and `dfm-cleanup.bats` "the menu entries match the USAGE spec") — the menu is the spec now.
    — files: those 3 test files — verify: suite passes; `rg -n 'match the USAGE spec|USAGE-declared' tests`
    is empty.
4. Top-level listing in one process: `usage()` keeps the tool gate and calls `dfm_menu` on each
    `dfm-<section>` file instead of executing it. — files: `local/bin/dfm`, `tests/dfm.bats` — verify:
    `hyperfine 'bash local/bin/dfm'` below 60 ms; `dfm.bats` "full usage with all sections" passes.
5. `scripts/install-completions.sh`: replace the hardcoded section list with the executable `local/bin/dfm-*`
    files. — files: `scripts/install-completions.sh` — verify: after `bash scripts/install-completions.sh`,
    `rg -n theme config/fish/completions/dfm.fish` matches (the generated files are gitignored);
    `tests/install-completions.bats` passes.
6. Move the `secrets_*` functions from `dfm-lib` into `dfm-secrets`, their only user. — files: `dfm-lib`,
    `dfm-secrets`, `local/bin/CLAUDE.md` — verify: `git grep -n 'secrets_[a-z_]*('` lists only `dfm-secrets`;
    `dfm.bats` secrets tests (286–558) pass.
7. `[[ $OSTYPE == darwin* ]]` replaces the `uname`/`uname -s` Darwin tests in `dfm-install` and `dfm-check`. —
    files: `dfm-install`, `dfm-check` — verify: `rg -n uname local/bin/dfm*` shows only the `arch` branch.

### Commit 6 — `feat(dfm): exit 2 on an unknown section or command`

Lands before the removals, so a removed command fails loudly instead of printing a menu with status 0.

1. `dfm_fallback`: an unknown argument prints `msgr err "unknown command: dfm <section> <arg>"` and the menu to
    stderr and exits 2. The dispatcher does the same for an unknown section and drops its "historical
    behaviour" comment. `dfm-docs`/`dfm-scripts`: `help`/`-h`/`--help` show the menu; an unknown name prints the
    error plus "run 'dfm docs' to list" and exits 2. `dfm helpers aliases` with a missing or unknown shell exits
    2. — files: `dfm-lib`, `dfm`, `dfm-docs`, `dfm-scripts`, `dfm-helpers` — verify: `dfm.bats` 28 and 52 expect
    status 2 and "unknown command", 90 expects 2; the three "unknown subcommand shows the menu" tests also
    assert status 2; new tests: `dfm docs help` and `dfm scripts --help` show the menu with status 0.
2. Update `local/bin/CLAUDE.md` and `local/bin/dfm.md`.

### Commit 7 — `feat(mise): move the Brewfile and the fonts into [bootstrap.packages]`

The Brewfile stays in this commit (`dfm-brew` still reads it); Commit 8 deletes it after the macOS check.

1. Move every `brew:` entry from `config/mise/conf.d/brew/mise.toml` into `conf.d/brew/mise.macos.toml`, which
    loads on macOS only (`auto_env`). dfm applies brew formulae only on macOS today ("Linux hosts get their
    packages from apt/dnf, not a linuxbrew prefix"); after the move, a plain `mise bootstrap` on Linux never
    pours into a Homebrew prefix. Add the Brewfile's formulae (`coreutils`, `ffmpeg`, `fontconfig`, `gnupg`,
    `doron-cohen/tap/antidot`) and its 40 non-font casks (`brew-cask:`) to the same file. Rewrite the header
    comments that say casks and these formulae are "kept on native brew". — files: both `conf.d/brew` TOML files
    — verify: `v8r`; on Linux, `mise bootstrap packages status` lists no `brew:` entry.
2. ImageMagick: check `mise exec imagemagick@latest -- magick -version` on Linux. If it runs, pin `imagemagick`
    in `config/mise/config.toml` `[tools]` (both OSes get `magick`, which `x-thumbgen` needs); otherwise add
    `brew:imagemagick` to `mise.macos.toml`, and Linux keeps no `magick` (`x-thumbgen` already prints an install
    hint). — files: `config/mise/config.toml` or `mise.macos.toml` — verify: `command -v magick` after
    `mise install`.
3. Fonts: `brew-cask:` font entries in `conf.d/brew/mise.toml` (loaded on every OS), the union of
    `scripts/install-fonts.sh` (JetBrainsMono Nerd Font, OpenDyslexic Nerd Font, Monaspace, FiraCode) and the
    Brewfile's font casks (`font-jetbrains-mono`, `font-jetbrains-mono-nerd-font`, `font-monaspace`,
    `font-monaspace-nf`, `font-open-sans`). Confirm each cask name with
    `mise bootstrap packages apply --dry-run brew-cask:<name>` on Linux before writing it. — files:
    `conf.d/brew/mise.toml` — verify: a real `apply --manager brew-cask` on Linux puts the fonts in
    `$XDG_DATA_HOME/fonts`; `fc-list | rg -i 'JetBrainsMono|Monaspace|FiraCode|OpenDyslexic'` finds them.
4. macOS check, run by you on a Mac (this Linux box shows macOS casks only as skipped): `mise bootstrap packages
    status` and `mise bootstrap packages apply --dry-run`. Report back every entry that cannot resolve (a `pkg`
    cask without `pkgutil` IDs, a services artifact) and any already-installed app mise would reinstall. —
    files: none — verify: your report. Abort point: Commit 8 deletes the Brewfile only after this is clean or
    each failing entry has a decision.

### Commit 8 — `feat(dfm): manage packages through one dfm packages section`

1. New `local/bin/dfm-packages`: `apply` (`mise bootstrap packages apply --yes`), `status`
    (`mise bootstrap packages status`; `--missing` decides the exit status, as `dfm check brew` does today) and
    `upgrade` (`mise bootstrap packages upgrade --yes`). No mise → error naming `dfm install mise`, exit 1. Not
    a sudoer (`is-sudoer`) → `apply`/`upgrade` warn and skip, as `install apt-packages` does today (apt and dnf
    need sudo). `prune` is not exposed: it uninstalls every formula and cask no config declares, which includes
    the native-brew PHP stack. — files: `local/bin/dfm-packages`, new `tests/dfm-packages.bats` — verify: a
    `mise` stub records the exact arguments for each command; non-sudoer and missing-mise paths tested.
2. Delete `dfm-apt` and `dfm-brew` (their `upkeep`, `install`, `update`, `upgrade`, `autoremove`, `clean`,
    the five deprecated stubs), `install apt-packages` and `install dnf-packages`. In the dispatcher, add
    `packages` to `DFM_SECTIONS`, remove `apt` and `brew`, and delete `dfm_section_requires` with its gate.
    `check brew` becomes `check packages` (`"$DFM" packages status`); `check updates` drops `brew outdated`;
    `check disk` drops the brew cache line; `cleanup brew` goes and `cleanup all` follows. — files: `dfm`,
    `dfm-check`, `dfm-cleanup`, `dfm-install`, the deleted files, `tests/dfm.bats` (173, 185, 200, 208),
    `tests/dfm-sections.bats` — verify: bats suite; `dfm check packages` on Linux exits 0 when apt packages are
    installed.
3. Delete `config/homebrew/Brewfile`, the `BREWFILE` variable and `tools/apt.txt`. Search first
    (`.claude/rules/grep-before-delete.md`) and update each reference: `.gitignore`, `.prettierignore`,
    `.yamllint.yml`, `biome.json`, `.exclusion-baseline.json`, `config/exports`, `config/fish/exports.fish`,
    `config/nvim/lua/options.lua`, `docs/mise.md`, `tests/pre-bash-route.bats` (leave it if the name is only a
    test string), the Brewfile example in `.claude/rules/read-routing.md`, and the comments in
    `conf.d/system-packages/mise.linux.toml`, `conf.d/macos-defaults/mise.macos.toml` and
    `local/bin/is-sudoer`. `config/homebrew/brew.env` and `trust.json` stay while the brew CLI exists. — verify:
    `git grep -n -e Brewfile -e BREWFILE -e apt.txt -e apt-packages -e dnf-packages` finds only history.
4. Update `README.md`, `.github/copilot-instructions.md`, `local/bin/CLAUDE.md` (the tool-gated sections
    paragraph goes) and `local/bin/dfm.md`.

### Commit 9 — `feat(dfm): run install all through mise bootstrap`

1. `dfm install all` becomes: Xcode CLI tools (macOS) → `ensure_mise` → the `GITHUB_TOKEN` prompt (moved from
    the mise step) → `mise bootstrap --yes`, or `mise bootstrap --yes --skip packages` when not a sudoer (fonts do
    not matter on the SSH-only hosts without sudo) → `mise reshim` → cheat databases → gh extensions → completions.
    The summary stays, and the step returns 1 when any step failed. Check the part name with `mise bootstrap
    --help` and preview with `mise bootstrap --dry-run` on Linux before writing. — files: `local/bin/dfm-install`,
    new `tests/dfm-install-all.bats` — verify: a fake `DOTFILES` tree (stub `install-*.sh`, an `is-sudoer` stub,
    empty `config/shared.sh`) and a `mise` stub that records arguments: sudoer → `bootstrap --yes`, non-sudoer →
    `bootstrap --yes --skip packages`; one failing step → status 1 with the step named in the summary; all
    passing → status 0 and "All done!". Every installer the step calls comes from `$DOTFILES` or a stub.
2. `dfm install mise`: `mise install --yes` + `mise reshim` + the token prompt; the macOS brew apply moves out
    (it is part of `mise bootstrap` and `dfm packages apply`). It ends with a warning instead of the success line
    when `install` or `reshim` failed (still exit 0: host-unsupported tools stay tolerated). `install macos` stays
    (`mise bootstrap --only macos-defaults,user --yes`). — files: `dfm-install`, `tests/dfm-install-mise.bats`.
3. Delete `install fonts` with `scripts/install-fonts.sh` and `tests/install-fonts.bats`; delete `install imagick`
    with `tests/dfm-install-imagick.bats`; delete `install mise-cleanup` (`dfm cleanup old-vms` takes over in
    Commit 10). `cheat-databases` reports each failing script and returns 1. Delete the trailing
    `source shared.sh` of `install all` and reword its opening line. — files: `dfm-install`, the deleted files,
    `tests/dfm-sections.bats` (its `@description` test names install-fonts; point it at another script) —
    verify: `git grep -n -e install-fonts -e 'install imagick' -e mise-cleanup` finds only history.

### Commit 10 — `feat(dfm): trim dfm dotfiles and dfm cleanup`

1. `dfm-dotfiles`: delete `yamlfmt` and `reset_all`. `shfmt` runs the repo's own hook,
    `(cd "$DOTFILES" && mise exec -- prek run shfmt --all-files)`; `fmt` runs `mise run fix` and then that hook;
    a missing `mise` is an error with exit 1. Check `prek run --help` (prek 0.5.10) for the hook-id and
    `--all-files` form before writing it. — files: `local/bin/dfm-dotfiles` — verify: `dfm dotfiles fmt` exits 0
    on a clean tree and leaves `git status` clean; a deliberately misformatted script is fixed by
    `dfm dotfiles shfmt`.
2. Rename `reset_nvim` to `reset-nvim` (hyphenated like `docs-nvim` and `cheat-databases`). Use
    `${XDG_DATA_HOME:-…}`, `${XDG_STATE_HOME:-…}`, `${XDG_CACHE_HOME:-…}` and `${XDG_CONFIG_HOME:-…}`; ask for
    confirmation when stdin is a terminal (non-terminal runs as today); `return 1` instead of `exit 1`; drop
    "astronvim" from the message. — files: `local/bin/dfm-dotfiles`, `tests/dfm-sections.bats` — verify: run
    with `HOME` and the XDG variables in `BATS_TEST_TMPDIR` and a `mise` stub → the four nvim directories are
    gone and `$XDG_CONFIG_HOME/nvim` links to `$DOTFILES/config/nvim`.
3. `dfm-cleanup`: `caches`, `mise` and `docker` collect each tool's status and print the success line only on
    success; `old-vms` passes its arguments on and its `#USAGE` gains `flag "--dry-run"`
    (`scripts/cleanup-old-version-managers.sh` accepts it). — files: `local/bin/dfm-cleanup`,
    `tests/dfm-cleanup.bats` — verify: a failing `mise`/`uv`/`docker` stub → status 1 and no "complete" line;
    `cleanup all` exits 1; `dfm cleanup old-vms --dry-run` reaches the script with the flag.
4. Update the docs and menu tests that name the changed commands (`dfm.bats` 138, `README.md`,
    `.github/copilot-instructions.md`, `local/bin/CLAUDE.md`, `local/bin/dfm.md`).

### Commit 11 — `feat(dfm): report the CPU in check arch and add check os`

1. `arch` prints and compares `uname -m`; new `os` prints and compares `uname -s`; both on the light path;
    `#USAGE` updated. — files: `local/bin/dfm-check`, `tests/dfm.bats` (244–258), `tests/dfm-sections.bats`
    (76), `local/bin/CLAUDE.md`, `.github/copilot-instructions.md` — verify: arch tests compare against
    `uname -m`; new os tests (current value exits 0, `FakeOS` exits 1).

### Commit 12 — `feat(theme): switch, re-apply and inspect themes from dfm theme`

1. `config/theme/apply --force <mode>` runs every handler even when the mode and family are unchanged, through
    the same parallel fork, 5 s timeout, `apply.lock` and `generation` stamp. Without `--force`, behaviour is
    unchanged (the watcher's call). — files: `config/theme/apply`, the apply tests (`tests/theme-handlers.bats`)
    — verify: unchanged apply skips; `--force` runs every handler and rewrites `generation`.
2. Move `local/bin/theme` into `dfm-theme`. `dfm theme family` lists the families with the active one marked,
    keeping today's warnings about an ignored saved choice and a `DOTFILES_THEME_FAMILY` override.
    `dfm theme family <name>` saves the choice and applies; `dfm theme reset` removes it and applies.
    `dfm theme reapply [mode]` validates the mode and runs `config/theme/apply --force "${1:-$(theme-mode)}"`.
    Every command runs on `dfm_bootstrap_min`. Delete `local/bin/theme`; port `tests/theme.bats` to
    `tests/dfm-theme.bats`. — files: `local/bin/dfm-theme`, `local/bin/theme`, the two test files — verify: the
    ported tests pass; `dfm theme reapply` is below 40 ms plus the handlers' own time.
3. `dfm theme status`, read-only, from `$XDG_STATE_HOME/dotfiles-theme/`: the mode; the family and where it came
    from (`DOTFILES_THEME_FAMILY`, saved choice or the tracked default); the watcher (pid from `daemon.pid`,
    alive by `kill -0`, or "not started", which is expected in SSH sessions); handlers pending retry (`retry`);
    when the last apply finished (`generation`). Read the file formats from `apply`, `watcher` and `_lib.sh`
    before writing it. — files: `local/bin/dfm-theme`, `tests/dfm-theme.bats` — verify: fixtures in a temp
    `XDG_STATE_HOME` for each state (no state yet, saved choice, env override, dead pid, pending retry).
4. Delete the `theme-reapply` bash function from `config/exports` and `config/fish/functions/theme-reapply.fish`
    (search first). Update `AGENTS.md`, `config/theme/CLAUDE.md`, `local/bin/CLAUDE.md`, `local/bin/dfm.md` and
    the `theme-handler-scaffold` skill where they name `theme`, `local/bin/theme` or `theme-reapply`. — verify:
    `git grep -n -e 'theme-reapply' -e 'local/bin/theme\b'` finds only history.

### Commit 13 — `fix(dfm): portable defaults for dfm ssh`

1. The 1Password agent socket default depends on `$OSTYPE` (current path on macOS; the Linux path from
    1Password's SSH agent documentation — fetch it before writing); `curl` gets `--connect-timeout 10
    --max-time 30`; a missing `curl` gets its own message instead of "network error". — files:
    `local/bin/dfm-ssh` — verify: `dfm-ssh.bats`; a `curl` stub that sleeps → the command returns within the
    timeout with the error line.

### Commit 14 — `chore(bin): remove x-set-php-aliases and php-switcher`

phpenv covers both: `phpenv global`/`local`/`use` replace `php-switcher`'s relinking, and its auto-switch reads
`.php-version` like `php-switcher --auto`. Nothing sources `x-set-php-aliases` (searched 2026-11-12: only its own
test names it), so its aliases are not active in any shell today.

1. Delete `local/bin/x-set-php-aliases`, `local/bin/x-set-php-aliases.md`, `tests/x-set-php-aliases.bats`,
    `local/bin/php-switcher`, `local/bin/php-switcher.md` and `tests/php-switcher.bats`, and the `php-switcher`
    line in `local/bin/README.md`. Their generated completion, markdown and manpage files are gitignored and drop
    out on the next `scripts/install-completions.sh`. — files: those 7 — verify:
    `git grep -n -e x-set-php-aliases -e php-switcher` finds only history; bats suite; `mise run lint-usage`.

### Commit 15 — `fix(mise): leave php to phpenv`

mise reads `.tool-versions` natively and has the `vfox-php` plugin installed here (`mise plugins ls`; no PHP
version installed). phpenv reads `.tool-version`/`.tool-versions` too, so a project listing `php` there would have
mise trying to provide PHP alongside phpenv's own `PATH` switch.

1. Add `disable_tools = ["php"]` to `[settings]` in `config/mise/config.toml` (the setting exists:
    `mise settings get disable_tools` prints `[]`), and run `mise plugins uninstall php` on each machine (the
    plugin is not tracked in the repo). — files: `config/mise/config.toml` — verify: `v8r`; in a temp directory
    whose `.tool-versions` says `php 8.3`, `mise current` lists no php and prints no warning, and phpenv still
    switches there.

### Close-out — no commit unless something changed

1. `mise run lint` and `mise run test` exit 0; `hyperfine` the baseline commands and compare. — verify: numbers
    in the PR description.
2. Refresh the graph: `graphify update .`, `scripts/graphify-tests.py`, `graphify export html`
    (`graphify-out/` is untracked; nothing to commit).
3. Manual macOS check on a stock-bash shell: `/bin/bash local/bin/dfm`, `dfm install` (menu),
    `dfm secrets list`, `dfm check os`, `dfm packages status`, `dfm theme status`, `mise bootstrap --dry-run`,
    then one full `./install` on a disposable account if available.

## Adversarial hardening

- **complexity** — Examined every new mechanism against the user's simplest-solution rule.
    - Cut: an in-process `msgr()` wrapper (3 ms per call, about 40 calls in `install all`); Commit 2 removes the
      msgr sourcing instead, which was dead code.
    - Cut: a shared `dfm_each` for `check all`, `cleanup all` and `helpers docs-all`; three 6-line loops do not
      justify an indirection.
    - Cut: rendering menus with the `usage` CLI. It is installed by mise, which `install all` itself
      bootstraps, so dfm cannot depend on it at runtime; a small bash parser of the same `#USAGE` lines keeps
      one source of truth with no dependency.
    - Cut: dropping the shfmt flags in favour of `.editorconfig`. Its shfmt glob,
      `{local/bin/*,**/*.sh,**/zshrc,config/*,scripts/*}`, does not cover extensionless executables below
      `config/` (for example `config/theme/handlers.d/*`), which would fall back to shfmt's defaults (tabs).
      Delegating to the prek hook removes the second definition without that risk.
    - Cut: moving the theme engine into dfm. The watcher is a daemon started from shell init and `apply` runs
      on every light/dark flip; routing either through dfm adds the dispatcher and library to that path and
      splits a self-contained module with its own tests. Only the commands a person types move.
    - Cut: exposing `mise bootstrap packages prune` (it would uninstall the native-brew PHP stack).
    - Kept, net removal: `dfm-apt`, `dfm-brew`, `dfm_section_requires`, six `dfm install` subcommands, the
      Brewfile, `tools/apt.txt`, `scripts/install-fonts.sh`, `local/bin/theme`, both `theme-reapply` copies,
      the bash-4 guard, the `MENU` arrays, three parity tests, the msgr ordering workaround, the `shared.sh`
      re-source and the hand-kept install ordering; 13 preludes go from 9 lines to 2.
    - Added: `dfm_menu`, `dfm_fallback`, `dfm-packages` (three thin commands), `dfm theme status`, `apply
      --force`, and the light-path `case` in `dfm-check`.
- **review** — Edge cases fixed in the tasks above:
    - Parser: no help string contains `\"` (checked with `rg`). A colon in help text is safe because
      `menu_builder` splits on the first `:` and names never contain one. Sections without subcommands are
      handled. `help` is reserved in `dfm docs` (no `docs/help.md` exists).
    - `uname -m` says `arm64` on macOS and `aarch64` on Linux; comparison is exact and the help says so.
    - `$HOSTNAME` may be fully qualified, the same as `hostname` today.
    - `brew:` entries move to the macOS-only file before `mise bootstrap` runs unfiltered, so Linux never pours
      into a Homebrew prefix. Non-sudoer hosts skip the packages part (apt/dnf need sudo).
    - Apps installed by native brew and now declared in mise: the macOS check (Commit 7.4) reports any that mise
      would reinstall before the Brewfile goes.
    - `mise bootstrap` runs hooks every time (`mise bootstrap --help`), including the macOS `post-defaults` hook
      with sudo. `install all` already ran it on every install via `dfm install macos`.
    - `install all` still runs every step and decides its status at the end; `./install` keeps the first
      non-zero status and never aborts midway.
    - `secrets_list` reads names with `IFS= read -r`, so hand-made names with spaces still list.
- **security** — Trust boundaries examined:
    - The `#USAGE` parser reads repo files dfm already executes, uses regex captures only (no `eval`) and prints
      them as `printf` arguments, never as the format.
    - `mise bootstrap` executes hooks and tasks from repo-owned config, the same trust as `dfm install macos`
      today.
    - `brew-cask` checks a cask's sha256 when the cask provides one (mise docs); casks without one install
      unverified, as with Homebrew.
    - Sudo use is unchanged: the `is-sudoer` gate stays and `prune` is not exposed.
    - `stderr: true` prints dotbot shell-step stderr to the user's own terminal. No CI workflow runs `./install`
      (checked `.github/workflows`).
    - The token prompt uses `read -s` and is unreachable under dotbot (stdin is `/dev/null`).
    - Moving the secrets code is a move; `dfm.bats` 424 re-checks that `list` prints names, not values.
- **errors / leaks** — Every new failure path ends in a non-zero status and a visible line: install steps
    including `mise bootstrap`, `./install` (rc carried through), `dfm packages` without mise, cleanup
    branches, cheat databases, ssh `curl` timeouts, `reset-nvim` link failure, `dfm theme reapply` with a bad
    mode. A user without sudo rights is not a failure: `dfm packages apply|upgrade` warns, skips and exits 0.
    No new resources: the parser reads through a redirect; `ensure_mise` keeps its `mktemp`+`trap`.
- **migrations** — The Brewfile-to-mise move is a config migration and is ordered for it: Commit 7 adds the mise
    entries while the Brewfile still exists, the macOS check runs, and only then Commit 8 deletes the Brewfile.
    Already-installed apps and formulae stay installed throughout. Commit 3 (`./install` keeps going) lands
    before Commit 9 (`install all` can fail), and Commit 6 (exit 2) before the removals.
- **concurrency** — The only ordering assumption in dfm, `shared.sh` before msgr, goes with the msgr sourcing.
    `apply --force` takes the same `apply.lock` as a flip, so a reapply and a watcher flip serialise.
- **contract** — The public surface is the dfm CLI (commands, output, exit status), the `theme` command, the
    `theme-reapply` function, and `dfm-lib` as sourced by `dfm-*` and `tests/dfm-lib.bats`. Removals and renames
    are listed in the commit bodies; per the user, no `!` or footers. `theme-mode` and `apply <mode>` (the
    watcher's call) keep their interfaces.
- **arch** — Checked against `local/bin/CLAUDE.md` and `config/theme/CLAUDE.md`. `dfm-lib` keeps the bootstrap
    family and gains the menu helpers; `secrets_*` and `get_script_description` move to their only callers.
    `dfm-packages` is a thin wrapper over `mise bootstrap packages`, and `dfm-theme` is the CLI over an engine it
    does not absorb. The dispatcher now reads `#USAGE`, a format already shared by `install-completions.sh` and
    `lint-usage`. Both CLAUDE.md files are updated in the commits that change them.
- **perf** — Baselines are in the table above, and each perf task has a measured threshold. The parser reads only
    each file's header, all sections in one process. `dfm theme` runs light for every command; `status` only
    reads files.
- **tests** — Every new check can fail: PATH stubs that exit non-zero or record arguments (`mise`, `brew` gone,
    `curl`, `docker`), a fake `DOTFILES` tree, `XDG_STATE_HOME` fixtures, a planted-positive control for the
    static syntax test, and a scratch run of `install`. Deleted tests covered things that no longer exist (the
    duplicated menus, the guard, the brew and apt sections, install-fonts, imagick). Bash 3.2 coverage on Linux
    CI is the static test only; see accepted risks.
- **config** — The mise TOML files carry a schema, so `v8r` checks them. The `brew:`/`brew-cask:` prefixes, tap
    resolution and font-cask behaviour come from the mise docs fetched this session; `--skip`/`--only` part names
    come from `mise bootstrap --help` and are confirmed with `--dry-run` before use. `shell.stderr` is checked
    against the vendored dotbot README. `DFM_SSH_AGENT_SOCK`'s default becomes per-OS (documented in the
    `dfm-ssh` header). No new environment variables.
- **privacy** — Examined `secrets_list`, `secrets_show` and dfm-ssh's principal (git-profile emails written to
    `allowed_signers`): behaviour unchanged, only moved or reorganised. `dfm theme status` prints only theme state.
- **a11y** — N/A: no UI beyond plain-text menus. The new error is text with a symbol, never colour alone.
- **i18n** — N/A: English-only CLI, no locale handling; `sort` keeps the caller's locale as today.
- **observability** — The signals are stdout, stderr and exit status. Under `./install`, stderr becomes visible
    and the exit status becomes truthful (Commits 3 and 9). `dfm theme status` exposes theme state that today
    needs reading files under `$XDG_STATE_HOME` by hand.

## Rollback / abort

Nothing is deployed: each machine pulls the repo and runs `./install`. Every commit can be reverted with
`git revert <sha>`. A machine that hits a problem mid-series can `git checkout` the previous commit and rerun
`./install --links`. Package changes never uninstall anything (no `prune`), so reverting Commits 7–9 brings the
Brewfile and the old install steps back with every installed app still in place.

Abort points:

- Commit 3: if the scratch run shows `./install` stopping early, stop before Commit 9.
- Commit 7.4: if the macOS check finds entries mise cannot install, stop before Commit 8 and decide per entry.
- Commit 9: if `mise bootstrap --dry-run` on Linux shows parts other than packages and tools changing, stop and
  ask.
- Commit 10.1: if `prek run shfmt --all-files` is not the right form, stop and ask.

## Open questions & accepted risks

- The brew CLI is still needed outside dfm, so it is not uninstalled by this plan: `/opt/homebrew/bin` reaches
  `PATH` through `brew shellenv` only when the brew CLI exists (`config/exports:345`, `config/fish/config.fish:27`),
  and mise pours its formulae into that same prefix. After Commit 14, phpenv's homebrew provider is the only PHP
  code that calls the brew CLI. Finishing the move away from brew needs two follow-ups outside this plan: put
  `/opt/homebrew/bin` on `PATH` without `brew shellenv`, and give phpenv a mise provider.
- That provider belongs in `ivuorinen/phpenv.fish`, and reaches this repo through `fisher update`. The copy under
  `config/fish/` is fisher-managed (`config/fish/fish_plugins`), so an edit made here is overwritten by the next
  update. The provider that keeps today's prebuilt bottles would install with `mise bootstrap packages apply
  brew:shivammathur/php/php@<v>` and locate with `mise bootstrap packages where …`. Its help names Apple-silicon
  macOS and x86_64/arm64 Linux, not Intel macOS. Listing available versions needs a source other than
  `brew tap-info`, which is a brew CLI call. It must install ad hoc (`apply`), not with `use`: `use` writes
  `config/mise/config.toml`, a tracked file in this repo.
- Until then, the brew CLI (phpenv) and mise's brew manager share `/opt/homebrew` and its libraries. dfm no longer
  runs `brew cleanup` or `brew autoremove` (Commit 8). Running them by hand can remove or relink kegs mise
  poured, and `mise bootstrap packages prune` would remove the PHP formulae, because no mise config declares them.
- The macOS half of Commit 7 can only be verified on a Mac (Commit 7.4, by you).
- Linux `magick` depends on `conda:imagemagick` working (Commit 7.2); the fallback leaves Linux without `magick`.
- mise's bootstrap packages are experimental (the existing `conf.d/brew` comment says so). A mise release can
  change them; `dfm packages` and `install all` report a failure instead of hiding it.
- `.claude/rules/commit-format.md` still requires `!` for removed or renamed commands. This plan follows your
  instruction instead; amending the rule is a separate change if you want it.
- Bash 3.2 is checked statically on Linux. The `bash:3.2` container check needs network access to pull the
  image, which failed during planning; the `/bin/bash` test runs only on a Mac, plus the manual close-out step.
- Light-path commands (`docs`, `ssh`, `secrets`, `tests`, `theme`, `check arch|os|host|perms`) find `glow`,
  `jq`, `git`, `ssh-add` and `curl` on the caller's `PATH`, not through `mise activate`. Each already degrades
  when one is missing (`cat` fallback, principal fallback, the new `curl` message).
- The Linux 1Password agent socket path could not be fetched during planning; Commit 13 verifies it first.
- With `stderr: true`, `./install` also prints the stderr of git, mise and the install scripts.
- The top-level `dfm` listing no longer lists every doc and install script; `dfm docs` and `dfm scripts` still do.
- `dfm-ssh` keeps `ivuorinen` as the last-resort GitHub user fallback; it is this repo's owner's default, not a
  portability bug.
