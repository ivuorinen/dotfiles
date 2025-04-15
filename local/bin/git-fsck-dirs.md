# git-fsck-dirs

A utility to check multiple Git repositories for corruption
using `git fsck`.

## Overview

`git-fsck-dirs` scans all subdirectories within a specified path
and performs a `git fsck` operation on each Git repository found.
This helps identify corrupted repositories or those with integrity
issues.

## Features

- Recursively checks all Git repositories in the given directory
- Provides a summary of repositories checked and any issues found
- Filters out common version control directories (.git, .svn, etc.)
- Supports verbose and debug modes

## Usage

```bash
git-fsck-dirs [path] [errors_file] [repo_count_file]
git fsck-dirs [path] [errors_file] [repo_count_file]
```

### Arguments

- `path`: Directory to scan (defaults to current directory)
- `errors_file`: Path to save errors (defaults to /tmp/git-fsck-errors.txt)
- `repo_count_file`: Path to save repository count
  (defaults to /tmp/git-fsck-repo-count.txt)

### Environment Variables

- `VERBOSE=1`: Enable verbose output
- `DEBUG=1`: Enable debug mode (shows executed commands)

## Examples

Check repositories in the current directory:

```bash
git fsck-dirs
git-fsck-dirs
```

Check repositories in a specific directory:

```bash
git fsck-dirs ~/projects
git-fsck-dirs ~/projects
```

Enable verbose output:

```bash
VERBOSE=1 git-fsck-dirs
```

## License

MIT License - Copyright 2023 Ismo Vuorinen

<!-- vim: set ft=markdown cc=80 : -->
