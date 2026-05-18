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

Running `bash -n` on a POSIX script can mask bashism leaks (e.g.
`[[ ]]`, `<<<`, arrays) that would fail under `dash` or `busybox sh`.
