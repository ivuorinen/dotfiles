# Host specific directories

Host folders contain machine specific overrides and an `install.conf.yaml` file that Dotbot processes during setup.

Current hosts:

- **air** – personal computer
- **lakka** – remote server
- **s** – work laptop
- **tunkki** – local server
- **twonky** – Electron flags and wallpaper overlay
- **v** – work desktop

## Overlay layout

- `hosts/<host>/base/**` links into `~/` (with a `.` prefix) and `hosts/<host>/config/**` into `~/.config/`,
  both with `force: true`.
- When `~/.config/<app>` is a symlink into this repo (fish, git, …), a file under
  `hosts/<host>/config/<app>/` links onto the matching path in `config/<app>/`. That is only safe on a
  gitignored path (as `hosts/s/config/git/` does); on a tracked file the forced link replaces it.
- Host fish exports therefore live at `hosts/<host>/fish/exports.fish` (and the gitignored
  `exports-secret.fish`); `config/fish/exports.fish` sources them by repo path.
- lakka's exports used to sit at `hosts/lakka/config/fish/exports.fish`, so on a checkout that already ran
  `./install` the forced link replaced the tracked `config/fish/exports.fish` with a symlink. `git pull`
  then aborts on the typechange, and a forced pull leaves a dangling link that the next `./install` cleans
  away, starting fish with no exports. Restore the tracked file before pulling:
  `git -C ~/.dotfiles checkout -- config/fish/exports.fish && git -C ~/.dotfiles pull`.
- The host `install.conf.yaml` runs on both a full `./install` and `./install --links`. With `--links` its
  `shell` directives are skipped (dotbot `--except shell`), so only links are refreshed. Host configs load
  only the `dotbot-include` plugin, so a directive from any other plugin aborts the install.

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
