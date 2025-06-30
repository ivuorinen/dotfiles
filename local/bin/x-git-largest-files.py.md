# x-git-largest-files.py

Lists the largest files in a git repository.

```bash
x-git-largest-files.py [options]
```

Options:

- `-c NUM` – number of files to show (default: 10)
- `--files-exceeding N` – list files larger than N KB
- `-p` – sort by on-disk size instead of pack size

## Example

```bash
x-git-largest-files.py -c 5
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
