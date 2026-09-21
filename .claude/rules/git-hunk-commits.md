---
description: "Stage and commit exclusively with git-hunk; never git add or git commit -a."
---

# Commit with git-hunk

Stage and commit only through `git-hunk` (installed via mise). Never
use `git add`, `git add -p`, or `git commit -a`.

```bash
git-hunk list                              # hunks with content hashes
git-hunk commit <hash>... -m "type(scope): summary"
git-hunk add <hash>                        # stage a whole hunk
git-hunk add <hash>:3-5,8                  # stage selected lines
git-hunk list --staged --oneline           # verify what is staged
```

`git-hunk commit` takes the named hunks straight to a commit, so
unrelated work in progress stays in the tree untouched. It runs the
pre-commit and commit-msg hooks, so no gate is lost. Message format
is still `.claude/rules/commit-format.md`.

`pre-bash-route.sh` denies `git add` (any form) and `git commit` with
`-a`/`--all`, and `BASH_OK` does not override it.

## Gotchas

- **Hashes depend on `-U`.** A hash from `git-hunk list -U 0` only
    matches when `commit`/`add` also get `-U 0`; otherwise the call
    fails with `no hunk matching`.
- **`-U 0` splits adjacent edits.** Neighbouring one-line version bumps
    merge into one hunk at the default context; `-U 0` keeps them
    separate so they can go to different commits.
- **Group by concern.** Leave hunks you did not author out unless asked.
    For "smart groups", split by what a revert would need to isolate:
    repo toolchain (`.mise.toml`), security tools, other global pins.
- `git-hunk list` prints output, so route it through context-mode
    (`bash-routing.md`); `git-hunk commit` is a state mutation and may
    run under `Bash`.
