# Nitpicker Findings

Generated: 2026-04-26
Last validated: 2026-05-20
Last pass: 18 (2026-05-20)

## Summary

- Total: 111 | Open: 0 | Fixed: 102 | Invalid: 9

## Open Findings

_(none)_

## Fixed

### Pass 16 — 2026-05-19

#### [N-095] `brew "pipx"` and `brew "python-setuptools"` effectively superseded by mise uv backend
Fixed: 2026-05-19
Notes: Verified zero references to `pipx` or `python-setuptools` in `local/bin/` and
`scripts/` (single comment in `cleanup-old-version-managers.sh`, not executable usage).
Both entries removed from `config/homebrew/Brewfile`. mise's `uv` backend with
`pipx.uvx = true` covers all pipx-style tool installs.

#### [N-056] `tag-changelog-config.js` `renderChangelog` uses wall-clock date, not tag date
Fixed: 2026-05-19
Notes: `renderChangelog` now extracts the date from the release tag name using
`release.match(/(\d{4})[.\-](\d{2})[.\-](\d{2})/)` — the `fregante/daily-version-action`
embeds the date in the tag (format `YYYY.MM.DD`), so no workflow changes are needed.
Falls back to `new Date()` only if the tag matches no known date pattern. Backfilled and
re-triggered runs now produce consistent changelog dates.

#### [N-013] WezTerm Wayland appearance detection depends on xdg-desktop-portal version
Fixed: 2026-05-19
Notes: Advisory accepted. No repo change is possible — the fix is environmental: install
WezTerm ≥ 20240203-110809 and ensure `xdg-desktop-portal` is running on affected Linux
systems. Finding documented and closed.

#### [N-020] oh-my-posh runtime still installed via mise
Fixed: 2026-05-19
Notes: Advisory accepted. No repo change is possible — oh-my-posh is not referenced in
`config/mise/config.toml` and will not be reinstalled. Manual action on affected machines:
`mise uninstall oh-my-posh`. Finding documented and closed.

### Pass 15 — 2026-05-19

#### [N-091] ntfy installed via custom download script instead of mise github backend
Category: maintainability
Area: `scripts/install-ntfy.sh`, `config/mise/config.toml`
Fixed: 2026-05-19
Notes: `scripts/install-ntfy.sh` manually detected OS/arch, fetched the latest release tag
via `x-gh-get-latest-version`, downloaded a tarball, and extracted the binary — 69 lines of
plumbing that mise's `github:` backend handles automatically. Added
`"github:binwiederhier/ntfy" = "latest"` to the `# GitHub releases` section of
`config/mise/config.toml`. Updated the `ntfy)` case in `section_install()` to delegate to
`mise install "github:binwiederhier/ntfy"` instead of running the shell script. The shell
script is preserved as a fallback reference but is no longer invoked by dfm.

#### [N-092] `dfm install mise` has no GITHUB_TOKEN gate before `mise install --yes`
Category: reliability
Area: `local/bin/dfm` section_install mise case
Fixed: 2026-05-19
Notes: `config/mise/config.toml` contains 10+ `"github:..."` tools. mise resolves `"latest"`
by querying the GitHub API — one request per `github:` tool. Unauthenticated requests are
rate-limited to 60/hr; on a fresh machine install, this exhausts the budget mid-run and
leaves tools partially installed with no clear error. Added a check for `${GITHUB_TOKEN:-}` in
the `mise)` case before calling `mise install --yes`. If unset, warns about rate limits and
offers to run `dfm secrets github` interactively, sourcing the resulting file so the token
is available for the current process before continuing.

#### [N-093] `brew "tmux"` duplicated in Brewfile — mise already owns tmux
Category: correctness
Area: `config/homebrew/Brewfile` line 232–233
Fixed: 2026-05-19
Notes: `tmux = "latest"` appears in `config/mise/config.toml` (line 138). `brew "tmux"` also
appears in `config/homebrew/Brewfile` (line 232). On macOS, Homebrew prepends its prefix to
PATH, so brew's tmux binary shadows the mise-managed one, making the mise pin ineffective.
Running `brew upgrade` and `mise upgrade tmux` independently causes version drift. Removed
the `# Terminal multiplexer` comment and `brew "tmux"` entry from the Brewfile.

