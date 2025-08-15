# git-dirty

A powerful tool to recursively check Git repository status across
multiple directories.

## Overview

`git-dirty` scans directories to identify Git repositories and reports their
status. It quickly shows which repositories have uncommitted changes,
untracked files, or need to be pushed, making it easy to maintain clean
workspaces across multiple projects.

## Features

- 🔍 **Recursive scanning** of directories to find Git repositories
- 🚦 **Visual indicators** showing repository status (clean/dirty/not git)
- 🔄 **Parallel processing** for faster scanning of large directory structures
- 🌳 **Tree-like display** with customizable depth
- 📊 **Progress tracking** for large repository scans
- 🎨 **Colorized output** (can be disabled)
- 📏 **Path truncation** for cleaner display
- 🔀 **Branch display** with smart formatting for main branches
- ⏱️ **Performance metrics** showing scan speed and ETA
- 📈 **Smart sorting** to maintain tree hierarchy in output
- ⚙️ **Configurable** via environment variables or config files

## Installation

Place the script in your PATH and make it executable:

```bash
# Clone the repository or download the script
curl -o ~/.local/bin/git-dirty https://raw.githubusercontent.com/ivuorinen/dotfiles/main/local/bin/git-dirty
chmod +x ~/.local/bin/git-dirty
```

## Usage

```bash
git-dirty [OPTIONS] [DIRECTORY]
# or if the file is in the PATH, you can use it as an git command
git dirty [OPTIONS] [DIRECTORY]

# to show help
git dirty -h
```

If no directory is specified, it will use `$HOME/Code` as the default.

### Options

- `-h` Show help message and exit
- `-d NUM` Set maximum depth for showing non-git directories (default: 5)
- `-p` Process directories in parallel (requires 'parallel' command)
- `-v` Enable verbose output
- `-a` Show all status details (stash, untracked files, etc.)
- `-e PATTERNS` Additional patterns to exclude (comma separated)
- `-m NUM` Set maximum recursion depth (default: 15)
- `-c` Toggle colorized output
- `-t` Toggle path truncation
- `-b` Toggle branch name display

### Examples

```bash
# Check default directory
git-dirty

# Check specific directory
git-dirty ~/Projects

# Check with extended status information
git-dirty -a ~/Code

# Exclude certain directories
git-dirty -e 'build,dist,node_modules' ~/Code

# Use parallel processing for faster results
git-dirty -p ~/large-directory

# Hide branch names in output
git-dirty -b ~/Code
```

## Status Indicators

The script uses the following status indicators:

- ✅ Clean repository
- ❌ Dirty repository with details:
  - `M` = Modified files
  - `S` = Staged changes
  - `?` = Untracked files (with `-a` flag)
  - `$` = Stashed changes (with `-a` flag)
  - `↑` = Unpushed commits
- ⚠️ Not a Git repository

## Branch Display

The script shows branch names for repositories not on main branches.
This helps identify repositories where work is happening on feature branches.
Main branches (configurable as `main`, `master`, and `trunk` by default) are
hidden to reduce output clutter.

## Configuration

You can customize the default behavior using environment variables:

```bash
# in your .bashrc, .zshrc, etc.
export GIT_DIRTY_DIR="$HOME/Projects"   # Set default directory
export GIT_DIRTY_DEPTH=3                # Show non-git dirs up to depth 3
export GIT_DIRTY_MAXDEPTH=15            # Maximum recursion depth
export GIT_DIRTY_COLOR=1                # Enable colorized output (0 to disable)
export GIT_DIRTY_TRUNCATE=1             # Enable path truncation (0 to disable)
export GIT_DIRTY_SHOW_BRANCH=1          # Show branch names (0 to disable)
export GIT_DIRTY_MAIN_BRANCHES="main master trunk" # Main branches (not shown in output)
export GIT_DIRTY_EXCLUDE="node_modules vendor .cache build dist .tests .test"  # Default excludes
```

### Config File

You can also create a configuration file at `$XDG_CONFIG_HOME/git-dirty/config`
(typically `~/.config/git-dirty/config`):

```bash
# Example config file
GIT_DIRTY_DIR="$HOME/Projects"
GIT_DIRTY_DEPTH=3
GIT_DIRTY_CHECK_STASH=1
GIT_DIRTY_SHOW_BRANCH=1
GIT_DIRTY_MAIN_BRANCHES="main master trunk develop"
GIT_DIRTY_EXCLUDE="node_modules vendor .cache build dist tmp"
```

## Skip Directories from Checking

If you want to skip a directory from being checked, add a `.ignore` file next
to the `.git` folder. You can add `.ignore` to your global `.gitignore` file
to avoid committing these files.

## Performance Features

- **Parallel processing**: Significant speed improvements when
  using the `-p` flag
- **Progress bars**: Real-time feedback on scanning progress with ETA
- **Rate limiting**: Controls parallel jobs to prevent system overloading
- **Smart directory traversal**: Skips excluded directories for
  faster processing

## Tips

Add an alias: Create an alias in your shell configuration:

```bash
alias gd='git-dirty'
```

Use it with specific directories:

```bash
git-dirty ~/specific/project
```

Run in parallel mode for large codebases:

```bash
git-dirty -p ~/huge-monorepo
```

Turn off branch display for cleaner output:

```bash
git-dirty -b
```

## Requirements

- Bash (version 4+)
- Git
- Optional: GNU Parallel for parallel processing

## License

MIT

## Credits

Created with ❤️ by Ismo Vuorinen

<!-- vim: set ft=markdown cc=80 : -->
