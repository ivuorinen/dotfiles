---
description: "Python packages come from mise's default-packages file; run mise install after adding a tool."
paths:
  - "config/mise/**"
  - ".mise.toml"
---

# mise-managed tools and Python packages

Never `pip install`, `python3 -m pip install`, `uv tool install`, or
`uv pip install` by hand. Add a Python library to
`config/mise/default-python-packages`; mise installs it into every
Python it builds, so a version bump never orphans it.

Run `mise install` after adding a tool to `config/mise/config.toml`.

`pre-bash-route.sh` (Bash) and `pre-ctx-write-guard.sh` (context-mode
sandbox code) deny the hand-run install commands via
`.claude/hooks/lib/bash-policy.sh`, and `BASH_OK` does not override it.
The versioned binaries mise installs (`pip3.12`, `python3.12 -m pip`) and
the one-word `-mpip` are denied the same way, as is any of these behind
a runner such as `mise exec --`.
