# ae

Encrypt a file with `age` using your GitHub SSH keys.

## Usage

```bash
ae [-f|--force] [--delete] <file|directory>...
```

`ae` is shorthand for `a -v encrypt`; see `a.md` for the full behaviour.

Writes `<file>.age`. An existing `<file>.age` is only replaced with
`-f`/`--force`, and a directory at that path is always refused. A directory
is encrypted recursively. Errors go to stderr; progress goes to stdout.

The recipient keys are cached in `AGE_KEYSFILE` (default: `~/.ssh/keys.txt`)
and fetched from `AGE_KEYSSOURCE` when the cache is missing or older than
`AGE_KEYS_MAX_AGE_DAYS` (default: `7`). A failed refetch warns and keeps
using the cached file.

## Example

```bash
ae secret.txt
ae *.txt           # every matching file
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
