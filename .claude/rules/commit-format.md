# Commit messages

Use Conventional Commits: `type(scope): summary`.

Allowed types are the commitlint defaults: `feat`, `fix`, `chore`,
`docs`, `refactor`, `test`, `style`, `perf`, `ci`, `build`, `revert`.
Scope is the affected area in lowercase (e.g. `tmux`, `nvim`,
`starship`, `dotfiles`). Summary is imperative mood, under 72
characters, no trailing period.

Examples:

- `fix(tmux): correct prefix binding`
- `feat(starship): add battery module`
- `chore(deps): bump grype 0.111.1 → 0.112.0`

Enforced by commitlint extending `@ivuorinen/commitlint-config` via a
pre-commit hook. Getting the format right on the first attempt avoids
a hook-failure round-trip.
