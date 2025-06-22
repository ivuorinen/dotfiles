# install-go-packages

Installs Go binaries defined in `config/go/packages`.

## Usage

```bash
scripts/install-go-packages.sh
```

The script uses `go install` for each package path listed in the configuration
file.
