# a

Encrypt or decrypt files and directories using `age` and your GitHub SSH keys.

## Usage

```bash
a encrypt <file|dir>
a decrypt <file.age|dir>
```

Options:

- `-v`, `--verbose` – show log output

Environment variables:

- `AGE_KEYSFILE` – location of the keys file
- `AGE_KEYSSOURCE` – URL to fetch keys if missing
- `AGE_LOGFILE` – log file path

## Example

```bash
a encrypt secret.txt
a decrypt secret.txt.age
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
