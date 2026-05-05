# Nitpicker Findings

Generated: 2026-04-26
Last validated: 2026-05-05
Pass 6 fixes applied: 2026-05-05
Scope of latest round (Pass 6): focused audit of sesh configuration —
`config/sesh/sesh.toml`, `config/tmux/sesh.sh`, and
`config/fish/completions/sesh.fish`. Re-validated prior open findings (0
real-Open at entry; N-013/N-020/N-056 remain under Advisory). Filed 7
new defects (N-057..N-063); fixed 5 (N-057, N-058, N-060, N-061, N-062);
ruled 2 Invalid (N-059, N-063) per maintainer judgment.
Scope of previous round (Pass 5): `.github/` folder and `.github/README.md` audit
run on main at bec6529. Re-validated prior findings (0 open at entry). Read all
workflow YAML files, `tag-changelog-config.js`, `renovate.json`, `copilot-instructions.md`,
`SECURITY.md`, `CODE_OF_CONDUCT.md`, `CODEOWNERS`, and `.github/README.md`.
Filed 14 new defects (N-043..N-056): missing `labels.yml`, debug-named production
workflow, absent submodule-init step in setup guide, shell injection in echo step,
wrong timezone comment, unpinned pre-commit, unmanaged stylua version, token spacing
inconsistency, noisy changelog exclusion list, sparse security policy, non-standard
README location, and three advisory items.
Scope of previous round (Pass 4): nvim-focused audit run on main at 00357dc.
Re-validated prior findings (0 open at entry). Read every Lua source under
`config/nvim/`, sampled `lsp/*.lua` server defs, ran headless nvim probes
to verify behaviour. Filed and fixed 9 new defects (N-034..N-042) covering
stale documentation, never-set nerd-font globals, mini.sessions pollution
on `--headless` invocations, dead LSP config, misleading comments, bogus
opts_extend path, alt-buffer error in `<leader>ba`, duplicate plenary spec,
and PATH-prepend duplication on `:source $MYVIMRC`. No Critical findings.
Scope of previous round (Pass 3): N-010 closed by theme orchestrator.
Scope of round before that (Pass 2): default-mode full-repo audit run on
feat/theming-and-switching at 88b74c2. Re-validated all prior findings,
hunted for new defects across mise/, scripts/, local/bin/, fish, neovim,
tests, and CI. Filed and fixed 7 new defects (N-023..N-029). Recorded
4 sub-agent claims as Invalid after verification (N-030..N-033).

## Summary

- Total: 68 | Open: 0 | Fixed: 57 | Advisory: 3 | Invalid: 8

Pass 8 (2026-05-05): closed N-068 by running the four prerequisite
audit skills (`arch-detector`, `arch-auditor`, `security-auditor`,
`doc-auditor`); also fixed N-069 (still-open issue triaged from
the now-deleted `docs/findings-todo.md`).

## Open Findings

_(none)_

## Advisory

#### [N-013] WezTerm Wayland appearance detection depends on xdg-desktop-portal version
No change. If wezterm colors don't update on Linux, check wezterm version
(>= 20240203-110809) and that `xdg-desktop-portal` is running.

#### [N-020] oh-my-posh runtime still installed via mise
No change in repo — manual `mise uninstall oh-my-posh` reclaims disk space.
The repo no longer references it, so it won't be reinstalled.

#### [N-056] `tag-changelog-config.js` `renderChangelog` uses wall-clock date, not tag date
Area: `.github/tag-changelog-config.js`
`new Date()` is called at render time. Backfilled or re-triggered releases will
carry the current date, not the original tag date. A comment was added to document
the limitation. Full fix requires passing the tag date from the calling workflow.

## Fixed

### Pass 9 — 2026-05-05

#### [N-070] `config/exports` lost shellcheck source-following hint after A-001 file move
Fixed: 2026-05-05
Notes: Replaced both `# shellcheck source=/dev/null` directives in
`config/exports:620, 622` with the correct relative paths
(`../hosts/lakka/config/exports-lakka` and
`../hosts/lakka/config/exports-lakka-secret`). shellcheck now
follows into the moved files for variable analysis.

#### [N-071] Rules-lint and audit-findings-lint hooks false-positive on backtick / code-block content
Fixed: 2026-05-05
Notes: Both hooks now pre-filter the input through awk: fenced
code blocks (`\`\`\` ... \`\`\``) are stripped, and inline
backtick-wrapped tokens (`\`...\``) are removed from prose lines
before pattern matching. Verified with four regression tests:
- rule body `Never use the word \`consider\` in rule prose` →
  exit 0 (was exit 2)
