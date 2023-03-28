#!/usr/bin/env bash

DIRECTORY=$1
FILENAME=$2

if [ -z "${DIRECTORY}" ]; then
  echo "DIRECTORY (first argument) is missing"
  echo "Usage: $0 folder_to_backup"
  exit
fi

if [ -z "${FILENAME}" ]; then
  FILENAME=$DIRECTORY
fi

FILENAME=${FILENAME} \
  | tr '/' _ \
  | iconv -t ascii//TRANSLIT \
  | sed -r s/[^a-zA-Z0-9]+/_/g \
  | sed -r s/^_+\|-+$//g

TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
FILENAME_TIMESTAMP="${FILENAME}_${TIMESTAMP}"

tar cvzf "${FILENAME_TIMESTAMP}.tar.gz" "${DIRECTORY}/"
