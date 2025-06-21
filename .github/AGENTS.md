# Guidelines for AI contributors

These instructions help language models work with this repository.

## Setup

1. Run `npm install` to get linting tools.
2. Install `bats` or make sure Docker is available. `test-all.sh` uses Docker
   automatically when `bats` is missing.

## Formatting

- Format code and docs with Prettier and markdownlint:

```bash
npm run fix:prettier
npm run fix:markdown
```

- Shell scripts should pass `shellcheck`.

## Testing

- When code changes, run `./test-all.sh` to execute Bats tests. The script
  falls back to a Docker image if the `bats` binary is not available.
- If only comments or documentation change, tests may be skipped.

## Commits and PRs

- Use Semantic Commit messages: `type(scope): summary`.
- Keep PR titles in the same format.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
