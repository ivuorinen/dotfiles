---
description: "config/lib.sh stays side-effect-free on source: no top-level set -e, trap, or exit."
paths:
  - "config/lib.sh"
---

# config/lib.sh is side-effect-free on source

Never add `set -e`, a `trap`, or an `exit` at the top level of
`config/lib.sh`. It is sourced by every interactive bash and zsh shell,
so a top-level side effect lands in the user's terminal. Scripts opt in
through `lib::strict` and `lib::trap_cleanup`.

`tests/lib.bats` covers the invariant.
