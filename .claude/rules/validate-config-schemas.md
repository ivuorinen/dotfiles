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

| File pattern                                   | Validator                              |
|------------------------------------------------|----------------------------------------|
| `.mega-linter.yml`                             | `yarn dlx v8r .mega-linter.yml`        |
| `.github/workflows/*.yml`                      | `actionlint` (already in pre-commit)   |
| `package.json`, `biome.json`, `tsconfig*.json` | `yarn dlx v8r <file>`                  |
| `.pre-commit-config.yaml`                      | `yarn dlx v8r .pre-commit-config.yaml` |
| `install.conf.yaml` (Dotbot)                   | `dotbot-validate` skill                |
| Generic YAML without a schema                  | `yamllint` (already in pre-commit)     |

If `v8r` says "no schema found", the file is not schema-backed — run the
project's existing syntax linter (yamllint, biome, ruff, …) to catch
formatting errors. Key-name guessing is still strictly prohibited; see
`no-schema-guessing.md` for what evidence is required before writing any
key name into a schema-less file.

## When extrapolation is fine

Only when the field is freeform (regex, glob list, log message text,
secrets value). Anything where the parser pattern-matches a known
key name → schema-validate.

## Why a Stop-hook does not replace this rule

Pre-commit hooks run shellcheck, yamllint, and actionlint, but none
of them schema-check `.mega-linter.yml` or other tool-specific
files. The Stop-hook's `yarn lint` aggregator skips them too. There
is no automatic safety net — the discipline is the safety net.