- bare `Always try to be careful` → still exit 2
- hedge inside a fenced code block → exit 0 (was exit 2)
- real `## Open Findings` duplicate → still exit 2

### Pass 8 — 2026-05-05

#### [N-068] Three audit-artifact prerequisites absent
Fixed: 2026-05-05
Notes: Closed by running `arch-detector`, `arch-auditor`,
`security-auditor`, and `doc-auditor` end-to-end. All four
artifacts now exist in `docs/audit/`. Their findings have been
triaged and applied in this same Pass-8 sweep (see
arch-findings.md, security-findings.md, and doc-findings.md
Pass 1 entries; claude-rules-auditor-findings.md Pass 4 entry
for CR-005 close).

#### [N-069] `x-compare-versions.py` empty-stdin returned silent success
Fixed: 2026-05-05
Notes: Pre-audit-framework finding from `docs/findings-todo.md`
(MEDIUM, "Empty stdin input returns exit 0 (silent pass)").
Triaged during Pass 4 of `claude-rules-auditor` (DOC-002 fix). Added
`if len(words) < 3: return False` at the top of `vercmp` in
`local/bin/x-compare-versions.py:27`. Empty or short input now
exits non-zero, matching the function's documented contract.

The other 9 entries in `docs/findings-todo.md` were verified as
already-resolved in current code (initialised vars in pushover,
moved CURL check, added directory/theme-file existence guards,
mysqldump word-splitting via `# shellcheck disable=SC2046`,
`brew list ... || true` for php-aliases, single yq parse path in
x-env-list, `quota <= 0` continue in quota-usage.php) or accepted
with a `# shellcheck disable` justification (the x-foreach eval).
`docs/findings-todo.md` deleted; `docs/audit/` is now the single
source of truth for findings.

### Pass 7 — 2026-05-05

#### [N-064] `nitpicker-findings.md` has two `## Invalid` h2 sections
Fixed: 2026-05-05
Notes: Pre-existing structural defect from Pass 2. The misplaced
Pass-2 fixed block (N-023..N-029, originally nested under the first
`## Invalid` header) was relocated under `## Fixed` with its own
`### Pass 2` heading, and the duplicate `## Invalid` h2 at the old
line 596 was removed. Pass-2 invalid entries (N-030..N-033) and the
Pass-5 invalid (N-054) now share the single `## Invalid` h2.
Verified by `grep -nE "^## (Open|Fixed|Invalid|Advisory)"` — one
Invalid header at line 325.

#### [N-065] `CLAUDE.md` Vendor-file bullet duplicates the migrated rule's imperative
Fixed: 2026-05-05
Notes: Reworded the bullet at `CLAUDE.md:180-181` from "Do not modify
(`.claude/rules/vendored-files.md`)." to "Edit policy:
`.claude/rules/vendored-files.md`." The imperative now lives only in
the rule file.

#### [N-066] `CLAUDE.md` "## Package Manager" was a 1-line stub after migration
Fixed: 2026-05-05
Notes: Removed the entire `## Package Manager` section (was 3 lines
including heading and blank line). The no-npm mandate lives in
`.claude/rules/no-npm.md`; CLAUDE.md no longer needs a pointer
section for it. CLAUDE.md root drops to ~227 lines.

#### [N-067] `config/tmux/sesh.sh` kept fzf-tmux in the cascade where it was unreachable
Fixed: 2026-05-05
Notes: Removed `pick_with_fzf_tmux` and its cascade branch entirely.
Cascade is now `gum → fzf → select`. Top-of-file comment block
explains why fzf-tmux was excluded (popup nesting). Verified with
`bash -n` and `shellcheck` — both clean.

### Pass 6 — 2026-05-05

#### [N-057] Picker cascade prefers gum over fzf-tmux, losing rich UI
Fixed: 2026-05-05
Reverted: 2026-05-05
Notes: Initial fix reordered the cascade to fzf-tmux → fzf → gum → select.
This broke the picker entirely. Root cause missed during the original
audit: `sesh.sh` is bound to `prefix + t` via `tmux display-popup -E`
in `config/tmux/tmux.conf:96`, so by the time the script runs it is
already inside a tmux popup. `fzf-tmux -p` then tries to open a second
popup, which tmux does not support. gum filter renders inline inside
the existing popup, which is why the original ordering put it first.
Reverted the cascade and added an explanatory comment block at the
top of `sesh.sh` documenting the popup-nesting constraint. The
finding is reclassified as **Invalid** below — see Pass 6 Invalid.

