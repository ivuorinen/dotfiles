# setup creates a temporary stub directory, prepends it to PATH so stubs override system commands, and sets SCRIPT to the test target path.

setup()
{
  STUB_DIR="$(mktemp -d)"
  export PATH="$STUB_DIR:$PATH"
  SCRIPT="$PWD/local/bin/mise-python-arch"
}

# teardown removes the temporary stub directory created during setup.
teardown()
{
  rm -rf "$STUB_DIR"
}

# Write a stub uname that returns controlled -s and -m values.
# _stub_uname writes an executable stub at "$STUB_DIR/uname" that responds to `uname -s` with the given OS string and `uname -m` with the given CPU string.
_stub_uname()
{
  local _os="$1"
  local _cpu="$2"
  cat > "$STUB_DIR/uname" << EOF
#!/bin/sh
case "\$1" in
  -s) printf '%s\n' "${_os}" ;;
  -m) printf '%s\n' "${_cpu}" ;;
esac
EOF
  chmod +x "$STUB_DIR/uname"
}

# Write a stub ldd that prints a fixed version string to stdout.
# _stub_ldd writes an executable stub `ldd` into `STUB_DIR` that prints the given version-string when invoked.
_stub_ldd()
{
  local _out="$1"
  cat > "$STUB_DIR/ldd" << EOF
#!/bin/sh
printf '%s\n' "${_out}"
EOF
  chmod +x "$STUB_DIR/ldd"
}

# Write a stub ls that always exits 1, preventing the /lib/libc.musl-* fallback
# _stub_ls_no_musl writes an executable stub named `ls` into `$STUB_DIR` that immediately exits with status 1 to block musl-detection fallbacks that inspect the real filesystem.
_stub_ls_no_musl()
{
  cat > "$STUB_DIR/ls" << 'EOF'
#!/bin/sh
exit 1
EOF
  chmod +x "$STUB_DIR/ls"
}

@test "macOS arm64 exports aarch64 arch and apple-darwin os" {
  _stub_uname "Darwin" "arm64"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="aarch64"
export MISE_PYTHON_PRECOMPILED_OS="apple-darwin"' ]
}

@test "macOS x86_64 exports x86_64 arch and apple-darwin os" {
  _stub_uname "Darwin" "x86_64"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="x86_64"
export MISE_PYTHON_PRECOMPILED_OS="apple-darwin"' ]
}

@test "Linux x86_64 glibc exports x86_64 arch and unknown-linux-gnu os" {
  _stub_uname "Linux" "x86_64"
  _stub_ldd "ldd (GNU libc) 2.35"
  _stub_ls_no_musl
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="x86_64"
export MISE_PYTHON_PRECOMPILED_OS="unknown-linux-gnu"' ]
}

@test "Linux x86_64 musl exports x86_64 arch and unknown-linux-musl os" {
  _stub_uname "Linux" "x86_64"
  _stub_ldd "musl libc (x86_64) 1.2.3"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="x86_64"
export MISE_PYTHON_PRECOMPILED_OS="unknown-linux-musl"' ]
}

@test "Linux aarch64 glibc exports aarch64 arch and unknown-linux-gnu os" {
  _stub_uname "Linux" "aarch64"
  _stub_ldd "ldd (GNU libc) 2.35"
  _stub_ls_no_musl
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="aarch64"
export MISE_PYTHON_PRECOMPILED_OS="unknown-linux-gnu"' ]
}

@test "Linux aarch64 musl exports aarch64 arch and unknown-linux-musl os" {
  _stub_uname "Linux" "aarch64"
  _stub_ldd "musl libc (aarch64) 1.2.3"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="aarch64"
export MISE_PYTHON_PRECOMPILED_OS="unknown-linux-musl"' ]
}

@test "Linux i686 glibc exports i686 arch and unknown-linux-gnu os" {
  _stub_uname "Linux" "i686"
  _stub_ldd "ldd (GNU libc) 2.17"
  _stub_ls_no_musl
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="i686"
export MISE_PYTHON_PRECOMPILED_OS="unknown-linux-gnu"' ]
}

@test "Linux i386 is normalized to i686 musl" {
  _stub_uname "Linux" "i386"
  _stub_ldd "musl libc (i386) 1.2.3"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="i686"
export MISE_PYTHON_PRECOMPILED_OS="unknown-linux-musl"' ]
}

@test "Unknown OS exits 1 with no output" {
  _stub_uname "FreeBSD" "x86_64"
  run sh "$SCRIPT"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "Unknown CPU exits 1 with no output" {
  _stub_uname "Linux" "riscv64"
  run sh "$SCRIPT"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "Linux x86_64 musl detected via ls fallback" {
  _stub_uname "Linux" "x86_64"
  _stub_ldd "ldd (GNU libc) 2.35"
  # stub ls to exit 0, simulating /lib/libc.musl-* present
  cat > "$STUB_DIR/ls" << 'EOF'
#!/bin/sh
exit 0
EOF
  chmod +x "$STUB_DIR/ls"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = 'export MISE_PYTHON_PRECOMPILED_ARCH="x86_64"
export MISE_PYTHON_PRECOMPILED_OS="unknown-linux-musl"' ]
}
