---
description: "Key-name guessing in schema-less or unvalidated config files is strictly prohibited."
alwaysApply: true
---

# No guessing without a schema

When editing any structured config file (YAML, JSON, TOML, INI, or any
key-value format) that has no JSON Schema **and** no linter that validates
key names:

**You must not guess, assume, infer, or extrapolate any key name or value.**

## What counts as guessing (all forbidden)

- **Sibling-key extrapolation**: "the adjacent key uses format X, so this
  one probably does too"
- **Cross-tool carry-over**: applying schema knowledge from a different
  tool's config file (e.g., using a plugin's frontmatter key in Claude
  Code's own frontmatter)
- **Training-data recall**: recalling from model weights — weights encode
  a past snapshot and may not match the current schema
- **Inferred docs**: "the docs URL structure suggests the key is named X"
  without fetching and reading the actual page
- **Unverified repo examples**: copying a key name from a file in this repo
  without confirming that file targets the same tool, the same config
  namespace, and a version of the schema that matches what is installed

## What is required instead

Before writing any key or value in a schema-less file, at least one of the
following must be true:

1. **Docs fetched in this session**: call `ctx_fetch_and_index` on the
    tool's official reference page and quote the exact key from the returned
    content. A previous session's fetch does not count — fetch again.
2. **Tool's own help output**: run `<tool> --help`, `<tool> schema`, or
    equivalent via `ctx_batch_execute` and quote the key from that output.
3. **User-provided key name**: the user typed or pasted the key name in
    this session.
4. **Tool-reported error**: the tool itself printed the correct key name in
    an error message visible in the current session's output.

"It looks right" is not evidence. "I've seen this before" is not evidence.
"The sibling key uses this pattern" is not evidence.

## Why syntax linters are not sufficient

yamllint, biome, and prettier validate **syntax and formatting only** — they
do not check whether a key name is recognised by the tool that reads the
file. A file where every key is misspelled can pass yamllint with no
errors. "The linter passed" never implies "the key names are correct."

This distinction is why `validate-config-schemas.md` falls back to yamllint
for schema-less files: yamllint catches syntax errors. It does NOT authorise
guessing key names. Both rules apply simultaneously.

## Canonical failure mode (N-078, 2026-05-18)

Claude Code's `.claude/rules/` frontmatter has no JSON schema. v8r returns
"no schema found". yamllint does not check frontmatter keys. Training data
recalled `globs:` (used by the context-mode superpowers plugin) and it was
applied to seven Claude Code rule files. The Claude Code docs use `paths:`.
All seven files required correction; an Invalid finding was filed.

Correct procedure: call `ctx_fetch_and_index` on `code.claude.com/docs/en/memory`,
search for "path-specific rules", quote `paths:` from the returned text.

## Relationship to validate-config-schemas.md

- File **has** a schema (`v8r` finds one) → run `yarn dlx v8r <file>` per
  `validate-config-schemas.md`. This rule still applies during writing; v8r
  is the commit-time gate.
- File **has no** schema → this rule is the only safety net. No commit-time
  gate exists. The discipline is the safety net.
