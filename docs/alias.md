# Alias Commands

This file mirrors the aliases defined in `config/alias`. Keep it in
sync when adding or removing aliases there. Some entries (e.g. `afk`,
`emptytrash`) are guarded to macOS in the source.

| Alias          | Command                                                                                                |
|----------------|--------------------------------------------------------------------------------------------------------|
| `.`            | `cd $HOME`                                                                                             |
| `..`           | `cd ..`                                                                                                |
| `...`          | `cd ../..`                                                                                             |
| `....`         | `cd ../../..`                                                                                          |
| `.b`           | `cd $XDG_BIN_HOME`                                                                                     |
| `.c`           | `cd $HOME/Code`                                                                                        |
| `.d`           | `cd $DOTFILES`                                                                                         |
| `.l`           | `cd $HOME/.local`                                                                                      |
| `.o`           | `cd $HOME/Code/ivuorinen/obsidian/`                                                                    |
| `.p`           | `cd $HOME/Code/ivuorinen`                                                                              |
| `.s`           | `cd $HOME/Code/s`                                                                                      |
| `afk`          | `osascript -e 'tell application "System Events" to keystroke "q" using {command down,control down}'`   |
| `art`          | `[ -f artisan ] && php artisan \|\| php vendor/bin/artisan`                                            |
| `cat`          | `bat`                                                                                                  |
| `cd..`         | `cd ..`                                                                                                |
| `cdgr`         | `cd "$(get_git_root)"`                                                                                 |
| `code_scanner` | `docker run … registry.gitlab.com/gitlab-org/ci-cd/codequality:"${CODEQUALITY_VERSION:-latest}" /code` |
| `dn`           | `du -chd1`                                                                                             |
| `emptytrash`   | `sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl`     |
| `flush`        | `dscacheutil -flushcache`                                                                              |
| `flushdns`     | `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`                                        |
| `grep`         | `grep --color`                                                                                         |
| `hide`         | `defaults write com.apple.finder AppleShowAllFiles -bool false; killall Finder`                        |
| `ips`          | `ifconfig -a` piped through `grep`/`sed`/`sort` to list interface IPs                                  |
| `irssi`        | `irssi --config=$XDG_CONFIG_HOME/irssi/config --home=$XDG_CONFIG_HOME/irssi`                           |
| `isodate`      | `date +'%Y-%m-%d'`                                                                                     |
| `l`            | `ls -a`                                                                                                |
| `ll`           | `ls -la`                                                                                               |
| `localip`      | `ipconfig getifaddr en1`                                                                               |
| `ls`           | `eza -h -s=type --git --icons --group-directories-first`                                               |
| `lsa`          | `ls -lah`                                                                                              |
| `mirror_site`  | `wget -m -k -K -E -e robots=off`                                                                       |
| `p`            | `gopass`                                                                                               |
| `peek`         | `tee >(cat 1>&2)`                                                                                      |
| `pubkey`       | `more ~/.ssh/id_rsa.pub \| pbcopy \| echo '=> Public key copied to pasteboard.'`                       |
| `sail`         | `[ -f sail ] && bash sail \|\| bash vendor/bin/sail`                                                   |
| `show`         | `defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder`                         |
| `sl`           | `ls`                                                                                                   |
| `svn`          | `svn --config-dir $XDG_CONFIG_HOME/subversion`                                                         |
| `trivy_scan`   | `docker run … aquasec/trivy`                                                                           |
| `updatedb`     | `sudo /usr/libexec/locate.updatedb`                                                                    |
| `vi`           | `nvim`                                                                                                 |
| `vim`          | `nvim`                                                                                                 |
| `watchx`       | `watch -dpbc`                                                                                          |
| `wget`         | `wget --hsts-file=$XDG_DATA_HOME/wget-hsts`                                                            |
| `x-datetime`   | `date +'%Y-%m-%d %H:%M:%S'`                                                                            |
| `x-ip`         | `dig +short myip.opendns.com @resolver1.opendns.com`                                                   |
| `x-timestamp`  | `date +'%s'`                                                                                           |
| `xdg`          | `xdg-ninja --skip-ok --skip-unsupported`                                                               |
| `zapall`       | `zapds && zappyc`                                                                                      |
| `zapds`        | `find . -name ".DS_Store" -print -delete`                                                              |
| `zappyc`       | `find . -type f -name '*.pyc' -ls -delete`                                                             |
| `zedit`        | `$EDITOR ~/.dotfiles`                                                                                  |

Total aliases: 53
