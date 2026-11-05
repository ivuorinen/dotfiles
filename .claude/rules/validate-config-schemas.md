---
description: "Run v8r schema validation before committing any structured config file change."
paths:
  - "**/*.yml"
  - "**/*.yaml"
  - "**/*.json"
  - "**/*.toml"
---

# Validate config schemas before guessing keys

When adding or changing a key in any structured-config file (YAML,
JSON, TOML), validate the file against its JSON Schema **before**
committing. Do not extrapolate key names from sibling keys, docs
URLs, or "looks consistent" patterns — schemas are authoritative,
extrapolation is not.

The repeat failure mode this rule prevents:

- Existing config has `BASH_SHFMT_ARGUMENTS` (descriptor `BASH`,
  tool `SHFMT`).
- New tool is documented as `bash-exec`.
- Pattern-match guess: `BASH_BASH_EXEC_*`.
- Schema-correct name: `BASH_EXEC_*`.
- Result: silently-ignored config, lint regressions in CI, force-push
  to fix, all avoidable with one validate call.

## How to validate

`mise exec -- v8r <file>` is the universal entry point — it looks the
file up in the `.v8rrc.yml` catalog first, then auto-detects the schema
from `schemastore.org` by filename. Run it after any edit to a
structured config file and before committing.

| File pattern                  | Tool                                       | Checks                   |
|-------------------------------|--------------------------------------------|--------------------------|
| `.mega-linter.yml`            | `mise exec -- v8r .mega-linter.yml`        | JSON Schema              |
| `.github/workflows/*.yml`     | `actionlint` (already in pre-commit)       | GHA grammar (not schema) |
| `.mise/config.toml`           | `mise exec -- v8r <file>`                  | JSON Schema              |
| `biome.json`                  | `mise exec -- v8r <file>`                  | JSON Schema              |
| `.pre-commit-config.yaml`     | `mise exec -- v8r .pre-commit-config.yaml` | JSON Schema              |
| `install.conf.yaml` (Dotbot)  | `dotbot-validate` skill                    | YAML + link targets      |
| Generic YAML without a schema | `yamllint` (already in pre-commit)         | Syntax/style only        |

If `v8r` says "no schema found", the file is not schema-backed — run the
project's existing syntax linter (yamllint, biome, ruff, …) for formatting
errors, then follow `.claude/rules/no-schema-guessing.md`. That rule is the
only safety net for schema-less files: it carries the evidence requirement
for every key name and the reason a syntax linter never substitutes for a
schema.

Which values need evidence and which are freeform is defined once, in
`.claude/rules/no-schema-guessing.md`.

## What the gates cover

`v8r --ignore-errors` runs in pre-commit (on staged files) and in
`mise run lint-v8r` (the Stop gate, on every YAML, JSON and TOML file git
tracks or does not ignore, so a new file counts before it is staged),
excluding submodules, cheat sheets, `config/gh/` (rewritten by
`gh config set`), `config/gh-dash/` (its schema's relative `$ref`s never
resolve), `graphify-out/`, `docs/audit/` and `schemas/`. A file that
fails validation fails both gates. A file with no match, or with several
candidate schemas, still passes unchecked, so give every new config file
an entry in `.v8rrc.yml` — v8r ignores in-file `$schema` / `#:schema`
lines, so the catalog is the only mapping it reads.

## The catalog

`.v8rrc.yml` maps a file to an upstream schema when its tool publishes
one, and otherwise to a repo-local schema under `schemas/`. Most
repo-local schemas are typed from the keys this repo already sets and
allow any other key, so they catch a wrong type or broken structure but
never an invented key name — `no-schema-guessing.md` still governs those
files. `dotbot.schema.json` is the exception: its directive options come
from the pinned `tools/dotbot` README and reject unknown ones. The
`schemas/` files are skipped as inputs because ajv checks each against
its meta-schema whenever it validates a file with it.