#### [N-094] No `dfm secrets` command; bash/zsh lack a secrets.d mechanism
Category: maintainability
Area: `local/bin/dfm`, `config/exports`, `config/secrets.d/` (new)
Fixed: 2026-05-19
Notes: Fish sources `config/fish/secrets.d/*.fish` at shell startup (via `exports.fish`).
Bash and zsh had no equivalent — only `exports-secret` and `exports-local` single-file
fallbacks. No dfm command existed to scaffold secrets files across all shells. Added:
(1) `section_secrets()` function in dfm with a `github` subcommand that prompts for
GITHUB_TOKEN (silent input via `read -rsp`) and writes fish and bash/zsh secrets files;
(2) `config/secrets.d/github.sh.example` template parallel to the fish example;
(3) `config/secrets.d/*` + allowlist entries in `.gitignore` so real secrets stay untracked;
(4) secrets.d sourcing loop at the end of `config/exports` for bash/zsh, matching the
existing fish pattern exactly.

### Pass 18 — 2026-05-20

#### [N-091] `pre-edit-block.sh` only blocked `local/bin/fzf-tmux`, not the five other vendored fzf files
Fixed: 2026-05-20
Notes: Added a new case branch in `.claude/hooks/pre-edit-block.sh` covering
`config/fzf/completion.bash`, `config/fzf/completion.zsh`,
`config/fzf/key-bindings.bash`, `config/fzf/key-bindings.zsh`, and
`config/fzf/key-bindings.fish`. All six files listed in `vendored-files.md`
are now hook-protected.

#### [N-092] `no-hook-bypass.md` self-contradicted on "unconditional" vs user authorisation
Fixed: 2026-05-20
Notes: Reworded the closing paragraph to make the user-authorisation route the
named single exception. Removed the contradictory "unconditional" wording.

#### [N-093] `host-specific-config.md` frontmatter was inert (`alwaysApply: false`, no `paths:`)
Fixed: 2026-05-20
Notes: Replaced `alwaysApply: false` with `paths: ["config/**", "hosts/**",
"base/**", "ssh/**"]`. The rule now activates on edits to those trees.

#### [N-094] `lsp-list-parity.md` verify command lacked `config/nvim/` prefix
Fixed: 2026-05-20
Notes: Verification snippet now wraps the diff in `cd config/nvim &&` and
uses `awk` range patterns to scope the grep to the relevant tables.

#### [N-095] `bash-routing.md` "one-line user-asked" exception was unbounded
Fixed: 2026-05-20
Notes: Exception 4 now requires the named command's expected output to be
under ~20 lines; unbounded commands route through `ctx_batch_execute` even
when the user asks for them by name.

#### [N-096] `lsp-list-parity.md` grep regex `"[a-z_]+"` matched any quoted lowercase token
Fixed: 2026-05-20
Notes: Verification command now uses `awk` range patterns to scope grep to
the `ensure_installed = {…}` and `vim.lsp.enable {…}` tables only.

#### [N-097] `editorconfig.md` omitted four `.editorconfig` sections
Fixed: 2026-05-20
Notes: Added entries for `[*.fish]` (120-char), `[*.hwdb]` (indent_size=1),
`[plan]` (literal `base/plan`), and
`[base/hammerspoon/hammerspoon.types.lua]` (max_line_length=off) to the
per-filetype overrides section.

#### [N-098] `validate-config-schemas.md` mislabeled actionlint/yamllint as validators
Fixed: 2026-05-20
Notes: Renamed the table column to "Tool" and added a "Checks" column.
Added a paragraph stating actionlint and yamllint catch grammar/style only
and that `no-schema-guessing.md` is the safety net for schema-less files.

#### [N-099] `vendored-files.md` did not name the submodule path or refresh command
Fixed: 2026-05-20
Notes: Replaced the false "submodule sync" claim with the actual
mechanism (manual fetch from upstream). Added the refresh `curl` snippet
for human operators, with a note that Claude itself is blocked from `curl`.

