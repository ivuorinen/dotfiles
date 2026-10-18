# nvim-arborist

Remove arborist.nvim's leftovers after the switch to nvim-treesitter (`main`).

## Usage

```bash
scripts/cleanup/nvim-arborist.sh [--dry-run]
```

## What it does

Removes, under `$XDG_DATA_HOME/nvim` and `$XDG_CACHE_HOME/nvim`:

1. `site/parser` and `site/queries` — arborist's parsers and queries.
2. `arborist-lock.json`.
3. The `arborist` cache directory.

nvim-treesitter installs into the same `site/` directories, so any parsers it
built are removed too; it rebuilds them when a file of that language opens.
Close every nvim before running.

Pass `--dry-run` to preview what would be removed without making changes.