#### [N-058] `Downloads` startup_command `lsa` is fish-only
Fixed: 2026-05-05
Notes: Added `alias lsa="ls -lah"` to `config/alias` (line 46), which
is sourced by both `base/bashrc` and `base/zshrc` via
`config/shared.sh`. Now resolves in fish (existing function),
bash, and zsh.

#### [N-060] `~/Code/**` wildcard runs `git status` in non-git org dirs
Fixed: 2026-05-05
Notes: `startup_command` in the `~/Code/**` wildcard now guards with
`git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git status || true`.
Top-level org directories stay quiet; real repos still get the git
status banner.

#### [N-061] `pick_with_gum` uses `-i`; rest of file uses `--icons`
Fixed: 2026-05-05
Notes: Changed `sesh list -i` → `sesh list --icons` on
`config/tmux/sesh.sh:19` for consistency with the six other call sites.

#### [N-062] `config/fish/completions/sesh.fish` lacks provenance / regen comment
Fixed: 2026-05-05
Notes: Added a 3-line header marking the file as auto-generated by
`sesh completion fish` and documenting the regen command.

### Pass 5 — 2026-04-30

#### [N-043] `sync-labels.yml` watched `.github/labels.yml` which did not exist
Fixed: 2026-04-30
Notes: Removed `.github/labels.yml` path from the `push:` trigger in `sync-labels.yml`.
The path trigger was a dead branch since the file was never present; the schedule and
`workflow_dispatch` triggers are unaffected.

#### [N-044] `changelog.yml` named "Debug Changelog" in production
Fixed: 2026-04-30
Notes: Deleted `.github/workflows/changelog.yml` entirely. The file was a
`workflow_dispatch`-only debug artifact that echoed changelog output to the
Actions log. No other workflow referenced it.

#### [N-045] First-time setup omitted `git submodule update --init --recursive`
Fixed: 2026-04-30
Notes: Added `git submodule update --init --recursive` as step 2 (before `./install`)
in the First-time setup section of `README.md`. Also applies to the now-deleted
`.github/README.md`.

#### [N-046] `changelog.yml` echo step injected expression directly into shell
Fixed: 2026-04-30
Notes: Closed by deletion of `changelog.yml` (N-044). No separate change needed.

#### [N-047] `new-release.yml` cron comment wrong in winter
Fixed: 2026-04-30
Notes: Updated comment on `new-release.yml` line 8 from
`# 00:00 at Europe/Helsinki` to `# 00:00 EEST (summer, UTC+3) / 23:00 EET (winter, UTC+2)`.

#### [N-048] `pre-commit-autoupdate.yml` unpinned pre-commit version
Fixed: 2026-04-30
Notes: Changed `pip install pre-commit` to `pip install pre-commit==4.2.0` in
`pre-commit-autoupdate.yml`, matching the version pinned in `copilot-setup-steps.yml`.

#### [N-049] stylua version hardcoded without Renovate tracking
Fixed: 2026-04-30
Notes: Added `# renovate: datasource=github-releases depName=JohnnyMorganz/StyLua`
annotation comment above `STYLUA_VERSION="2.4.1"` in `copilot-setup-steps.yml`.
Effective if `ivuorinen/renovate-config` enables a matching `regexManagers` pattern.

#### [N-050] `update-submodules.yml` token expression missing spaces
Fixed: 2026-04-30
Notes: Changed `${{secrets.GITHUB_TOKEN}}` to `${{ secrets.GITHUB_TOKEN }}` on
`update-submodules.yml` line 31, consistent with all other workflow files.

#### [N-051] `tag-changelog-config.js` `excludeTypes: []` surfaces style/test noise
Fixed: 2026-04-30
Notes: Set `excludeTypes: ['style', 'codestyle', 'lint', 'test', 'tests']`.
`chore`, `ci`, and `build` are intentionally retained (user preference).

#### [N-052] `SECURITY.md` provided no response SLA
Fixed: 2026-04-30
Notes: Added a paragraph committing to 7-day acknowledgement, 30-day resolution
target, and 14-day public disclosure permission if no response.

