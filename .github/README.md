# .dotfiles

Welcome to [ivuorinen](https://github.com/ivuorinen)'s .dotfiles repository.
It's a hodgepodge of scripts and configurations, tests and mistakes I'm not
aware of yet. As I find more interesting tools, configs and other stuff,
this repository will live accordingly.

Please for the love of everything good do not use these 1:1 as your own dotfiles,
fork or download the repo as a zip and go from there with your own configs.

## Setup

### First time setup

1. Clone this repository to `$HOME/.dotfiles`
2. `./install`
3. ???
4. Profit

### Updates

`cd $HOME/.dotfiles && git pull && ./install`

## The looks

![screenshot of the oh-my-posh shell](./screenshots/oh-my-posh.png)

![screenshot of light version of tmux with nvim editing this repo](./screenshots/tmux-nvim-kickstart-light.png)

![screenshot of dark version of tmux with nvim editing this repo](./screenshots/tmux-nvim-kickstart-dark.png)

## Interesting files and locations

### Interesting folders

| Path                | Description                                  |
| ------------------- | -------------------------------------------- |
| `.github`           | GitHub Repository configuration files.       |
| `hosts/{hostname}/` | Configs that should apply to that host only. |
| `local/bin`         | Helper scripts that I've collected or wrote. |
| `scripts`           | Setup scripts.                               |

### dotfile folders

| Repo      | Destination | Description                                 |
| --------- | ----------- | ------------------------------------------- |
| `base/`   | `.*`        | `$HOME` level files.                        |
| `config/` | `.config/`  | Configurations for applications.            |
| `local/`  | `.local/`   | XDG Base folder: `bin`, `share` and `state` |
| `ssh/`    | `.ssh/`     | SSH Configurations.                         |

### dfm - the dotfiles manager

`.local/bin/dfm` is a shell script that has some tools that help with dotfiles management.

## Configuration

The folder structure follows [XDG Base Directory Specification][xdg] where possible.

### XDG Variables

| Env                | Default              | Short description                              |
| ------------------ | -------------------- | ---------------------------------------------- |
| `$XDG_BIN_HOME`    | `$HOME/.local/bin`   | Local binaries                                 |
| `$XDG_CONFIG_HOME` | `$HOME/.config`      | User-specific configs                          |
| `$XDG_DATA_HOME`   | `$HOME/.local/share` | User-specific data files                       |
| `$XDG_STATE_HOME`  | `$HOME/.local/state` | App state that should persist between restarts |

#### XDG_BIN_HOME (`$HOME/.local/bin`)

`$XDG_BIN_HOME` defines directory that contains local binaries.

User-specific executable files may be stored in `$HOME/.local/bin`.
Distributions should ensure this directory shows up in the UNIX `$PATH`
environment variable, at an appropriate place.

#### XDG_DATA_HOME (`$HOME/.local/share`)

`$XDG_DATA_HOME` defines the base directory relative to which
user-specific _data files_ should be stored.

If `$XDG_DATA_HOME` is either not set or empty,
a default equal to `$HOME/.local/share` should be used.

#### XDG_CONFIG_HOME (`$HOME/.config`)

`$XDG_CONFIG_HOME` defines the base directory relative to which
user-specific _configuration files_ should be stored.

If `$XDG_CONFIG_HOME` is either not set or empty,
a default equal to `$HOME/.config` should be used.

#### XDG_STATE_HOME (`$HOME/.local/state`)

`$XDG_STATE_HOME` defines the base directory relative to which
user-specific _state files_ should be stored.

If `$XDG_STATE_HOME` is either not set or empty,
a default equal to `$HOME/.local/state` should be used.

The `$XDG_STATE_HOME` contains _state data_ that should
_persist between (application) restarts_, but that is not important or
portable enough to the user that it should be stored in `$XDG_DATA_HOME`.

- It may contain:
  - actions history (logs, history, recently used files, …)
  - current state of the application that can be reused
    on a restart (view, layout, open files, undo history, …)

#### XDG_DATA_DIRS

`$XDG_DATA_DIRS` defines the preference-ordered set of base directories
to search for data files in addition to the `$XDG_DATA_HOME` base directory.
The directories in `$XDG_DATA_DIRS` should be separated with a colon ':'.

[xdg]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