#### [N-100] `posix-scripts.md` did not warn about macOS `/bin/sh` being bash-in-sh-mode
Fixed: 2026-05-20
Notes: Added a "macOS caveat" section recommending `dash -n` for strict
bashism-leak checks; `sh -n` remains the syntax-level smoke test.

#### [N-101] `no-hook-bypass.md` referenced only `.claude/settings.json` hooks
Fixed: 2026-05-20
Notes: Bullet now also names plugin-supplied `hooks.json` (e.g. the
context-mode plugin) as part of the protected hook chain.

#### [N-105] `notify-idle.sh` shell-interpolated `$msg` into AppleScript code
Fixed: 2026-05-20
Notes: Rewrote the `osascript` call to pass `$msg` as `argv[1]`. The
AppleScript reads it via `item 1 of argv`, bypassing string-construction
entirely. Closes the command-injection vector.

#### [N-106] `async-bats.sh` used `node_modules/.bin/bats` instead of mise-PATH bats
Fixed: 2026-05-20
Notes: Replaced the hard-coded path with bare `bats` plus a
`command -v bats` guard. Aligns with the recorded user preference.

#### [N-107] `stop-lint-gate.sh` lint chain diverged from `yarn lint`
Fixed: 2026-05-20
Notes: Replaced the explicit `lint:biome && lint:prettier && lint:md-table
&& lint:ec` chain with `$YARN_BIN lint`. markdownlint, v8r, and usage-lint
now run as part of the Stop gate.

#### [N-108] `stop-lint-gate.sh` silently degraded on `ec` download failure
Fixed: 2026-05-20
Notes: Network-aware branch now prints a specific error and exits with
non-zero status. The download failure no longer slips through as a
warning.

#### [N-109] `post-edit-format.sh` shfmt shebang regex matched `zsh`
Fixed: 2026-05-20
Notes: Anchored the regex to `(/|env )(bash|sh)( |$)` so `zsh`, `fish`,
and `python3` shebangs no longer route through shfmt.

#### [N-110] `post-edit-dotbot-validate.sh` Python fallback interpolated `$fp`
Fixed: 2026-05-20
Notes: Switched to `python3 -c '... sys.argv[1] ...' "$fp"` so the path
is passed as argv and cannot break out of the source literal.

#### [N-111] `install.conf.yaml` swallowed submodule errors with `|| true`
Fixed: 2026-05-20
Notes: Removed the `|| true` so a failed `add-submodules.sh` halts the
install instead of leaving a half-installed tree for the subsequent
`git submodule update` to operate on.

#### [N-102] `commit-format.md` "under 72 characters" claim was unverified
Fixed: 2026-05-20
Notes: Fetched `@ivuorinen/commitlint-config` `index.cjs` from upstream —
it extends `@commitlint/config-conventional` (default `header-max-length:
100`) plus `body-leading-blank: [2, always]`. Rule now distinguishes the
72-char target (discipline) from the 100-char hard limit (enforcement),
and documents the body-leading-blank override.

#### [N-103] `keymap-descriptions.md` had no automated enforcement
Fixed: 2026-05-20
Notes: Added a "Manual verification" section with a grep regex that
catches two-argument `K.*` calls missing the opts/desc argument,
excluding `utils.lua` where the K-table itself is defined.

#### [N-104] `no-schema-guessing.md` accepted `--help` as primary schema evidence
Fixed: 2026-05-20
Notes: Demoted `--help` to supporting evidence only. Promoted `<tool>
schema`, `<tool> --print-schema`, and `man <tool>` as the primary
non-docs-fetch evidence sources.

#### [N-112] `post-edit-rules-lint.sh` hedge-word pattern was incomplete
Fixed: 2026-05-20
Notes: Extended the pattern to include `should` (the RFC 2119
weakening). Documented in the hook header why other modal verbs (`may`,
`could`, `usually`) stay excluded: they appear in rule prose as factual
qualifications rather than as normative weakening. Rewrote the one
occurrence of `should` in `bash-routing.md` that the extension would
have flagged.

