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

`yarn dlx v8r <file>` is the universal entry point — it auto-detects
the schema from `schemastore.org` for most well-known formats. Run
it after any edit to a file with a known schema and before
committing.

| File pattern                                   | Tool                                   | Checks                   |
|------------------------------------------------|----------------------------------------|--------------------------|
| `.mega-linter.yml`                             | `yarn dlx v8r .mega-linter.yml`        | JSON Schema              |
| `.github/workflows/*.yml`                      | `actionlint` (already in pre-commit)   | GHA grammar (not schema) |
| `package.json`, `biome.json`, `tsconfig*.json` | `yarn dlx v8r <file>`                  | JSON Schema              |
| `.pre-commit-config.yaml`                      | `yarn dlx v8r .pre-commit-config.yaml` | JSON Schema              |
| `install.conf.yaml` (Dotbot)                   | `dotbot-validate` skill                | YAML + link targets      |
| Generic YAML without a schema                  | `yamllint` (already in pre-commit)     | Syntax/style only        |

If `v8r` says "no schema found", the file is not schema-backed — run the
project's existing syntax linter (yamllint, biome, ruff, …) for formatting
errors, then follow `.claude/rules/no-schema-guessing.md`. That rule is the
only safety net for schema-less files: it carries the evidence requirement
for every key name and the reason a syntax linter never substitutes for a
schema.

Which values need evidence and which are freeform is defined once, in
`.claude/rules/no-schema-guessing.md`.

## What the gates cover

`v8r --ignore-errors` runs in pre-commit and in `yarn lint:v8r` (the
Stop gate) over every tracked YAML, JSON and TOML file, excluding
submodules, cheat sheets, `config/gh/` (rewritten by `gh config set`),
`graphify-out/` and `docs/audit/`. A file with a schema-store match that
fails validation fails both gates. A file with no match, or with several
candidate schemas (`.github/renovate.json`, `.prettierrc.json`), passes
unchecked — for those, `no-schema-guessing.md` is the only safety net.
