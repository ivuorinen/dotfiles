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
a [options] <command> <file|directory>...
```

Every target is processed. A target that is missing, or a named file
without `.age` when decrypting, counts as a failure and the rest still run;
any failure makes the exit status 1.

Commands:

- `e`, `enc`, `encrypt` - encrypt files
- `d`, `dec`, `decrypt` - decrypt files
- `help`, `--help`, `-h` - show help
- `version`, `--version` - show version

Options (accepted anywhere on the command line):

- `-v`, `--verbose` - print progress messages to stdout
- `--delete` - delete the source file after a successful encrypt or decrypt;
  a source that cannot be deleted fails that file (exit 1)
- `-f`, `--force` - overwrite existing output files

Environment variables:

- `AGE_KEYSFILE` - location of the keys file (default: `~/.ssh/keys.txt`)
- `AGE_KEYSSOURCE` - URL to fetch keys from when the keys file is missing or
  stale (default: GitHub keys)
- `AGE_KEYS_MAX_AGE_DAYS` - days before the keys file is refetched (default:
  `7`), so a key removed from GitHub stops receiving new files; a failed
  refetch, a refreshed file `age` cannot parse, or one that cannot be
  installed, warns and keeps using the cached file
- `AGE_IDENTITY` - private key used to decrypt (default: `~/.ssh/id_ed25519`,
  else `~/.ssh/id_rsa`); the keys file holds public keys and cannot decrypt
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

- Encrypting or decrypting a directory processes all files recursively,
  including hidden files; a symlinked directory inside the tree is skipped
  with a warning, while one named as the target is processed
- Already encrypted files (`.age`) are skipped during encryption
- Only `.age` files are processed during directory decryption; a named file
  without the `.age` suffix is refused
- Original files are preserved by default (use `--delete` to remove them)
- Output files are not overwritten by default (use `--force` to overwrite);
  a directory at the output path is refused even with `--force`
- Errors and warnings always go to stderr and the log file; progress
  messages go to stdout only with `-v`
- A failed file does not stop a directory run; the remaining files are
  processed and the exit status is 1 with a count of the failures
- `ae` and `ad` are shorthands for `a -v encrypt` and `a -v decrypt`

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
