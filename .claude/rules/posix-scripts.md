---
description: "POSIX script validation — validate with sh -n not bash -n for these scripts."
paths:
  - "local/bin/x-ssh-audit"
  - "local/bin/x-codeql"
  - "local/bin/x-until-error"
  - "local/bin/x-until-success"
  - "local/bin/x-ssl-expiry-date"
  - "local/bin/x-list-open-prs"
  - "local/bin/x-quota-usage"
  - "local/bin/mise-python-arch"
  - "local/bin/pushover"
---

# POSIX shell scripts

Validate POSIX shell scripts with `sh -n`, never `bash -n`.

The following scripts are POSIX, not bash. Keep this list in step with
reality — `git ls-files | xargs head -1` and look for `sh` shebangs, since a
script missing from here gets validated as bash and a bashism slips through:

- `local/bin/x-ssh-audit`
- `local/bin/x-codeql`
- `local/bin/x-until-error`
- `local/bin/x-until-success`
- `local/bin/x-ssl-expiry-date`
- `local/bin/x-list-open-prs`
- `local/bin/x-quota-usage`
- `local/bin/mise-python-arch`

One more declares `#!/usr/bin/env sh` rather than `#!/bin/sh`, and is POSIX
all the same:

- `local/bin/pushover`

Running `bash -n` on a POSIX script masks bashism leaks (e.g.
`[[ ]]`, `<<<`, arrays) that would fail under `dash` or `busybox sh`.

## macOS caveat

On macOS, `/bin/sh` is bash invoked as `sh` (POSIX-ish mode), and
some bashisms still parse. A script that passes `sh -n` on macOS
can fail under `dash` or `busybox sh` on a Linux CI runner. Use
`dash -n <file>` (install via `brew install dash`) for the strict
bashism-leak check; fall back to `sh -n` only as a syntax-level
smoke test.
