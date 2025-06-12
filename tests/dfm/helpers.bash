run_with_dfm() {
  local cmd="$*"
  run env \
    PROJECT_ROOT="$PROJECT_ROOT" \
    DFM_CMD_DIR="$PROJECT_ROOT/local/dfm/cmd" \
    DFM_LIB_DIR="$PROJECT_ROOT/local/dfm/lib" \
    DOTFILES="${DOTFILES:-$PROJECT_ROOT}" \
    NO_AUTOMATION="${NO_AUTOMATION:-1}" \
    TEMP_DIR="$TEMP_DIR" \
    bash -c 'set -e
      cmd="$1"
      source "$PROJECT_ROOT/local/dfm/lib/common.sh"
      source "$PROJECT_ROOT/local/dfm/lib/utils.sh"
      set +e
      eval "$cmd"' bash "$cmd"
}
