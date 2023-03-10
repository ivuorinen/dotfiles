# Scripts

All scripts have been normalized to same code standard using `shfmt`.
Some problematic code has been fixed per `shellcheck` suggestions.

## Homegrown

- dfm
- x-backup-mysql-with-prefix
- x-check-git-attributes
- x-open-ports

## Sourced

| Script                  | Source            |
|-------------------------|-------------------|
| `x-dupes`               | skx/sysadmin-util |
| `x-foreach`             | mvdan/dotfiles    |
| `x-multi-ping`          | skx/sysadmin-util |
| `x-ssl-expiry-date`     | skx/sysadmin-util |
| `x-until-error`         | skx/sysadmin-util |
| `x-until-success`       | skx/sysadmin-util |
| `x-validate-sha256-sum` | onnimonni         |
| `x-when-down`           | skx/sysadmin-util |
| `x-when-up`             | skx/sysadmin-util |

- Sources:
  - [skx/sysadmin-utils](https://github.com/skx/sysadmin-util/)
    - Tools for Linux/Unix sysadmins.
    - [Licence](https://github.com/skx/sysadmin-util/blob/master/LICENSE)
  - [onnimonni](https://github.com/onnimonni)
    - [validate_sha256sum](https://gist.github.com/onnimonni/b49779ebc96216771a6be3de46449fa1)
  - [mvdan/dotfiles](https://github.com/mvdan/dotfiles)
