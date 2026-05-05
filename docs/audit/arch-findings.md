# Architecture Audit Findings

Generated: 2026-05-05
Last validated: 2026-05-05

## Summary

- Total: 2 | Open: 0 | Fixed: 2 | Invalid: 0
- Pass 1 fixes applied: 2026-05-05.

Audited against `docs/audit/arch-profile.md` (Pass 1, 2026-05-05).
The 8 inferred structural rules were validated; 2 violations found.
Theme-orchestrator extension contract (rule 1), host-overlay
secrets policy (rule 4), submodule boundary (rule 5), helper-script
location (rule 6), per-app config layout (rule 7), and bats test
location (rule 8) all pass.

## Open Findings

_(none)_

## Fixed

### Pass 1 — 2026-05-05

#### [A-001] Host-specific exports leak into shared `config/` tree
Fixed: 2026-05-05
Notes: `git mv config/exports-lakka hosts/lakka/config/exports-lakka`.
The host-overlay link block in `hosts/lakka/install.conf.yaml`
already symlinks `hosts/lakka/config/**` to `~/.config/`, so the
hostname-suffix dispatch in `config/exports:618-623` keeps working
unchanged on the lakka host. The two stale `# shellcheck source=`
hints in `config/exports` were also updated to `source=/dev/null`
(the relative path no longer resolves) and a comment now explains
the dispatch.

#### [A-002] `palettes.d/dircolors.{dark,light}` lack extension
Fixed: 2026-05-05
Notes: Resolved by softening rule 2 in `arch-profile.md` —
extension is now required only when the consuming format expects
one (`.toml`, `.conf`, `.yml`); formats with no canonical
extension (dircolors) may omit it. The dircolors handler at
`config/theme/handlers.d/dircolors:14` is recorded as the one
current exception. No file rename needed.

## Invalid

_(none — first pass)_
