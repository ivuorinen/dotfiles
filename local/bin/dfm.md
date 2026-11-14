# dfm

Dotfiles manager. `dfm <section> <command>` runs `dfm-<section>` from the same
directory, the way git finds `git-<command>`. Run a section without a command
to see its commands.

## Usage

```bash
dfm                           # every section and its commands
dfm <section>                 # one section's commands
dfm <section> <command> [args]
```

An unknown section or command prints an error and the menu, and exits 2.

Sections:

- `install` – install everything (`all`) or one part of the setup
- `secrets` – create, list, show and remove shell secrets files
- `ssh` – reconcile public keys with `allowed_signers` and GitHub
- `cleanup` – remove old installs, caches and unused packages
- `packages` – install, check and upgrade the packages mise declares (apt,
  dnf, Homebrew formulae and casks)
- `check` – system information and health checks
- `dotfiles` – format the repository, reset nvim
- `docs` – list the guides under `docs/`, or show one
- `scripts` – list or run the `scripts/install-*.sh` scripts
- `helpers` – inspect aliases, colours, env, functions and `PATH`;
  regenerate the generated docs
- `theme` – list and switch theme families, print the mode, re-run handlers

Set `VERBOSE=1` to see the setup messages the shell environment prints while
dfm loads it.

### Example

```bash
dfm install all
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
