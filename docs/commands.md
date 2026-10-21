# Commands

Quick reference for common workflows. Most commands are also
discoverable via `dfm help` and the mise file tasks in `.mise/tasks/`
(`mise tasks` lists them).

## Setup

```bash
mise install   # Install the pinned toolchain (required before lint/test)
```

## Linting

```bash
mise run lint              # Runs all nine lint-* steps below, in order
mise run lint-biome        # Biome only
mise run lint-prettier     # Prettier (YAML) check only
mise run lint-ec           # EditorConfig checker only
mise run lint-md-table     # Markdown table formatting check
mise run lint-markdownlint # markdownlint (honors .markdownlintignore)
mise run lint-v8r          # JSON Schema validation of schema-backed configs
mise run lint-usage        # usage lint for scripts/ and local/bin/
mise run lint-bandit       # Python SAST (config in [tool.bandit], pyproject.toml)
mise run lint-exclusions   # Third-party exclusion lists agree across gates (scripts/check-exclusion-drift.py)
mise run fix               # Autofix everything (biome + prettier + md-table)
mise run fix-md-table      # Auto-fix markdown tables
```

## Formatting

```bash
mise run fix-biome     # Autofix with biome (JS/TS/JSON/MD)
mise run fix-prettier  # Autofix with prettier (YAML); alias: format-yaml
mise run format        # Format with biome
```

## Testing

```bash
mise run test              # Run all tests (bash test-all.sh)
scripts/bats-run.sh        # Run the suite as the hook and CI do; ends with a
                           # file:line list of every failing test
bats tests/dfm.bats        # Run a single test file (bats from PATH, via mise)
```

## Shell / Lua

```bash
shellcheck <script>     # Lint shell scripts
stylua config/nvim/     # Format neovim Lua files
```

## Pre-commit

```bash
prek run --all-files
```

## Tooling maintenance

```bash
biome migrate --write   # Update biome schema version (mise-pinned biome)
```
