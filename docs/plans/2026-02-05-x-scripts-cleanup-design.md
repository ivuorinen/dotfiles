# x-* Scripts Cleanup Design

## Summary

Comprehensive cleanup of all 34 x-* utility scripts in `local/bin/`.
Fix critical bugs, consolidate duplicates, standardize patterns.

## Changes

### Removals

- `x-mkd`, `x-mkd.md`, `tests/x-mkd.bats` — unused, cd-in-subshell broken
- `x-validate-sha256sum.sh`, `x-validate-sha256sum.sh.md` — duplicates x-sha256sum-matcher

### Thin Wrappers (delegate to x-path)

- `x-path-append` → calls `x-path append "$@"`
- `x-path-prepend` → calls `x-path prepend "$@"`
- `x-path-remove` → calls `x-path remove "$@"`

### Critical Fixes

- `x-clean-vendordirs`: call msgr as command (it's in PATH)
- `x-foreach`: replace eval with direct "$@" execution
- `x-ip`: add error handling, curl check

### Consistency Fixes

- Fix `#!/bin/bash` → `#!/usr/bin/env bash` (x-env-list, x-localip)
- POSIX scripts keep `#!/bin/sh`
- Add `set -euo pipefail` where missing in bash scripts
- Use XDG variables instead of hardcoded paths (x-change-alacritty-theme)
- Quote unquoted variables

### Minor Fixes

- `x-multi-ping`: remove unused VERBOSE variable
- `x-when-down`, `x-when-up`: add error handling
- `x-term-colors`: add usage message
- `x-record`: fix undefined notify-call reference

## Verification

- `yarn test` — ensure remaining tests pass
- `shellcheck` on modified scripts
- `bash -n` syntax check on all modified bash scripts
