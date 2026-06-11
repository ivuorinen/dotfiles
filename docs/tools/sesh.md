# sesh

[sesh](https://github.com/joshmedeski/sesh) is a smart tmux session
manager built on zoxide: it lists, creates, and connects to sessions by
project directory instead of by hand. It is mise-managed (the
`github:joshmedeski/sesh` entry in `config/mise/config.toml`) and
configured in `config/sesh/sesh.toml`.

## Commands

| Command          | Does                                                |
|------------------|-----------------------------------------------------|
| `sesh list`      | List sessions (`-t` tmux, `-c` config, `-z` zoxide) |
| `sesh connect …` | Connect to (or create) a session                    |
| `sesh last`      | Connect to the last tmux session                    |
| `sesh picker`    | Interactive session picker                          |
| `sesh preview`   | Preview a session or directory                      |
| `sesh clone …`   | Clone a git repo and connect to it as a session     |
| `sesh root`      | Show the root of the active session                 |

## tmux integration

Bound in `config/tmux/tmux.conf` (after the tmux prefix):

| Key        | Action                                              |
|------------|-----------------------------------------------------|
| `prefix t` | Custom session picker popup (`config/tmux/sesh.sh`) |
| `prefix L` | Jump to the last session (`sesh last`)              |
| `prefix N` | sesh's own UI popup                                 |

`config/tmux/sesh.sh` is a cascading picker: it prefers `gum filter`,
falls back to `fzf`, then to a plain bash `select` menu, and finally to
the native tmux picker if sesh is not installed. Inside the gum/fzf
picker:

- `Ctrl-a` — all sessions
- `Ctrl-t` — tmux sessions only
- `Ctrl-g` — configured sessions only
- `Ctrl-x` — zoxide directories
- `Ctrl-d` — kill the highlighted tmux session

## Configuration (`config/sesh/sesh.toml`)

- **Defaults**: `dir_length = 2` (shows the last two path segments),
  `cache = true`, and a `blacklist` that hides scratch/underscore
  sessions.
- **Wildcard**: any session under `~/Code/**` runs `gh-set-profile` on
  startup so the correct git identity is applied (see
  [git-profile.md](git-profile.md)).
- **Named sessions**: explicit entries for `~`, `~/.dotfiles`, the sesh
  config dir, `~/.dotfiles/local/bin`, and `~/Code/`, some with their own
  `startup_command` (e.g. `nvim sesh.toml`).

## Notes

- `disable_startup_command = true` on a session skips the wildcard
  startup command — used for plain home/`~/Code` sessions where no
  project profile applies.
- Because sesh leans on zoxide, the more you navigate with `z`, the
  better `sesh list -z` and the picker's zoxide mode work.
