# Architecture Profile

Generated: 2026-10-22 (re-detected; first profile 2026-05-05, see Drift)

This is a personal dotfiles repository, not an application. Standard
application patterns (DDD, Hexagonal, Clean, Onion, MVC, CQRS,
microservices, etc.) do not apply. The patterns below describe how
the configuration code is *organised and extended*.

## Detected Patterns

### Plugin / Extension — High confidence

Evidence — multiple `*.d/` drop-in extension points, each loaded at
runtime by a co-located orchestrator:

- `config/theme/handlers.d/` — one executable per app, per-app theme flip
  executables; the orchestrator forks each one in parallel under a
  5 s timeout. Add a new app by dropping a file here. Documented in
  `config/theme/CLAUDE.md` ("Add new apps by dropping a file here")
- `config/theme/palettes.d/<family>/<variant>/<app>[.<ext>]` — per-app
  palette assets keyed by theme family + variant + app; the active
  family is `DOTFILES_THEME_FAMILY` when set, else the per-machine saved
  choice (`local/bin/theme`), else the tracked default in
  `config/theme/family`.
- `config/fish/conf.d/` (4 entries) — fish auto-loaded config
  fragments.
- `config/fish/secrets.d/` (3 entries; only `*.example` and
  `README.md` tracked) — gitignored shell secrets sourced by
  `exports.fish`.
- `config/fish/functions/` (16 entries) — fish autoloaded function
  files.
- `config/fish/completions/` (13 tracked entries) — generated and hand-
  rolled fish completions.
- `local/bin/dfm` — git-style dispatcher: it resolves
  `"$_dfm_selfdir/dfm-$sub"` (or `dfm-$sub` on PATH) and execs it; 14
  `local/bin/dfm-*` files serve the sections. Dependency direction is
  one-way: no `dfm-*` sources another `dfm-*`, only `dfm-lib`, `msgr`
  and (on action paths) `config/shared.sh`.
- `.mise/tasks/` (16 entries) — mise file tasks, discovered by name.
- `config/mise/conf.d/brew/` — mise folder fragment for
  `[bootstrap.packages]`, split by platform (`mise.toml`,
  `mise.macos.toml`, the latter loaded through `auto_env`).

The contract is uniform: a directory's files are discovered by name
or extension, no central registry, no manual wiring.

### Event-driven (theme orchestrator) — High confidence

Evidence — a self-locking daemon publishes state changes; multiple
handlers consume them:

- `config/theme/watcher` — daemon that subscribes to OS appearance
  events (xdg-desktop-portal / gsettings on Linux, `defaults read`
  polling on macOS).
- `config/theme/apply <mode>` — actor that atomic-writes
  `$XDG_STATE_HOME/dotfiles-theme/mode` and forks each
  `handlers.d/<name>` in parallel.
- `config/fish/conf.d/theme-switch.fish` — independent consumer that
  watches the same mode state file and reacts.
- `config/theme/_lib.sh` — shared library used by `apply` and
  handlers.

Pattern flavour is **fanout, not pipe-and-filter** — handlers run in
parallel under a timeout rather than chained.

### Host-specific Overlay (custom) — High confidence

Evidence — directory layout dedicated to per-machine overrides:

- `hosts/` contains 5 active overlays (`air/`, `lakka/`, `s/`,
  `tunkki/`, `twonky/`) plus a `README.md`.
- Each overlay has its own `base/`, `config/`, and
  `install.conf.yaml`. Dotbot applies the host overlay after the
  global config at install time.

Not in the canonical pattern list, but the convention is explicit
in AGENTS.md and enforced by `.claude/rules/host-specific-config.md`.

### XDG Base Directory layout — High confidence

Evidence — top-level directories map directly to XDG destinations
via Dotbot:

| Source          | Destination       |
|-----------------|-------------------|
| `base/*`        | `~/.*`            |
| `config/*`      | `~/.config/`      |
| `local/bin/*`   | `~/.local/bin/`   |
| `local/share/*` | `~/.local/share/` |
| `local/man/**`  | `~/.local/man/`   |
| `ssh/*`         | `~/.ssh/`         |

This is not an architectural pattern from the catalogue, but it is
the strongest organising principle in the repo.

### Modular Monolith (configuration) — Medium confidence

Evidence — `config/` houses ~25 self-contained per-app
subdirectories (`config/nvim/`, `config/tmux/`, `config/fish/`,
`config/theme/`, etc.). Each app's configuration lives entirely
under its own directory; cross-app references are minimal and
explicit (e.g. `config/theme/handlers.d/tmux` knows about tmux
sourcing).

Confidence is Medium because there is no shared kernel and no
runtime dependency graph between modules — they are configuration
neighbours, not collaborating components.

### Vendored boundary via submodules — High confidence

Evidence — four git submodules:

- `tools/dotbot`, `tools/antidote`
- `config/cheat/cheatsheets/community`,
  `config/cheat/cheatsheets/tldr`

Plus in-tree vendored files (five fish plugin functions), tracked under
`.claude/rules/vendored-files.md`.

The boundary rule is consistent: third-party code lives under
`tools/` or specifically-named subdirectories; updates flow via
submodule sync, never direct edits.

## Detected Combination

**Custom hybrid: Plugin / Extension + Event-driven (theme) +
Host-specific Overlay over an XDG-layered file tree.**

