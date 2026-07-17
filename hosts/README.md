# Host specific directories

Host folders contain machine specific overrides and an `install.conf.yaml` file that Dotbot processes during setup.

Current hosts:

- **air** – personal computer
- **lakka** – remote server
- **s** – work laptop
- **tunkki** – local server
- **v** – work desktop

## Lifecycle hooks (`before.d` / `after.d`)

`./install` runs host-specific hook scripts if either folder exists:

- `hosts/<host>/before.d/*` — run **before** the main `install.conf.yaml`
- `hosts/<host>/after.d/*` — run **after** all Dotbot configs are applied

Rules:

- Scripts run in **alphabetical order** (prefix with `10-`, `20-`, … to control sequence).
- Scripts must be **executable** (`chmod +x`); non-executable files are skipped with a warning.
- A failing hook is **logged but does not abort** the install — the next hook and the rest of the run continue.
- `$DOTFILES` is exported so hooks can locate the repo.
- Hooks run only during a full `./install`, not `./install --links`.
