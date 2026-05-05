# Security Audit Findings

Generated: 2026-05-05
Last validated: 2026-05-05
Pass: 1

## Tool Coverage

- Available: gitleaks, yarn (`yarn npm audit`), grype, trivy, snyk,
  npm, pnpm, semgrep, opengrep, checkov, gosec
- Not applicable: gosec (no Go source files in repo proper); npm /
  pnpm (no `package-lock.json` / `pnpm-lock.yaml` — only `yarn.lock`)
- Not run in this pass: semgrep, opengrep, snyk, checkov.
  Whole-tree SAST on a dotfiles repo (heavy on shell/lua/fish/toml)
  is high-noise. Recorded for the next pass once a tighter rule set
  is configured. checkov on `.github/workflows/` is also pending.
- Errored: none

## Summary

Total: 3 | Open: 0 | Fixed: 1 | Invalid: 0 | Accepted: 2
Critical: 0 | High: 0 | Medium: 0 | Low: 1 | Advisory: 2

Pass 1 close-out 2026-05-05 — SEC-002 mitigated by chmod 600;
SEC-001 and SEC-003 carried as informational (vendored CVE
exposure that the repo does not own; deferred SAST coverage
respectively).

Tracked content is clean. All open findings are in vendored, cached,
or gitignored paths that the repo does not author or version-control.

## Open Findings

_(none — see Fixed and Accepted sections below)_

## Fixed

### Pass 1 — 2026-05-05

#### [SEC-002] trivy detected a working-tree secret in `config/fish/exports-secret.fish`
Fixed: 2026-05-05
Notes: Operational mitigation applied — `chmod 600` on the file
(`stat` confirms `-rw-------`). The file was already gitignored
and never tracked by git; the trivy detection was a true positive
in a correctly-handled local secret store. No code change needed.
PAT rotation is the user's call; recommended periodically per
GitHub guidance.

## Accepted (informational — no repo-side fix)

### Pass 1 — 2026-05-05

#### [SEC-001] grype reports 159 dependency CVEs in vendored / cached / gitignored paths
Accepted: 2026-05-05
Notes: All matches resolve under `config/vim/extra/fzf/**`,
`config/vim/plugged/**`, or `node_modules/**` — none of which is
tracked by git. Updates flow through the upstream tool chain
(yarn, vim-plug, fzf submodule sync). Re-running grype after a
`yarn install` / `vim +PlugUpdate` sweep will refresh the report.

#### [SEC-003] Heavy SAST tools (semgrep, opengrep, snyk, checkov) deferred
Accepted: 2026-05-05
Notes: Deferred to a future security-auditor pass with tighter
rule sets configured. Opening the report to whole-tree
shell/lua/fish/toml SAST without scoping floods low-signal
matches.

## Invalid

_(none — first pass)_
