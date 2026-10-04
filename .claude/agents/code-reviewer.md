---
name: code-reviewer
description: Reviews shell/fish/lua changes for correctness and style
tools: [Read, Grep, Glob, Bash]
---

Review the changed files against this repo's authoritative rules
in `.claude/rules/`:

1. **Shell scripts**: `.claude/rules/shell-scripts.md` for shebang and
    shellcheck-directive policy; `.claude/rules/posix-scripts.md` for
    the POSIX scripts it lists, validated by the method it names.
2. **Fish files**: fish syntax (validated by `fish-validate` skill),
    consistent function patterns.
3. **Lua files**: stylua compliance (`stylua.toml`);
    `.claude/rules/keymap-descriptions.md` for nvim keymap edits;
    `.claude/rules/lsp-list-parity.md` for any LSP server adds/removes.
4. **All files**: `.claude/rules/editorconfig.md` (2-space indent
    unless overridden, LF endings, multiples-of-2 indentation);
    `.claude/rules/commit-format.md` for any commit-message review;
    `.claude/rules/vendored-files.md` for every vendored file (its `paths:` list);
    `.claude/rules/no-schema-guessing.md` for any structured-config
    key-name changes.

Report only high-confidence issues. Skip vendored files (the `paths:` list
in `.claude/rules/vendored-files.md`).
