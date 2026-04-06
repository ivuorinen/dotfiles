# x-help — Dotfiles Documentation Browser

**Date:** 2026-04-06
**Status:** Design approved

## Purpose

A universal help browser for the dotfiles ecosystem. Provides both an
interactive fzf-based browser and direct name-based lookup for all `.md`
documentation files across the repository.

## Files

| File                    | Purpose                      |
| ----------------------- | ---------------------------- |
| `local/bin/x-help`      | The script                   |
| `local/bin/x-help.md`   | Companion documentation      |

## Dependencies

- `fzf` — interactive selection (checked at startup)
- `msgr` — colored error/warning output (sourced)
- `find` — file discovery
- `cat` — display (user has this linked to `bat`)

## Configuration

```bash
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
```

## File Discovery

Single `find` call from `$DOTFILES` for all `*.md` files, with
exclusions:

```bash
find "$DOTFILES" -name '*.md' -type f \
  -not -path '*/tools/*' \
  -not -path '*/docs/plans/*' \
  -not -path '*/docs/superpowers/*' \
  -not -path '*/config/tmux/plugins/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*'
```

Results are stripped of the `$DOTFILES/` prefix to produce relative
paths (e.g., `local/bin/x-foreach.md`), piped through `sort -u` for
deterministic, deduplicated output.

## Modes of Operation

### Interactive mode (`x-help`)

1. Run file discovery
2. Pipe sorted relative paths into `fzf`
3. If fzf exits non-zero (ESC/Ctrl+C) or selection is empty → `exit 0`
4. `cat "$DOTFILES/$selected"`

### Direct mode (`x-help <name>`)

Argument is the bare name without `.md` extension.

1. Run file discovery
2. Filter for entries where basename matches `<name>.md` exactly
3. If exactly 1 match → `cat` it
4. If multiple matches → pipe them into `fzf` to disambiguate
5. If zero matches → `msgr err` and `exit 1`

## Error Handling

| Condition              | Behavior                                         |
| ---------------------- | ------------------------------------------------ |
| `fzf` not installed    | `msgr err` + exit 1                              |
| No `.md` files found   | `msgr warn` + exit 0                             |
| Direct mode, no match  | `msgr err "No documentation found for '<name>'"` + exit 1 |
| fzf cancel / empty     | Silent `exit 0` (via `\|\| exit 0`)              |
| `$DOTFILES` unset      | Defaults to `$HOME/.dotfiles`                    |

## Script Conventions

- `#!/usr/bin/env bash` with `set -euo pipefail`
- Sources `msgr` for colored output
- Function-based structure
- Follows shfmt settings from `.editorconfig` (2-space indent,
  `binary_next_line`, `switch_case_indent`, `space_redirects`,
  `function_next_line`)

## Companion Documentation (`x-help.md`)

```markdown
# x-help

Browse and display dotfiles documentation.

## Usage

x-help              # Interactive fzf browser
x-help <name>       # Show docs for <name> directly

## Examples

x-help x-foreach    # Show x-foreach documentation
x-help alias        # Show alias documentation
x-help              # Browse all docs with fzf
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
