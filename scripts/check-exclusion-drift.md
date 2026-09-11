# check-exclusion-drift

Keeps the repo's five third-party exclusion lists in step with each other.

## Why

`.codacy.yml` carries the requirement in prose:

> The exclusion set below mirrors the one every other gate already uses --
> `tool.ruff.extend-exclude` and `tool.bandit.exclude_dirs` (pyproject.toml),
> `FILTER_REGEX_EXCLUDE` (.mega-linter.yml), and the vendored trees listed in
> `.claude/rules/vendored-files.md`. Keep the four in step when one moves.

Nothing enforced it. A vendored tree added to one gate could stay missing from
the other four indefinitely, and the symptom — unactionable findings against
third-party code — shows up in a CI report weeks later, far from the edit that
caused it.

## What it checks

The five gates do **not** have identical scope: ruff and bandit only ever see
Python files, grype only scans dependency manifests. Requiring every gate to
list every tree would report ~40 differences on day one, all of them correct.

So the check compares the **coverage matrix** — which gates exclude which tree
— against a reviewed baseline in `.exclusion-baseline.json`, and fails when
that matrix changes:

| Change                                 | Reported  |
|----------------------------------------|-----------|
| Tree appears in some gates, not others | `NEW`     |
| Tree disappears from every gate        | `DROPPED` |
| Tree gains or loses a gate             | `CHANGED` |

Entries are normalised before comparison, so `./tools/**`, `tools/**` and
`tools` are recognised as the same tree.

## Usage

```bash
yarn lint:exclusions              # or: ./scripts/check-exclusion-drift.py
./scripts/check-exclusion-drift.py --update   # re-baseline a reviewed change
```

Runs as part of `yarn lint`, so the Stop-hook lint gate covers it.

## When it fires

Add the tree to the gates that should have it, then re-run. If the difference
is deliberate — a tree that genuinely belongs in only some gates — record it
with `--update` and commit the updated `.exclusion-baseline.json` alongside the
config change, so the reason is visible in that commit's diff.

Do not re-baseline to silence a failure you have not understood: the baseline
is the only record of which gates were intended to cover what.

## Sources parsed

| Gate       | File               | Key                            |
|------------|--------------------|--------------------------------|
| grype      | `.grype.yaml`      | `exclude`                      |
| codacy     | `.codacy.yml`      | `exclude_paths`                |
| ruff       | `pyproject.toml`   | `[tool.ruff]` `extend-exclude` |
| bandit     | `pyproject.toml`   | `[tool.bandit]` `exclude_dirs` |
| megalinter | `.mega-linter.yml` | `FILTER_REGEX_EXCLUDE`         |

`.claude/rules/vendored-files.md` is the prose policy behind the set. It is not
parsed — it is documentation, and a regex over prose would be the kind of
brittle coupling this script exists to avoid. Update it by hand when a tree
moves.

Stdlib only (`tomllib` plus regex for the two flat YAML lists), so the check
needs nothing installed beyond Python.

## Tests

`tests/check-exclusion-drift.bats`. The tests point the script at a fixture
repo via `EXCLUSION_CHECK_ROOT`; the important cases are the failing ones, plus
a guard that the committed baseline still matches the live config files.
