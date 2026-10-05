#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export TMPDIR_TEST
  export XDG_STATE_HOME="$TMPDIR_TEST"
  export THEME_HANDLERS_DIR="$TMPDIR_TEST/handlers.d"
  mkdir -p "$THEME_HANDLERS_DIR"
  WATCHER="$BATS_TEST_DIRNAME/../config/theme/watcher"

  # Curated PATH sandbox for the linux-source tests below. $BIN holds
  # fake gsettings/busctl binaries that each test installs as needed;
  # $UTIL holds symlinks to the coreutils + bash + timeout the watcher
  # and _lib.sh actually rely on. With PATH=$BIN:$UTIL only, the
  # watcher's `command -v gsettings` / `command -v busctl` reflect
  # exactly what the test placed in $BIN — host-installed binaries on
  # /usr/bin become invisible.
  BIN="$TMPDIR_TEST/bin"
  UTIL="$TMPDIR_TEST/util"
  mkdir -p "$BIN" "$UTIL"
  for cmd in bash env mkdir dirname basename mktemp mv ln rm cat date tail wc kill sleep printf timeout gtimeout awk grep find pkill; do
    real="$(command -v "$cmd" 2> /dev/null || true)"
    [[ -n "$real" && -e "$real" ]] && ln -sf "$real" "$UTIL/$cmd" || true
  done
  ISO_PATH="$BIN:$UTIL"
  TIMEOUT_BIN=""
  [[ -x "$UTIL/timeout" ]] && TIMEOUT_BIN="$UTIL/timeout"
  [[ -z "$TIMEOUT_BIN" && -x "$UTIL/gtimeout" ]] && TIMEOUT_BIN="$UTIL/gtimeout"

  # Recorder handler — captures the mode the actor passed to handlers.
  # Shared by stub-source and linux-source tests; install once here so
  # the per-test setup stays focused on its specific scenario.
  cat > "$THEME_HANDLERS_DIR/recorder" << 'HND'
#!/usr/bin/env bash
echo "$1" >> "${TMPDIR_TEST}/recorded"
HND
  chmod +x "$THEME_HANDLERS_DIR/recorder"
}

teardown()
{
  if [[ -f "$TMPDIR_TEST/dotfiles-theme/daemon.pid" ]]; then
    pid=$(cat "$TMPDIR_TEST/dotfiles-theme/daemon.pid" 2> /dev/null)
    [[ -n "$pid" && "$pid" != "$$" ]] && kill "$pid" 2> /dev/null || true
  fi
  rm -rf "$TMPDIR_TEST"
}

# --- Helpers for the linux-source tests ---

# Install a fake `gsettings` in $BIN. $1 is the raw value `gsettings
# get` should print (single-quoted, e.g. "'prefer-dark'"). The fake
# `monitor` subcommand exits 0 with no output so the watcher's
# `monitor | while read` pipeline sees EOF immediately and exits.
fake_gsettings()
{
  local scheme="$1"
  cat > "$BIN/gsettings" << STUB
#!/usr/bin/env bash
printf 'gsettings %s\n' "\$*" >> "$BIN/calls"
case "\$1" in
  get) echo "${scheme}" ;;
  monitor) ;;
esac
STUB
  chmod +x "$BIN/gsettings"
}

# Install a fake `busctl`. $1 is the integer the synchronous
# Settings.Read should report inside the JSON variant (1=dark,
# 2=light, 0=no preference). The `monitor` subcommand exits 0 with
# no output, same trick as fake_gsettings.
fake_busctl()
{
  local n="$1"
  cat > "$BIN/busctl" << STUB
#!/usr/bin/env bash
printf 'busctl %s\n' "\$*" >> "$BIN/calls"
mode=
for a in "\$@"; do
  case "\$a" in
    call) mode=call ;;
    monitor) mode=monitor ;;
  esac
done
case "\$mode" in
  call) printf '{"type":"v","data":[{"type":"v","data":{"type":"u","data":%s}}]}\n' "${n}" ;;
  monitor) ;;
esac
STUB
  chmod +x "$BIN/busctl"
}

