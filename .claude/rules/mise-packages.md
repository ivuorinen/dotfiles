---
description: "Python tools are pipx: entries in mise's config; run mise install after adding a tool."
paths:
  - "config/mise/**"
  - ".mise/config.toml"
---

# mise-managed tools and Python packages

Never `pip install`, `python3 -m pip install`, `uv tool install`, or
`uv pip install` by hand. Add a Python tool to `config/mise/config.toml` as
`"pipx:<package>" = "<version>"`; each gets its own virtualenv, so neither a
Python version bump nor a project's own Python can orphan it. A package with no
executables cannot be a mise tool: a standalone script declares such a library
inline instead (PEP 723, run by `uv run --script`), as
`local/bin/x-compare-versions.py` does for `packaging`.

Run `mise install` after adding a tool to `config/mise/config.toml`.

`pre-bash-route.sh` (Bash) and `pre-ctx-write-guard.sh` (context-mode
sandbox code) deny the hand-run install commands via
`.claude/hooks/lib/bash-policy.sh`, and `BASH_OK` does not override it.
The versioned binaries mise installs (`pip3.12`, `python3.12 -m pip`) and
the one-word `-mpip` are denied the same way, as is any of these behind
a runner such as `mise exec --`.
