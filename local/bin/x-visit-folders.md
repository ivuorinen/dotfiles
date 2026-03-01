# x-visit-folders

Register level-1 subdirectories with zoxide so they appear in
`z` completions.

## Usage

```bash
x-visit-folders [options] [directory]
```

- `directory` – target directory (defaults to current directory)
- `-n`, `--dry-run` – list directories without adding them
- `-v`, `--verbose` – print each directory as it is visited
- `-h`, `--help` – show usage information

## Example

```bash
x-visit-folders ~/Code/ivuorinen
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
