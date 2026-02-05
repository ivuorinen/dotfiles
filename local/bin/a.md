# a

Encrypt or decrypt files and directories using `age` and your GitHub SSH keys.

## Requirements

- [age](https://github.com/FiloSottile/age) - encryption tool
- curl - for fetching SSH keys

Install age:

```bash
brew install age     # macOS
apt install age      # Debian/Ubuntu
dnf install age      # Fedora
```

## Usage

```bash
a [options] <command> <file|directory>
```

Commands:

- `e`, `enc`, `encrypt` - encrypt files
- `d`, `dec`, `decrypt` - decrypt files
- `help`, `--help`, `-h` - show help
- `version`, `--version` - show version

Options:

- `-v`, `--verbose` - show log output
- `--delete` - delete original files after successful operation
- `-f`, `--force` - overwrite existing output files

Environment variables:

- `AGE_KEYSFILE` - location of the keys file (default: `~/.ssh/keys.txt`)
- `AGE_KEYSSOURCE` - URL to fetch keys if missing (default: GitHub keys)
- `AGE_LOGFILE` - log file path (default: `~/.cache/a.log`)

## Examples

```bash
# Encrypt a file
a encrypt secret.txt

# Encrypt with short command
a e secret.txt

# Decrypt a file
a decrypt secret.txt.age
a d secret.txt.age

# Encrypt a directory (includes hidden files)
a e /path/to/secrets/

# Encrypt and delete originals
a --delete e secret.txt

# Force overwrite existing .age file
a -f e secret.txt

# Verbose output
a -v e secret.txt
```

## Behavior

- Encrypting a directory processes all files recursively, including hidden files
- Already encrypted files (`.age`) are skipped during encryption
- Only `.age` files are processed during directory decryption
- Original files are preserved by default (use `--delete` to remove them)
- Output files are not overwritten by default (use `--force` to overwrite)

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
