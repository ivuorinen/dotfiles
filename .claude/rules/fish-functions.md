---
description: "Fish autoload functions: one function per file, named after the file, with --description."
paths:
  - "config/fish/functions/**"
---

# Fish functions

- Each file in `config/fish/functions/` defines exactly one function,
  named after the file. Fish autoloads by filename; a mismatch leaves
  the function undefined until something sources the file by hand.
- Always pass `--description`.

The five vendored plugin files in this directory are exempt and never
edited — `.claude/rules/vendored-files.md`.
