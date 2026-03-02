# install-shellspec

Installs [shellspec](https://github.com/shellspec/shellspec), a BDD-style
testing framework for shell scripts.

## Usage

```bash
scripts/install-shellspec.sh
```

The script clones shellspec to `~/.cache/shellspec` and runs
`make install PREFIX=$HOME/.local`, placing the binary in `~/.local/bin/`.
Re-running the script pulls the latest version and reinstalls.
