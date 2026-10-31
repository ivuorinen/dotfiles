---
id: audit-befb5587
auditor: audit
severity: low
category: conventions
area: git history
status: open
found: 2026-10-31
---

# Commit bbaae5b5 typed docs(dfm) but changed install-completions.sh behaviour

## Problem

bbaae5b5 is typed `docs`, but its diff to scripts/install-completions.sh changes what the generator produces: it adds `ssh` to the dfm section loop, so the completion spec and man page gain a subtree, and adds an EXIT trap. The body calls the omission "functional, not only cosmetic". A `docs` type keeps a user-visible fix out of a conventional-commits changelog and version bump.

## Evidence

`git show --stat bbaae5b5`: "docs(dfm): document the ssh section and add it to completions" — CLAUDE.md | 2, scripts/install-completions.sh | 3.
Diff: `+  trap 'rm -rf -- "$dfm_spec_dir"' EXIT` and the section list gaining `ssh`.
Body: "The same omission was functional, not only cosmetic ... the generated dfm completion spec and man page never carried its USAGE subtree."

## Impact

The release notes for the release containing it list no completion fix, and a reader filtering by `fix`/`feat` misses the change.

## Fix

History is not rewritten. Going forward, split mixed commits (`docs(dfm): …` plus `fix(completions): include the ssh section`), or type the commit by its functional part (`fix`).
