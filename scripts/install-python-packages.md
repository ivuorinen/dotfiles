# install-python-packages

Install Python **libraries** (not tools — those are managed by mise).

## Usage

```bash
scripts/install-python-packages.sh
```

## What it does

1. Checks that `uv` is available; if missing, exits with an error (install `uv` via mise first).
2. Installs each library from the inline `libraries` array using `uv pip install --system --upgrade`.

To add or remove packages, edit the `libraries` array in `scripts/install-python-packages.sh`.
