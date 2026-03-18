# cleanup-old-version-managers

Remove old version manager installations that have been replaced by mise.

## Usage

```bash
scripts/cleanup-old-version-managers.sh [--dry-run]
```

## What it does

1. Removes data directories for nvm, fnm, pyenv, goenv, and bob-nvim.
2. Removes cargo-installed tool binaries now managed by mise.
3. Removes go-installed tool binaries from `$GOPATH/bin`.
4. Uninstalls Homebrew packages replaced by mise (if brew is available).

Mason binaries (`$XDG_DATA_HOME/nvim/mason/`) are not touched.

Pass `--dry-run` to preview what would be removed without making changes.
