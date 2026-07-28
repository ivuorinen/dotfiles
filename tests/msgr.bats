#!/usr/bin/env bats
#
# msgr is sourced or invoked by 29 files in this repo; a regression in its
# verb dispatch or output shape breaks every script that reports progress.
# These tests pin the dispatch table and the visible markers.
#
# Stream assertions deliberately capture both stdout and stderr: `msgr err`
# currently writes to stdout, which is filed as a finding
# (docs/audit/findings — "msgr err and msgr warn write to stdout"). Pinning
# the stream here would bake that in before the decision is made.

setup()
{
  MSGR="$BATS_TEST_DIRNAME/../local/bin/msgr"
}

@test "msgr ok: prints the message with the success marker" {
  run "$MSGR" ok "hello world"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello world"* ]]
  [[ "$output" == *"✔"* ]]
}

@test "msgr err: prints the message with the error marker" {
  run "$MSGR" err "something failed"
  [ "$status" -eq 0 ]
  [[ "$output" == *"something failed"* ]]
  [[ "$output" == *"⛌"* ]]
}

@test "msgr warn: prints the message with the warning marker" {
  run "$MSGR" warn "careful"
  [ "$status" -eq 0 ]
  [[ "$output" == *"careful"* ]]
  [[ "$output" == *"⁕"* ]]
}

@test "msgr yay: prints the celebration marker" {
  run "$MSGR" yay "shipped"
  [ "$status" -eq 0 ]
  [[ "$output" == *"shipped"* ]]
  [[ "$output" == *"🎉"* ]]
}

@test "msgr nested: indents the message" {
  run "$MSGR" nested "child"
  [ "$status" -eq 0 ]
  [[ "$output" == "    "* ]]
  [[ "$output" == *"child"* ]]
}

@test "msgr run_done: renders both the message and the second parameter" {
  run "$MSGR" run_done "task" "detail"
  [ "$status" -eq 0 ]
  [[ "$output" == *"task"* ]]
  [[ "$output" == *"detail"* ]]
}

@test "msgr done: appends the completion checkmark" {
  # "done" quoted throughout: it is a msgr verb, not the shell keyword.
  run "$MSGR" "done" "finished"
  [ "$status" -eq 0 ]
  [[ "$output" == *"finished"* ]]
  [[ "$output" == *"✔"* ]]
}

@test "msgr: unknown verb falls back to usage and exits 0" {
  run "$MSGR" definitely-not-a-verb "x"
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage: msgr"* ]]
}

@test "msgr: no arguments prints usage without erroring" {
  run "$MSGR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage: msgr"* ]]
}

@test "msgr: every verb in the dispatch table is reachable" {
  # Guards against a verb being added to the #USAGE spec but not to the
  # case statement, which would silently print usage instead.
  for verb in msg "done" done_suffix err nested nested_done ok prompt \
    prompt_done run run_done warn yay yay_done; do
    run "$MSGR" "$verb" "probe-$verb"
    [ "$status" -eq 0 ]
    [[ "$output" != *"usage: msgr"* ]] || {
      echo "verb '$verb' fell through to usage"
      return 1
    }
  done
}
