---
id: audit-442aa6d9
auditor: audit
severity: low
category: conventions
area: .codacy.yml
status: open
found: 2026-08-13
---

# Codacy still reports 18 Bandit issues the repo has explicitly decided to accept, pending a UI-only toggle

## Problem

Codacy analyses this repo through the GitHub App and runs its own Bandit with default patterns. As of this run the repo records its Bandit decisions in `[tool.bandit]` in `pyproject.toml`, but Codacy only reads a tool's own config file when "use configuration file" is enabled for that tool in the repository's Code patterns page — a setting that cannot be expressed in `.codacy.yml`. Until it is toggled, Codacy and the local gate disagree about the same code.

## Evidence

Codacy API for `gh/ivuorinen/dotfiles` at commit `e1836f1`: grade A (95), `issuesCount: 23`, every one in the Security category. By pattern:

```
Bandit_B101   11   local/bin/x-compare-versions.py:50-66
Bandit_B607    7   local/bin/x-git-largest-files.py:106,111,116,119,159,160,190
Bandit_B603    2   config/fish/functions/__bass.py:64,71
Bandit_B404    1   config/fish/functions/__bass.py:13
Opengrep dangerous-subprocess-use-audit  2   config/fish/functions/__bass.py:64,71
```

The local gate now reports zero on the same tree:

```
$ bandit -c pyproject.toml -r . -q; echo "rc=$?"
rc=0
```

`.codacy.yml` (added this run) excludes `config/fish/functions/__bass.py`, which retires the 5 `__bass.py` issues. The remaining 18 (11x B101, 7x B607) are in first-party files that must stay analysed, so exclusion is the wrong instrument for them.

## Impact

Two gates disagree on the same commit: `yarn lint` passes while the Codacy check reports 18 security issues, 11 of them at High. A reviewer cannot tell an accepted decision from an unreviewed one, and the standing count trains everyone to ignore the Codacy status — at which point a genuinely new Bandit finding lands unnoticed among the 18.

## Fix

One of two, both requiring dashboard access (https://app.codacy.com/gh/ivuorinen/dotfiles):

1. Preferred — Code patterns > Bandit > enable "use configuration file". Codacy then reads `[tool.bandit]` from `pyproject.toml`, and the B101/B607 decisions plus their recorded reasons apply in both places from one source.
2. Fallback, if that toggle is unavailable on the plan — disable patterns `Bandit_B101` and `Bandit_B607` in the Default coding standard. This drifts from `pyproject.toml`, so add a comment in `[tool.bandit]` pointing at the UI as a second place to update.

After either, re-check the count:

```
curl -s https://app.codacy.com/api/v3/analysis/organizations/gh/ivuorinen/repositories/dotfiles | jq .data.issuesCount
```

Expect 0. Anything else is a pattern the repo has not yet ruled on.
