# dfm command split — design

Date: 2026-06-02
Status: approved (key decisions chosen interactively)

## Goal

Split the monolithic `local/bin/dfm` (1343 lines) into many small
git-style subcommand executables: `dfm brew` → `local/bin/dfm-brew`,
`dfm apt` → `local/bin/dfm-apt`, etc. `dfm` becomes a thin dispatcher.

## Decisions

1. **Dispatch**: git-style. `dfm <sub> <args>` resolves `dfm-<sub>`
    (sibling-of-dispatcher first, then `PATH`) and `exec`s it.
2. **install granularity**: one `dfm-install` file with an internal
    `case` for `all|fonts|mise|macos|composer|…` (no `dfm-install-*`).
3. **USAGE specs**: per-file fragments, merged by the generator into
    one `dfm` completion tree.
4. **Shared internals**: a sourced, non-executable `local/bin/dfm-lib`.

## File inventory

```
local/bin/dfm           # dispatcher + root #USAGE (name/bin/about/author)
local/bin/dfm-lib       # sourced shared library — NON-executable (0644)
local/bin/dfm-install   # internal case: all|fonts|mise|macos|composer|…
local/bin/dfm-brew
local/bin/dfm-apt
local/bin/dfm-check
local/bin/dfm-dotfiles
local/bin/dfm-helpers
local/bin/dfm-docs
local/bin/dfm-scripts
local/bin/dfm-cleanup
local/bin/dfm-secrets
local/bin/dfm-tests
```

The 11 sections come from `main()`: install, apt, brew, check,
dotfiles, helpers, docs, scripts, cleanup, secrets, tests.

## Dispatcher (`dfm`)

```bash
sub="${1:-}"; [ $# -gt 0 ] && shift
selfdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
case "$sub" in
  ""|help|-h|--help) usage; exit 0 ;;
esac
cand="$selfdir/dfm-$sub"
if [ -x "$cand" ]; then exec "$cand" "$@"; fi
if command -v "dfm-$sub" >/dev/null 2>&1; then exec "dfm-$sub" "$@"; fi
msgr err "dfm: '$sub' is not a dfm command. See 'dfm help'."; exit 1
```

`usage()` enumerates the sections so `dfm` / `dfm help` /
`dfm nonexistent` keep printing the full section list (the three
`tests/dfm.bats` usage tests stay green). Sibling-first lookup keeps
`bash local/bin/dfm brew …` working in tests and pre-`install`
checkouts (mirrors git's libexec lookup).

## Shared library (`dfm-lib`)

Non-executable (`chmod 644`) so `command -v dfm-lib` never matches it
(no `dfm lib` namespace collision) and the missing exec bit signals
"source, don't run". Contains:

- `dfm_bootstrap` — sets `DOTFILES`/`BREWFILE`/`HOSTFILES`, enforces
  bash 4+, sources `config/shared.sh` and `local/bin/msgr`.
- `menu_builder`, `get_script_description`.
- the `secrets_*` family (filename_from_env, valid_name, create,
  env_names, list, show, remove).

Each `dfm-*` does:

```bash
_libdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=local/bin/dfm-lib
. "$_libdir/dfm-lib"
dfm_bootstrap
```

## USAGE merge (`scripts/install-completions.sh`)

Each `dfm-<sub>` carries its own `#USAGE cmd "<sub>" help="…" { … }`
fragment (the subtree it owns today). The generator is reworked:

1. Skip `dfm` and `dfm-*` in the normal per-file `local/bin/*` loop
    (their fragments are not valid standalone root specs).
2. Add an assemble step: emit `name dfm` / `bin dfm` + root
    `about`/`author` (read from the `dfm` dispatcher's `#USAGE`), then
    append each `dfm-*` fragment via `sed -n 's/^#USAGE //p'` (sorted
    for stable output) into one temp `.kdl`; run the five
    `usage generate` calls (fish/bash/zsh/markdown/manpage) against it
    with bin_name `dfm`.

Result: `dfm.fish`/`dfm.bash`/`_dfm`/`dfm.md`/`dfm.1` regenerate to the
same tree as today. `dfm-*` are not separately completed (like
`git-rebase` isn't), but direct invocation still works.

## Backward compatibility

- `dfm install all` (in `install.conf.yaml`) unchanged.
- `dfm scripts`, `dfm docs …`, every `dfm <sub>` unchanged.
- `dfm` / `dfm help` / `dfm nonexistent` → dispatcher `usage()`.

## Testing

- `tests/dfm.bats` (436 lines) stays as the integration suite — all
  calls route through the dispatcher.
- Add targeted bats per new script where logic warrants
  (`bats-test-scaffold`).
- Gate: `pre-commit run --all-files` + the `yarn lint` Stop hook.

## Alternatives rejected

- Explicit allowlist dispatch (less git-like).
- Nested `dfm-install-*` (≈15 extra files).
- Master spec retained in dispatcher (chose per-file merged).
- Duplicating helpers per script (chose `dfm-lib`).
