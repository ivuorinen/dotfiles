# install-shellspec

Installs [shellspec](https://github.com/shellspec/shellspec), a BDD-style
testing framework for shell scripts.

## Usage

```bash
scripts/install-shellspec.sh
```

The script resolves the latest release tag via `x-gh-get-latest-version`,
clones shellspec to `~/.cache/shellspec` pinned to that tag, and runs
`make install PREFIX=$HOME/.local`, placing the binary in `~/.local/bin/`.
Re-running the script fetches and checks out the newest release tag
before reinstalling.
