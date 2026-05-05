# Claude Rules Audit Findings

Generated: 2026-05-05
Last validated: 2026-05-05
Pass 3 — 2026-05-05: re-validated 11 rule files; both CLAUDE.md
files clean (194 + 164 lines, no atomic mandates remaining). Filed
2 new defects (CR-010, CR-011): wrong path entry in
`shell-scripts.md`; secrets-files.md wording narrower than
.gitignore policy.
Pass 2 — 2026-05-05: filed and fixed 4 defects (CR-006..CR-009)
plus 1 suggestion (CR-110); created 4 new rule files; root
CLAUDE.md down to 194 lines.

## Summary

- Rules files audited: 12 (`.claude/rules/`)
- CLAUDE.md files audited: 2 (`CLAUDE.md` 194 lines, `config/nvim/CLAUDE.md` 164 lines)
- Validation errors: 0 | Misplaced rules: 0 | Redundant rules: 0
  | Suggestions: 0 (open) | Cross-file conflicts: 0
- Pass 5 fixes applied: 2026-05-05 (CR-012 closed by creating
  `.claude/rules/editorconfig.md`).
- Pass 4 fixes applied: 2026-05-05 (CR-005 closed by running the
  four prerequisite audit skills; all artifacts now present).
- Pass 3 fixes applied: 2026-05-05 (CR-010, CR-011 — validation
  fixes on existing rule files).

## Open Findings

_(none — all findings closed.)_

## Fixed

### Pass 5 — 2026-05-05

#### [CR-012] Suggested rule: mandatory `.editorconfig` adherence
Fixed: 2026-05-05
Notes: Created `.claude/rules/editorconfig.md` (unconditional;
loaded every session). Body covers default rules, the markdown
indent trap (multiples of 2; ordered-list continuations indent 4
not 3, bullet wraps indent 6 not 5), per-filetype overrides
(PHP/fish 4-space, git config tab, .plist tab, Python 4-space,
Lua 90-char), the shell-script shfmt knobs, and the ignored
tree list (tools, asdf, cheatsheets). Verified clean against
both `editorconfig-checker` and the new rules-lint hook.

### Pass 4 — 2026-05-05

#### [CR-005] Three of four expected audit artifacts are missing
Fixed: 2026-05-05
Notes: Ran the four prerequisite skills in sequence:
- `arch-detector` → `docs/audit/arch-profile.md` (8 inferred
  structural rules; 0 ambiguities)
- `arch-auditor` → `docs/audit/arch-findings.md` (2 violations:
  A-001 Medium host-specific exports leak, A-002 Low palette
  naming)
- `security-auditor` → `docs/audit/security-findings.md`
  (3 findings: 1 Low grype CVEs in vendored/cached/gitignored
  paths, 2 Advisory)
- `doc-auditor` → `docs/audit/doc-findings.md` (4 findings:
  DOC-001 Critical stale `dfm docs` subcommands in README,
  DOC-002 Medium pre-audit-framework findings dump,
  DOC-003 Medium README local/ mapping wrong, DOC-004 Low
  undocumented hostname-suffixed dispatch)

All four prerequisite artifacts now exist. Future passes of this
skill can derive rule suggestions from architectural and security
findings as well as nitpicker.

### Pass 3 — 2026-05-05

#### [CR-010] `shell-scripts.md` `paths:` glob included `.pre-commit-config.yaml`
Fixed: 2026-05-05
Notes: Removed `.pre-commit-config.yaml` from the `paths:`
frontmatter. The rule now scopes only to actual shell scripts
(`local/bin/**`, `scripts/**`, `config/theme/handlers.d/**`, and
the three `config/theme/` POSIX scripts).

#### [CR-011] `secrets-files.md` wording was narrower than the `.gitignore` policy
Fixed: 2026-05-05
Notes: Reworded the lead imperative to "Never commit anything under
`config/fish/secrets.d/` except `*.example` files and `README.md`",
mirroring the gitignore directly. The "copy `<name>.example`" hint
in the body was generalised away from `*.fish` so any future secret
format (env, json, etc.) is covered.

### Pass 2 — 2026-05-05