# The timeout is a hang guard only: every caller's fake monitor ends at
# once, so the watcher exits by itself and the test asserts that status.
# 3 s killed the seed apply (it now takes the apply lock) under the full
# suite's parallel load, turning the expected exit 1 into 143.
run_watcher_linux()
{
  local de="$1"
  PATH="$ISO_PATH" XDG_CURRENT_DESKTOP="$de" \
    "$TIMEOUT_BIN" 20 "$WATCHER" --source linux
}

# --- Existing tests ---

@test "watcher: --source stub reads modes from a file and applies each" {
  tmo="$(command -v timeout 2> /dev/null || command -v gtimeout 2> /dev/null || true)"
  [ -n "$tmo" ] || skip "no timeout(1) on PATH"
  printf 'dark\nlight\ndark\n' > "$TMPDIR_TEST/source-stub"
  run "$tmo" 3 "$WATCHER" --source stub --stub-input "$TMPDIR_TEST/source-stub"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$TMPDIR_TEST/recorded")" -ge 3 ]
}

# Send TERM to a background watcher (pid $1) once its pidfile exists and
# assert it exits 143 and removes the pidfile. The watcher and the
# watchdog run with fd 3 closed and their output on /dev/null: bats waits
# for every holder of its descriptors, so an orphaned `sleep` holding
# one would stall the test for the full watchdog window.
assert_term_exits_143()
{
  local pid="$1" pidfile="$TMPDIR_TEST/dotfiles-theme/daemon.pid" _
  for _ in $(seq 1 50); do
    [[ -s "$pidfile" ]] && break
    sleep 0.1
  done
  [ -s "$pidfile" ]
  # Watchdog: a watcher that ignores TERM would hang `wait`; KILL it
  # after 8 s so the test fails with 137 instead.
  (
    exec 3>&- > /dev/null 2>&1
    sleep 8
    kill -KILL "$pid" 2> /dev/null
  ) &
  local dog=$!
  kill -TERM "$pid"
  local rc=0
  wait "$pid" || rc=$?
  pkill -P "$dog" 2> /dev/null || true
  kill "$dog" 2> /dev/null || true
  [ "$rc" -eq 143 ]
  [ ! -e "$pidfile" ]
}

@test "watcher: TERM exits 143 and removes the pidfile" {
  # Before the fix the signal trap only removed the pidfile and the loop
  # kept running, leaving an unlocked daemon a second watcher could join.
  cat > "$BIN/defaults" << 'STUB'
#!/usr/bin/env bash
echo Dark
STUB
  chmod +x "$BIN/defaults"
  PATH="$ISO_PATH" "$WATCHER" --source macos 3>&- > /dev/null 2>&1 &
  assert_term_exits_143 "$!"
}

# Run a linux watcher on a fake gsettings monitor, TERM it, and assert
# the monitor dies with it. `exec sleep` makes the fake monitor itself the
# long-running process, so its pid is the one the exit cleanup has to kill.
assert_term_stops_monitor()
{
  cat > "$BIN/gsettings" << 'STUB'
#!/usr/bin/env bash
case "$1" in
  get) echo "'prefer-dark'" ;;
  monitor)
    echo $$ > "$TMPDIR_TEST/monitor.pid"
    exec sleep 30
    ;;
esac
STUB
  chmod +x "$BIN/gsettings"
  PATH="$ISO_PATH" XDG_CURRENT_DESKTOP=GNOME \
    "$WATCHER" --source linux 3>&- > /dev/null 2>&1 &
  local watcher=$! _
  for _ in $(seq 1 50); do
    [[ -s "$TMPDIR_TEST/monitor.pid" ]] && break
    sleep 0.1
  done
  [ -s "$TMPDIR_TEST/monitor.pid" ]
  monitor="$(cat "$TMPDIR_TEST/monitor.pid")"
  assert_term_exits_143 "$watcher"
  # An orphaned monitor would keep feeding apply beside the respawned
  # watcher.
  for _ in $(seq 1 20); do
    kill -0 "$monitor" 2> /dev/null || break
    sleep 0.1
  done
  if kill -0 "$monitor" 2> /dev/null; then
    kill "$monitor"
    false
  fi
}

@test "watcher linux: TERM exits 143 while the monitor pipeline runs" {
  # A foreground `monitor | while read` pipeline deferred the TERM trap
  # until the never-ending monitor exited.
  assert_term_stops_monitor
}

