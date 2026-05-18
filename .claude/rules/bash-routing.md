---
description: "Shell command routing — ctx_batch_execute is the default tool for all commands producing output."
alwaysApply: true
---

# Bash routing — ctx_batch_execute is the default

ALWAYS use `mcp__plugin_context-mode_context-mode__ctx_batch_execute` for shell
commands. The default tool for ANY shell invocation in this repo is
`ctx_batch_execute` — `Bash` is the exception, not the rule.

## The default rule

If a shell command produces output you intend to read, use
`ctx_batch_execute`. This includes:

- `rg`, `fd`, `grep`, `find` — every search.
- `shellcheck`, `shfmt --diff`, `fish_indent --check` — every lint/format check.
- `biome check`, `yamllint`, `actionlint`, `stylua --check` — every formatter check.
- `ruff check`, `ruff format --check` — every Python check.
- `pre-commit run`, `yarn lint`, `yarn lint:ec`, `yarn lint:sh` — every quality gate.
- `dfm <subcommand>` — dotfiles manager commands.
- `git log`, `git diff`, `git diff --stat`, `git show`, `git status -s`
  when output is more than 5 lines.
- `ls`, `tree`, `cat`, `head`, `tail`, `wc -l` — anything reading file content
  for analysis.
- `which <tool>`, `<tool> --version` when probing more than one tool at once
  — batch the probes.

Even when output is short, batch related commands together: one
`ctx_batch_execute` call with five commands costs less than five `Bash`
calls.

## When Bash is acceptable

Only these narrow cases:

1. **Side-effect commands that produce no output you need to read:**
    `git add <file>`, `git commit -m '...'`, `git mv`, `git rm`,
    `git checkout <branch>`, `git push`, `mkdir -p <dir>`, `chmod`, `chown`.
    The exit code is the signal; the stdout is irrelevant.
2. **In-place formatters with no output to capture:**
    `fish_indent --write <file>`, `shfmt -w <file>`.
3. **Package installations that must stream output interactively:**
    `yarn install`, `yarn add <pkg>`, `brew install <pkg>`.
4. **One-line commands the user explicitly asks for** during a
    conversation (e.g., "run `yarn build`").

If you find yourself piping through `head`, `tail`, or `grep` to truncate
output, you should be using `ctx_batch_execute` instead. The truncation
is a tell that the raw output is bigger than you want in chat context.

## Forbidden patterns

- `Bash` with `rg -n ... | head -20` — use `ctx_batch_execute` with a
  focused `queries:` array instead.
- Chaining many small `ctx_execute` calls — one `ctx_batch_execute` with
  multiple `commands` and `queries` is the right shape.
- `ctx_execute` / `ctx_execute_file` to write files — use `Write` / `Edit`.
- `WebFetch` for documentation — use `ctx_fetch_and_index`.

## Practical patterns

Investigation pass — one `ctx_batch_execute`, many queries:

```yaml
commands:
  - label: "shellcheck on changed scripts"
    command: "shellcheck local/bin/dfm local/bin/msgr"
  - label: "shfmt diff"
    command: "shfmt --diff local/bin/dfm"
  - label: "yamllint on install config"
    command: "yamllint install.conf.yaml"
queries:
  - "shellcheck errors"
  - "shfmt formatting differences"
  - "yamllint violations"
```

Lint pass — batch the full quality gate:

```yaml
commands:
  - label: "yarn lint"
    command: "yarn lint"
queries:
  - "lint errors"
  - "editorconfig violations"
```

Search pass — rg with follow-up:

```yaml
commands:
  - label: "functions referencing theme apply"
    command: "rg -n 'theme apply' config/fish/"
  - label: "handlers list"
    command: "ls config/theme/handlers.d/"
queries:
  - "theme apply callers"
  - "handler names"
```
