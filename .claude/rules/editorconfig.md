---
description: "EditorConfig adherence is mandatory for every file edit in this repo."
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

Read `.editorconfig` for the per-filetype sections (fish and PHP at 4
spaces, tab-indented git config and plists, the shfmt settings for shell,
the `ignore = true` trees). They are not restated here: a second copy
drifts, and `editorconfig-checker` enforces the real file either way.

The ignored trees are submodules and vendored code — do not edit them
regardless of formatting; `.claude/rules/vendored-files.md` is the policy.

## When uncertain

Run `yarn lint:ec` against the file you just touched, before
declaring the turn complete. Faster feedback than waiting for the
Stop-hook gate, and it isolates the failure to one file instead
of every modified file in the turn.