@test "watcher linux: TERM stops the monitor when pkill is not installed" {
  # The exit cleanup relied on pkill alone; without it the error was
  # silenced and the monitor kept feeding apply after the pidfile went.
  rm -f "$UTIL/pkill"
  assert_term_stops_monitor
}

@test "watcher: second invocation exits 1 when first holds the lock" {
  echo $$ > "$TMPDIR_TEST/dotfiles-theme/daemon.pid" 2> /dev/null || {
    mkdir -p "$TMPDIR_TEST/dotfiles-theme"
    echo $$ > "$TMPDIR_TEST/dotfiles-theme/daemon.pid"
  }
  run "$WATCHER" --source stub --stub-input /dev/null
  [ "$status" -eq 1 ]
}

# Regression: _acquire_lock must never hand the same lock to two processes.
#
# The stale-reclaim path used to unlink the dead pidfile and then ln its own,
# unguarded. Two racers that both saw the same dead pid could both return 0 —
# the second's `rm -f` deleted the first's *live* pidfile. Against that code
# this test reports 2 winners; against the break-lock version it reports 1.
#
# A dead pid is manufactured by starting a subshell and waiting for it to
# exit, so the pid is real, unambiguously gone, and not a guess.
@test "_acquire_lock: concurrent stale reclaim produces exactly one winner" {
  local libsh="${BATS_TEST_DIRNAME}/../config/theme/_lib.sh"
  local dir="$TMPDIR_TEST/lockrace"
  mkdir -p "$dir"
  local pidfile="$dir/daemon.pid"

  # A pid that is certainly dead: spawn, reap, reuse the number.
  sh -c 'exit 0' &
  local dead=$!
  wait "$dead" 2> /dev/null || true
  printf '%s\n' "$dead" > "$pidfile"

  # Race N acquirers. Each writes a line only if _acquire_lock returned 0.
  local n=8 i
  for ((i = 0; i < n; i++)); do
    (
      # shellcheck source=/dev/null
      . "$libsh"
      if _acquire_lock "$pidfile"; then
        printf 'won\n' >> "$dir/winners"
      fi
    ) &
  done
  wait

  local winners=0
  [ -f "$dir/winners" ] && winners="$(grep -c '^won$' "$dir/winners")"
  [ "$winners" -eq 1 ]

  # The survivor's pid must be the one actually recorded in the lock.
  [ -f "$pidfile" ]
  [ -s "$pidfile" ]
}

@test "_acquire_lock: a live holder is never displaced" {
  local libsh="${BATS_TEST_DIRNAME}/../config/theme/_lib.sh"
  local dir="$TMPDIR_TEST/lockLive"
  mkdir -p "$dir"
  local pidfile="$dir/daemon.pid"

  # $$ is this bats process — definitively alive for the whole test.
  printf '%s\n' "$$" > "$pidfile"

  run bash -c '. "$1"; _acquire_lock "$2"' _ "$libsh" "$pidfile"
  [ "$status" -eq 1 ]
  # The live holder's pid is still the recorded owner.
  [ "$(cat "$pidfile")" = "$$" ]
}

# --- Linux source-selection + initial-seed tests ---

@test "watcher linux: GNOME prefers gsettings; seed applies before monitor" {
  [ -n "$TIMEOUT_BIN" ] || skip "no timeout(1) on PATH"
  fake_gsettings "'prefer-dark'"
  fake_busctl 1 # would also map to dark, but must NOT be invoked

  run run_watcher_linux GNOME
  # The fake monitor ends at once: the watcher logs it and exits 1.
  [ "$status" -eq 1 ]
  grep -q 'ERROR watcher linux: gsettings monitor stream ended' \
    "$TMPDIR_TEST/dotfiles-theme/log"

  # gsettings was used for both seed get and monitor; busctl untouched.
  grep -q '^gsettings get org.gnome.desktop.interface color-scheme$' "$BIN/calls"
  grep -q '^gsettings monitor org.gnome.desktop.interface color-scheme$' "$BIN/calls"
  run grep -q '^busctl' "$BIN/calls"
  [ "$status" -ne 0 ]

  # Seed-before-monitor ordering proven by the calls log.
  first=$(awk 'NR==1' "$BIN/calls")
  second=$(awk 'NR==2' "$BIN/calls")
  [[ "$first" == "gsettings get"* ]]
  [[ "$second" == "gsettings monitor"* ]]

  # Seed applied 'dark' to handlers and the state file before the
  # monitor pipeline started — the recorder ran inside `apply` which
  # `seed_initial_state` calls synchronously.
  [ "$(cat "$TMPDIR_TEST/recorded")" = "dark" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "dark" ]
}

