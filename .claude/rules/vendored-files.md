# Vendored files

Never modify these files — they are vendored verbatim from
[junegunn/fzf](https://github.com/junegunn/fzf) and updated via
submodule sync, never via direct edits:

- `local/bin/fzf-tmux`
- `config/fzf/completion.bash`
- `config/fzf/completion.zsh`
- `config/fzf/key-bindings.bash`
- `config/fzf/key-bindings.zsh`
- `config/fzf/key-bindings.fish`

The shell loaders `config/fzf/fzf.bash` and `config/fzf/fzf.zsh`
are local shims that `source` the vendored files — those are
project code and may be edited.

`.pre-commit-config.yaml` excludes the vendored shell files from
`shfmt`. The vendored files self-disable shellcheck via an in-file
`# shellcheck disable=all` directive, so no shellcheck exclude is
needed.

The `.claude/settings.json` PreToolUse hook blocks edits to
`local/bin/fzf-tmux`. Bypassing the hook is forbidden; see
`.claude/rules/no-hook-bypass.md`.
