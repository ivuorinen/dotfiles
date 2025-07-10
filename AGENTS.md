# Project guidelines

This repository contains configuration files and helper scripts for managing a development environment. Dotbot drives the installation and host specific folders under `hosts/` include extra configs.

## Keeping the repository up to date

1. Update submodules with `git submodule update --remote --merge`.
2. Pull the latest changes and run `./install`.
3. Run `yarn install` whenever `package.json` changes.

## Linting and tests

- Format files with:

  ```bash
  yarn fix:prettier
  yarn fix:markdown
  ```

- Shell scripts must pass `shellcheck`. Run:

  ```bash
  find . -path ./node_modules -prune -o -name '*.sh' -print0 | xargs -0 shellcheck
  ```

- Execute tests with `yarn test`.

## Debugging lint issues

- `yarn lint:prettier` and `yarn lint:markdown` show formatting errors.
- Ensure shell scripts have a shebang or `# shellcheck shell=bash` directive.
- Consult `.shellcheckrc` for project specific checks.

Scripts rely on helpers in `config/shared.sh` so they run under Bash, Zsh and Fish by default.
