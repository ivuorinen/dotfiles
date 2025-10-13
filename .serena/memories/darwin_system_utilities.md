# Darwin (macOS) System Utilities

## Available Command Paths

Based on the current system setup:

### Core System Commands

- `git`: `/opt/homebrew/bin/git` (Homebrew version)
- `find`: `/usr/bin/find` (system version)
- `cd`: shell built-in command
- `ls`: aliased to `eza -h -s=type --git --icons --group-directories-first`
- `grep`: aliased to `grep --color`

### Modern Alternatives (Rust-based)

- `fd`: `/Users/ivuorinen/.local/share/cargo/bin/fd` (modern find)
- `rg`: `/Users/ivuorinen/.local/share/cargo/bin/rg` (ripgrep for text search)

## Recommended Usage Patterns

### File Search

```bash
# Use fd instead of find when possible
fd "*.sh"                    # Find shell scripts
fd -t f -e lua              # Find Lua files
find . -name "*.sh"         # Fallback to system find
```

### Text Search

```bash
# Use rg (ripgrep) instead of grep when possible
rg "function.*bash"         # Search for bash functions
rg -t shell "export"        # Search in shell files only
grep "pattern" file.txt     # Fallback to system grep
```

### Directory Navigation

```bash
# Use eza features via ls alias
ls                          # Shows icons, git status, grouped directories
ls -la                      # Long format with hidden files
cd /full/path               # Always use full paths in scripts
```

## Path Configuration

The system is configured with these PATH priorities:

1. `~/.local/bin` (user scripts)
2. `~/.dotfiles/local/bin` (dotfiles scripts)
3. `~/.local/share/bob/nvim-bin` (Neovim)
4. `~/.local/share/cargo/bin` (Rust tools like fd, rg)
5. `/opt/homebrew/bin` (Homebrew packages)
6. `/usr/local/bin` (system packages)

## Shell Compatibility

The dotfiles support multiple shells through `config/shared.sh`:

- Functions prefixed with `x-` work across bash, zsh, and fish
- Path management handled automatically per shell
- Environment variables set appropriately per shell
