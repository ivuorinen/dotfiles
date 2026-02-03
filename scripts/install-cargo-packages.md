# install-cargo-packages

Install Rust packages defined in the script.

## Usage

```bash
scripts/install-cargo-packages.sh
```

## What it does

1. If `cargo-install-update` is available, updates all existing packages first
   and tracks which packages are already installed.
2. Installs each package from the inline list using `cargo install`,
   skipping any already handled by the update step.
   Builds run in parallel using available CPU cores (minus two).
3. Runs package-specific post-install steps.
4. Cleans the cargo cache with `cargo cache --autoclean`.

To add or remove packages, edit the `packages` array in `scripts/install-cargo-packages.sh`.
