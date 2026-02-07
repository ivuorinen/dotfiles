# Skip Already-Installed Cargo Packages

## Problem

`install-cargo-packages.sh` runs `cargo install-update -a` to update installed
packages, then runs `cargo install` for every package in the list — including
ones that are already installed and up-to-date. This wastes time rebuilding
packages that don't need it.

## Solution

Capture the `cargo install-update -a` output, parse installed package names,
and skip `cargo install` for any package that appeared in the update output.

## Changes

**File:** `scripts/install-cargo-packages.sh`

1. Declare an associative array `installed_packages` at the top.
2. In the `cargo-install-update` section, capture output with `tee /dev/stderr`
   so it displays in real-time while also being stored in a variable.
3. Parse the captured output with `awk` — extract the first column from lines
   matching a version pattern (`v[0-9]+\.[0-9]+`), skipping the header.
4. Populate `installed_packages` associative array from parsed names.
5. In `install_packages()`, check each package against the array. If found, log
   a skip message via `msgr` and continue. If not found, install as before.
6. If `cargo-install-update` is not available, the array stays empty and all
   packages install normally (preserves existing behavior).

## Output Parsing

The `cargo install-update -a` output format:

```
Package           Installed  Latest   Needs update
zoxide            v0.9.8     v0.9.9   Yes
bkt               v0.8.2     v0.8.2   No
```

Extraction: `awk '/v[0-9]+\.[0-9]+/ { print $1 }'` gets package names.
