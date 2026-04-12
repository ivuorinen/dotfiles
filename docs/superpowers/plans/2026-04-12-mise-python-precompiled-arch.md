# MISE_PYTHON_PRECOMPILED_ARCH Detection Helper Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `local/bin/mise-python-arch`, a POSIX sh script that detects and prints the correct LLVM target triple for `MISE_PYTHON_PRECOMPILED_ARCH`, and wire it into bash/zsh/sh and fish startup before mise activates.

**Architecture:** Single executable `local/bin/mise-python-arch` uses `uname -s` / `uname -m` for OS and CPU, `ldd --version` for Linux libc detection, and prints the triple to stdout (exits 1 if unrecognized). `config/exports` and `config/fish/exports.fish` each get a small block that calls the script and exports the result before the mise activation block.

**Tech Stack:** POSIX sh (`/bin/sh`), bats (Bash Automated Testing System), fish shell

---

## File Map

| File                          | Action             | Responsibility                                                   |
|-------------------------------|--------------------|------------------------------------------------------------------|
| `local/bin/mise-python-arch`  | Create             | Detection script — prints LLVM arch triple to stdout             |
| `tests/mise_python_arch.bats` | Create             | 9-case bats test suite                                           |
| `config/exports`              | Modify (~line 516) | Export `MISE_PYTHON_PRECOMPILED_ARCH` before mise activates      |
| `config/fish/exports.fish`    | Modify (~line 108) | Set `MISE_PYTHON_PRECOMPILED_ARCH` in fish before mise activates |

---

### Task 1: Write the bats test suite

**Files:**
- Create: `tests/mise_python_arch.bats`

- [ ] **Step 1: Create the test file**

```bash
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

@test "macOS arm64 returns aarch64-apple-darwin"
{
  _stub_uname "Darwin" "arm64"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "aarch64-apple-darwin" ]
}

@test "macOS x86_64 returns x86_64-apple-darwin"
{
  _stub_uname "Darwin" "x86_64"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "x86_64-apple-darwin" ]
}

@test "Linux x86_64 glibc returns x86_64-unknown-linux-gnu"
{
  _stub_uname "Linux" "x86_64"
  _stub_ldd "ldd (GNU libc) 2.35"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "x86_64-unknown-linux-gnu" ]
}

@test "Linux x86_64 musl returns x86_64-unknown-linux-musl"
{
  _stub_uname "Linux" "x86_64"
  _stub_ldd "musl libc (x86_64) 1.2.3"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "x86_64-unknown-linux-musl" ]
}

@test "Linux aarch64 glibc returns aarch64-unknown-linux-gnu"
{
  _stub_uname "Linux" "aarch64"
  _stub_ldd "ldd (GNU libc) 2.35"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "aarch64-unknown-linux-gnu" ]
}

@test "Linux aarch64 musl returns aarch64-unknown-linux-musl"
{
  _stub_uname "Linux" "aarch64"
  _stub_ldd "musl libc (aarch64) 1.2.3"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "aarch64-unknown-linux-musl" ]
}

@test "Linux i686 glibc returns i686-unknown-linux-gnu"
{
  _stub_uname "Linux" "i686"
  _stub_ldd "ldd (GNU libc) 2.17"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "i686-unknown-linux-gnu" ]
}

@test "Linux i386 is normalized to i686 musl"
{
  _stub_uname "Linux" "i386"
  _stub_ldd "musl libc (i386) 1.2.3"
  run sh "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "i686-unknown-linux-musl" ]
}

@test "Unknown OS exits 1 with no output"
{
  _stub_uname "FreeBSD" "x86_64"
  run sh "$SCRIPT"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}
```

- [ ] **Step 2: Run the tests to confirm they all fail (script not created yet)**

```
yarn test tests/mise_python_arch.bats
```

Expected: all 9 tests fail with something like `sh: …/local/bin/mise-python-arch: No such file or directory`.

---

### Task 2: Create the detection script

**Files:**
- Create: `local/bin/mise-python-arch`

- [ ] **Step 1: Write the script**

```sh
#!/bin/sh
# shellcheck shell=sh
# @description Print the MISE_PYTHON_PRECOMPILED_ARCH triple for this machine.
# Exits 0 and prints the triple on success; exits 1 silently on unknown systems.

_os="$(uname -s)"
_cpu="$(uname -m)"

# Normalize CPU names to match LLVM target triple conventions
case "$_cpu" in
  arm64) _cpu="aarch64" ;;
  i386) _cpu="i686" ;;
esac

case "$_os" in
  Darwin)
    printf '%s-apple-darwin\n' "$_cpu"
    ;;
  Linux)
    _libc="gnu"
    if ldd --version 2>&1 \
      | grep -qi musl; then
      _libc="musl"
    elif ls /lib/libc.musl-* > /dev/null 2>&1; then
      _libc="musl"
    fi
    printf '%s-unknown-linux-%s\n' "$_cpu" "$_libc"
    ;;
  *)
    exit 1
    ;;
esac
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x local/bin/mise-python-arch
```

