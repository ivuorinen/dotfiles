# install-python-packages

Install Python packages defined in the script using `uv`.

## Usage

```bash
scripts/install-python-packages.sh
```

## What it does

1. Checks that `uv` is available; if missing, installs it via the official installer.
2. Installs each CLI tool from the inline `tools` array using `uv tool install --upgrade`.
3. Installs each library from the inline `libraries` array using `uv pip install --system --upgrade`.
4. Upgrades all uv-managed tools with `uv tool upgrade --all`.

To add or remove packages, edit the `tools` or `libraries` arrays in `scripts/install-python-packages.sh`.
