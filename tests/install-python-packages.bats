#!/usr/bin/env bats

setup()
{
  export DOTFILES="$PWD"
  # Pre-set CURRENT_SHELL so config/shared.sh's x-path-prepend works
  # even in environments where `ps` is unavailable.
  export CURRENT_SHELL="bash"
  export XDG_DATA_HOME="$BATS_TMPDIR/share"
  export XDG_BIN_HOME="$BATS_TMPDIR/bin"
  export XDG_CONFIG_HOME="$BATS_TMPDIR/config"
  export XDG_CACHE_HOME="$BATS_TMPDIR/cache"
  export XDG_STATE_HOME="$BATS_TMPDIR/state"
  mkdir -p "$XDG_DATA_HOME" "$XDG_BIN_HOME"

  # Fake bin directory for mock commands
  export FAKE_BIN="$BATS_TMPDIR/fake-bin"
  mkdir -p "$FAKE_BIN"
}

teardown()
{
  rm -rf "$BATS_TMPDIR/share" "$BATS_TMPDIR/bin" "$BATS_TMPDIR/fake-bin" \
         "$BATS_TMPDIR/config" "$BATS_TMPDIR/cache" "$BATS_TMPDIR/state"
}

# ── Group 1: uv availability check ────────────────────────────────────

@test "script exits 1 when uv is not found" {
  # Run with a PATH that does not contain uv
  run env PATH="$FAKE_BIN:/usr/bin:/bin" bash scripts/install-python-packages.sh
  [ "$status" -eq 1 ]
}

@test "script prints error message when uv is not found" {
  run env PATH="$FAKE_BIN:/usr/bin:/bin" bash scripts/install-python-packages.sh
  [ "$status" -eq 1 ]
  [[ "$output" == *"uv not found"* ]]
}

@test "error message directs user to install uv via mise" {
  run env PATH="$FAKE_BIN:/usr/bin:/bin" bash scripts/install-python-packages.sh
  [ "$status" -eq 1 ]
  [[ "$output" == *"mise"* ]]
}

# ── Group 2: Successful library installation ───────────────────────────

@test "script exits 0 when uv is available and installs succeed" {
  # Create a mock uv that succeeds for all invocations
  cat > "$FAKE_BIN/uv" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -eq 0 ]
}

@test "script calls uv pip install for libtmux" {
  local calls_log="$BATS_TMPDIR/uv-calls.log"
  cat > "$FAKE_BIN/uv" <<EOF
#!/usr/bin/env bash
echo "uv \$@" >> "$calls_log"
exit 0
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -eq 0 ]
  grep -q "libtmux" "$calls_log"
}

@test "script calls uv pip install for pynvim" {
  local calls_log="$BATS_TMPDIR/uv-calls.log"
  cat > "$FAKE_BIN/uv" <<EOF
#!/usr/bin/env bash
echo "uv \$@" >> "$calls_log"
exit 0
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -eq 0 ]
  grep -q "pynvim" "$calls_log"
}

@test "script uses --system flag with uv pip install" {
  local calls_log="$BATS_TMPDIR/uv-calls.log"
  cat > "$FAKE_BIN/uv" <<EOF
#!/usr/bin/env bash
echo "uv \$@" >> "$calls_log"
exit 0
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -eq 0 ]
  grep -q -- "--system" "$calls_log"
}

@test "script uses --upgrade flag with uv pip install" {
  local calls_log="$BATS_TMPDIR/uv-calls.log"
  cat > "$FAKE_BIN/uv" <<EOF
#!/usr/bin/env bash
echo "uv \$@" >> "$calls_log"
exit 0
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -eq 0 ]
  grep -q -- "--upgrade" "$calls_log"
}

@test "script prints success message when all libraries are installed" {
  cat > "$FAKE_BIN/uv" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"complete"* ]]
}

# ── Group 3: Failure propagation ──────────────────────────────────────

@test "script exits non-zero when uv pip install fails" {
  cat > "$FAKE_BIN/uv" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -ne 0 ]
}

@test "script does not install tools via uv tool install" {
  # This PR removed tool installation; only library (pip) installs remain.
  local calls_log="$BATS_TMPDIR/uv-calls.log"
  cat > "$FAKE_BIN/uv" <<EOF
#!/usr/bin/env bash
echo "uv \$@" >> "$calls_log"
exit 0
EOF
  chmod +x "$FAKE_BIN/uv"

  run env PATH="$FAKE_BIN:$PATH" bash scripts/install-python-packages.sh
  [ "$status" -eq 0 ]
  # "uv tool install" should NOT appear in calls
  run grep "tool install" "$calls_log"
  [ "$status" -ne 0 ]
}