#### [N-113] `.claude/hook-failures.log` was never rotated
Fixed: 2026-05-20
Notes: `log-failures.sh` now tail-rotates the file at 1000 lines using a
temp-file + rename so a concurrent appender cannot observe a
half-truncated log. `.gitignore`'s `*.log` rule keeps the file out of
the working tree.

#### [N-114] `.claude/agents/code-reviewer.md` did not reference `.claude/rules/`
Fixed: 2026-05-20
Notes: Rewrote the agent prompt to point at the specific rule files
(`shell-scripts.md`, `posix-scripts.md`, `editorconfig.md`,
`keymap-descriptions.md`, `lsp-list-parity.md`, `commit-format.md`,
`vendored-files.md`, `no-schema-guessing.md`). The agent now reviews
against the project's rule set, not generic conventions.

### Pass 14 — 2026-05-19

#### [N-087] `scripts/` and `local/bin/` usage specs were sidecar `.kdl` files, not inline

Category: maintainability
Area: `scripts/*.usage.kdl`, `local/bin/*.usage.kdl` (74 files)
Fixed: 2026-05-19
Notes: The usage CLI v3+ supports inline `#USAGE` comment directives embedded directly in
scripts, eliminating the need for paired `.kdl` sidecar files. 18 sidecar files under
`scripts/` and 56 under `local/bin/` were replaced by injecting `#USAGE about "..."` (and
`flag`/`arg`/`cmd`/`alias` blocks where the KDL carried them) immediately after the shebang
and `# @description` line in each script. PHP scripts use `//USAGE` (PHP line-comment
prefix). All 74 KDL files were deleted. The `# @description` tag was preserved in all scripts
that carried it — it is consumed by `dfm get_script_description()` independently of usage.

#### [N-088] `install-completions.sh` scanned for `.kdl` globs instead of inline-annotated scripts

Category: correctness
Area: `scripts/install-completions.sh`
Fixed: 2026-05-19
Notes: The completion generator looped over `**/*.usage.kdl` globs and passed the KDL sidecar
path to `usage generate -f`. After the migration to inline specs, no `.kdl` files exist and
the script generated nothing. Refactored into a `generate_for_spec(spec, bin_name)` helper
function that runs the five generators (fish/bash/zsh completions, markdown, manpage). Two
replacement loops: `local/bin/` uses `grep -q '#USAGE\|//USAGE'` as a self-filter so only
scripts with inline directives are processed; `scripts/*.sh` iterates all `.sh` files,
skipping `shared.sh` (library). `usage generate -f` accepts inline-annotated scripts directly.

#### [N-090] `new-script` skill template missing `#USAGE about` directive and stale Step 3 docs

Category: docs
Area: `.claude/skills/new-script/SKILL.md`
Fixed: 2026-05-19
Notes: The scaffold template did not include a `#USAGE about` line. `install-completions.sh`
discovers scripts via `grep -q '#USAGE\|//USAGE'`; any script created from the old template
would be silently skipped — no completions, markdown docs, or manpages generated. Step 3 told
users to run `dfm docs script <name>`, which is the old pre-migration workflow. Added
`#USAGE about "<one-line description>"` immediately after `# @description` in the template,
added bullet points explaining both tags' purposes, and replaced Step 3 with
`scripts/install-completions.sh` as the correct regen entry point.

#### [N-089] No `usage lint` quality gate in lint pipeline or pre-commit hooks

Category: reliability
Area: `package.json`, `.pre-commit-config.yaml`
Fixed: 2026-05-19
Notes: The `usage lint` command validates inline `#USAGE` directives against the spec, but it
was not wired into the quality pipeline. Two additions: (1) `package.json` gained a
`lint:usage` script (`bash -c '...'` loop over `scripts/*.sh` and `grep -rl`-discovered
`local/bin/` files) included in the `lint` aggregate; (2) `.pre-commit-config.yaml` gained a
local `usage-lint` hook with `files: ^(scripts/.*\.sh|local/bin/[^/]+)$` that runs
`usage lint "$f"` per matched file. The pre-commit entry pattern uses `bash -c '...' --` so
matched filenames land in `"$@"` (not `$0`). Verified: `yarn lint` exits 0 with 74× "No
issues found."

### Pass 13 — 2026-05-18

