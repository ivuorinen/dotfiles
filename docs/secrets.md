# Shell secrets

Two directories hold live credentials: `config/fish/secrets.d/`
(sourced by `config/fish/exports.fish`) and `config/secrets.d/`
(sourced by `config/exports` for bash and zsh). Both reach `~/.config`
through symlinks, so the repo path and the home path are the same inode.

The agent-facing mandates live in `.claude/rules/secrets-files.md`.

## Adding a secret

Copy the matching `<name>.example` file to `<name>` (without the
`.example` suffix) and edit the copy locally. The non-example files are
auto-sourced at shell startup.

## Modes

Secret directories are `0700` and secret files are `0600` — owner only.
The `.example` templates and `README.md` are tracked, carry no
credentials, and keep their normal mode.

`dfm secrets create` writes them correctly: it sets `umask 077` before
creating anything, then re-applies `chmod 700` to the directories and
`chmod 600` to the files, because a umask governs only newly created
paths and would leave an existing file untouched.

Files created any other way — copied from a template by hand, restored
from a backup, written by an editor — inherit the `0002` umask and land
at `0664`, readable by every local account. `dfm check perms` reports
that and `dfm check perms --fix` repairs it; `./install` runs the
`--fix` form on every run.

Do not rely on `~` being `0750` for this. It is today, which is why a
`0664` secret was not actually exposed, but a single permission change
on the home directory would turn every one of them into a readable
file. The file mode is the control that belongs to the secret.
