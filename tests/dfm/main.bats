load "$BATS_TEST_DIRNAME/helpers.bash"

setup() {
  PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
  TEMP_DIR="$(mktemp -d)"
  export TEMP_DIR
}

teardown() {
  rm -rf "$TEMP_DIR"
}

@test "list_available_commands shows commands" {
  run_with_dfm main::list_available_commands
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Available commands"
  echo "$output" | grep -q "install"
}

@test "interactive confirm returns 0 on yes" {
  run_with_dfm "utils::interactive::confirm \"Proceed?\" <<< \"y\"; echo \$?"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "0" ]
}

@test "interactive confirm returns 1 on no" {
  run_with_dfm "utils::interactive::confirm \"Proceed?\" <<< \"n\"; echo \$?"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "1" ]
}

@test "execute_command runs function" {
  run_with_dfm "main::execute_command install fonts"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Installing fonts"
}

@test "execute_command fails on missing function" {
  run_with_dfm "main::execute_command install nofunc >/dev/null 2>&1"
  [ "$status" -eq 1 ]
}

@test "get_function_description returns description" {
  run_with_dfm "main::get_function_description $PROJECT_ROOT/local/dfm/cmd/install.sh fonts"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Install all configured fonts"
}
