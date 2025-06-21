# git-attributes

Checks that every tracked file has a matching pattern in `.gitattributes`.
Can optionally suggest or write missing rules.

## Usage

```bash
git-attributes [options]
```

Options include:

- `-v, --verbose` – show progress information
- `-e, --exit` – exit with non-zero status if missing rules
- `-p, --pattern <glob>` – pattern to check (default: `text: auto`)
- `-w, --write` – append suggestions to `.gitattributes`

### Example

```bash
git-attributes -v --write
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
