---
description: "Conventional Commits format for all commit messages in this repo."
alwaysApply: true
---

# Commit messages

Use Conventional Commits: `type(scope): summary`.

Allowed types are the commitlint defaults: `feat`, `fix`, `chore`,
`docs`, `refactor`, `test`, `style`, `perf`, `ci`, `build`, `revert`.
Scope is the affected area in lowercase (e.g. `tmux`, `nvim`,
`starship`, `dotfiles`). Summary is imperative mood, no trailing
period.

Header length: target 72 characters (matches `git log --oneline`
width). The actual hard limit from `@ivuorinen/commitlint-config`
(which extends `@commitlint/config-conventional`) is 100 characters
— commitlint rejects only above 100. Keep the 72-char target as a
discipline; anything 73–100 passes the hook but reads poorly in
short-log views.

Body: separated from the header by a single blank line
(`body-leading-blank: [2, always]` is the only override added by
`@ivuorinen/commitlint-config` on top of conventional defaults).

Examples:

- `fix(tmux): correct prefix binding`
- `feat(starship): add battery module`
- `chore(deps): bump grype 0.111.1 → 0.112.0`

Enforced by commitlint extending `@ivuorinen/commitlint-config` via a
pre-commit hook. Getting the format right on the first attempt avoids
a hook-failure round-trip.
