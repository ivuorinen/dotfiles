---
description: "Vendored third-party files must never be modified — refresh from upstream instead."
paths:
  - "config/fish/functions/fisher.fish"
  - "config/fish/functions/bass.fish"
  - "config/fish/functions/__bass.py"
  - "config/fish/functions/__z_add.fish"
  - "config/fish/functions/__z_clean.fish"
---

# Vendored files

Never modify vendored files. One group, the fish plugin functions below,
is vendored in-tree rather than carried as a submodule; it is refreshed
from upstream, never edited in place.

fzf is not vendored: the mise-installed binary generates its own shell
integration (`fzf --bash`/`--zsh`), which `config/fzf/fzf.{bash,zsh}` cache
through `lib::init_cached`. Those loaders are project code.

Neither is the graphify skill: `graphify install --platform claude` writes it
as a personal skill (`.claude/rules/graphify-first.md`). An in-tree copy
existed until 2026-10 and was removed because Claude Code runs a personal
skill over a project skill of the same name, so the copy was shadowed and
drifted from the CLI version.

## fish plugin functions

Five files under `config/fish/functions/` are plugin code, not repo
code. They sit beside hand-written functions with no naming signal,
which is exactly why they are listed here:

| File                     | Upstream                                                      |
|--------------------------|---------------------------------------------------------------|
| `fisher.fish`            | [jorgebucaran/fisher](https://github.com/jorgebucaran/fisher) |
| `bass.fish`, `__bass.py` | [edc/bass](https://github.com/edc/bass)                       |
| `__z_add.fish`           | [jethrokuan/z](https://github.com/jethrokuan/z)               |
| `__z_clean.fish`         | [jethrokuan/z](https://github.com/jethrokuan/z)               |

`fisher.fish` carries its own version marker — `set --local
fisher_version 4.4.8` on line 3 — so check that before and after any
refresh. Refresh each through fisher itself (`fisher update`), never
by editing the file.

Scanner exclusions for this group already exist: `__bass.py` is in
`exclude_dirs` under `[tool.bandit]` in `pyproject.toml`, and all five
are in `exclude_paths` in `.codacy.yml`. Without them Codacy reports
five unactionable Security issues against `__bass.py` alone (B404,
two B603, two Opengrep `dangerous-subprocess-use`).

## Enforcement

One regex, `PROTECTED_RE` in `.claude/hooks/lib/protected-paths.sh`,
covers every path listed above plus the submodule trees and the git
hook files (`.git/hooks`, `.git/config`). Three hooks source it: `pre-edit-block.sh` blocks
Edit/Write, `pre-ctx-write-guard.sh` blocks sandbox code that writes
(each `ctx_batch_execute` command judged on its own, as each runs in its
own shell), and `pre-bash-route.sh` blocks Bash commands that write (`>`, `cp`,
`mv`, `rm`, `tee`, `sed -i`, `perl`/`ruby -i`, `ed`/`ex`/`vi`/`vim`/`nvim`,
`patch`, `rsync`, awk `print >` or `-i inplace`, `git checkout … --`).
Sandbox code that launches an editor through a subprocess without naming
a policy tool is not seen. The `paths:` list in
this file's frontmatter is the source: `tests/protected-paths-parity.bats`
fails when any entry is not refused by all three hooks. Bypassing the
hooks is forbidden; see `.claude/rules/no-hook-bypass.md`.
