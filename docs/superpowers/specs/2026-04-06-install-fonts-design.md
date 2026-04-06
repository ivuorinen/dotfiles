# install-fonts.sh — Cross-Platform Font Installer

**Date:** 2026-04-06
**Status:** Design approved

## Purpose

Replace the deprecated nerd-fonts `install.sh`-based font installer
with a cross-platform script that downloads fonts from multiple GitHub
repositories. Supports macOS and Linux.

## Files

| File                       | Purpose                         |
|----------------------------|---------------------------------|
| `scripts/install-fonts.sh` | Replaces existing script        |
| `scripts/install-fonts.md` | Updated companion documentation |

## Dependencies

- `curl` — download release assets
- `unzip` — extract font archives
- `fc-cache` — refresh font cache (Linux only)
- `msgr` — colored output (sourced with fallback)
- `gh` — GitHub API (optional, falls back to anonymous curl)

## CLI Interface

```
Usage: install-fonts.sh [--force] [--help]

  --force    Re-download and reinstall all fonts
  --help     Show usage information
```

No per-font selection. Always processes the full list.

## Font Registry

Array at the top of the script. Pipe-delimited fields:

```
display_name|check_pattern|github_repo|version|asset_pattern
```

- **display_name**: Human-readable name for output
- **check_pattern**: Glob matched against font dir to detect installed
- **github_repo**: GitHub `owner/repo`
- **version**: `latest` or pinned tag (e.g., `v3.3.0`)
- **asset_pattern**: Matched against release asset filenames

Initial font list:

```bash
FONTS=(
  "JetBrainsMono NF|JetBrainsMonoNL*|ryanoasis/nerd-fonts|latest|JetBrainsMono.zip"
  "OpenDyslexic NF|OpenDyslexic*|ryanoasis/nerd-fonts|latest|OpenDyslexic.zip"
  "Monaspace|Monaspace*|githubnext/monaspace|latest|monaspace-*.zip"
  "FiraCode|FiraCode*|tonsky/FiraCode|latest|Fira_Code_*.zip"
)
```

Adding a font = adding one line.

## Font Directory

- **macOS:** `~/Library/Fonts`
- **Linux:** `~/.local/share/fonts`

## Installation Flow

For each font in the registry:

1. Check if `check_pattern` matches files in font dir. Skip if
   found, unless `--force`.
2. Resolve release URL via `gh api repos/{repo}/releases/latest`
   (preferred) or anonymous `curl` to GitHub API.
3. Find asset matching `asset_pattern` from release JSON.
4. Download ZIP to temp dir.
5. Extract `.ttf`, `.otf`, and `.woff2` files to font dir
   (flatten nested directories).
6. Clean up temp dir.

After all fonts processed:

- **Linux:** Run `fc-cache -f`
- **macOS:** No action needed (automatic pickup)

## Error Handling

- Missing `curl` or `unzip`: `msgr err` + exit 1
- Network failure on a single font: `msgr warn` + continue to next
- GitHub API rate limit: warn and suggest using `gh auth login`
- No matching asset in release: `msgr err` for that font, continue

## Integration

`dfm install fonts` already calls
`bash "$DOTFILES/scripts/install-fonts.sh"` — no changes needed.

## Script Conventions

- `#!/usr/bin/env bash` with `set -euo pipefail`
- Sources `msgr` with `set +u` guard and `declare -f` fallback
- Function-based structure
- `@description` tag for `dfm scripts` discovery
- Follows shfmt settings from `.editorconfig`

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
