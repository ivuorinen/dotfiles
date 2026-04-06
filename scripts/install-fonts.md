# install-fonts

Install fonts from GitHub releases. Supports macOS and Linux.

## Usage

```bash
scripts/install-fonts.sh           # Install missing fonts
scripts/install-fonts.sh --force   # Re-download all fonts
dfm install fonts                  # Via dotfiles manager
```

## Fonts Installed

- JetBrainsMono Nerd Font (ryanoasis/nerd-fonts)
- OpenDyslexic Nerd Font (ryanoasis/nerd-fonts)
- Monaspace (githubnext/monaspace)
- FiraCode (tonsky/FiraCode)

## Adding Fonts

Edit the `FONTS` array at the top of the script. Each entry is
pipe-delimited:

```text
display_name|check_pattern|github_repo|version|asset_pattern
```

`version` can be `latest` or a pinned tag (e.g., `v3.3.0`).

## Font Directories

- **macOS:** `~/Library/Fonts`
- **Linux:** `~/.local/share/fonts`

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