#### [N-053] Root `README.md` absent; canonical README was in `.github/`
Fixed: 2026-04-30
Notes: Created `README.md` at repository root with updated image paths
(`.github/screenshots/...` instead of `./screenshots/...`). Deleted
`.github/README.md` to eliminate the duplicate.

#### [N-055] `copilot-instructions.md` hardcoded host list would become stale
Fixed: 2026-04-30
Notes: Replaced the explicit host name list in `copilot-instructions.md` with
`run \`ls hosts/\` for current list`, removing the stale-on-update risk.

### Pass 2 — 2026-04-27

#### [N-023] Wrong mise schema URL (typo)
Fixed: 2026-04-27
Notes: `config/mise/config.toml:1` had
`#:schema https://mise.en.dev/schema/mise.json`. The actual mise docs domain
is `mise.jdx.dev` (cross-referenced by the repo's own
`docs/superpowers/plans/2026-04-12-mise-python-precompiled-arch.md`). The
broken URL silently no-ops in editors that respect `#:schema`, so schema
validation never fired. Fixed to `https://mise.jdx.dev/schema/mise.json`.

#### [N-024] `install-composer.sh` leaked files in cwd on installer failure under `set -e`
Fixed: 2026-04-27
Notes: With `set -euo pipefail`, a non-zero exit from
`php composer-setup.php --quiet` aborted the script before reaching the
cleanup `rm composer-setup.php` and the `mv composer.phar` lines. Net result:
`composer-setup.php` and possibly a partial `composer.phar` were left in the
caller's cwd. The `RESULT=$?` capture and the `if [[ $RESULT -eq 0 ]]; then mv...`
branch was also dead code under `set -e` — `RESULT` could only ever be 0 by
the time the if ran. Rewrote to `cd "$(mktemp -d)"` with `trap 'rm -rf "$tmpdir"' EXIT`
and dropped the dead `RESULT` plumbing. Also added `mkdir -p ~/.local/bin`
so the final `mv` doesn't fail on a fresh box.

#### [N-025] `x-ssl-expiry-date` lacked signal-based tmp file cleanup
Fixed: 2026-04-27
Notes: `local/bin/x-ssl-expiry-date` only removed its `mktemp` on the
success path or on openssl failure. SIGINT / SIGTERM / SIGHUP between the
mktemp and the `rm -f` left the temp file under `/tmp` (or `$TMPDIR`).
Added `trap 'rm -f "$tmp"' EXIT INT TERM HUP` after mktemp and a
`trap - EXIT INT TERM HUP` after the explicit rm so the trap doesn't
re-fire on the next loop iteration's mktemp.

#### [N-026] `config.fish` PATH append for LM Studio inconsistent and dedup-broken
Fixed: 2026-04-27
Notes: Line 59 was `set -gx PATH $PATH $HOME/.lmstudio/bin` (raw append).
Two practical issues: (a) APPENDS rather than prepending, so a system
binary by the same name would shadow the user one; (b) re-sourcing
config.fish duplicated the entry. Replaced with
`fish_add_path $HOME/.lmstudio/bin`, matching the same idiom used at
line 65 for opencode. `fish_add_path` defaults to prepending and dedupes.

#### [N-027] `handleDesc` mutated caller's table when `desc` lacked `desc` key
Fixed: 2026-04-27
Notes: `config/nvim/lua/utils.lua` had
`if not desc.desc then desc.desc = '?'; return desc end` — mutating the
caller's table. Concrete failing scenario: a user passes a shared opts
table to `K.n('a', cmdA, opts)` then `K.n('b', cmdB, opts)`; after the
first call `opts.desc == '?'`, so the second call sees a populated `desc`
and skips adding its own. Switched to
`return vim.tbl_extend('force', desc, { desc = '?' })` so the function
returns a clone with the default added. Caller's table is left intact.

#### [N-028] `pushover.bats` did not assert that the curl stub was invoked
Fixed: 2026-04-27
Notes: `tests/pushover.bats` only checked `[ "$status" -eq 0 ]`. The stub
returned a JSON success regardless of arguments, so a regression that
short-circuited and never called curl would still pass. Made the stub
`touch "$STUB_DIR/curl.called"` and added
`[ -f "$STUB_DIR/curl.called" ]` to both success-path tests. Verified by
running the full bats suite — all five tests still pass.

