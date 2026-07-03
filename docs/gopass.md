# gopass

[gopass](https://www.gopass.pw) is a `pass`-compatible password manager:
secrets are GPG- (or age-) encrypted files in a git-backed store. It is
installed and pinned via mise (the `gopass` entry in
`config/mise/config.toml`).

## How it is wired here

- **`p` alias**: `config/alias` defines `alias p="gopass"`, gated behind
  `x-have gopass` so it only exists when gopass is on PATH. So `p show …`
  ≡ `gopass show …`.
- **Fish completions**: `config/fish/completions/gopass.fish` provides
  entry-name and subcommand completion (it shells out to
  `gopass ls --flat`).
- **age backend**: the `age` tool is also mise-managed, so gopass can
  use age recipients in addition to GPG.

## First-time setup

```bash
gopass setup            # interactive: create or clone a store, pick GPG/age
# or, to attach an existing remote store:
gopass clone git@github.com:you/store.git
```

## Everyday commands

| Command                      | Does                                           |
|------------------------------|------------------------------------------------|
| `p ls`                       | List all secrets in the store                  |
| `p show <path>`              | Show a secret (first line = password)          |
| `p show -c <path>`           | Copy the password to the clipboard             |
| `p find <term>` / `p search` | Find secrets by name                           |
| `p grep <term>`              | Search **inside** decrypted secret contents    |
| `p insert <path>`            | Add a secret interactively                     |
| `p generate <path> [length]` | Generate and store a new password              |
| `p edit <path>`              | Edit a secret in `$EDITOR`                     |
| `p cp` / `p mv` / `p rm`     | Copy / move / remove secrets                   |
| `p otp <path>`               | Print a TOTP/HOTP token for the entry          |
| `p sync`                     | Pull/push all stores against their git remotes |
| `p audit`                    | Scan for weak or leaked passwords              |
| `p history <path>`           | Show a secret's git history                    |

## Access management (GPG recipients)

A store's **recipients** are the GPG (or age) keys allowed to decrypt
it. Granting or revoking access means editing that recipient list with
`gopass recipients`; gopass then re-encrypts every secret for the new
set of keys.

| Command                               | Does                                       |
|---------------------------------------|--------------------------------------------|
| `p recipients`                        | List the keys authorized on each store     |
| `p recipients add <key-id\|email>`    | Authorize a key (alias `authorize`)        |
| `p recipients remove <key-id\|email>` | Revoke a key (aliases `rm`, `deauthorize`) |
| `p recipients ack`                    | Acknowledge a changed recipient list       |

Granting access to a new person:

```bash
gpg --import their-public-key.asc       # import their public key first
gpg --list-keys their@email             # confirm the key id / fingerprint
p recipients add their@email            # re-encrypts the store for them
p sync                                  # push the re-encrypted store + new recipient
```

Revoking access:

```bash
p recipients remove their@email         # drop the key and re-encrypt
p sync                                  # push the change
```

Notes on access management:

- You can only `add` a key that GPG already knows about — import the
  recipient's public key (`gpg --import`) before authorizing it.
- `remove` re-encrypts so the revoked key can no longer decrypt **new**
  changes, but anyone who already cloned the store keeps the old
  ciphertext. Treat any secret a removed recipient could read as
  compromised and rotate it (`p generate <path>`).
- For multiple stores, recipients are per-mount; run `p mounts` to see
  them and target a specific store with `p recipients add --store <name> …`.
- When gopass warns that the recipient list changed out-of-band,
  `p recipients ack` records that you have reviewed it.

## Notes

- `p show` prints the secret to the terminal; prefer `p show -c` to copy
  it to the clipboard without it landing in scrollback.
- The store is just git underneath — `p sync` is the safe way to
  reconcile with the remote; avoid running raw `git` inside the store
  unless you know what you are doing.
- gopass entries are unrelated to this repo's `config/fish/secrets.d/*`
  shell-secret files — those are sourced env exports, not gopass secrets.
