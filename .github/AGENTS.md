# Guidelines for AI contributors

These instructions help language models work with this repository.

## Setup

1. Run `npm install` to get linting tools.
2. Ensure `bats` is installed if tests will run. Install with
   `sudo apt-get install bats` or `brew install bats-core`.
   GitHub Actions installs Bats automatically for CI runs.

## Formatting

- Format code and docs with Prettier and markdownlint:

```bash
npm run fix:prettier
npm run fix:markdown
```

- Shell scripts should pass `shellcheck`.

## Testing

- When code changes, run `./test-all.sh` to execute Bats tests.
- If only comments or documentation change, tests may be skipped.

## Commits and PRs

- Use Semantic Commit messages: `type(scope): summary`.
- Keep PR titles in the same format.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