#### [N-086] `pre-edit-block.sh` `*.example.fish` exception allows secrets bypass

Category: security
Area: `.claude/hooks/pre-edit-block.sh`
Fixed: 2026-05-18
Notes: Both the Read block (line 18) and Edit/Write block (line 43) contained the
exception `*.example.fish | *.fish.example`. The `*.example.fish` half matches any
file ending in `.example.fish` — e.g., `prod.example.fish` in `secrets.d/`, which
fish auto-sources as a `*.fish` file and which `.gitignore` treats as a secret. That
file would pass the exception and be readable/editable despite containing credentials.
The tracked example naming convention is `*.fish.example` only (e.g.,
`github.fish.example`). Removed `*.example.fish |` from both case branches so only
`*.fish.example` files are exempted. Copilot report PR #376 r3262054215.

### Pass 12 — 2026-05-18

#### [N-081] `pre-edit-block.sh` exits 0 on malformed JSON hook payload

Fixed: 2026-05-18
Notes: `jq -r '.tool_input.file_path // empty'` returned empty string and exit 0 on
malformed JSON input, so the hook allowed all subsequent blocking logic to be bypassed.
Replaced with `jq -er '.tool_input.file_path'` inside `if !`; the hook now exits 2 with
a BLOCKED message when the payload is missing `tool_input.file_path` or is not valid JSON.
CodeRabbitAI report on PR #376.

#### [N-082] `MultiEdit` not included in PreToolUse file-guard matcher

Fixed: 2026-05-18
Notes: `settings.json` matcher was `Edit|Write|Read`, leaving `MultiEdit` (which also
carries `file_path`) outside the `pre-edit-block.sh` guard. Vendor, submodule, and secrets
edit blocks could be bypassed via MultiEdit. Matcher updated to `Edit|Write|Read|MultiEdit`.
Copilot report on PR #376.

#### [N-083] `no-schema-guessing.md` "exactly one" over-constrains valid multi-evidence cases

Fixed: 2026-05-18
Notes: "Before writing any key … exactly one of the following must be true" made the rule
logically unsatisfiable when two sources corroborated the same key (e.g., user-provided key
also confirmed by fetched docs). Changed to "at least one". Copilot report on PR #376.

#### [N-084] `context-mode.md` Bash summary contradicts `bash-routing.md`

Fixed: 2026-05-18
Notes: "Bash is reserved for side-effect-only operations that produce no output" conflicted
with bash-routing.md, which also permits in-place formatters, streaming package installs,
and one-line user-requested commands. Replaced the summary sentence with "See
`bash-routing.md` for the complete list of allowed Bash exceptions." Copilot report on PR #376.

#### [N-085] `settings.json` `"WebFetch(*)"` fails v8r schema pattern

Fixed: 2026-05-18
Notes: The schemastore pattern for deny entries requires the parenthetical argument to
contain at least one character that is not `)`, `*`, or `?` (lookahead `(?=.*[^)*?])`).
`WebFetch(*)` contains only `*` as the argument, so the lookahead fails. Changed to `"WebFetch"`
(no parens), which matches the bare-tool-name branch and denies all WebFetch calls. v8r now
reports `.claude/settings.json is valid`.

### Pass 11 — 2026-05-18

#### [N-080] `validate-config-schemas.md` fallback implied yamllint suffices; key-name guessing loophole open
Fixed: 2026-05-18
Notes: The fallback line "fall back to the project's existing linter (yamllint, biome,
ruff, …)" implied that a passing syntax linter permitted proceeding without evidence for
key names. yamllint validates syntax, not key names. Created `no-schema-guessing.md`
to prohibit all forms of guessing/extrapolation for schema-less files and to define the
four acceptable evidence sources (fetched docs, tool help output, user-provided key,
tool error message). Updated the fallback line in `validate-config-schemas.md` to
cross-reference `no-schema-guessing.md` explicitly. Canonical failure mode: N-078.

### Pass 10 — 2026-05-18

