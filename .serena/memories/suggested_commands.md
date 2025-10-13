# Essential Commands for .dotfiles Development

## Installation & Setup

```bash
# Initial setup - install linting tools and dependencies
yarn install

# Install/update all dotfiles configurations
./install

# Update git submodules (multiple approaches)
git submodule update --remote --merge
git submodule update --init --recursive --force
bash add-submodules.sh
```

## Development Commands

```bash
# Linting (run all linters - ALWAYS fix all issues)
yarn lint

# Individual linting commands
yarn lint:markdown    # Markdownlint
yarn lint:prettier    # Prettier check
yarn lint:ec          # EditorConfig checker

# Auto-fixing (use these BEFORE manual linting)
yarn fix              # Fix all format issues
yarn fix:markdown     # Fix markdown formatting
yarn fix:prettier     # Fix prettier formatting

# Testing
yarn test             # Run all Bats tests
bash test-all.sh      # Alternative test runner
```

## Pre-commit Hooks (Comprehensive)

Current pre-commit configuration includes:

- **Security**: detect-aws-credentials, detect-private-key
- **File integrity**: check-case-conflict, check-merge-conflict, check-symlinks
- **Shell scripts**: shellcheck, shfmt (formatting)
- **YAML/JSON**: yamllint, check-yaml, check-toml, pretty-format-json
- **Markdown**: markdownlint with auto-fix
- **Lua**: stylua formatting for Neovim configs
- **Fish**: fish_syntax, fish_indent for shell configs
- **GitHub Actions**: actionlint validation
- **Renovate**: renovate-config-validator
- **General**: trailing-whitespace, end-of-file-fixer, mixed-line-ending

```bash
# Run pre-commit manually
pre-commit run --all-files
```

## Version Management

```bash
# Check current versions
node --version        # Managed by nvm (.nvmrc: v20.18.1)
go version           # Managed by asdf (.go-version)
python --version     # Managed by asdf (.python-version)
```

## System Utilities (Darwin-specific)

```bash
# Modern CLI tools available
ls                   # aliased to eza with icons and git info
grep                 # aliased to grep --color
fd pattern           # modern find alternative
rg pattern           # ripgrep for text search
bat file            # modern cat with syntax highlighting
```

## Project-specific Scripts (100+ available)

```bash
# Dotfiles management
bash local/bin/dfm install all

# Git utilities
git-dirty            # Check for dirty git repositories
git-fsck-dirs        # Run fsck on git directories
git-update-dirs      # Update multiple git directories

# Development utilities
x-pr-comments <pr>   # Analyze GitHub PR comments (NEW)
x-set-php-aliases    # Generate PHP version aliases
x-env-list          # List environment variables
x-open-ports        # Check open network ports

# Backup utilities
x-backup-folder     # Backup directories
x-backup-mysql-with-prefix  # MySQL backup with prefix
```

## Configuration Management

```bash
# Load shell configurations
source config/shared.sh      # Cross-shell compatibility functions
source x-set-php-aliases     # PHP version management

# Host-specific configurations
# Automatically applied: hosts/{hostname}/
```

## Quality Assurance (CRITICAL)

**All linting errors are BLOCKING and must be fixed:**

- EditorConfig violations are considered blocking errors
- ShellCheck warnings must be addressed
- Prettier formatting must be consistent
- Markdownlint rules must be followed
- NEVER use --no-verify with git operations
- ALWAYS run autofixers before manual intervention
