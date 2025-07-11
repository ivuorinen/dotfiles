# .dotfiles

Welcome to [ivuorinen](https://github.com/ivuorinen)'s .dotfiles repository.
It's a hodgepodge of scripts and configurations, tests and mistakes I'm not
aware of yet. As I find more interesting tools, configs and other stuff,
this repository will live accordingly.

Please for the love of everything good do not use these 1:1 as your own dotfiles,
fork or download the repository as a zip and go from there with your own configs.

It would be nice if you'd add an issue linking to your fork or repo so I can
see what interesting stuff you've done with it. Sharing is caring.

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

![screenshot of light version of tmux with nvim editing this repository](./screenshots/tmux-nvim-kickstart-light.png)

![screenshot of dark version of tmux with nvim editing this repository](./screenshots/tmux-nvim-kickstart-dark.png)

## Interesting files and locations

### Interesting folders

| Path                | Description                                  |
| ------------------- | -------------------------------------------- |
| `.github`           | GitHub Repository configuration files, meta. |
| `hosts/{hostname}/` | Configs that should apply to that host only. |
| `local/bin`         | Helper scripts that I've collected or wrote. |
| `scripts`           | Setup scripts.                               |

### Host specific configuration

Configurations under `hosts/<hostname>` are applied only when running on the
matching machine. Each host folder contains its own `install.conf.yaml` that
is processed by Dotbot during installation.

### dotfile folders

| Repo      | Destination | Description                                 |
| --------- | ----------- | ------------------------------------------- |
| `base/`   | `.*`        | `$HOME` level files.                        |
| `config/` | `.config/`  | Configurations for applications.            |
| `local/`  | `.local/`   | XDG Base folder: `bin`, `share` and `state` |
| `ssh/`    | `.ssh/`     | SSH Configurations.                         |

### `dfm` - the dotfiles manager

[`.local/bin/dfm`][dfm] is a shell script that has some tools that help with dotfiles management.

Running `dfm` gives you a list of available commands.

#### Documentation generation

`dfm docs` generates Markdown documentation under the `docs/` directory. The
subcommands are:

```bash
dfm docs alias        # regenerate alias table
dfm docs folders      # document interesting folders
dfm docs keybindings  # update keybinding docs for tmux, nvim and others
dfm docs all          # run every docs task
```

The `docs/` folder contains generated cheat sheets, keybindings and other
reference files. New documentation can be added without modifying this README.

## Configuration

The folder structure follows [XDG Base Directory Specification][xdg] where possible.

### XDG Variables

| Env                | Default              | Short description                              |
| ------------------ | -------------------- | ---------------------------------------------- |
| `$XDG_BIN_HOME`    | `$HOME/.local/bin`   | Local binaries                                 |
| `$XDG_CONFIG_HOME` | `$HOME/.config`      | User-specific configs                          |
| `$XDG_DATA_HOME`   | `$HOME/.local/share` | User-specific data files                       |
| `$XDG_STATE_HOME`  | `$HOME/.local/state` | App state that should persist between restarts |

Please see [docs/folders.md][docs-folders] for more information.

## Managing submodules

This repository uses Git submodules for external dependencies. After cloning,
run:

```bash
git submodule update --init --recursive
```

To pull submodule updates later use:

```bash
git submodule update --remote --merge
```

The helper script `add-submodules.sh` documents how each submodule is added and
configured. Submodules are automatically updated by the
[update-submodules.yml](.github/workflows/update-submodules.yml) workflow.

## Testing

Shell scripts under `local/bin` are validated with [Bats](https://github.com/bats-core/bats-core).
Run `yarn test` to execute every test file. Bats is installed as a development
dependency, so run `yarn install` first if needed.

[dfm]: https://github.com/ivuorinen/dotfiles/blob/main/local/bin/dfm
[docs-folders]: https://github.com/ivuorinen/dotfiles/blob/main/docs/folders.md
[xdg]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
