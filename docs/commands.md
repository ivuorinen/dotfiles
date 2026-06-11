# Commands

Quick reference for common workflows. Most commands are also
discoverable via `dfm help` and the `scripts` block in `package.json`.

## Setup

```bash
yarn install   # Install dependencies (required before lint/test)
```

## Linting

```bash
yarn lint              # biome + prettier + editorconfig-checker + md-table
yarn lint:biome        # Biome only
yarn lint:prettier     # Prettier (YAML) check only
yarn lint:ec           # EditorConfig checker only
yarn lint:md-table     # Markdown table formatting check
yarn fix               # Autofix everything (biome + prettier + md-table)
yarn fix:md-table      # Auto-fix markdown tables
```

## Formatting

```bash
yarn fix:biome     # Autofix with biome (JS/TS/JSON/MD)
yarn fix:prettier  # Autofix with prettier (YAML)
yarn format        # Format with biome
yarn format:yaml   # Format YAML files with prettier
```

## Testing

```bash
yarn test                  # Run all tests (bash test-all.sh)
bats tests/dfm.bats        # Run a single test file (bats from PATH, via mise)
```

## Shell / Lua

```bash
shellcheck <script>     # Lint shell scripts
stylua config/nvim/     # Format neovim Lua files
```

## Pre-commit

```bash
pre-commit run --all-files
```

## Tooling maintenance

```bash
yarn dlx @biomejs/biome migrate --write   # Update biome schema version
```
