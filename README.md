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

| Var                | Default              |
| ------------------ | -------------------- |
| `$XDG_DATA_HOME`   | `$HOME/.local/share` |
| `$XDG_STATE_HOME`  | `$HOME/.local/state` |
| `$XDG_CONFIG_HOME` | `$HOME/.config`      |
| `$XDG_BIN_HOME`    | `$HOME/.local/bin`   |

- `$XDG_BIN_HOME` is a custom `env` for `.local/bin` folder.
- `$XDG_DATA_HOME` defines the base directory relative to which user-specific data
  files should be stored. If `$XDG_DATA_HOME` is either not set or empty,
  a default equal to `$HOME/.local/share` should be used.
- `$XDG_CONFIG_HOME` defines the base directory relative to which user-specific configuration
  files should be stored. If `$XDG_CONFIG_HOME` is either not set or empty,
  a default equal to `$HOME/.config` should be used.
- `$XDG_STATE_HOME` defines the base directory relative
  to which user-specific state files should be stored.
  If `$XDG_STATE_HOME` is either not set or empty, a default
  equal to `$HOME/.local/state` should be used.
- The `$XDG_STATE_HOME` contains state data that should persist
  between (application) restarts,
  but that is not important or portable enough to the user that
  it should be stored in `$XDG_DATA_HOME`.
  It may contain:
  - actions history (logs, history, recently used files, …)
  - current state of the application that can be reused
    on a restart (view, layout, open files, undo history, …)
- User-specific executable files may be stored in `$HOME/.local/bin`.
  Distributions should ensure this directory shows up in the UNIX `$PATH`
  environment variable, at an appropriate place.
- `$XDG_DATA_DIRS` defines the preference-ordered set of base directories
  to search for data files in addition to the `$XDG_DATA_HOME` base directory.
  The directories in `$XDG_DATA_DIRS` should be seperated with a colon ':'.

[xdg]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

## Interesting links

### Interesting dotfiles repos

- [dotfiles.github.io/inspiration/](https://dotfiles.github.io/inspiration)
- [frdmn/dotfiles](https://github.com/github.com/frdmn/dotfiles) - Ansible-based
  dotfile setup for macOS
- [mvdan/dotfiles](https://github.com/mvdan/dotfiles) - Here be dragons
- [vsouza/dotfiles](https://github.com/vsouza/dotfiles) - 🏡 My dotfiles
- [freekmurze/dotfiles](https://github.com/freekmurze/dotfiles) - My personal dotfiles
