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

Add a portable detection helper that exports `MISE_PYTHON_PRECOMPILED_ARCH` and
`MISE_PYTHON_PRECOMPILED_OS` for the current machine, loaded before mise activates in
all supported shells: **bash, sh, zsh, and fish**.

## Files

| File                          | Purpose                                                                           |
|-------------------------------|-----------------------------------------------------------------------------------|
| `local/bin/mise-python-arch`  | POSIX sh executable — detects and prints export statements for arch and OS        |
| `config/exports`              | Evaluates the script output in the mise section (existing file, small addition)   |
| `config/fish/exports.fish`    | Evaluates the script output in the Python section (existing file, small addition) |
| `tests/mise_python_arch.bats` | Bats test suite                                                                   |

## Script: `local/bin/mise-python-arch`

- Shebang: `#!/bin/sh` (POSIX, no bashisms)
- Prints two export statements to stdout: `MISE_PYTHON_PRECOMPILED_ARCH` and `MISE_PYTHON_PRECOMPILED_OS`
- Exits 0 on success, exits 1 silently if the system is unrecognized
- No side effects; safe to call multiple times

### Detection logic

1. `uname -s` → OS
2. `uname -m` → CPU; normalize `arm64` → `aarch64`, `i386` → `i686`
3. Linux only: detect libc via `ldd --version 2>&1 | grep -qi musl`; fallback check
   for `/lib/libc.musl-*`; default to `gnu`

### Output matrix

| OS     | CPU (`uname -m`) | libc  | MISE_PYTHON_PRECOMPILED_ARCH | MISE_PYTHON_PRECOMPILED_OS |
|--------|------------------|-------|------------------------------|----------------------------|
| Darwin | arm64 / aarch64  | —     | `aarch64`                    | `apple-darwin`             |
| Darwin | x86_64           | —     | `x86_64`                     | `apple-darwin`             |
| Linux  | x86_64           | glibc | `x86_64`                     | `unknown-linux-gnu`        |
| Linux  | x86_64           | musl  | `x86_64`                     | `unknown-linux-musl`       |
| Linux  | aarch64          | glibc | `aarch64`                    | `unknown-linux-gnu`        |
| Linux  | aarch64          | musl  | `aarch64`                    | `unknown-linux-musl`       |
| Linux  | i686 / i386      | glibc | `i686`                       | `unknown-linux-gnu`        |
| Linux  | i686 / i386      | musl  | `i686`                       | `unknown-linux-musl`       |
| other  | any              | any   | (no output, exit 1)          | (no output, exit 1)        |

## Integration

### `config/exports` (bash / zsh / sh)

Added before the `mise` activation block. Output is captured first; `eval` only runs
when the command succeeds and produces non-empty output, preserving the helper's exit
status and avoiding silent masking of failures:

```sh
# Set precompiled Python arch+OS so mise downloads the right binary
if command -v mise-python-arch > /dev/null 2>&1; then
  if _mise_python_arch_env="$(mise-python-arch 2>/dev/null)" && [ -n "$_mise_python_arch_env" ]; then
    eval "$_mise_python_arch_env"
  fi
  unset _mise_python_arch_env
fi
```

If detection fails (exit 1), the variables are left unset and mise falls back to its own
detection. The script exports both `MISE_PYTHON_PRECOMPILED_ARCH` and `MISE_PYTHON_PRECOMPILED_OS`.

### `config/fish/exports.fish` (fish)

Added in the Python configuration section. Output is read line-by-line using
`while read -l` (safe for lines containing spaces), and temporary parsing variables
use `set -l` to avoid leaking into the caller's global scope:

```fish
# Set precompiled Python arch+OS so mise downloads the right binary
if command -v mise-python-arch >/dev/null 2>&1
    mise-python-arch 2>/dev/null | while read -l _line
        set -l _kv (string replace -r '^export ' '' -- $_line)
        set -l _key (string split -m1 '=' $_kv)[1]
        set -l _val (string replace -r '^[^=]+="|"$' '' -- $_kv | string replace -ra '"' '')
        set -gx $_key $_val
    end
end
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

| # | Scenario                       | Expected ARCH | Expected OS          | Exit |
|---|--------------------------------|---------------|----------------------|------|
| 1 | macOS arm64                    | `aarch64`     | `apple-darwin`       | 0    |
| 2 | macOS x86_64                   | `x86_64`      | `apple-darwin`       | 0    |
| 3 | Linux x86_64 + glibc           | `x86_64`      | `unknown-linux-gnu`  | 0    |
| 4 | Linux x86_64 + musl            | `x86_64`      | `unknown-linux-musl` | 0    |
| 5 | Linux aarch64 + glibc          | `aarch64`     | `unknown-linux-gnu`  | 0    |
| 6 | Linux aarch64 + musl           | `aarch64`     | `unknown-linux-musl` | 0    |
| 7 | Linux i686 + glibc             | `i686`        | `unknown-linux-gnu`  | 0    |
| 8 | Linux i386 (normalized) + musl | `i686`        | `unknown-linux-musl` | 0    |
| 9 | Unknown OS                     | (no output)   | (no output)          | 1    |

## Out of scope

- x86_64 microarchitecture levels (v2/v3/v4) — baseline `x86_64` chosen for maximum portability
- Windows support — not a target platform for this dotfiles repo
- Per-host overrides — host-specific `exports` files can override the var after it is set