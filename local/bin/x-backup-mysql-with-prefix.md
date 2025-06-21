# x-backup-mysql-with-prefix

Dump MySQL tables matching a prefix to a timestamped file.

## Usage

```bash
x-backup-mysql-with-prefix <prefix> <name> [database]
```

- `prefix` – table prefix to match (e.g. `wp_`)
- `name` – file name prefix
- `database` – database name (default: `wordpress`)

## Example

```bash
x-backup-mysql-with-prefix wp_ blog
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
