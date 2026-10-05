# ad

Decrypt a file that `ae` encrypted to your GitHub SSH keys, using the matching
SSH private key.

## Usage

```bash
ad [-f|--force] [--delete] <file.age|directory>...
```

`ad` is shorthand for `a -v decrypt`; see `a.md` for the full behaviour.

Decrypts with `AGE_IDENTITY` (default: `~/.ssh/id_ed25519`, else
`~/.ssh/id_rsa`). The public keys file `ae` uses cannot decrypt.

The output is the input name without `.age`. A named file without the `.age`
suffix is refused, an existing output file is only replaced with
`-f`/`--force`, and a directory at the output path is always refused. A
directory is decrypted recursively. Errors go to stderr; progress goes to
stdout.

## Example

```bash
ad secret.txt.age
ad --force secret.txt.age   # replace an existing secret.txt
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
