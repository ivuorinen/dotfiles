# Vendored files

Never modify `local/bin/fzf-tmux`. It is vendored verbatim from
[junegunn/fzf](https://github.com/junegunn/fzf). Updates come via
submodule sync, never via direct edits.

The `.claude/settings.json` PreToolUse hook already blocks edits to
this path. Bypassing the hook is forbidden; see
`.claude/rules/no-hook-bypass.md`.
