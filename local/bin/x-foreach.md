# x-foreach

Run a command in each directory produced by another command.

## Usage

```bash
x-foreach "<list-cmd>" "<cmd>"
```

- `list-cmd` – command that outputs directories
- `cmd` – command to run inside each directory

## Example

```bash
x-foreach "ls -d */" "git status"
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
