# Contributing

This is a personal dotfiles repository with a single maintainer. Outside pull
requests are welcome; this page links to where each requirement is defined
rather than repeating it.

## Setup

Linting and testing run from the clone; nothing needs to be installed into
your home directory.

```bash
git clone https://github.com/ivuorinen/dotfiles.git
cd dotfiles
mise install       # lint/test toolchain, bats and prek, from .mise.toml
yarn install       # Yarn v4; never npm (.claude/rules/no-npm.md)
prek install       # installs the pre-commit and commit-msg hooks
```

Do not run `./install` or `./install --links` to contribute. They symlink these
dotfiles into `~` and `~/.config` with forced links, replacing your own shell rc
files and app configs. They are meant for the maintainer's machines.

## Checks

Run these before opening a pull request. The full command catalogue, including
each `lint:*` step, is [docs/commands.md](../docs/commands.md).

```bash
yarn fix                 # autofixers first
yarn lint                # every lint step; must pass with no warnings
yarn test                # full test run
bats tests/<file>.bats   # one bats file
```

## Commit convention

Conventional Commits, enforced by commitlint on the commit-msg hook. Format,
allowed types and length limits: [.claude/rules/commit-format.md](../.claude/rules/commit-format.md).

## Pull requests

- The PR title must also be a Conventional Commit; the
  [semantic-pr](workflows/semantic-pr.yml) workflow checks it.
- Reviewers are assigned from [CODEOWNERS](CODEOWNERS).
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Report vulnerabilities as described in [SECURITY.md](SECURITY.md), not in a
public issue.

## License

The repository's own work is under the MIT [LICENSE](../LICENSE). Third-party
portions keep their own licenses; [NOTICE](../NOTICE) lists them.
