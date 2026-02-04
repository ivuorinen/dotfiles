# install-go-packages

Install Go packages defined in the script.

## Usage

```bash
scripts/install-go-packages.sh
```

## What it does

1. Checks that `go` is available.
2. Installs each package from the inline list using `go install`.
3. Runs post-install steps (e.g. generating shell completions).
4. Clears the Go module and build caches.

To add or remove packages, edit the `packages` array in `scripts/install-go-packages.sh`.
