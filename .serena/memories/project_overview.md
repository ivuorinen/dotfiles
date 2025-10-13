# .dotfiles Project Overview

## Purpose

This is a comprehensive personal dotfiles repository for managing development
environment configurations across macOS systems. The project uses **Dotbot** as
the primary installation framework to manage symlinks and setup configurations.

## Key Features

- Automated configuration management using Dotbot
- Support for multiple development tools and applications
- Host-specific configurations in `/hosts/` directory
- Comprehensive testing and linting setup with pre-commit hooks
- Cross-shell compatibility (bash, zsh, fish)
- Large collection of custom utility scripts in `local/bin/`
- Git submodules for external tools (dotbot, antidote, tmux plugins)
- Environment-specific configurations (secrets management)

## Recent Notable Changes (from git status)

- New everforest color theme configurations added
- Multiple temporary fish configuration files present
- Updates to various configuration files (.commitlintrc.json, .eslintrc.json, etc.)
- New x-pr-comments script and documentation added
- Various tmux plugin updates
- Husky configuration relocated from base/ to config/husky/

## Tech Stack

- **Shell**: Bash (primary), with Fish and Zsh support
- **Configuration Manager**: Dotbot with plugins (asdf, brew, include, pip)
- **Package Manager**: Yarn 1.22.22 (Node.js), Homebrew (macOS), pipx (Python)
- **Testing**: Bats test framework, custom test-all.sh script
- **Linting**: MegaLinter, Prettier, ESLint, Markdownlint, ShellCheck, EditorConfig
- **Automation**: Pre-commit hooks, GitHub Actions, Renovate

## Project Structure Highlights

- `/config/` - Main configuration directory (74+ subdirectories)
- `/local/bin/` - Custom utility scripts (100+ scripts with documentation)
- `/hosts/` - Host-specific configurations
- `/tools/` - Git submodules for external tools
- `/base/` - Base configuration files
- `/secrets/` - Secret management configurations
- `/scripts/` - Installation and setup scripts
- `/.github/` - GitHub Actions workflows and configurations

## Target System

- **Platform**: Darwin (macOS) - Version 24.6.0
- **Architecture**: Universal (Intel/Apple Silicon via Homebrew)
- **Dependencies**: Git, Homebrew, Yarn, various CLI tools managed via asdf/aqua

## Development Environment

- Node.js managed via nvm/asdf
- Go version specified (.go-version)
- Python version specified (.python-version)
- Package management via Yarn with lockfile
- TypeScript support for configuration files
