---
description: "Conventions for new scripts in local/bin: #USAGE directive, x- prefix, a bats test."
paths:
  - "local/bin/**"
---

# local/bin scripts

- Every new script in `local/bin/` carries a `#USAGE about "…"` line.
  `scripts/install-completions.sh` discovers scripts by it, and the
  `usage-lint` pre-commit hook lints it.
- Name a standalone utility `x-<name>`. `dfm-*` subcommands and the
  vendored files keep their own names.
- Add `tests/<script>.bats` for every new script (the
  `bats-test-scaffold` skill writes the skeleton).
