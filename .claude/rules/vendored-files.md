---
description: "Vendored fzf files must never be modified — refresh from upstream as one bundle."
paths:
  - "local/bin/fzf-tmux"
  - "config/fzf/completion.bash"
  - "config/fzf/completion.zsh"
  - "config/fzf/key-bindings.bash"
  - "config/fzf/key-bindings.zsh"
  - "config/fzf/key-bindings.fish"
---

# Vendored files

Never modify these files — they are vendored verbatim from
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

The `.claude/settings.json` PreToolUse hook blocks edits to all
six vendored files. Bypassing the hook is forbidden; see
`.claude/rules/no-hook-bypass.md`.
