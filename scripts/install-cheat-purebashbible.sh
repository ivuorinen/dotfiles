#!/usr/bin/env bash
# @description  Update pure-bash-bible cheatsheets
# shellcheck disable=SC2231,SC2034,SC2181,SC2068
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"

PBB_REQUIRED_TOOLS=(git cheat)
PBB_GIT="https://github.com/dylanaraps/pure-bash-bible.git"
PBB_SOURCE="source: $PBB_GIT"
PBB_SYNTAX="syntax: bash"
PBB_TAGS="tags: [bash]"
PBB_TEMP_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cheat/pbb"

check_required_tools()
{
  for t in "${PBB_REQUIRED_TOOLS[@]}"; do
    if ! x-have "$t"; then
      echo "(!) $t is missing, can't continue..."
      exit 1
    fi
  done
}

clone_or_update_repo()
{
  if [ ! -d "$PBB_TEMP_DIR/.git" ]; then
    msg_run "Starting to clone $PBB_GIT"
    git clone --depth 1 --single-branch -q "$PBB_GIT" "$PBB_TEMP_DIR" \
      && msg_yay "Cloned $PBB_GIT"
  else
    msg_run "Starting to update $PBB_GIT"
    git -C "$PBB_TEMP_DIR" reset --hard origin/master
    git -C "$PBB_TEMP_DIR" pull -q \
      && msg_yay "Updated $PBB_GIT"
  fi
}

prepare_cheat_dest()
{
  local cheat_dest
  cheat_dest="$(cheat -d | grep pure-bash-bible | head -1 | awk '{print $2}')"

  if [ ! -d "$cheat_dest" ]; then
    mkdir -p "$cheat_dest"
  fi

  echo "$cheat_dest"
}

process_chapters()
{
  local cheat_dest
  cheat_dest=$(prepare_cheat_dest)

  mapfile -t PBB_CHAPTERS < <(ls -1v "$PBB_TEMP_DIR"/manuscript/chapter*)

  for f in "${PBB_CHAPTERS[@]}"; do
    local header cheat_file
    header=$(grep -e '^[#] ' "$f" | head -1 | awk '{print tolower($2)}')
    cheat_file="$cheat_dest/$header"

    if ! replacable "$f" "$cheat_file"; then
      cp "$f" "$cheat_file" && msg_run "Updated: $cheat_file"
    fi

    LC_ALL=C perl -pi.bak -e 's/\<\!-- CHAPTER END --\>//' "$cheat_file"
    rm "$cheat_file.bak"

    if [ '---' != "$(head -1 < "$cheat_file")" ]; then
      local metadata
      metadata="$PBB_SYNTAX\n$PBB_TAGS\n$PBB_SOURCE\n"
      echo -e "---\n$metadata---\n$(cat "$cheat_file")" > "$cheat_file"
    fi
  done
}

main()
{
  check_required_tools
  clone_or_update_repo
  process_chapters
}

main "$@"
