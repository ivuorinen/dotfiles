# Alias Commands

This file lists all aliases defined in `config/alias`.

| Alias | Command |
| --- | --- |
| `....`        | `cd ../../..`                                                                                                 |
| `...`         | `cd ../..`                                                                                                    |
| `..`          | `cd ..`                                                                                                       |
| `.`           | `cd $HOME`                                                                                                    |
| `.b`          | `cd $XDG_BIN_HOME`                                                                                            |
| `.c`          | `cd $HOME/Code`                                                                                               |
| `.d`          | `cd $DOTFILES`                                                                                                |
| `.l`          | `cd $HOME/.local`                                                                                             |
| `.o`          | `cd $HOME/Code/ivuorinen/obsidian/`                                                                           |
| `art`         | `[ -f artisan ] && php artisan \|\| php vendor/bin/artisan`                                                   |
| `cd..`        | `cd ..`                                                                                                       |
| `cdgr`        | `cd "$(get_git_root)"`                                                                                        |
| `dn`          | `du -chd1`                                                                                                    |
| `flush`       | `dscacheutil -flushcache`                                                                                     |
| `grep`        | `grep --color`                                                                                                |
| `hide`        | `defaults write com.apple.finder AppleShowAllFiles -bool false; killall Finder`                               |
| `ips`         | `ifconfig -a \| grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\\                                   | [a-fA-F0-9:]\+\)' \| sed -e 's/inet6\* //' \| sort` |
| `irssi`       | `irssi --config=$XDG_CONFIG_HOME/irssi/config --home=$XDG_CONFIG_HOME/irssi`                                  |
| `isodate`     | `date +'%Y-%m-%d'`                                                                                            |
| `l`           | `ls -a`                                                                                                       |
| `ll`          | `ls -la`                                                                                                      |
| `localip`     | `ipconfig getifaddr en1`                                                                                      |
| `mirror_site` | `wget -m -k -K -E -e robots=off`                                                                              |
| `peek`        | `tee >(cat 1>&2)`                                                                                             |
| `pubkey`      | `more ~/.ssh/id_rsa.pub \| pbcopy \| echo '=> Public key copied to pasteboard.'`                              |
| `sail`        | `[ -f sail ] && bash sail \|\| bash vendor/bin/sail`                                                          |
| `show`        | `defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder`                                |
| `sl`          | `ls`                                                                                                          |
| `svn`         | `svn --config-dir $XDG_CONFIG_HOME/subversion`                                                                |
| `trivy_scan`  | `docker run -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy` |
| `updatedb`    | `sudo /usr/libexec/locate.updatedb`                                                                           |
| `vi`          | `nvim`                                                                                                        |
| `vim`         | `nvim`                                                                                                        |
| `watchx`      | `watch -dpbc`                                                                                                 |
| `wget`        | `wget --hsts-file=$XDG_DATA_HOME/wget-hsts`                                                                   |
| `x-datetime`  | `date +'%Y-%m-%d %H:%M:%S'`                                                                                   |
| `x-ip`        | `dig +short myip.opendns.com @resolver1.opendns.com`                                                          |
| `x-timestamp` | `date +'%s'`                                                                                                  |
| `xdg`         | `xdg-ninja --skip-ok --skip-unsupported`                                                                      |
| `zapall`      | `zapds && zappyc`                                                                                             |
| `zapds`       | `find . -name ".DS_Store" -print -delete`                                                                     |
| `zappyc`      | `find . -type f -name '*.pyc' -ls -delete`                                                                    |
| `zedit`       | `$EDITOR ~/.dotfiles`                                                                                         |

Total aliases: 43
Last updated: Fri 17 Jan 2025 13:06:59 EET
