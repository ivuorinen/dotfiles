---
description: "EditorConfig adherence is mandatory for every file edit in this repo."
alwaysApply: true
---

# EditorConfig adherence

Every edit and every write to a tracked file in this repo must
conform to `.editorconfig`. The Stop-hook lint gate runs
`editorconfig-checker` via `yarn lint:ec`, and a violation blocks
the turn from finishing.

## Default rules (`[*]`)

- 2-space indent, LF line endings, UTF-8, final newline, trim
  trailing whitespace
- **Indent counts are multiples of 2** — never 3, 5, or 7

The most common trap is markdown ordered-list continuations: a
line that wraps a `"1. "` item indents **4** spaces, not the
canonical 3. A wrapped bullet under a numbered list indents
**6**, not 5. Examples:

```markdown
1. First item that runs onto a second line
    must indent 4 spaces, never 3.

2. Numbered item with a nested bullet:
    - First bullet
    - Second bullet, whose continuation text
      indents 6 spaces, never 5.
```

## Markdown overrides (`[*.md]`)

- 120-char wrap limit
- Trailing whitespace is **not** trimmed — markdown hard breaks
  use two trailing spaces, and the override exists to preserve
  them

## Per-filetype overrides

- `[*.{php,fish}]` — 4-space indent
- `[*.fish]` — 120-char line length
- `[.git{ignore,modules}]` — tab indent, `indent_size = 1`
- `[*.plist]`, `[config/git/**]`, `[**/config/git/**]` — tab
  indent, `indent_size = 1`
- `[*.py]` — 4-space indent, 120-char line length
- `[*.lua]` — 90-char line length (handled by stylua, but the
  ceiling is the editorconfig)
- `[*.hwdb]` — `indent_size = 1`
- `[plan]` — literal filename match for `base/plan`:
  `trim_trailing_whitespace = false`, `max_line_length = off`
- `[base/hammerspoon/hammerspoon.types.lua]` — `max_line_length =
  off` (overrides the `[*.lua]` 90-char ceiling for the generated
  Hammerspoon type stubs)

## Shell scripts (`[{local/bin/*,**/*.sh,**/zshrc,config/*,scripts/*}]`)

- 2-space indent
- shfmt-aware: `binary_next_line`, `switch_case_indent`,
  `space_redirects`, `function_next_line`, `keep_padding = false`

## Ignored trees

`tools/**`, `local/bin/asdf/**`, `config/cheat/cheatsheets/**`
have `ignore = true` — editorconfig-checker skips them. Do not
edit those files anyway (they are submodules or vendored;
`.claude/rules/vendored-files.md` covers the policy).

## When uncertain

Run `yarn lint:ec` against the file you just touched, before
declaring the turn complete. Faster feedback than waiting for the
Stop-hook gate, and it isolates the failure to one file instead
of every modified file in the turn.
