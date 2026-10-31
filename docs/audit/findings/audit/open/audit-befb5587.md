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

bbaae5b5 is typed `docs`, but its diff to scripts/install-completions.sh changes what the generator produces: it adds `ssh` to the dfm section loop, so the completion spec and man page gain a subtree, and adds an EXIT trap. The body calls the omission "functional, not only cosmetic". The release notes therefore file a functional fix under Documentation Changes instead of Bugfixes. The type does not drop the commit from the changelog, and releases are date-versioned, so it affects no version bump.

## Evidence

`git show --stat bbaae5b5`: "docs(dfm): document the ssh section and add it to completions" — CLAUDE.md | 2, scripts/install-completions.sh | 3.
Diff: `+  trap 'rm -rf -- "$dfm_spec_dir"' EXIT` and the section list gaining `ssh`.
Body: "The same omission was functional, not only cosmetic ... the generated dfm completion spec and man page never carried its USAGE subtree."
.github/tag-changelog-config.js:9 maps `doc`/`docs` to "📚 Documentation Changes" and :4 maps `fix` to "🐛 Bugfixes"; .github/workflows/new-release.yml versions releases with fregante/daily-version-action.

## Impact

The release containing bbaae5b5 lists the completion fix under Documentation Changes, so a reader scanning the Bugfixes section for completion changes does not find it.

## Fix

History is not rewritten. Going forward, split mixed commits (`docs(dfm): …` plus `fix(completions): include the ssh section`), or type the commit by its functional part (`fix`).
