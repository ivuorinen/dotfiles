#!/usr/bin/env bats
#
# Coverage for scripts/check-host-leak.sh, the pre-commit gate for
# .claude/rules/host-specific-config.md (agent-loopholes-2f346170). Each test
# builds a throwaway repo so the staged diff is fully controlled.

bats_require_minimum_version 1.5.0

setup()
{
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false
  SCRIPT="${BATS_TEST_DIRNAME}/../scripts/check-host-leak.sh"
  cd "$BATS_TEST_TMPDIR" || return 1
  git init -q repo && cd repo || return 1
  mkdir -p hosts/tunkki hosts/s config/app
  printf 'alias .p="cd ~/Code/old"\n' > config/app/rc
  git add -A && git -c user.name=t -c user.email=t@t commit -qm init
}

@test "check-host-leak: an added host name is rejected" {
  printf 'Host tunkki\n' >> config/app/rc
  git add config/app/rc
  run -1 bash "$SCRIPT" config/app/rc
  [[ "$output" == *"tunkki"* ]]
}

@test "check-host-leak: an added ~/Code path is rejected" {
  printf 'cd ~/Code/myorg/x\n' >> config/app/rc
  git add config/app/rc
  run -1 bash "$SCRIPT" config/app/rc
}

@test "check-host-leak: pre-existing references and short host names pass" {
  printf 'export s=1\n' >> config/app/rc
  git add config/app/rc
  run -0 bash "$SCRIPT" config/app/rc
}
