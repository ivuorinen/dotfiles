setup() {
  PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
}

@test "list_available_commands shows commands" {
  run bash -c "export DFM_CMD_DIR=$PROJECT_ROOT/local/dfm/cmd; export DFM_LIB_DIR=$PROJECT_ROOT/local/dfm/lib; export TEMP_DIR=\$(mktemp -d); source $PROJECT_ROOT/local/dfm/lib/common.sh; source $PROJECT_ROOT/local/dfm/lib/utils.sh; set +e; main::list_available_commands"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Available commands"
  echo "$output" | grep -q "install"
}

@test "interactive confirm returns 0 on yes" {
  run bash -c "source $PROJECT_ROOT/local/dfm/lib/utils.sh; set +e; utils::interactive::confirm \"Proceed?\" <<< \"y\"; echo \$?"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "0" ]
}

@test "interactive confirm returns 1 on no" {
  run bash -c "source $PROJECT_ROOT/local/dfm/lib/utils.sh; set +e; utils::interactive::confirm \"Proceed?\" <<< \"n\"; echo \$?"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

@test "execute_command runs function" {
  run bash -c "export DFM_CMD_DIR=$PROJECT_ROOT/local/dfm/cmd; export DFM_LIB_DIR=$PROJECT_ROOT/local/dfm/lib; export TEMP_DIR=\$(mktemp -d); source $PROJECT_ROOT/local/dfm/lib/common.sh; source $PROJECT_ROOT/local/dfm/lib/utils.sh; set +e; main::execute_command install fonts"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Installing fonts"
}

@test "execute_command fails on missing function" {
  run bash -c "export DFM_CMD_DIR=$PROJECT_ROOT/local/dfm/cmd; export DFM_LIB_DIR=$PROJECT_ROOT/local/dfm/lib; export TEMP_DIR=\$(mktemp -d); source $PROJECT_ROOT/local/dfm/lib/common.sh; source $PROJECT_ROOT/local/dfm/lib/utils.sh; set +e; main::execute_command install nofunc >/dev/null 2>&1; echo \$?"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}
