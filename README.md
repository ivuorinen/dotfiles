# .dotfiles

The folder structure follows [XDG Base Directory Specification][xdg] where possible.

## Setup

## rcrc

Update install script

```bash
rcup -B 0 -g > ~/.dotfiles/install.sh | shfmt -w -l ~/.dotfiles/install.sh
```

## brew

Install everything described in `Brewfile`

```bash
brew bundle install --force --file=~/.dotfiles/Brewfile
```


Update `Brewfile`

```bash
brew bundle dump --force --file=~/.dotfiles/Brewfile --describe
```

Enable automatic brew updates and upgrades.

```bash
brew autoupdate start 43200 --upgrade --cleanup --immediate
```

## XDG Variables

| Var                | Default              |
|--------------------|----------------------|
| Executables        | `$HOME/.local/bin`   |
| `$XDG_DATA_HOME`   | `$HOME/.local/share` |
| `$XDG_STATE_HOME`  | `$HOME/.local/state` |
| `$XDG_CONFIG_HOME` | `$HOME/.config`      |


- `$XDG_DATA_HOME` defines the base directory relative to which user-specific data files should be stored. If `$XDG_DATA_HOME` is either not set or empty, a default equal to ` $HOME/.local/share` should be used.
- `$XDG_CONFIG_HOME` defines the base directory relative to which user-specific configuration files should be stored. If `$XDG_CONFIG_HOME` is either not set or empty, a default equal to `$HOME/.config` should be used.
- `$XDG_STATE_HOME` defines the base directory relative to which user-specific state files should be stored. If `$XDG_STATE_HOME` is either not set or empty, a default equal to `$HOME/.local/state` should be used.
- The `$XDG_STATE_HOME` contains state data that should persist between (application) restarts, but that is not important or portable enough to the user that it should be stored in `$XDG_DATA_HOME`. It may contain:
  - actions history (logs, history, recently used files, …)
  - current state of the application that can be reused on a restart (view, layout, open files, undo history, …)
- User-specific executable files may be stored in `$HOME/.local/bin`. Distributions should ensure this directory shows up in the UNIX `$PATH` environment variable, at an appropriate place.
- `$XDG_DATA_DIRS` defines the preference-ordered set of base directories to search for data files in addition to the `$XDG_DATA_HOME` base directory. The directories in `$XDG_DATA_DIRS` should be seperated with a colon ':'.


[xdg]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
