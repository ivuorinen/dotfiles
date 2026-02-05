#!/usr/bin/env bash
set -euo pipefail
# @description Install PHP Package Manager Composer
#
# shellcheck source="shared.sh"
source "$DOTFILES/config/shared.sh"

if ! command -v php &> /dev/null; then
  msg_err "PHP Not Available, cannot install composer"
  exit 0
fi

EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
  echo >&2 'ERROR: Invalid installer checksum'
  rm composer-setup.php
  exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
if [ $RESULT -eq 0 ]; then
  mv composer.phar ~/.local/bin/composer
fi
exit $RESULT