#### [CR-006] Shell-script shebang/shellcheck mandate misplaced in CLAUDE.md
Fixed: 2026-05-05
Notes: Created `.claude/rules/shell-scripts.md` (path-scoped to
`local/bin/**`, `scripts/**`, `config/theme/handlers.d/**`, and the
three `config/theme/` POSIX scripts). The CLAUDE.md bullet at
lines 156-160 was reduced to a 3-line pointer.

#### [CR-007] LSP list-parity mandate misplaced in `config/nvim/CLAUDE.md`
Fixed: 2026-05-05
Notes: Created `.claude/rules/lsp-list-parity.md` (path-scoped to
`config/nvim/lua/plugins/lsp.lua`, `config/nvim/init.lua`,
`config/nvim/lsp/*.lua`). nvim CLAUDE.md lines 127-129 reduced to a
2-line pointer.

#### [CR-008] Commit-message format mandate misplaced in CLAUDE.md
Fixed: 2026-05-05
Notes: Created `.claude/rules/commit-format.md` with the conventional
commits format, allowed types, and three examples. CLAUDE.md
"## Commit Convention" trimmed to a 2-line pointer plus the
commitlint reference.

#### [CR-009] Root `CLAUDE.md` was 226 lines — over the 200-line guideline
Fixed: 2026-05-05
Notes: Down to 194 lines. The 35-line `## Commands` code block was
extracted to `docs/commands.md` and replaced with a 4-line pointer.
While moving, normalised `npx @biomejs/biome migrate` to
`yarn dlx @biomejs/biome migrate` to comply with `no-npm.md`.

#### [CR-110] Suggested rule: never use `--no-verify` (preventive)
Fixed: 2026-05-05
Notes: Created `.claude/rules/no-hook-bypass.md` consolidating the
"don't bypass hooks" guidance. Trimmed the trailing hook-bypass
paragraphs from `vendored-files.md`, `no-npm.md`, and
`secrets-files.md`; each now points to the canonical rule.

### Pass 1 — 2026-05-05

