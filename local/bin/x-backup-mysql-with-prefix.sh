#!/usr/bin/env bash
#
# Backup local MySQL Database tables with certain prefix.
# Ismo Vuorinen <https://github.com/ivuorinen> 2018
#

SCRIPT=$(basename "$0")
PREFIX=$1
FILENAME=$2
DATABASE=$3

: "${VERBOSE:=0}"
: "${DEFAULT_DATABASE:="wordpress"}"

if [ -z "${PREFIX}" ]; then
  echo "(!) TABLE_PREFIX (first argument) is missing"
  echo "(>) Usage: $SCRIPT <TABLE_PREFIX> <FILENAME_PREFIX> [<DATABASE>]"
  echo " * <TABLE_PREFIX>    = database table prefix, e.g. 'wp_'"
  echo " * <FILENAME_PREFIX> = FILENAME prefix, defaults to table prefix. Use something descriptive e.g. 'wordpress'"
  echo " * <DATABASE>        = [optional] Third argument DATABASE, defaults to '$DEFAULT_DATABASE'."
  exit 0
fi

if [ -z "${FILENAME}" ]; then
  # echo "FILENAME (second argument) is missing, using PREFIX ($PREFIX)"
  FILENAME=$PREFIX
fi

if [ -z "${DATABASE}" ]; then
  # echo "DATABASE (third argument) is missing, using default ($DEFAULT_DATABASE)"
  DATABASE=$DEFAULT_DATABASE
fi

TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
FILENAME_TIMESTAMP="${DATABASE}_${FILENAME}_${TIMESTAMP}.sql"

mysqldump \
  "${DATABASE}" \
  "$(
    echo "show tables like '${PREFIX}%';" \
      | mysql "${DATABASE}" \
      | sed '/Tables_in/d'
  )" > "${FILENAME_TIMESTAMP}"
