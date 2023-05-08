#!/usr/bin/env bash
# shellcheck disable=SC2231,SC2034,SC2181,SC2068
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

PBB_REQUIRED_TOOLS=(basename git mkdir cheat ls grep head awk cp echo rm)
for t in ${PBB_REQUIRED_TOOLS[@]}; do
  ! have "$t" && echo "(!) $t is missing, can't continue..." && exit 1
done

PBB_GIT="https://github.com/dylanaraps/pure-bash-bible.git"
PBB_SOURCE="source: $PBB_GIT"
PBB_SYNTAX="syntax: bash"
PBB_TAGS="tags: [bash]"

PBB_TEMP_PREFIX=$(basename "$0")
PBB_TEMP_DIR="/tmp/pbb-$(rnd)"

# If there's no .git, clone the folder
if [ ! -d "$PBB_TEMP_DIR/.git" ]; then
  msg_run "Starting to clone $PBB_GIT"
  git clone --depth 1 --single-branch -q "$PBB_GIT" "$PBB_TEMP_DIR" \
    && msg_yay "Cloned $PBB_GIT"
fi

PBB_CHAPTERS=$(ls -1v "$PBB_TEMP_DIR"/manuscript/chapter*)
CHEAT_DEST="$(cheat -d | grep pure-bash-bible | head -1 | awk '{print $2}')"

if [ ! -d "$CHEAT_DEST" ]; then
  mkdir -p "$CHEAT_DEST"
fi

for f in ${PBB_CHAPTERS[@]}; do
  # get all headers, take the first one, strip the # and return the first word in lowercase
  HEADER=$(grep -e '^[#] ' "$f" | head -1 | awk '{print tolower($2)}')
  CHEAT_FILE="$CHEAT_DEST/${HEADER}"

  if [ ! -f "$CHEAT_FILE" ]; then
    cp "$f" "$CHEAT_FILE" && msg_run "$CHEAT_FILE"
  fi

  LC_ALL=C perl -pi.bak -e 's/\<\!-- CHAPTER END --\>//' "$CHEAT_FILE"
  rm "$CHEAT_FILE.bak"

  # add tags if the file doesn't have them
  if [ '---' != "$(head -1 < "$CHEAT_FILE")" ]; then
    T="$PBB_SYNTAX\n$PBB_TAGS\n$PBB_SOURCE\n"
    echo -e "---\n$T---\n$(cat "$CHEAT_FILE")" > "$CHEAT_FILE"
  fi
done

# Cleanup
if [ -d "$PBB_TEMP_DIR" ]; then
  rm -rf "$PBB_TEMP_DIR"
fi
