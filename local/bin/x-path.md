# x-path

Manage entries in the `PATH` variable through subcommands.

## Usage

```bash
x-path <command> <directory1> [directory2 ...]
```

### Commands

- `append` / `a` – Append directories to `PATH`
- `prepend` / `p` – Prepend directories to `PATH`
- `remove` – Remove directories from `PATH`
- `check` – Validate directories (default: all in `PATH`)

Set `VERBOSE=1` for progress output.

## Examples

```bash
# Prepend /opt/bin to PATH
x-path prepend /opt/bin

# Remove /usr/local/bin from PATH
x-path remove /usr/local/bin
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
