# install-cargo-packages

Install Rust packages listed in `config/asdf/cargo-packages`.

## Usage

```bash
scripts/install-cargo-packages.sh
```

The script installs each package with `cargo install` and runs
`cargo-install-update` when available to update existing packages.
