# Scripts

All scripts have been normalized to same code standard using `shfmt`.
Some problematic code has been fixed per `shellcheck` suggestions.

## Homegrown

- dfm
- git-dirty (based on git-extra-tools)
- git-fsck-dirs
- git-update-dirs
- php-switcher
- x-backup-folder
- x-backup-mysql-with-prefix
- x-check-git-attributes
- x-clean-vendordirs
- x-env-list
- x-open-ports

## Sourced

| Script                  | Source            |
| ----------------------- | ----------------- |
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
  - [skx/sysadmin-utils][skx]
    - Tools for Linux/Unix sysadmins.
    - [Licence][skx-license]
  - [onnimonni][onnimonni]
    - [validate_sha256sum][onnimonni-gist]
  - [mvdan/dotfiles][mvdan]

[onnimonni]: https://github.com/onnimonni
[onnimonni-gist]: https://gist.github.com/onnimonni/b49779ebc96216771a6be3de46449fa1
[skx]: https://github.com/skx/sysadmin-util
[skx-license]: https://github.com/skx/sysadmin-util/blob/master/LICENSE
[mvdan]: https://github.com/mvdan/dotfiles
