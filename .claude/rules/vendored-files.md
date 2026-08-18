---
description: "Vendored third-party files must never be modified — refresh from upstream instead."
paths:
  - "local/bin/fzf-tmux"
  - "config/fzf/completion.bash"
  - "config/fzf/completion.zsh"
  - "config/fzf/key-bindings.bash"
  - "config/fzf/key-bindings.zsh"
  - "config/fzf/key-bindings.fish"
  - "local/man/man1/fzf.1"
  - "local/man/man1/fzf-tmux.1"
  - "local/bin/iterm2_shell_integration.zsh"
  - ".claude/skills/graphify/**"
  - "config/fish/functions/fisher.fish"
  - "config/fish/functions/bass.fish"
  - "config/fish/functions/__bass.py"
  - "config/fish/functions/__z_add.fish"
  - "config/fish/functions/__z_clean.fish"
---

# Vendored files

Never modify vendored files. Four groups are vendored in-tree rather
than carried as submodules; each is refreshed from upstream, never
edited in place.

## fzf

Vendored verbatim from
[junegunn/fzf](https://github.com/junegunn/fzf). The repo has no
fzf submodule; refresh happens by fetching the upstream files
directly and replacing the local copies in a single commit. The
vendored set:

- `local/bin/fzf-tmux` (from upstream `bin/fzf-tmux`)
- `config/fzf/completion.bash` (from `shell/completion.bash`)
- `config/fzf/completion.zsh` (from `shell/completion.zsh`)
- `config/fzf/key-bindings.bash` (from `shell/key-bindings.bash`)
- `config/fzf/key-bindings.zsh` (from `shell/key-bindings.zsh`)
- `config/fzf/key-bindings.fish` (from `shell/key-bindings.fish`)

Refresh procedure (human operator only — Claude is blocked from
`curl`/`wget` by `.claude/rules/context-mode.md`):

```bash
FZF_REF="${1:-master}"
BASE="https://raw.githubusercontent.com/junegunn/fzf/${FZF_REF}"
curl -sf "${BASE}/bin/fzf-tmux"            -o local/bin/fzf-tmux
curl -sf "${BASE}/shell/completion.bash"   -o config/fzf/completion.bash
curl -sf "${BASE}/shell/completion.zsh"    -o config/fzf/completion.zsh
curl -sf "${BASE}/shell/key-bindings.bash" -o config/fzf/key-bindings.bash
curl -sf "${BASE}/shell/key-bindings.zsh"  -o config/fzf/key-bindings.zsh
curl -sf "${BASE}/shell/key-bindings.fish" -o config/fzf/key-bindings.fish
```

The shell loaders `config/fzf/fzf.bash` and `config/fzf/fzf.zsh`
are local shims that `source` the vendored files — those are
project code and may be edited.

`.pre-commit-config.yaml` excludes the vendored shell files from
`shfmt`. The vendored files self-disable shellcheck via an in-file
`# shellcheck disable=all` directive, so no shellcheck exclude is
needed.

## graphify skill

`.claude/skills/graphify/` is the graphify skill, copied in from the
plugin cache rather than authored here. `.pre-commit-config.yaml`
excludes the whole tree from every hook, so edits to it are never
linted. Refresh by re-copying the skill from the plugin cache; never
hand-edit a file under it, because the next refresh discards the
change with no submodule sync to recover from.

## iTerm2 shell integration

`local/bin/iterm2_shell_integration.zsh` is vendored from iTerm2.
Refresh by downloading the current version from
<https://iterm2.com/shell_integration/zsh>.

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

The `.claude/settings.json` PreToolUse hook
(`.claude/hooks/pre-edit-block.sh`) blocks edits to every path listed
above. Bypassing the hook is forbidden; see
`.claude/rules/no-hook-bypass.md`.
