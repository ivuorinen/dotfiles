# Chezmoi Quick Reference

Quick reference guide for common chezmoi operations with your dotfiles.

## Installation

```bash
# Fresh install on a new machine
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply ivuorinen

# Or if chezmoi is already installed
chezmoi init --apply ivuorinen
```

## Daily Workflow

### Making Changes

```bash
# Edit a dotfile (opens in $EDITOR)
chezmoi edit ~/.bashrc

# Or edit directly and add to chezmoi
vim ~/.bashrc
chezmoi add ~/.bashrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply
```

### Syncing Across Machines

```bash
# On machine A: commit and push changes
cd $(chezmoi source-path)
git add -A
git commit -m "Update configuration"
git push

# On machine B: pull and apply changes
chezmoi update
# This is equivalent to:
# cd $(chezmoi source-path) && git pull && chezmoi apply
```

## Common Commands

### Viewing and Inspecting

```bash
# See what chezmoi would do
chezmoi diff

# List all managed files
chezmoi managed

# List unmanaged files
chezmoi unmanaged

# Show the source path
chezmoi source-path

# Show what a file would look like after templating
chezmoi cat ~/.bashrc

# Show available template data
chezmoi data
```

### Adding and Removing Files

```bash
# Add a file
chezmoi add ~/.newfile

# Add a file as a template
chezmoi add --template ~/.newfile

# Add a directory recursively
chezmoi add --recursive ~/.config/newapp

# Add with autodetection (templates, scripts, etc.)
chezmoi add --autotemplate ~/.newfile

# Stop managing a file (removes from chezmoi)
chezmoi forget ~/.oldfile

# Remove a file from both chezmoi and home directory
chezmoi remove ~/.oldfile
```

### Working with Templates

```bash
# Execute a template expression
chezmoi execute-template "{{ .chezmoi.hostname }}"

# Edit template data
chezmoi edit-config

# Verify templates
chezmoi verify
```

### Applying Changes

```bash
# Apply all changes
chezmoi apply

# Apply with verbose output
chezmoi apply -v

# Dry run (show what would happen)
chezmoi apply --dry-run -v

# Force apply (re-runs scripts)
chezmoi apply --force

# Apply only specific files
chezmoi apply ~/.bashrc ~/.zshrc
```

### Updating from Repository

```bash
# Update dotfiles from repository
chezmoi update

# Update but don't apply
cd $(chezmoi source-path) && git pull

# Update with interactive merge
chezmoi update --interactive
```

## File Naming Conventions

### Basic Prefixes

| Source File | Destination | Description |
|------------|-------------|-------------|
| `dot_bashrc` | `~/.bashrc` | Dot file |
| `dot_config/` | `~/.config/` | Dot directory |
| `private_dot_ssh/` | `~/.ssh/` | Private directory (0700) |
| `executable_dot_local/bin/script` | `~/.local/bin/script` | Executable |
| `symlink_dot_vim` | `~/.vim` | Symlink |
| `readonly_dot_file` | `~/.file` | Read-only |

### Template Files

| Source File | Description |
|------------|-------------|
| `dot_bashrc.tmpl` | Template file |
| `dot_config/fish/config.fish.tmpl` | Nested template |

### Scripts

| Script Name | When It Runs |
|------------|--------------|
| `run_once_before_*.sh` | Once before applying |
| `run_once_after_*.sh` | Once after applying |
| `run_before_*.sh` | Every time before applying |
| `run_after_*.sh` | Every time after applying |
| `run_onchange_*.sh` | When script content changes |

## Template Syntax

### Basic Variables

```go
// Hostname
{{ .chezmoi.hostname }}

// Username
{{ .chezmoi.username }}

// Operating system
{{ .chezmoi.os }}

// Home directory
{{ .chezmoi.homeDir }}

// Source directory
{{ .chezmoi.sourceDir }}

// Custom data from .chezmoi.yaml
{{ .is_macos }}
{{ .is_linux }}
```

### Conditionals

```go
{{ if eq .chezmoi.hostname "air" }}
# Configuration for air
{{ else if eq .chezmoi.hostname "lakka" }}
# Configuration for lakka
{{ else }}
# Default configuration
{{ end }}

{{ if .is_macos }}
# macOS-specific
{{ end }}

{{ if and .is_macos (eq .chezmoi.hostname "air") }}
# macOS on air
{{ end }}
```

### Loops

```go
{{ range $key, $value := .data }}
{{ $key }}: {{ $value }}
{{ end }}
```

