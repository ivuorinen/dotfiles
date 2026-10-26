---
id: deps-cb48b739
auditor: deps
severity: low
category: reliability
area: .v8rrc.yml
status: open
found: 2026-10-26
location: .v8rrc.yml:8-14
location_sha: 8bf7ee196b6738b2
---

# pyproject.toml schema pinned to a SchemaStore commit until complexipy.json is published

## Problem

SchemaStore's catalog maps `pyproject.toml` to the moving `master` copy of `pyproject.json` on raw.githubusercontent.com. SchemaStore commit e44768a6 ("Add complexipy schema", #6521, 2026-10-25) added a `$ref` to `https://www.schemastore.org/complexipy.json`, which the published site still answers with 404. v8r fails fetching it during cache pre-warm and exits non-zero despite `--ignore-errors`, so `mise run lint-v8r` and the Stop lint gate failed on every run. `.v8rrc.yml` now carries a `customCatalog` entry pinning `pyproject.toml` to `pyproject.json` at SchemaStore 6ae72b03 (the commit before #6521). The pin is a temporary workaround: while it stays, `pyproject.toml` is validated against a frozen schema that misses later upstream additions.

## Evidence

`mise run lint-v8r` (2026-10-26) printed `✖ Failed fetching https://www.schemastore.org/complexipy.json` followed by `[lint-v8r] ERROR task failed`. `v8r -v` on the TOML files showed the fetch chain: `calling .../schemastore/master/src/schemas/json/pyproject.json` then `calling https://www.schemastore.org/complexipy.json`. master's `pyproject.json` holds `"complexipy": {"$ref": "https://www.schemastore.org/complexipy.json"`; `src/schemas/json/complexipy.json` exists on master (200) but `https://www.schemastore.org/complexipy.json` and `https://json.schemastore.org/complexipy.json` both return 404. After the pin, `mise run lint-v8r` exits 0 and logs `✔ pyproject.toml is valid` against the 6ae72b03 URL.

## Impact

Without the pin, every turn's Stop gate fails on an upstream deployment lag unrelated to repo changes. With the pin, `pyproject.toml` silently stops tracking upstream schema updates (new `[tool.*]` sections) until someone removes it.

## Fix

Once `https://www.schemastore.org/complexipy.json` returns 200, delete `.v8rrc.yml` (its only entry is this pin), run `mise run lint-v8r` to confirm it passes against the catalog's master URL, and resolve this finding as fixed.
