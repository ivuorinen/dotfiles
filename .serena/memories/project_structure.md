# Project Structure

## Root Directory

```text
.dotfiles/
├── install                 # Main installation script (Dotbot runner)
├── install.conf.yaml      # Dotbot configuration
├── package.json           # Node.js dependencies for linting/testing (Yarn managed)
├── AGENTS.md              # Project documentation and guidelines
├── test-all.sh            # Bats test runner
├── add-submodules.sh      # Git submodule management
└── .serena/               # Claude Code/Serena analysis cache (new)
```

## Main Directories

### `config/` (74+ subdirectories)

Configuration files for development tools and applications:

- `git/` - Git configuration with delta integration and everforest theme
- `nvim/` - Neovim configuration with Lua plugins
- `tmux/` - Tmux configuration with multiple plugins (dark-notify, window-name, etc.)
- `fish/` - Fish shell configuration with completions and functions
- `zsh/` - Zsh configuration with antidote plugin manager
- `fzf/` - Fuzzy finder configuration with everforest theme
- `wezterm/` - WezTerm terminal configuration
- `homebrew/` - Homebrew environment configuration
- `starship.toml` - Starship prompt configuration
- `shared.sh` - Cross-shell compatibility functions
- `aerospace/`, `amethyst/`, `yabai/`, `skhd/` - Window managers
- `direnv/`, `asdf/`, `aqua/` - Development environment tools
- `gpg-tui/`, `op/`, `gh/` - Security and CLI tools
- Theme configurations: everforest color schemes across multiple tools

### `base/`

Dotfiles that get symlinked to home directory with `.` prefix:

- Contains traditional dotfiles like `.bashrc`, `.zshrc`, etc.
- `plan` - Planning/note-taking configuration
- `shellcheckrc` - ShellCheck rules

### `local/`

- `bin/` - 100+ custom scripts with comprehensive documentation
  - Homegrown utilities (dfm, git tools, backup scripts, etc.)
  - Sourced utilities (from skx/sysadmin-util, mvdan/dotfiles)
  - Each script has corresponding .md documentation
  - Recent additions: x-pr-comments for GitHub PR analysis
- `share/fonts/` - JetBrains Mono font files
- `man/` - Manual pages

### `ssh/`

SSH configuration files (mode 0600/0700)

- `shared.d/` - Shared SSH configurations for specific hosts

### `tools/` (Git submodules)

External tools and Dotbot plugins:

- `dotbot/` - Dotbot installation framework
- `dotbot-*` - Dotbot plugins (asdf, brew, include, pip)
- `antidote/` - Zsh plugin manager
- Various tmux plugins (continuum, resurrect, yank, etc.)

### `hosts/`

Host-specific configurations:

- `air/`, `s/`, `v/` - Individual host configurations
- Applied after main configuration

### `secrets/`

Secret and credential management configuration

### `scripts/`

Installation and setup automation scripts

### `.github/`

- GitHub Actions workflows
- Renovate configuration
- Issue templates and documentation

### Development Configuration Files

- `.editorconfig` - Editor configuration rules
- `.prettierrc.js` - Prettier formatting rules
- `.eslintrc.json` - ESLint linting rules
- `.commitlintrc.json` - Commit message linting
- `.shellcheckrc` - ShellCheck configuration
- `.mega-linter.yml` - MegaLinter configuration
- `.luarc.json` - Lua language server configuration
- `.nvmrc`, `.go-version`, `.python-version` - Version management
- Various ignore files (.gitignore, .prettierignore, .yamlignore, etc.)

## Testing Infrastructure

- `tests/` - Bats test files
- `test-all.sh` - Main test runner
- Pre-commit hooks for automated testing
- GitHub Actions for CI/CD

## Recent Structural Changes

- Husky configuration moved from `base/huskyrc` to `config/husky/init.sh`
- Addition of everforest theme configurations across multiple tools
- New .serena directory for AI analysis caching
- Multiple temporary fish configuration files (everforest themes)
- Enhanced git configuration with delta and everforest theming