- [ ] **Step 3: Run the tests and verify all 9 pass**

```
yarn test tests/mise_python_arch.bats
```

Expected output:
```
 ✓ macOS arm64 returns aarch64-apple-darwin
 ✓ macOS x86_64 returns x86_64-apple-darwin
 ✓ Linux x86_64 glibc returns x86_64-unknown-linux-gnu
 ✓ Linux x86_64 musl returns x86_64-unknown-linux-musl
 ✓ Linux aarch64 glibc returns aarch64-unknown-linux-gnu
 ✓ Linux aarch64 musl returns aarch64-unknown-linux-musl
 ✓ Linux i686 glibc returns i686-unknown-linux-gnu
 ✓ Linux i386 is normalized to i686 musl
 ✓ Unknown OS exits 1 with no output

9 tests, 0 failures
```

---

### Task 3: Integrate into `config/exports`

**Files:**
- Modify: `config/exports` (~line 516)

- [ ] **Step 1: Read the target region (lines 514–520) to confirm context**

```bash
sed -n '514,520p' config/exports
```

Expected (verify it matches before editing):
```sh
# sonarqube-cli
[ -d "$HOME/.local/share/sonarqube-cli/bin" ] && export PATH="$HOME/.local/share/sonarqube-cli/bin:$PATH"

# mise — unified tool version manager
# https://mise.jdx.dev
if command -v mise &> /dev/null; then
```

- [ ] **Step 2: Insert the arch detection block before the mise section**

Edit `config/exports`: find the exact string:
```
# mise — unified tool version manager
# https://mise.jdx.dev
```

Replace with:
```sh
# Set precompiled Python arch so mise downloads the right binary
if _arch="$(mise-python-arch 2>/dev/null)"; then
  export MISE_PYTHON_PRECOMPILED_ARCH="$_arch"
fi
unset _arch

# mise — unified tool version manager
# https://mise.jdx.dev
```

- [ ] **Step 3: Verify the change looks correct**

```bash
sed -n '514,530p' config/exports
```

Expected: the new block appears between the sonarqube-cli PATH line and the mise section.

---

### Task 4: Integrate into `config/fish/exports.fish`

**Files:**
- Modify: `config/fish/exports.fish` (~line 108)

- [ ] **Step 1: Read the target region (lines 106–112) to confirm context**

```bash
sed -n '106,112p' config/fish/exports.fish
```

Expected:
```fish
# Python configuration
set -q WORKON_HOME; or set -x WORKON_HOME "$XDG_DATA_HOME/virtualenvs"

# Poetry configuration
```

- [ ] **Step 2: Insert the arch detection after the WORKON_HOME line**

Edit `config/fish/exports.fish`: find the exact string:
```
# Python configuration
set -q WORKON_HOME; or set -x WORKON_HOME "$XDG_DATA_HOME/virtualenvs"
```

Replace with:
```fish
# Python configuration
set -q WORKON_HOME; or set -x WORKON_HOME "$XDG_DATA_HOME/virtualenvs"

# Set precompiled Python arch so mise downloads the right binary
set _arch (mise-python-arch 2>/dev/null)
if test $status -eq 0; and test -n "$_arch"
    set -gx MISE_PYTHON_PRECOMPILED_ARCH $_arch
end
set -e _arch
```

- [ ] **Step 3: Verify the change looks correct**

```bash
sed -n '106,120p' config/fish/exports.fish
```

Expected: the new block appears directly below the WORKON_HOME line.

---

### Task 5: Run the full lint and test suite

- [ ] **Step 1: Run all tests**

```
yarn test
```

Expected: all tests pass, 0 failures.

- [ ] **Step 2: Run lint**

```
yarn lint
```

Expected: no errors or warnings.

---

### Task 6: Commit

- [ ] **Step 1: Stage the files**

```bash
git add \
  local/bin/mise-python-arch \
  tests/mise_python_arch.bats \
  config/exports \
  config/fish/exports.fish \
  docs/superpowers/specs/2026-04-12-mise-python-precompiled-arch-design.md \
  docs/superpowers/plans/2026-04-12-mise-python-precompiled-arch.md
```

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat(mise): add MISE_PYTHON_PRECOMPILED_ARCH detection helper

Adds local/bin/mise-python-arch — a POSIX sh script that detects the
correct python-build-standalone LLVM target triple for the current
machine (OS, CPU, musl vs glibc) and exports it as
MISE_PYTHON_PRECOMPILED_ARCH before mise activates in bash/zsh/sh
and fish. Avoids source-build fallbacks on Linux when precompiled
arch detection fails.
EOF
)"
```