#### [N-029] `tests/x-foreach.bats` cleanup leaked tmp dirs on test failure
Fixed: 2026-04-27
Notes: The original test had inline `tmpdir=$(mktemp -d)` and inline
`rm -rf "$tmpdir"` at end of test. If any assertion in between failed,
bats aborts the test before the `rm -rf` runs, leaking the tmp dir under
`/tmp`. Extracted into bats `setup()` / `teardown()` (named `TMPDIR_TEST`
to avoid colliding with the standard `TMPDIR` env var). Bats guarantees
`teardown()` runs even on assertion failure.

## Invalid

### Pass 6 — 2026-05-05

#### [N-057] Picker cascade prefers gum over fzf-tmux, losing rich UI
Notes: Original premise wrong. The cascade prefers gum because
`sesh.sh` is invoked via `tmux display-popup -E`, and `fzf-tmux -p`
cannot nest another popup inside the existing one. gum filter renders
inline and is the only rich-ish picker that works in this context.
The "rich UI" the original finding lamented (preview, ctrl-a/t/g/x/f/d
binds) is reachable only by running the script outside a popup — and
the cascade still falls through to fzf-tmux/fzf there. No defect.

#### [N-059] Host-specific SSH targets and personal paths in shared config
Notes: Maintainer ruling — these dotfiles are personal, not a public
template. The SSH FQDNs (`air.local`, `baal.antiprocess.net`,
`purson.antiprocess.net`) and the `Code/ivuorinen` path describe the
owner's own infrastructure on the owner's own repo. No fork
isolation or recon concern applies. Kept in the shared
`config/sesh/sesh.toml`.

#### [N-063] `pick_with_select` uses `mapfile` (bash 4+)
Notes: Maintainer ruling — bash 4 is installed via Homebrew on every
machine the owner provisions, so the bash-3.2 fallback path is
unreachable in practice. The `mapfile` line is left as-is.

### Pass 4 — 2026-04-28

#### [N-034] config/nvim/CLAUDE.md is multiply stale

Fixed: 2026-04-28
Notes: Rewrote three sections to match the current code. Plugin Files
table now lists the 8 files actually present (`completion`, `editor`,
`lsp`, `navigation`, `qa`, `tools`, `treesitter`, `ui`) with accurate
purpose blurbs — `qa.lua` not `conform.lua`; `navigation.lua` is just
telescope+trouble (neo-tree gone, mini.files replaces it; stickybuf gone,
replaced by the `winfixbuf` autogroup); `ui.lua` lists render-markdown
not the never-installed fff; `tools.lua` lost its plenary spec.
Leader Key Groups table replaced with the 10 prefixes mini.clue actually
declares: added `q` (Quit), `cb` (CommentBox), `cc` (Calls), `tm`
(Toggle Options); removed phantom `<leader>a` (Automation) and
`<leader>z` (TreeSitter) — runtime probe found 0 mappings under either.
LSP Architecture rewritten to clarify that `vim.lsp.config('*', ...)`
and `vim.lsp.enable {...}` live in `init.lua`, not `lsp.lua`, and that
`lazydev.nvim` is not installed (lsp/lua_ls.lua sets workspace.library
and diagnostics.globals manually). Documented that fish_lsp and taplo
come from mise, not mason.

#### [N-035] vim.g.have_nerd_font / vim.g.nerd_font_variant never set

Fixed: 2026-04-28
Notes: Added explicit `g.have_nerd_font = true` and
`g.nerd_font_variant = 'mono'` near the top of `lua/options.lua`.
Concrete failing scenario before fix: `lua/autogroups.lua:105-112` had
`vim.g.have_nerd_font and {...} or {}`, so with the global nil the
diagnostic config used `signs = {}` — empty signcolumn for diagnostics.
Likewise `lua/plugins/completion.lua:17` always fell back to `'mono'`
regardless of intent. Verified post-fix via headless probe: diagnostic
`signs.text[ERROR]` is now `󰅚` (nerd-font glyph) instead of nil.

#### [N-036] mini.sessions auto-write fires on --headless invocations

