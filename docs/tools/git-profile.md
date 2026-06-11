# git-profile

[git-profile](https://github.com/dotzero/git-profile) manages multiple
Git identities and switches between them per repository. It is
mise-managed (the `github:dotzero/git-profile` entry in
`config/mise/config.toml`) and backed by shell completions for bash
(`config/bash/completions.d/x-gitprofile.bash`) and zsh
(`config/zsh/completion/_git-profile`).

The base identity lives in `config/git/config` (`Ismo Vuorinen
<ismo@ivuorinen.net>`); git-profile overlays a different
name/email/signing key on top, per repo.

## Profiles

Three identities are used here: **home**, **work**, **masf**. Profiles
are stored in `~/.gitprofile` (override with `-c <file>`).

## Commands

| Command                     | Does                                     |
|-----------------------------|------------------------------------------|
| `git profile list`          | List defined profiles                    |
| `git profile current`       | Show the profile active in this repo     |
| `git profile use <name>`    | Apply a profile to the current repo      |
| `git profile add <name> …`  | Add or update a profile's entries        |
| `git profile del <name>`    | Delete a profile (or one of its entries) |
| `git profile export <name>` | Export a profile                         |
| `git profile import`        | Import a profile                         |

## Automatic per-directory switching

Two mechanisms wire profiles to directories so you rarely call
`git profile use` by hand:

### `gh-set-profile` (path → profile)

`local/bin/gh-set-profile` inspects the repo root and runs
`git profile use <name>` based on where the repo lives under `~/Code`
(work / home / masf — see the `case` in the script for exact paths). It
is invoked as the sesh `startup_command` for the `~/Code/**` wildcard
(`config/sesh/sesh.toml`), so entering a project session sets the right
identity. See `local/bin/gh-set-profile.md` for details.

### `x-gitprofile` (mise enter hooks)

`local/bin/x-gitprofile` drops a `.mise.toml` into a directory with:

```toml
[hooks]
enter = "git profile use <profile>"
```

so mise switches the profile whenever you `cd` into that tree. Run
`x-gitprofile` with no args to set up the defaults, or
`x-gitprofile <profile> <dir>` to wire a specific directory.

## Notes

- `git profile current` is the quickest way to confirm which identity a
  commit will use before you push.
- Auto-switching only fires on session start (`gh-set-profile`) or
  directory enter (mise hook). After editing profiles, re-enter the
  directory or run `git profile use <name>` to apply immediately.
