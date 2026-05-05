# Documentation Audit Findings

Generated: 2026-05-05
Last validated: 2026-05-05

## Summary

- Total: 4 | Open: 0 | Fixed: 4 | Invalid: 0
- Pass 1 fixes applied: 2026-05-05.

Sources scanned: `README.md`, `docs/folders.md`, `docs/alias.md`,
`docs/findings-todo.md`, `docs/commands.md`, `docs/*-keybindings.md`,
`hosts/README.md`, `local/bin/README.md`. Submodule READMEs
(`tools/dotbot`, `tools/antidote`, `tools/dotbot-include`) skipped
as out-of-repo content. Plan files under `docs/plans/` and
`docs/superpowers/` skipped as historical records.

## Open Findings

_(none)_

## Fixed

### Pass 1 — 2026-05-05

#### [DOC-001] `README.md` documents non-existent `dfm docs` subcommands
Fixed: 2026-05-05
Notes: Replaced the stale `dfm docs alias/folders/keybindings/all`
list with the actual subcommands `dfm docs {all|tmux|nvim|wezterm}`.
Added a sentence noting the alias/folder/command-catalogue docs
are maintained directly rather than via `dfm`.

#### [DOC-002] `docs/findings-todo.md` was a pre-audit-framework findings dump
Fixed: 2026-05-05
Notes: Triaged all 10 entries against current code:
- 9 already-resolved (initialised pushover vars; CURL check moved
  to script top; `[ ! -d ]` guard in x-backup-folder; `[ ! -f ]`
  guard in x-change-alacritty-theme; mysqldump word-splitting via
  `# shellcheck disable=SC2046`; `brew list ... || true` in
  x-set-php-aliases; single yq parse path in x-env-list;
  `quota <= 0` continue in x-quota-usage.php; eval in x-foreach
  accepted with shellcheck-disable + comment).
- 1 still open (x-compare-versions.py empty stdin returning 0)
  fixed in this same pass via `if len(words) < 3: return False`;
  recorded as N-069 in `nitpicker-findings.md`.
File deleted; `docs/audit/` is the single source of truth.

#### [DOC-003] `README.md` claimed `local/` maps to "bin, share and state"
Fixed: 2026-05-05
Notes: Changed the table cell to `bin, share and man`, matching
`install.conf.yaml`.

#### [DOC-004] Hostname-suffixed exports pattern undocumented
Fixed: 2026-05-05
Notes: Added a paragraph to CLAUDE.md "Host-specific Configs"
section explaining the dispatch in `config/exports:618-623` and
naming the canonical home for the files
(`hosts/<hostname>/config/exports-<hostname>`). Updated the two
`# shellcheck source=./exports-lakka(-secret)?` hints to
`source=/dev/null` since the moved file is no longer a sibling.

## Invalid

_(none — first pass)_
