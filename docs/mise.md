# mise

[mise](https://mise.jdx.dev) is the single source of truth for language
runtimes and CLI tools in this setup. It replaces asdf, nvm, pyenv,
rbenv, and most of Homebrew's role for developer tooling. Tools are
pinned in `config/mise/config.toml` and installed into per-version
shims, so `which node`, `which gopass`, etc. resolve to mise rather than
a system or Homebrew path.

## How it is wired here

- **Config**: `config/mise/config.toml` (symlinked to `~/.config/mise/`).
  Tools are grouped by function (runtimes, shell, search, git, linters,
  security, …), not by backend.
- **Activation**: `config/exports` runs `mise activate` for bash/zsh:

  ```bash
  eval "$(env -u MISE_SHELL SHELL=bash mise activate bash)"
  ```

  Fish activates separately in its own config chain.
- **Backends**: an unprefixed key (e.g. `ripgrep`) resolves through
  the default aqua registry. Prefixed keys pick a specific backend:
  `npm:prettier`, `dotnet:csharpier`, `github:owner/repo`, `pipx:…`,
  `aqua:owner/repo`.
- **Reproducibility**: `lockfile = true` writes `mise.lock` with
  checksums. `idiomatic_version_file = true` makes mise respect
  `.nvmrc`, `.python-version`, `.go-version`, etc. in other projects.
- **npm/dotnet tools live in mise, not `package.json`**, so hook scripts
  and interactive shells get them on PATH without relying on a package
  manager's `node_modules/.bin` shim. This repo has no `package.json`: its
  lint, fix and test commands are mise file tasks in `.mise/tasks/`.

## Everyday commands

| Command                 | Does                                             |
|-------------------------|--------------------------------------------------|
| `mise install`          | Install everything pinned in the config          |
| `mise install <tool>`   | Install one tool (alias `mise i`)                |
| `mise ls`               | List installed/active tool versions              |
| `mise outdated`         | Show tools with newer versions available         |
| `mise upgrade`          | Upgrade tools to latest allowed versions         |
| `mise use <tool>@<ver>` | Pin a version in the nearest config              |
| `mise exec <tool> -- …` | Run a command with a tool on PATH (alias `x`)    |
| `mise run <task>`       | Run a task defined in config (alias `r`)         |
| `mise prune`            | Delete unused installed versions                 |
| `mise reshim`           | Rebuild shims after a manual install             |
| `mise doctor`           | Diagnose activation / PATH problems (alias `dr`) |
| `mise self-update`      | Update mise itself                               |

## Adding a tool

1. Add the pinned entry under the right group in
   `config/mise/config.toml` (use a backend prefix if it is not in the
   default registry).
2. Run `mise install`.
3. If a shell completion or alias is needed, wire it in `config/alias`
   or `config/fish/`.

## Homebrew formulae via mise (bootstrap packages)

Plain `homebrew/core` CLI formulae are installed by mise's experimental
brew bootstrap instead of the `brew` CLI. They live under
`[bootstrap.packages]` in the `config/mise/conf.d/brew/` folder fragment as
`"brew:<formula>" = "latest"`, and mise pours them into the canonical
Homebrew prefix (`/opt/homebrew`), so paths match a native
`brew install`. `mise.toml` there holds the formulae every platform gets;
`mise.macos.toml` holds the macOS-only ones and loads through the
`auto_env = true` platform environment set in `config/mise/miserc.toml`
and exported as `MISE_AUTO_ENV=true` by `config/exports` and
`config/fish/exports.fish`.

| Command                                       | Does                                     |
|-----------------------------------------------|------------------------------------------|
| `mise bootstrap packages status` (alias `ls`) | Show configured formulae + install state |
| `mise bootstrap packages apply -m brew -y`    | Install any missing formulae             |
| `mise bootstrap packages upgrade -m brew`     | Upgrade installed bootstrap formulae     |
| `mise bootstrap packages import -m brew`      | Snapshot on-request formulae into config |

> **Do not run `mise bootstrap packages prune --manager brew` here.** prune
> removes every formula mise config does not declare, including the Brewfile
> stack (imagemagick, ffmpeg, coreutils, antidot, dark-notify) and phpenv's
> PHP and its extensions. Use `dfm cleanup brew` (brew cleanup + autoremove)
> instead.

`dfm install mise` runs `apply` automatically (macOS only). Only
on-request **leaves** are listed — mise resolves each formula's
dependency closure, so transitive deps must not be added. Casks and the
imagemagick/ffmpeg/coreutils stack stay on native brew
in `config/homebrew/Brewfile` (see its header). PHP is managed by
`phpenv.fish` (homebrew provider), not brew or mise.

## Linux distribution packages

`config/mise/conf.d/system-packages/mise.linux.toml` lists the apt
(Debian/Ubuntu) and dnf (Fedora/RHEL) packages under
`[bootstrap.packages]`: build toolchains, headers for compiling languages,
and CLI utilities no mise backend provides. It loads only in the `linux`
platform environment, and mise skips the entries whose manager is not on
`PATH`, so one list serves both distros. Tools already pinned in
`[tools]` are not repeated there.

`dfm install apt-packages` and `dfm install dnf-packages` run
`mise bootstrap packages apply --manager apt|dnf --yes` (sudo), skipping
when the user has no sudo rights. They install the mise binary first when
it is missing, because `dfm install all` runs them before the mise step.

## macOS defaults

`config/mise/conf.d/macos-defaults/mise.macos.toml` holds the macOS
preferences as `[bootstrap.macos.defaults."<domain>"]` tables, the login
shell (`[bootstrap.user] login_shell = "fish"`), and a `post-defaults`
hook. It loads only in the `macos` platform environment. mise writes
preferences as the user and never templates them, so the hook covers the
rest: the three preferences whose value holds `$HOME`, the app restarts,
and the root-level settings (`nvram`, `pmset`, `systemsetup`, the login
window). The hook runs under `sh -o errexit`, so a failing command fails
the run instead of being skipped silently.

| Command                                          | Does                                        |
|--------------------------------------------------|---------------------------------------------|
| `dfm install macos`                              | `mise bootstrap --only macos-defaults,user` |
| `mise bootstrap macos defaults status`           | Show which preferences differ               |
| `mise bootstrap --only macos-defaults --dry-run` | Preview the writes and the hook             |

`dfm install all` applies it after the mise step, which installs fish.
Writing the `com.apple.Safari` domain needs Full Disk Access for the
terminal running mise, because Safari is sandboxed.

## Gotchas

- `experimental = true` is set — some commands (`deps`, `oci`, `mcp`) are
  marked experimental and may change.
- The `pipx`/`uvx` combination is partly disabled in the config because
  the mise pipx backend cannot find `uvx` when `uv` is mise-managed
  (see the inline comment and upstream discussion link in the config).
- Prefer mise versions over hardcoded Homebrew paths anywhere in this
  repo — the migration to mise is intentional and complete.
