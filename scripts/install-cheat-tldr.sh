#!/usr/bin/env bash
# shellcheck disable=SC2231,SC2034,SC2181,SC2068
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

TLDR_REQUIRED_TOOLS=(basename git mkdir cheat ls grep head awk cp echo rm)
for t in ${TLDR_REQUIRED_TOOLS[@]}; do
  ! have "$t" && echo "(!) $t is missing, can't continue..." && exit 1
done

TLDR_GIT="https://github.com/tldr-pages/tldr.git"
TLDR_SOURCE="source: $TLDR_GIT"
TLDR_SYNTAX="syntax: markdown"
TLDR_TAGS="tags: [bash]"

TLDR_TEMP_PREFIX=$(basename "$0")
TLDR_TEMP_DIR="/tmp/cheat-tldr-$(rnd)"

# If there's no .git, clone the folder
if [ ! -d "$TLDR_TEMP_DIR/.git" ]; then
  git clone "$TLDR_GIT" "$TLDR_TEMP_DIR"
fi

# Fetch the destination directory from cheat defined directories.
TLDR_CHEAT_DEST="$(cheat -d | grep tldr | head -1 | awk '{print $2}')"

[ "$TLDR_CHEAT_DEST" = "" ] && msg_err "cheat doesn't know about the destination" && exit 1

if [ ! -d "$TLDR_CHEAT_DEST" ]; then
  mkdir -p "$TLDR_CHEAT_DEST"
fi

for d in "$TLDR_TEMP_DIR"/pages/*; do
  DIRNAME=$(basename "$d")
  # echo "-> $DIRNAME ($d)"

  case "$DIRNAME" in
    *common)
      SECTION_DIR="${TLDR_CHEAT_DEST}"
      TLDR_TAGS="tags: [common]"
      ;;
    *)
      SECTION_DIR="${TLDR_CHEAT_DEST}/$DIRNAME"
      TLDR_TAGS="tags: [$DIRNAME]"
      ;;
  esac

  if [ ! -d "$SECTION_DIR" ]; then
    mkdir -p "$SECTION_DIR"
  fi

  for FILE in $d/*.md; do
    BASENAME=$(basename "$FILE" .md)
    FILENAME="${BASENAME%%.*}"
    # echo "-> $FILE = $FILENAME"
    TLDR_FILE="$SECTION_DIR/${FILENAME}"
    # echo "-> dest: $TLDR_FILE"

    if [ ! -f "$TLDR_FILE" ]; then
      cp "$FILE" "$TLDR_FILE"
    fi

    if [ -f "$TLDR_FILE" ] && [ '---' != "$(head -1 < "$TLDR_FILE")" ]; then
      echo -e "---\n$TLDR_SYNTAX\n$TLDR_TAGS\n$TLDR_SOURCE\n---\n$(cat "$TLDR_FILE")" > "$TLDR_FILE"
    fi

  done
done

# Cleanup
if [ -d "$TLDR_TEMP_DIR" ]; then
  rm -rf "$TLDR_TEMP_DIR"
fi