#### [N-072] `context-mode.md` listed `npm install` and `pip install` as acceptable Bash
Fixed: 2026-05-18
Notes: `.claude/rules/context-mode.md` line 37-38 declared `npm install` and `pip install`
as acceptable Bash commands. `npm` is explicitly prohibited by `no-npm.md`; `pip install` has
no role in this repo's tool management (mise handles Python). Changed to `yarn install,
brew install` — the two package install commands that belong in Bash per no-npm.md and
bash-routing.md. Verified with `grep npm .claude/rules/context-mode.md` → no results.

#### [N-073] `pre-edit-block.sh` did not block Read tool on secrets files
Fixed: 2026-05-18
Notes: The hook only guarded `Edit|Write` operations. The `Read` tool could read any file
under `config/fish/secrets.d/` without interception. Updated `pre-edit-block.sh` to:
(a) buffer stdin with `input=$(cat)` so `tool_name` and `file_path` can both be extracted,
(b) detect `tool == "Read"` and apply a secrets-only block with an appropriate message
("do not read … it contains secrets"), (c) skip the vendor/submodule blocks for Read (those
files are readable, just not editable). Verified: `shellcheck` clean, `editorconfig-checker`
clean. Note: the hook fires only when settings.json matcher includes `Read` — see N-075.

#### [N-074] Eight rules files lacked YAML frontmatter
Fixed: 2026-05-18
Notes: Added frontmatter to `bash-routing.md` (alwaysApply), `context-mode.md` (alwaysApply),
`no-npm.md` (alwaysApply), `editorconfig.md` (alwaysApply), `host-specific-config.md`,
`posix-scripts.md` (globs for 5 POSIX scripts), `secrets-files.md` (globs for secrets.d),
`vendored-files.md` (globs for vendored fzf files). Remaining 3 files resolved under N-077.

#### [N-075] `settings.json` PreToolUse matcher excluded Read — secrets-read block inert
Fixed: 2026-05-18
Notes: Changed `"Edit|Write"` to `"Edit|Write|Read"` in the PreToolUse hook matcher in
`.claude/settings.json`. The pre-edit-block.sh Read-blocking logic was already in place
(N-073); this change activates it. Verified: matcher now reads `"Edit|Write|Read"`.

#### [N-076] `settings.json` had no `permissions.deny` — curl/WebFetch unrestricted at permission layer
Fixed: 2026-05-18
Notes: Added `"permissions": {"deny": ["Bash(curl:*)", "Bash(wget:*)", "WebFetch(*)"]}` to
`.claude/settings.json`. These three denies enforce at the permission layer what `context-mode.md`
and `bash-routing.md` mandate at the instruction layer. Project-level deny overrides the global
`~/.claude/settings.json` allow entries for curl and WebFetch domains.

#### [N-077] Two rules files lacked frontmatter — `commit-format.md`, `validate-config-schemas.md`
Fixed: 2026-05-18
Notes: `no-hook-bypass.md` was fixed in an earlier Write attempt in this pass (alwaysApply: true).
`commit-format.md` (alwaysApply: true) and `validate-config-schemas.md` (paths for yml/yaml/json/toml)
were fixed after the user switched from auto-mode, which unblocked the self-modification guard.
All 14 rules files now have YAML frontmatter.

#### [N-079] Four rules files added in Pass 10 used `globs:` — correct key is `paths:`
Fixed: 2026-05-18
Notes: `posix-scripts.md`, `secrets-files.md`, `vendored-files.md`, and
`validate-config-schemas.md` were written with `globs:` as the file-scoping frontmatter key.
Official docs (`code.claude.com/docs/en/memory`) confirm the correct key is `paths:`. Renamed
in all four files. Also corrected the erroneous `globs:` mention in N-077 notes.

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

### Pass 10 — 2026-05-18

#### [N-078] Three existing rule files use `paths:` frontmatter key — correct key is `globs:`
Notes: Premise wrong. Official Claude Code docs (`code.claude.com/docs/en/memory`,
"Path-specific rules" section) use `paths:` as the correct YAML frontmatter key for
file-scoped rules. The three files (`shell-scripts.md`, `keymap-descriptions.md`,
`lsp-list-parity.md`) were already correct. The finding was filed based on a mistaken
belief that `globs:` (used by the context-mode superpowers plugin) was the schema key.

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