### Including Files

```go
{{ include "template-file.txt" }}
{{ includeTemplate "template-file.tmpl" }}
```

## Host-Specific Configuration

### Method 1: Template Conditionals

In `dot_bashrc.tmpl`:
```bash
# Common configuration
export PATH="$HOME/.local/bin:$PATH"

{{ if eq .chezmoi.hostname "air" }}
# air-specific configuration
export WORK_DIR="$HOME/Work"
{{ end }}

{{ if eq .chezmoi.hostname "lakka" }}
# lakka-specific configuration
export WORK_DIR="$HOME/Projects"
{{ end }}
```

### Method 2: Separate Files with Symlinks

Use `.chezmoiignore` to exclude files for specific hosts:

```
{{ if ne .chezmoi.hostname "air" }}
dot_config/air-specific-app/
{{ end }}

{{ if ne .chezmoi.hostname "lakka" }}
dot_config/lakka-specific-app/
{{ end }}
```

## Working with Secrets

### Environment Variables

```go
{{ .Env.MY_SECRET }}
```

### 1Password

```go
{{ (onepasswordDocument "my-secret").content }}
{{ (onepasswordItemFields "my-item").password.value }}
```

### External Commands

```go
{{ output "op" "read" "op://vault/item/field" }}
```

## Troubleshooting

### Check Configuration

```bash
# Verify chezmoi is working correctly
chezmoi doctor

# Check state
chezmoi verify

# See detailed info
chezmoi data
```

### Debug Templates

```bash
# See what a template would produce
chezmoi cat ~/.bashrc

# Execute a template
chezmoi execute-template "{{ .chezmoi.hostname }}"

# Verbose output
chezmoi apply -v
```

### Fix Issues

```bash
# Re-apply everything
chezmoi apply --force

# Reset state (dangerous!)
chezmoi state reset

# Clear cache
rm -rf $(chezmoi source-path)/.git/chezmoi-*
```

### Common Errors

**Error: template: ... undefined variable**
- Check template syntax
- Verify data with `chezmoi data`

**Error: entry ... is not in source state**
- File not added to chezmoi: `chezmoi add <file>`

**Error: ... has been modified since chezmoi last wrote it**
- See changes: `chezmoi diff`
- Re-add: `chezmoi add <file>`
- Or force apply: `chezmoi apply --force`

## Useful Aliases

Add these to your shell configuration:

```bash
# Chezmoi shortcuts
alias cm='chezmoi'
alias cma='chezmoi apply'
alias cmd='chezmoi diff'
alias cme='chezmoi edit'
alias cmu='chezmoi update'
alias cmcd='cd $(chezmoi source-path)'

# Common workflows
alias cmup='chezmoi git pull && chezmoi apply'
alias cmpush='cd $(chezmoi source-path) && git add -A && git commit && git push'
```

## Environment Variables

```bash
# Change source directory (default: ~/.local/share/chezmoi)
export CHEZMOI_SOURCE_DIR="$HOME/.dotfiles"

# Change config file location
export CHEZMOI_CONFIG_FILE="$HOME/.config/chezmoi/chezmoi.yaml"

# Use different editor
export EDITOR="vim"
```

## Advanced Usage

### Using chezmoi as a dotfiles manager

```bash
# Initialize with local directory
chezmoi init --source ~/.dotfiles

# Use current directory as source
chezmoi init --source $(pwd)
```

### Managing Multiple Machines

Use data in `.chezmoi.yaml.tmpl`:

```yaml
data:
  is_work_machine: {{ or (eq .chezmoi.hostname "work-laptop") (eq .chezmoi.hostname "work-desktop") }}
  is_personal: {{ eq .chezmoi.hostname "personal-laptop" }}
```

Then in templates:

```go
{{ if .is_work_machine }}
# Work configuration
{{ end }}
```

### External Files

```yaml
# .chezmoiexternal.yaml
".config/nvim/lua/plugins":
  type: "archive"
  url: "https://github.com/user/nvim-config/archive/main.tar.gz"
  stripComponents: 1
  refreshPeriod: "168h"
```

## Resources

- [Official Documentation](https://www.chezmoi.io/)
- [User Guide](https://www.chezmoi.io/user-guide/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
- [Command Reference](https://www.chezmoi.io/reference/commands/)
- [FAQ](https://www.chezmoi.io/faq/)

## Help

```bash
# General help
chezmoi help

# Command-specific help
chezmoi help apply
chezmoi help add

# Show version
chezmoi --version
```
