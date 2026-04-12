---
title: MISE_PYTHON_PRECOMPILED_ARCH detection helper
date: 2026-04-12
status: approved
---

# MISE_PYTHON_PRECOMPILED_ARCH Detection Helper

## Background

Removing `python.compile = 1` from `config/mise/config.toml` (to avoid long source
builds on Linux) means mise now relies on precompiled Python binaries from
python-build-standalone. On some systems mise cannot auto-select the correct
precompiled architecture, causing install failures. Setting
`MISE_PYTHON_PRECOMPILED_ARCH` explicitly before mise is activated fixes this.

## Goal

Add a portable detection helper that sets `MISE_PYTHON_PRECOMPILED_ARCH` to the
correct LLVM target triple for the current machine, loaded before mise activates in
all supported shells: **bash, sh, zsh, and fish**.

## Files

| File                          | Purpose                                                                  |
|-------------------------------|--------------------------------------------------------------------------|
| `local/bin/mise-python-arch`  | POSIX sh executable — detects and prints arch triple                     |
| `config/exports`              | Sources the result in the mise section (existing file, small addition)   |
| `config/fish/exports.fish`    | Sources the result in the Python section (existing file, small addition) |
| `tests/mise_python_arch.bats` | Bats test suite                                                          |

## Script: `local/bin/mise-python-arch`

- Shebang: `#!/bin/sh` (POSIX, no bashisms)
- Prints exactly one line to stdout: the LLVM target triple
- Exits 0 on success, exits 1 silently if the system is unrecognized
- No side effects; safe to call multiple times

### Detection logic

1. `uname -s` → OS
2. `uname -m` → CPU; normalize `arm64` → `aarch64`, `i386` → `i686`
3. Linux only: detect libc via `ldd --version 2>&1 | grep -qi musl`; fallback check
   for `/lib/libc.musl-*`; default to `gnu`

### Output matrix

| OS     | CPU (`uname -m`) | libc  | Output                       |
|--------|------------------|-------|------------------------------|
| Darwin | arm64 / aarch64  | —     | `aarch64-apple-darwin`       |
| Darwin | x86_64           | —     | `x86_64-apple-darwin`        |
| Linux  | x86_64           | glibc | `x86_64-unknown-linux-gnu`   |
| Linux  | x86_64           | musl  | `x86_64-unknown-linux-musl`  |
| Linux  | aarch64          | glibc | `aarch64-unknown-linux-gnu`  |
| Linux  | aarch64          | musl  | `aarch64-unknown-linux-musl` |
| Linux  | i686 / i386      | glibc | `i686-unknown-linux-gnu`     |
| Linux  | i686 / i386      | musl  | `i686-unknown-linux-musl`    |
| other  | any              | any   | (no output, exit 1)          |

## Integration

### `config/exports` (bash / zsh / sh)

Added in the `mise` section, before `eval "$(... mise activate ...)"`:

```sh
# Set precompiled Python arch for mise to avoid source builds
_arch="$(mise-python-arch 2>/dev/null)" && export MISE_PYTHON_PRECOMPILED_ARCH="$_arch"
unset _arch
```

If detection fails (exit 1), the var is left unset and mise falls back to its own
detection. The temp variable is unset immediately to keep the environment clean.

### `config/fish/exports.fish` (fish)

Added in the Python configuration section:

```fish
# Set precompiled Python arch for mise to avoid source builds
set _arch (mise-python-arch 2>/dev/null)
if test $status -eq 0; and test -n "$_arch"
    set -gx MISE_PYTHON_PRECOMPILED_ARCH $_arch
end
set -e _arch
```

### Why this order is safe

`local/bin` (symlinked to `~/.local/bin`) is prepended to PATH early in the
bootstrap section of `config/exports`, before the mise section. Dotfiles are
installed before mise is activated, so `mise-python-arch` is always on PATH when
these lines run.

## Tests: `tests/mise_python_arch.bats`

Each test stubs `uname` and optionally `ldd` by prepending a temp directory of
wrapper scripts to PATH, then asserts the script's stdout and exit code.

### Test cases

| # | Scenario                       | Expected output              |
|---|--------------------------------|------------------------------|
| 1 | macOS arm64                    | `aarch64-apple-darwin`       |
| 2 | macOS x86_64                   | `x86_64-apple-darwin`        |
| 3 | Linux x86_64 + glibc           | `x86_64-unknown-linux-gnu`   |
| 4 | Linux x86_64 + musl            | `x86_64-unknown-linux-musl`  |
| 5 | Linux aarch64 + glibc          | `aarch64-unknown-linux-gnu`  |
| 6 | Linux aarch64 + musl           | `aarch64-unknown-linux-musl` |
| 7 | Linux i686 + glibc             | `i686-unknown-linux-gnu`     |
| 8 | Linux i386 (normalized) + musl | `i686-unknown-linux-musl`    |
| 9 | Unknown OS                     | empty output, exit code 1    |

## Out of scope

- x86_64 microarchitecture levels (v2/v3/v4) — baseline `x86_64` chosen for maximum portability
- Windows support — not a target platform for this dotfiles repo
- Per-host overrides — host-specific `exports` files can override the var after it is set
