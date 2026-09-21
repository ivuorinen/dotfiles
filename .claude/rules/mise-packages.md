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

`pre-bash-route.sh` denies the hand-run install commands, and `BASH_OK`
does not override it.