@test "watcher linux: COSMIC prefers busctl portal; data:2 -> light seed" {
  [ -n "$TIMEOUT_BIN" ] || skip "no timeout(1) on PATH"
  fake_gsettings "'prefer-dark'" # would map to dark; must NOT be invoked
  fake_busctl 2                  # data:2 = light

  run run_watcher_linux COSMIC
  [ "$status" -eq 1 ]
  grep -q 'ERROR watcher linux: busctl monitor stream ended' \
    "$TMPDIR_TEST/dotfiles-theme/log"

  # busctl was used (call for seed, monitor for events); gsettings untouched.
  grep -q '^busctl --user --json=short call ' "$BIN/calls"
  grep -q '^busctl --user --json=short monitor org.freedesktop.portal.Desktop$' "$BIN/calls"
  run grep -q '^gsettings' "$BIN/calls"
  [ "$status" -ne 0 ]

  first=$(awk 'NR==1' "$BIN/calls")
  second=$(awk 'NR==2' "$BIN/calls")
  [[ "$first" == "busctl "*" call "* ]]
  [[ "$second" == "busctl "*" monitor "* ]]

  [ "$(cat "$TMPDIR_TEST/recorded")" = "light" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "light" ]
}

@test "watcher linux: ubuntu:GNOME falls back to busctl when gsettings absent" {
  [ -n "$TIMEOUT_BIN" ] || skip "no timeout(1) on PATH"
  fake_busctl 1 # data:1 = dark

  # ubuntu:GNOME also matches `*GNOME*` — exercises the wildcard and the
  # have_gsettings=false branch of the selector.
  run run_watcher_linux ubuntu:GNOME
  [ "$status" -eq 1 ]

  run grep -q '^gsettings' "$BIN/calls"
  [ "$status" -ne 0 ]
  grep -q '^busctl ' "$BIN/calls"
  [ "$(cat "$TMPDIR_TEST/recorded")" = "dark" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "dark" ]
}

@test "watcher linux: COSMIC falls back to gsettings when busctl absent" {
  [ -n "$TIMEOUT_BIN" ] || skip "no timeout(1) on PATH"
  fake_gsettings "'prefer-light'"

  run run_watcher_linux COSMIC
  [ "$status" -eq 1 ]

  run grep -q '^busctl' "$BIN/calls"
  [ "$status" -ne 0 ]
  grep -q '^gsettings ' "$BIN/calls"
  [ "$(cat "$TMPDIR_TEST/recorded")" = "light" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "light" ]
}

@test "watcher linux: gsettings 'default' (no preference) seeds dark" {
  [ -n "$TIMEOUT_BIN" ] || skip "no timeout(1) on PATH"
  fake_gsettings "'default'"

  run run_watcher_linux GNOME
  [ "$status" -eq 1 ]

  grep -q '^gsettings ' "$BIN/calls"
  [ "$(cat "$TMPDIR_TEST/recorded")" = "dark" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "dark" ]
}

@test "watcher linux: busctl no-preference (data:0) seeds dark" {
  [ -n "$TIMEOUT_BIN" ] || skip "no timeout(1) on PATH"
  fake_busctl 0 # data:0 = no preference -> dark

  run run_watcher_linux COSMIC
  [ "$status" -eq 1 ]

  grep -q '^busctl --user --json=short call ' "$BIN/calls"
  [ "$(cat "$TMPDIR_TEST/recorded")" = "dark" ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "dark" ]
}

@test "watcher linux: neither gsettings nor busctl -> exit 0 with WARN" {
  [ -n "$TIMEOUT_BIN" ] || skip "no timeout(1) on PATH"

  run run_watcher_linux GNOME
  [ "$status" -eq 0 ]

  grep -q 'WARN watcher linux: neither gsettings nor busctl available' \
    "$TMPDIR_TEST/dotfiles-theme/log"
  [ ! -e "$BIN/calls" ]
  [ ! -e "$TMPDIR_TEST/recorded" ]
}
