# git-update-dirs

A tool that efficiently updates all Git repositories in subdirectories
of the current folder.

## Overview

`git-update-dirs` scans the current directory for Git repositories
and updates them with:

- Fast parallel execution
- Intelligent error handling
- Progress visualization
- Detailed logging
- Optional branch cleanup

## Installation

Place the script in your PATH and make it executable:

```bash
# Using wget
wget -O ~/bin/git-update-dirs https://raw.githubusercontent.com/ivuorinen/dotfiles/main/local/bin/git-update-dirs
chmod +x ~/bin/git-update-dirs

# Or simply copy the script to a location in your PATH
cp git-update-dirs ~/bin/
chmod +x ~/bin/git-update-dirs
```

## Usage

```text
Usage: git-update-dirs [OPTIONS]

Updates all git repositories in subdirectories.

Options:
  --help, -h      Display this help message and exit
  --version, -v   Display version information and exit
  --verbose       Display detailed output
  --quiet, -q     Suppress all output except errors
  --exclude DIR   Exclude directory from updates
                  (can be used multiple times)
  --cleanup       Remove local branches that have been merged into
                  current branch
  --config FILE   Read options from configuration file
  --log FILE      Log details and errors to FILE

Environment variables:
  VERBOSE         Set to 1 to enable verbose output
  EXCLUDE_DIRS    Space-separated list of directories to exclude
```

## Examples

Basic usage to update all repositories:

```bash
git-update-dirs
```

Update with detailed output:

```bash
git-update-dirs --verbose
```

Exclude specific directories:

```bash
git-update-dirs --exclude node_modules --exclude vendor
```

Update and clean up merged branches:

```bash
git-update-dirs --cleanup
```

Use options from a configuration file:

```bash
git-update-dirs --config ~/.gitupdate.conf
```

## Configuration File

You can create a configuration file to store your preferred options:

```text
# Example ~/.gitupdate.conf
verbose
exclude node_modules
exclude vendor
cleanup
log ~/.gitupdate.log
```

## Features

- **Smart Updates**: Uses `--rebase --autostash --prune`
  for clean updates
- **Error Handling**: Skips repositories with conflicts or
  untracked files that would be overwritten
- **Visual Progress**: Shows a progress bar with current status
- **Repository Management**: Optionally cleans up merged branches
- **Detailed Logging**: Records all operations with timestamps

## License

[MIT License][MIT] - Copyright 2023 Ismo Vuorinen

[MIT]: https://opensource.org/license/mit/

<!-- vim: set ft=markdown cc=80 : -->
