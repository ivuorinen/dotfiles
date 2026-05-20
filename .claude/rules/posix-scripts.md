---
description: "POSIX script validation — validate with sh -n not bash -n for these five scripts."
paths:
  - "local/bin/x-ssh-audit"
  - "local/bin/x-codeql"
  - "local/bin/x-until-error"
  - "local/bin/x-until-success"
  - "local/bin/x-ssl-expiry-date"
---

# POSIX shell scripts

Validate POSIX shell scripts with `sh -n`, never `bash -n`.

The following scripts use `/bin/sh` (POSIX), not bash:

- `local/bin/x-ssh-audit`
- `local/bin/x-codeql`
- `local/bin/x-until-error`
- `local/bin/x-until-success`
- `local/bin/x-ssl-expiry-date`

Running `bash -n` on a POSIX script masks bashism leaks (e.g.
`[[ ]]`, `<<<`, arrays) that would fail under `dash` or `busybox sh`.

## macOS caveat

On macOS, `/bin/sh` is bash invoked as `sh` (POSIX-ish mode), and
some bashisms still parse. A script that passes `sh -n` on macOS
can fail under `dash` or `busybox sh` on a Linux CI runner. Use
`dash -n <file>` (install via `brew install dash`) for the strict
bashism-leak check; fall back to `sh -n` only as a syntax-level
smoke test.
