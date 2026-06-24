# Television (tv)

Rust-based TUI fuzzy finder — channel-driven, shell-integrated.
Config: `config/television/config.toml` → `~/.config/television/config.toml`
Cables: `config/television/cable/` → `~/.config/television/cable/`

## Config

```toml
history_size  = 200
global_history = false
```

## Shell Integration

`config/fish/config.fish` initialises television for fish:

```fish
type -q tv; and tv init fish | source
```

This registers `Ctrl-r` and `Ctrl-t` in the shell and enables channel triggers.

### Shell Keybindings

| Key      | Action                                 |
|----------|----------------------------------------|
| `Ctrl-r` | Open command history (`fish-history`)  |
| `Ctrl-t` | Smart autocomplete (context-sensitive) |

### Channel Triggers

`Ctrl-t` opens a channel matching the command token left of the cursor.

| Command(s)                                                                      | Channel         |
|---------------------------------------------------------------------------------|-----------------|
| `alias`, `unalias`                                                              | `alias`         |
| `export`, `unset`                                                               | `env`           |
| `cd`, `ls`, `rmdir`, `z`                                                        | `dirs`          |
| `cat`, `less`, `head`, `tail`, `vim`, `nano`, `bat`, `cp`, `mv`, `rm`, `touch`, | `files`         |
| `chmod`, `chown`, `ln`, `tar`, `zip`, `unzip`, `gzip`, `gunzip`, `xz`           |                 |
| `git add`, `git restore`                                                        | `git-diff`      |
| `git checkout`, `git branch`, `git merge`, `git rebase`, `git pull`, `git push` | `git-branch`    |
| `git log`, `git show`                                                           | `git-log`       |
| `nvim`, `hx`, `git clone`                                                       | `git-repos`     |
| `ssh`, `scp`                                                                    | `ssh-hosts`     |
| `tmux new-session`, `tmux attach-session`                                       | `tmux-sessions` |
| *(anything else)*                                                               | `files`         |

## UI Keybindings

### Navigation

| Key                   | Action           |
|-----------------------|------------------|
| `Ctrl-n` / `↓`        | Next entry       |
| `Ctrl-p` / `↑`        | Previous entry   |
| `Ctrl-d` / `PageDown` | Half page down   |
| `Ctrl-u` / `PageUp`   | Half page up     |
| `Enter`               | Confirm / action |
| `Esc` / `Ctrl-c`      | Quit             |

### Preview Panel

| Key      | Action                 |
|----------|------------------------|
| `Ctrl-o` | Toggle preview panel   |
| `Ctrl-]` | Preview half page down |
| `Ctrl-[` | Preview half page up   |

### Input Field

| Key         | Action                    |
|-------------|---------------------------|
| `Backspace` | Delete previous character |
| `Ctrl-w`    | Delete previous word      |
| `Delete`    | Delete next character     |
| `←` / `→`   | Move cursor               |

### Channel Control

| Key      | Action                              |
|----------|-------------------------------------|
| `Ctrl-s` | Cycle sources (multi-source cables) |

## Tmux Integration

`prefix + t` opens a tmux popup running `~/.config/tmux/sesh.sh`, which calls
`tv sesh` via the `sesh` cable (see below). Tmux prefix is `Ctrl-Space`.

## Custom Cables

### `sesh` — Session + directory picker

`config/television/cable/sesh.toml`
Requirements: `sesh`, `fd`
Sources (cycle with `Ctrl-s`): all sessions, tmux sessions, sesh configs, zoxide dirs, `fd` dirs

| Key      | Action                                       |
|----------|----------------------------------------------|
| `Enter`  | Connect to selected session (`sesh connect`) |
| `Ctrl-s` | Cycle sources                                |

Kill action available (unlisted keybinding): `tmux kill-session`

---

### `dirs` — Directory browser

`config/television/cable/dirs.toml`
Requirements: `fd`, `eza`
Sources (cycle with `Ctrl-s`): visible dirs, hidden dirs

| Key      | Action                          |
|----------|---------------------------------|
| `Enter`  | `cd` into selected directory    |
| `Ctrl-s` | Toggle hidden directories       |
| `F2`     | Open this channel from anywhere |

---

### `dotfiles` — Edit dotfiles

`config/television/cable/dotfiles.toml`
Requirements: `fd`, `bat`
Sources (cycle with `Ctrl-s`): `~/.config` files, `~/.dotfiles` source files