This is not in the canonical combination table (no DDD/Hexagonal/
Clean fit). It is best described as:

> A configuration-as-code repository where (1) the file tree is the
> XDG destination map, (2) host-specific overrides layer on top via
> dotbot, and (3) extensible behaviour is plugged in by dropping
> files into well-known `*.d/` directories that an orchestrator
> discovers at runtime.

## Inferred Structural Rules

These are the structural mandates `arch-auditor` should validate.
Items already enforced by `.claude/rules/` are flagged.

1. **Theme apps must register via `config/theme/handlers.d/<name>`,
   not by editing `apply` or `watcher`.** The orchestrator forks
   every executable under that directory; modifying the orchestrator
   to special-case an app violates the extension contract.
2. **Per-app palette files follow `config/theme/palettes.d/<family>/<variant>/<app>[.<ext>]`.**
   Variant is `dark` or `light`. Extension is required when the
   consuming format expects one (`.toml` for starship, `.conf` for
   tmux, `.yml` for eza). Formats with no canonical extension —
   e.g. dircolors — may omit it (`<family>/<variant>/dircolors` is the
   one current case). Handlers resolve the path with `_palette` from
   `config/theme/_lib.sh`, and a family that ships no file gets the
   stale link removed rather than another family's palette kept.
3. **Host-specific values must live under `hosts/<hostname>/`,
   never in shared `config/` or `base/`.** ✅ Already enforced by
   `.claude/rules/host-specific-config.md`.
4. **Secrets must live under `config/fish/secrets.d/`; only
   `*.example` and `README.md` are tracked.** ✅ Already enforced
   by `.claude/rules/secrets-files.md`.
5. **Third-party code enters the repo as a submodule under
   `tools/` (or the specific cheatsheets paths), or as an explicitly
   vendored tree — never as ad-hoc copied files.** The in-tree
   vendored set is authoritative in
   `.claude/rules/vendored-files.md`: five fish plugin functions under
   `config/fish/functions/`. Each is
   excluded from the relevant linters and blocked by the PreToolUse
   edit guard.
6. **Helper scripts go in `local/bin/`** — they are symlinked into
   `~/.local/bin/` by dotbot and become part of the user's PATH.
   Tests for them live in `tests/<script-name>.bats`.
7. **App-specific configuration goes in `config/<app>/`** —
   one directory per logical app. Top-level files outside this
   structure are owners of cross-cutting concerns
   (`shared.sh`, `exports`, `alias`).
8. **Bats tests live in `tests/*.bats`** — bats is the only test
   framework. New scripts should ship with a matching `.bats`.
9. **A `dfm-*` subcommand reaches shared behaviour only through
   `dfm-lib`** — never by sourcing or calling another `dfm-*`. Menu
   and help paths use `dfm_bootstrap_min`; only action paths pay for
   the full `config/shared.sh` chain.
10. **Every package has exactly one owner**: a tool pinned in mise
    `[tools]`, a formula declared in mise `[bootstrap.packages]`
    (`config/mise/conf.d/brew/`), a leaf in `config/homebrew/Brewfile`,
    or PHP owned by `phpenv.fish` — never two. Checked 2026-10-22: the
    Brewfile, conf.d/brew and `[tools]` leaf sets are disjoint.

## Ambiguities & Contradictions

The plugin-extension idiom is uniform across `*.d/` directories, the
host-overlay pattern is documented and used as designed, and the XDG
mapping is mechanical via dotbot. Rule 10 is where the structure strains:

- `mise bootstrap packages prune` assumes mise config is the sole
  owner of the Homebrew prefix, which the three-owner split does not
  satisfy. It stays a standing hazard, documented in `docs/mise.md` and
  the Brewfile header rather than removed (finding audit-b1d8b796).
- Resolved 2026-10-22: the Brewfile also listed the dependency closure
  of formulae owned elsewhere (mise-declared formulae and phpenv's PHP);
  it now lists leaves only (finding audit-ef569197).

One minor mismatch: `config/theme/_lib.sh` lives at the same level
as the `apply`/`watcher` actors and the `handlers.d/` extension
point, but the underscore prefix marks it as private. Some
maintainers prefer `lib/` or `internal/` for clarity. Not a defect,
just a convention choice.

## Drift

Since the 2026-05-05 profile:

- **Added extension points:** `.mise/tasks/` (mise file tasks, moved out
  of inline `.mise.toml` tasks) and the `config/mise/conf.d/brew/` folder
  fragment (Homebrew formulae for mise's brew bootstrap, split by
  platform). The `dfm` dispatcher was present before but not profiled;
  it is now listed under Plugin / Extension.
- **New structural rules:** 9 (dfm-lib as the only shared surface) and 10
  (single package owner), the latter introduced by the brew → mise
  bootstrap migration.
- **Host overlays:** 4 → 5 (`twonky/` added).
- **Submodules:** 5 → 4 (`tools/dotbot-include` removed;
  `add-submodules.sh` lists it under `old_submodules`).
- **Counts:** `config/fish/conf.d/` 3 → 4, `config/fish/functions/` 14 → 16,
  `config/fish/completions/` 87 → 13 tracked entries.
- **Contradictions:** none before; two found against rule 10, one
  resolved, one documented as a standing hazard (see above).
