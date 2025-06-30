# Guidelines for AI contributors

These instructions help language models work with this repository.

## Setup

1. Run `yarn install` to get linting tools and the Bats test framework.

## Formatting

- Format code and docs with Prettier and markdownlint:

```bash
yarn fix:prettier
yarn fix:markdown
```

- Shell scripts should pass `shellcheck`.

## Testing

- When code changes, run `yarn test` to execute Bats tests.
- If only comments or documentation change, tests may be skipped.

## Commits and PRs

- Use Semantic Commit messages: `type(scope): summary`.
- Keep PR titles in the same format.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
