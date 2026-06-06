#!/usr/bin/env bash
set -euo pipefail
# @description Install PHP Package Manager Composer
#USAGE about "Install PHP Package Manager Composer"
#
# shellcheck source="shared.sh"
source "$DOTFILES/config/shared.sh"

if ! command -v php &> /dev/null; then
  msgr warn "php not available, skipping composer install"
  exit 0
fi

# Run the installer in an ephemeral temp dir so partial state never leaks
# into the caller's cwd if php (or the network) fails mid-install.
tmpdir="$(mktemp -d)"
lib::register_cleanup "$tmpdir"
lib::trap_cleanup

cd "$tmpdir"

EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [[ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]]; then
  logger::error "Invalid installer checksum"
  exit "$LIB_E_EXECUTION_FAILED"
fi

php composer-setup.php --quiet

mkdir -p "$HOME/.local/bin"
mv composer.phar "$HOME/.local/bin/composer"
