# Project guidelines

This repository contains configuration files and helper scripts for managing
a development environment.
Dotbot drives installation, and host-specific folders under `hosts/` contain extra configs.

## Setup

1. Run `yarn install` to fetch linting tools and the Bats test framework.
2. Re-run `yarn install` whenever `package.json` changes.
3. Yarn is the package manager of choice; avoid `npm` commands.

## Keeping the repository up to date

1. Update submodules with `git submodule update --remote --merge`.
2. Pull the latest changes and run `./install`.

## Linting and tests

- Format files with:

  ```bash
  yarn fix:prettier
  yarn fix:markdown
  ```

- Shell scripts must pass `shellcheck`.

  ```bash
  find . -path ./node_modules -prune -o -name '*.sh' -print0 | xargs -0 shellcheck
  ```

- Ensure `.editorconfig` rules pass:

  ```bash
  tools/install-ec.sh
  ec
  ```

- Execute tests with `yarn test` when code changes.

## Debugging lint issues

- `yarn lint:prettier` and `yarn lint:markdown` show formatting errors.
- Ensure shell scripts have a shebang or `# shellcheck shell=bash` directive.
- Consult `.shellcheckrc` for project specific checks.

Scripts rely on helpers in `config/shared.sh` so they run under Bash, Zsh and Fish by default.

## Commits and PRs

- Use Semantic Commit messages: `type(scope): summary`.
- Keep PR titles in the same format.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