#### [CR-001] `.claude/rules/` absent despite 12 atomic behavioral rules in CLAUDE.md
Category: misplaced
Area: `CLAUDE.md`, `config/nvim/CLAUDE.md`
Problem: The project has 12 atomic behavioral mandates (imperatives
addressed to Claude's conduct) embedded inside CLAUDE.md prose, and
no `.claude/rules/` directory at all. Per the Severity Guide, absent
`.claude/rules/` plus ≥5 atomic rules is Critical. CLAUDE.md is
delivered as a user message after the system prompt, so
security-critical and compliance mandates ride along with workflow
documentation and lose enforcement reliability. The fix is to move
each atomic rule into its own focused file under `.claude/rules/`.
Evidence: rules detected with file/line locations:

| #  | Rule                                                                                        | Source                  | Line(s)                           |
|----|---------------------------------------------------------------------------------------------|-------------------------|-----------------------------------|
| 1  | POSIX scripts use `/bin/sh`; validate with `sh -n`, not `bash -n`                           | `CLAUDE.md`             | 177-179                           |
| 2  | Never modify `local/bin/fzf-tmux` (vendored from junegunn/fzf)                              | `CLAUDE.md`             | 180-181                           |
| 3  | `config/fish/secrets.d/*.fish` are gitignored; only `*.example` and `README.md` are tracked | `CLAUDE.md`             | 188-191                           |
| 4  | Yarn (v4+) is the package manager; do not use npm                                           | `CLAUDE.md`             | 225                               |
| 5  | curl / wget bash commands are BLOCKED — use `ctx_fetch_and_index`                           | `CLAUDE.md`             | 235; `nvim/CLAUDE.md` 164-168     |
| 6  | Inline HTTP (`fetch('http`, `requests.get(`, …) is BLOCKED — use `ctx_execute`              | `CLAUDE.md`             | 239-243; `nvim/CLAUDE.md` 170-173 |
| 7  | WebFetch is BLOCKED — use `ctx_fetch_and_index`                                             | `CLAUDE.md`             | 245-248; `nvim/CLAUDE.md` 175-178 |
| 8  | Bash is ONLY for git/mkdir/rm/mv/cd/ls and other short-output commands                      | `CLAUDE.md`             | 252-256; `nvim/CLAUDE.md` 182-186 |
| 9  | Read for analysis is forbidden — use `ctx_execute_file`                                     | `CLAUDE.md`             | 258-262; `nvim/CLAUDE.md` 188-190 |
| 10 | Grep for large results is forbidden — use `ctx_execute` shell wrapper                       | `CLAUDE.md`             | 264-267; `nvim/CLAUDE.md` 192-193 |
| 11 | Keep responses under 500 words; write artifacts to FILES, not inline                        | `CLAUDE.md`             | 295-298; `nvim/CLAUDE.md` 209-211 |
| 12 | Always provide a description for keymaps; mini.clue uses it                                 | `config/nvim/CLAUDE.md` | 50                                |

Impact: Compliance is unreliable — critical mandates (HTTP blocking,
Bash scope, vendored-file protection) sit alongside workflow prose
and depend on the model parsing 317+219 lines of mixed content. Rules
in `.claude/rules/` are dedicated context injection and load reliably.
Fixed: 2026-05-05
Notes: All 12 atomic rules migrated into 7 single-topic files under
`.claude/rules/`. CLAUDE.md sources retain a 1-line pointer per
migrated rule. Root CLAUDE.md dropped from 317 → 230 lines; nvim
CLAUDE.md from 219 → 164 lines.

#### [CR-002] context-mode rule block duplicated across both CLAUDE.md files with formatting drift
Category: conflict
Area: `CLAUDE.md:227-318` vs. `config/nvim/CLAUDE.md:158-219`
Problem: The full context-mode "MANDATORY routing rules" block (~90
lines in root, ~62 lines in nvim subdir) appears in both CLAUDE.md
files. Semantic content is the same, but formatting has already
drifted: heading depth (`##`/`###` vs. `#`/`##`), line wrapping
(hard-wrapped at ~70 cols in root, single long lines in nvim), and
section ordering. Two copies guarantee future content drift.
Evidence: `diff` output of the two regions shows divergent heading
levels and formatting starting at the very first line of the block;
both nominally describe the same blocked tools and tool selection
hierarchy.
Impact: One copy gets edited in a session, the other doesn't.
Behavior diverges depending on which directory Claude is reading
from. This already happened with formatting; semantic drift is the
next step.
Fixed: 2026-05-05
Notes: Both CLAUDE.md files now point to the canonical
`.claude/rules/context-mode.md`. The duplicated ~150 lines collapsed
into a 4-line pointer in each location.

#### [CR-003] Root `CLAUDE.md` was 317 lines (over the 200-line guideline)
Category: validation
Area: `CLAUDE.md`
Problem: 317 lines is past the 200-line target the auditor uses as a
proxy for adherence. Roughly a third of the file is the context-mode
block (lines 227-318), which is also a duplicate (CR-002). Migrating
that block alone drops the file under 230 lines.
Evidence: `wc -l CLAUDE.md` → 317.
Impact: Longer files reduce per-instruction adherence; mandates
buried late in the document are easy to miss.
Fixed: 2026-05-05
Notes: Down to 230 lines. Residual content is pure CONTEXT (skills
tables, hooks documentation, architecture overview). Atomic rules
have all been migrated. Still nominally over the 200-line target
but no longer carries any behavioral mandates that benefit from
dedicated injection.

#### [CR-004] `config/nvim/CLAUDE.md` was 219 lines (over the 200-line guideline)
Category: validation
Area: `config/nvim/CLAUDE.md`
Problem: 219 lines, with lines 158-219 being the duplicated
context-mode block. Removing that drops the file to ~157 lines —
well under the guideline.
Evidence: `wc -l config/nvim/CLAUDE.md` → 219.
Impact: Same as CR-003.
Fixed: 2026-05-05
Notes: Down to 164 lines — under the 200-line guideline. Migrated
the duplicated context-mode block (replaced by 4-line pointer) and
the lone keymap-description imperative on the old line 50.

## Suggestions (new rule files) — applied in Pass 1

### Migration suggestions — atomic rules currently in CLAUDE.md

Each suggestion proposes a single-topic kebab-case file under
`.claude/rules/`. Approving a suggestion creates the file AND removes
the corresponding imperative(s) from CLAUDE.md.

#### [CR-101] Create `.claude/rules/context-mode.md`
Source: CR-001 rules #5..#11 + CR-002 duplicate block.
Proposed body: distill the BLOCKED-commands section (curl/wget,
inline HTTP, WebFetch), the REDIRECTED-tools section (Bash >20 lines,
Read for analysis, Grep large results), and the tool-selection
hierarchy into one focused file. Keep the ctx-commands table in
CLAUDE.md (it's user-facing reference, not Claude conduct).
After-migration delta: removes ~90 lines from `CLAUDE.md` and ~62
lines from `config/nvim/CLAUDE.md`; eliminates CR-002 entirely.

#### [CR-102] Create `.claude/rules/posix-scripts.md`
Source: CR-001 rule #1.
Proposed body:
```
Validate POSIX shell scripts with `sh -n`, not `bash -n`.
The following scripts use `/bin/sh`: x-ssh-audit, x-codeql,
x-until-error, x-until-success, x-ssl-expiry-date.
```

#### [CR-103] Create `.claude/rules/vendored-files.md`
Source: CR-001 rule #2.
Proposed body:
```
Never modify `local/bin/fzf-tmux`. It is vendored verbatim from
junegunn/fzf. Updates come via submodule sync, not edits.
```

#### [CR-104] Create `.claude/rules/no-npm.md`
Source: CR-001 rule #4.
Proposed body:
```
Use yarn (v4+), never npm. The repo uses Yarn Berry; npm corrupts
the lockfile and bypasses the workspace resolver.
```

#### [CR-105] Create `.claude/rules/secrets-files.md`
Source: CR-001 rule #3.
Proposed body:
```
Never commit `config/fish/secrets.d/*.fish` files. Only `*.example`
and `README.md` under that directory are tracked. To add a new
secret, copy the matching `.example` file and edit the copy locally.
```

#### [CR-106] Create `.claude/rules/keymap-descriptions.md` (path-scoped)
Source: CR-001 rule #12.
Proposed frontmatter + body:
```
---
paths:
  - "config/nvim/**/*.lua"
---

Always pass a description when registering keymaps via `K.n`,
`K.nl`, `K.d`, or `K.ld`. mini.clue surfaces it in the popup; an
omitted description leaves the binding unlabelled.
```

### Suggestions derived from nitpicker patterns

#### [CR-107] Create `.claude/rules/host-specific-config.md`
Source: nitpicker findings N-055 (`copilot-instructions.md` hardcoded
hosts) and N-059 (sesh SSH targets). Pattern: machine-specific values
keep landing in shared config.
Proposed body:
```
Personal hostnames, SSH targets, paths under `~/Code/<your-org>/`,
and any other machine-specific value belong in
`hosts/<hostname>/config/<app>/...`, never in the shared `config/`
tree. The dotbot host overlay layers these on top of the global
config at install time.
```

## Applied in Pass 1

All 7 suggestions approved as a batch and applied 2026-05-05.

| ID     | Result  | Files created                                                                  | CLAUDE.md edit                                                |
|--------|---------|--------------------------------------------------------------------------------|---------------------------------------------------------------|
| CR-101 | Applied | `.claude/rules/context-mode.md`                                                | Both CLAUDE.md files: ~150 lines collapsed → 4-line pointer   |
| CR-102 | Applied | `.claude/rules/posix-scripts.md`                                               | Pointer added; full rule in rule file                         |
| CR-103 | Applied | `.claude/rules/vendored-files.md`                                              | Pointer added                                                 |
| CR-104 | Applied | `.claude/rules/no-npm.md`                                                      | Package Manager section reduced to 1 sentence + pointer       |
| CR-105 | Applied | `.claude/rules/secrets-files.md`                                               | Imperative replaced with pointer; context kept                |
| CR-106 | Applied | `.claude/rules/keymap-descriptions.md` (path-scoped to `config/nvim/**/*.lua`) | nvim CLAUDE.md: imperative replaced with pointer              |
| CR-107 | Applied | `.claude/rules/host-specific-config.md`                                        | n/a — derived from nitpicker N-055/N-059, no CLAUDE.md change |

## Invalid

_(none — first pass)_
