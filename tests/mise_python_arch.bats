#!/usr/bin/env bats

setup()
{
  STUB_DIR="$(mktemp -d)"
  export PATH="$STUB_DIR:$PATH"
  SCRIPT="$PWD/local/bin/mise-python-arch"
}

teardown()
{
  rm -rf "$STUB_DIR"
}

# Write a stub uname that returns controlled -s and -m values.
# Usage: _stub_uname <os-string> <cpu-string>
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
# Usage: _stub_ldd <version-string>
_stub_ldd()
{
  local _out="$1"
  cat > "$STUB_DIR/ldd" << EOF
#!/bin/sh
printf '%s\n' "${_out}"
EOF
  chmod +x "$STUB_DIR/ldd"
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