| Key      | Action                                |
|----------|---------------------------------------|
| `Enter`  | Open in `$EDITOR` (default: `nvim`)   |
| `Ctrl-s` | Toggle between live config and source |

---

### `tmux-sessions` — tmux session manager

`config/television/cable/tmux-sessions.toml`
Requirements: `tmux`
Preview: captured pane content of the session

| Key      | Action                     |
|----------|----------------------------|
| `Enter`  | Attach to selected session |
| `Ctrl-d` | Kill selected session      |

---

### `tmux-windows` — tmux window switcher

`config/television/cable/tmux-windows.toml`
Requirements: `tmux`
Preview: last 50 lines of the window's pane

| Key     | Action                    |
|---------|---------------------------|
| `Enter` | Switch to selected window |

---

### `git-worktrees` — Git worktree switcher

`config/television/cable/git-worktrees.toml`
Requirements: `git`
Preview: last 10 commits + `git status` for the worktree

| Key      | Action                             |
|----------|------------------------------------|
| `Enter`  | `cd` into worktree + open `$SHELL` |
| `Ctrl-d` | Remove selected worktree           |

---

### `wt` — `wt` tool worktree switcher

`config/television/cable/wt-list.toml`
Requirements: `wt`, `jq`, `git`
Preview: last 10 commits for the branch

| Key     | Action                         |
|---------|--------------------------------|
| `Enter` | `wt switch` to selected branch |

---

### `ssh-hosts` — SSH host connector

`config/television/cable/ssh-hosts.toml`
Requirements: `grep`, `awk`, `find`
Source: scans `~/.ssh/shared.d/` and `~/.ssh/local.d/`
Preview: aligned key-value list of host config options (User, HostName, IdentityFile, etc.)

| Key     | Action                 |
|---------|------------------------|
| `Enter` | `ssh` to selected host |

---

### `fish-history` — Fish command history

`config/television/cable/fish-history.toml`
Requirements: `fish`
Also triggered by `Ctrl-r` via shell integration.

| Key     | Action                   |
|---------|--------------------------|
| `Enter` | Execute selected command |

---

### `gh-issues` — GitHub issues

`config/television/cable/gh-issues.toml`
Requirements: `gh`, `jq`
Source: open issues for current repo (newest first)
Preview: issue detail (title, status, author, age, labels, body)

| Key     | Action                |
|---------|-----------------------|
| `Enter` | Open issue in browser |

---

### `gh-prs` — GitHub pull requests

`config/television/cable/gh-prs.toml`
Requirements: `gh`, `jq`
Source: open PRs for current repo (newest first)
Preview: PR detail (title, status, author, review decision, age, labels, body)

| Key      | Action             |
|----------|--------------------|
| `Enter`  | Open PR in browser |
| `Ctrl-o` | `gh pr checkout`   |
| `Ctrl-y` | `gh pr merge`      |

---

## Bundled Channels

Imported from [omerxx/dotfiles](https://github.com/omerxx/dotfiles/tree/master/television).
Use `tv` with the channel name directly: `tv alias`, `tv brew-packages`, etc.

`alias`, `bash-history`, `brew-packages`, `cargo-commands`, `cargo-crates`,
`channels`, `crontab`, `diskutil`, `docker-compose`, `docker-containers`,
`docker-images`, `docker-networks`, `docker-volumes`, `downloads`, `env`,
`figlet-fonts`, `files`, `fonts`, `git-branch`, `git-deletions`, `git-diff`,
`git-files`, `git-log`, `git-reflog`, `git-remotes`, `git-repos`, `git-stash`,
`git-submodules`, `git-tags`, `just-recipes`, `make-targets`, `man-pages`,
`mounts`, `node-packages`, `npm-packages`, `npm-scripts`, `nu-history`,
`path`, `pip-packages`, `procs`, `python-venvs`, `recent-files`, `rustup`,
`text`, `todo-comments`, `unicode`, `zoxide`, `zsh-history`

## Usage Examples

```sh
# Open any channel by name
tv sesh
tv dotfiles
tv gh-issues
tv git-log

# Use with a custom source and preview inline
tv -s "git branch" -p "git log --oneline -10 {}"

# Open in a tmux popup (triggered via prefix + t)
# Uses sesh.sh → tv sesh automatically

# Smart autocomplete in the shell
# Type a partial command, then Ctrl-t:
cd ~/Code/<Ctrl-t>        # opens dirs channel
git checkout <Ctrl-t>     # opens git-branch channel
ssh <Ctrl-t>              # opens ssh-hosts channel
```