Fixed: 2026-04-28
Notes: Gated both the VimEnter session-read and the VimLeavePre
session-write callbacks in `lua/plugins/editor.lua` on
`#vim.api.nvim_list_uis() > 0`. Concrete evidence before fix:
`~/.local/share/nvim/sessions/` had 31 entries including short-lived
directories the user never intentionally saved (e.g. one-off Code/*
dirs). Headless probes during the audit visibly created session files,
seeing `(mini.sessions) Written session …` in stdout. Verified post-fix:
`nvim --headless -c qall` exits with no session message and writes no
new session file.

#### [N-037] LSP enable list out of sync with mason ensure_installed and lsp/*.lua

Fixed: 2026-04-28
Notes: Removed `lsp/ast_grep.lua` (LSP config that was registered but
never enabled in `init.lua`'s `vim.lsp.enable {...}` list) and
`'ast-grep'` from mason `ensure_installed` in `lua/plugins/lsp.lua` (no
longer needed for the LSP path; ast-grep can be reinstalled via mise or
brew if wanted as a standalone CLI). Added a comment to the
`ensure_installed` block stating that servers enabled in `init.lua` but
absent from the list (`fish_lsp`, `taplo`) come from mise. Verified
post-fix: `vim.lsp.config.ast_grep` is now nil and the enabled-server
count is unchanged at 18.

#### [N-038] LSP capability map only handles 2 of 4 default keys; comment lies

Fixed: 2026-04-28
Notes: Rewrote the comment block above `lsp_method_map` in
`lua/autogroups.lua` to be honest: only the *less-universal* methods
(textDocument_typeDefinition / `grt`, textDocument_implementation /
`gri`) need the capability check, because references (`grr`) and code
action (`gra`) are supported by virtually every LSP. The map itself is
unchanged — the prior comment incorrectly implied all four nvim-0.11
defaults were wrapped.

#### [N-039] completion.lua opts_extend references non-existent path

Fixed: 2026-04-28
Notes: Removed the
`opts_extend = { 'sources.completion.enabled_providers' }` line from
`lua/plugins/completion.lua`. Runtime probe confirmed blink.cmp has no
`sources.completion` table — the actual default-source list is at
`sources.default`. The directive was a silent no-op. No alternate spec
extends blink.cmp's source list, so the line was pure dead code.

#### [N-040] keymaps.lua <leader>ba errors when no alternate buffer

Fixed: 2026-04-28
Notes: Replaced `vim.cmd '%bd|e#|bd#'` in `lua/keymaps.lua` with an
explicit loop that walks `vim.api.nvim_list_bufs()` and deletes every
loaded buffer except the current one, each delete wrapped in `pcall`
so an unsavable modified buffer doesn't abort the rest. Failing scenario
before fix: `nvim foo.txt` then `<leader>ba` → `E194: No alternate file
name to substitute for '#'` after `%bd` removed the only buffer.
Single-buffer state is now a no-op. Verified via headless probe: the
mapping callback returns `true` (no error) on a fresh nvim.

#### [N-041] tools.lua duplicate plenary.nvim spec

Fixed: 2026-04-28
Notes: Removed the standalone `nvim-lua/plenary.nvim` spec from
`lua/plugins/tools.lua` — telescope already pulls it in transitively
via its `dependencies` table in `lua/plugins/navigation.lua`. Replaced
with a one-line comment so a future reader doesn't re-add it. Verified
via headless probe: `require 'plenary'` still resolves cleanly.

#### [N-042] init.lua PATH prepend duplicates entries on :source $MYVIMRC

Fixed: 2026-04-28
Notes: Wrapped the prepend in `lua/init.lua` in a local
`_path_prepend(p)` helper that skips when `p` is already in
`vim.env.PATH`. Each candidate path is now checked before being
prepended. Verified via headless probe: `:source $MYVIMRC` followed by
the original PATH length comparison shows growth of 0 chars (was
previously growing by ~70 chars per re-source).

### Pass 3 — 2026-04-27

#### [N-010] No verification scenario for fish-without-tmux (wezterm direct)

Fixed: 2026-04-27
Notes: Replaced by the theme orchestrator. The watcher daemon is spawned
from shell init (any flavour, with `_acquire_lock` ensuring single-instance),
so fish-without-tmux now gets live OS-driven updates. SSH sessions skip
the spawn and rely on per-session OSC 11 via `theme-mode`. The "chain
requires tmux" CLAUDE.md note has been removed.

### Pass 1 — 2026-04-26

#### [N-001] macOS has no continuous appearance watcher
Fixed: 2026-04-26
Notes: Created `config/tmux/macos-dark-notify.sh` polling
`defaults read -g AppleInterfaceStyle` every 2s in a daemon mirroring
`linux-dark-notify.sh`'s lifecycle (per-tmux-socket lock file, nohup
backgrounding, SIGTERM/SIGINT/SIGHUP cleanup). Wired in `tmux.conf` after
`linux-dark-notify.sh`. Both daemons exit silently on non-matching platforms.
Theme-resolution and symlink-update logic extracted into
`config/tmux/_apply-theme.sh` (sourced library) so both daemons share
behaviour with `theme-activate.sh`. Toggling System Settings → Appearance on
macOS now flips wezterm + tmux + starship within ~2s of detection.

#### [N-002] Bash had no light/dark theme reaction
Fixed: 2026-04-26
Notes: Replaced hardcoded ANSI `PS1` in `base/bashrc` with `eval "$(starship init bash)"`.

#### [N-003] Zsh had no light/dark theme reaction
Fixed: 2026-04-26
Notes: Replaced p10k sourcing in `base/zshrc` with starship init. Removed
`romkatv/powerlevel10k` from antidote plugins and deleted `config/zsh/p10k.zsh`.

#### [N-004] `set -o errexit` in dark-notify daemon could be killed by transient `tmux source-file` failure
Fixed: 2026-04-26
Notes: `apply_theme` (now in `config/tmux/_apply-theme.sh`) wraps
`tmux source-file "$theme_path" 2>/dev/null || true` so a transient tmux
server failure no longer terminates the daemon. The inner `read` loop in
`linux-dark-notify.sh` and `macos-dark-notify.sh` also wraps the
`apply_theme` call with `|| true`. Removed `set -o errexit` from the daemon
top-levels (the original reason for the wrap is now belt-and-braces).

#### [N-005] oh-my-posh half-wired
Fixed: 2026-04-26
Notes: Removed omp wiring from `config/exports`, `config/mise/config.toml`,
and deleted `config/omp/`.

#### [N-006] Fish handler swallowed first symlink-creation event
Fixed: 2026-04-26
Notes: Removed the `__theme_switch_initialized` guard from
`config/fish/conf.d/theme-switch.fish`. The handler now always re-saves on
the first observed symlink target, eliminating the fish-then-tmux ordering
edge case. Cost is one extra `fish_config theme save` fork per fish session
— negligible.

#### [N-007] `theme-activate.sh` and dark-notify daemons raced on first tmux launch
Fixed: 2026-04-26
Notes: Both `linux-dark-notify.sh` and `macos-dark-notify.sh` now check
`[[ ! -L "$THEME_LINK" ]]` before their initial `apply_theme`. If
`theme-activate.sh` already ran during config load, the symlink exists and
the daemon skips its redundant initial apply.

#### [N-008] `ivuorinen/tmux-dark-notify` plugin declared but not installed
Fixed: 2026-04-26
Notes: Removed `set -g @plugin 'ivuorinen/tmux-dark-notify'` and the
`@dark-notify-theme-path-{light,dark}` options from `config/tmux/tmux.conf`.
Theme paths are hardcoded in the new `_apply-theme.sh` library. Daemon
ownership is now unambiguous: dotfiles own the chain end-to-end via the
two daemons + library.

#### [N-009] `theme-activate.sh` rewrote symlinks unconditionally
Fixed: 2026-04-26
Notes: `_apply-theme.sh` provides `_idempotent_ln_sf` which only calls
`ln(1)` when `readlink` shows the target actually changed. Both the tmux
state symlink and the starship symlink go through this helper. `prefix+r`
no longer churns symlink mtimes.

#### [N-011] `set -Ugq` flag in theme-{light,dark}.conf required tmux ≥ 3.4
Fixed: 2026-04-26
Notes: Added inline comment in both `config/tmux/theme-{light,dark}.conf`
documenting the tmux ≥ 3.4 requirement and what happens on older tmux
(parser silently ignores `-U`, leaving stale colors).

#### [N-012] Misleading "Setting up oh-my-posh configuration" log
Fixed: 2026-04-26
Notes: Subsumed by N-005.

#### [N-014] Starship bootstrap created broken symlinks on fresh installs
Fixed: 2026-04-26
Notes: `config/exports` bootstrap now (a) requires `[ -f "$default" ]` before
linking, so it never creates a brand-new broken symlink; and (b) detects an
existing broken symlink (`[ -L ] && [ ! -e ]`) and repairs it. Verified
end-to-end: missing source → bootstrap skips; source then created → bootstrap
links; source removed → broken symlink → bootstrap repairs on next shell start.

#### [N-016] Dead `autoload -U promptinit; promptinit` in `base/zshrc`
Fixed: 2026-04-26
Notes: Removed line 7. zsh's promptinit framework is unused; starship owns
the prompt entirely.

#### [N-017] Orphan `oh-my-posh.png` in `.github/screenshots/`
Fixed: 2026-04-26
Notes: `git rm .github/screenshots/oh-my-posh.png`. README reference was
already removed in the previous round.

#### [N-018] Starship dark/light TOMLs duplicated module config
Fixed: 2026-04-26
Notes: Strengthened the maintainer-note header in both
`config/starship/starship-{dark,light}.toml` so future editors see the
sync-required convention immediately. A generator script was deferred —
the divergence risk is intentionally cosmetic and the comment is sufficient
for a config-file pair this small.

#### [N-021] `_idempotent_ln_sf` clobbered regular files at the destination
Fixed: 2026-04-26
Notes: Added a guard to `_idempotent_ln_sf` in `config/tmux/_apply-theme.sh`:
if the destination is a regular file (not a symlink), the helper returns
early instead of replacing it with `ln -sf`. Reproduced before fix: a
hand-rolled `~/.config/starship.toml` with custom content was silently
destroyed on the next theme flip. Reproduced after fix: the regular file
is preserved across daemon invocations; a working symlink is still
left alone (mtime unchanged); a broken symlink is still repaired.

#### [N-022] Dangling `@` separator when username shows but hostname doesn't
Fixed: 2026-04-26
Notes: Username had `format = "[$user]($style)[@](subtext0)"` which
emitted `user@` even when the hostname module was suppressed (running
as root locally with no SSH). Moved the `@` separator into the hostname
format: `format = "[@](subtext0)[$hostname]($style) "`. Now the `@`
only renders when the hostname does. Username keeps just `[$user]($style)`.
Applied to both starship-dark.toml and starship-light.toml.


### Pass 2 — 2026-04-27

#### [N-030] (Rejected) "GitHub token in tracked exports-secret.fish"
Notes: Sub-agent flagged a Critical "exposed token in tracked file"
during the Pass-2 fish audit. Verified false: `.gitignore` lines 19 and
32 explicitly exclude `**/exports-secret.fish` and
`config/fish/secrets.d/*` (with allowlist for `*.example` and
`README.md`). `git ls-files | grep -i secret` returns only the
`*.example` files and `secrets.d/README.md`. The actual secret file is
a local untracked file used per the design described in CLAUDE.md.

#### [N-031] (Rejected) "set -gx in fish leaks across sessions universally"
Notes: Sub-agent flagged Critical based on a misreading of fish scopes.
`set -gx` creates a global, exported variable scoped to the current
shell session. Universal would be `set -Ux` (different flag). Verified
against fish documentation. Was a real (low-severity) issue with the
specific PATH-append pattern at config.fish line 59 — captured under
N-026 with correct severity (Low) and correct rationale (dedup +
ordering, not session leak).

#### [N-032] (Rejected) "fish_add_path appends instead of prepending"
Notes: Sub-agent claimed `fish_add_path` puts user paths after system,
shadowing user binaries. Verified false against fish's own
`functions -d fish_add_path` output: "It defaults to keeping
$fish_user_paths or creating a universal, prepending and ignoring
existing entries." `fish_add_path` prepends by default. The append
behaviour requires the explicit `--append` flag.

#### [N-033] (Rejected) "GitHub Actions workflows missing top-level permissions: blocks"
Notes: Sub-agent flagged 7 of 8 workflows as missing top-level
`permissions:`. Verified false. All 8 workflows under `.github/workflows/`
have a top-level `permissions:` block within the first 20 lines of the
file (verified by `head -20 *.yml | grep -L '^permissions:'`). The
sync-labels.yml file does have it at line 22. Per-job permissions are
correctly used to elevate only where needed (e.g. issues: write).

### Pass 5 — 2026-04-30

#### [N-054] (Rejected) "`renovate.json` extends only external private config"
Notes: Finding assumed `local>ivuorinen/renovate-config` was a dependency risk.
Confirmed by user: `ivuorinen/renovate-config` is the owner's own repository,
intentionally shared across many repos as a centralised Renovate baseline.
This is by design, not a fragility.
