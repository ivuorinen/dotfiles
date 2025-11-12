# Migration Guide: Dotbot to Chezmoi

This guide documents the migration from dotbot to chezmoi for managing dotfiles.

## Table of Contents

1. [Why Migrate to Chezmoi?](#why-migrate-to-chezmoi)
2. [Key Differences](#key-differences)
3. [Dotbot to Chezmoi Mapping](#dotbot-to-chezmoi-mapping)
4. [New File Structure](#new-file-structure)
5. [Migration Steps](#migration-steps)
6. [Usage Guide](#usage-guide)
7. [Troubleshooting](#troubleshooting)

## Why Migrate to Chezmoi?

Chezmoi offers several advantages over dotbot:

- **Built-in templating**: Use Go templates for dynamic configuration
- **Secret management**: Native support for password managers (1Password, LastPass, etc.)
- **Cross-platform**: Better support for managing dotfiles across different OS and machines
- **State tracking**: Chezmoi tracks what it manages more precisely
- **Active development**: Regular updates and large community
- **No dependencies**: Single binary, no Python required

## Key Differences

### Philosophy

**Dotbot**:
- Configuration-driven (YAML files)
- Manages symlinks from a source directory
- Plugins extend functionality

**Chezmoi**:
- Source-state driven
- Copies files to home directory (can also use symlinks)
- Built-in templating for dynamic content
- Manages the entire lifecycle of dotfiles

### Directory Structure

**Dotbot**:
```
~/.dotfiles/
├── base/          # Files symlinked to ~/.*
├── config/        # Files symlinked to ~/.config/
├── local/         # Scripts and local files
├── install        # Installation script
└── install.conf.yaml  # Configuration
```

**Chezmoi**:
```
~/.local/share/chezmoi/  # Source directory
├── .chezmoi.yaml.tmpl   # Configuration template
├── .chezmoiignore       # Files to ignore
├── run_once_*.sh.tmpl   # One-time setup scripts
├── run_*.sh.tmpl        # Scripts that run on every apply
├── dot_bashrc           # Becomes ~/.bashrc
├── dot_config/          # Becomes ~/.config/
└── private_dot_ssh/     # Becomes ~/.ssh/ with 0700
```

## Dotbot to Chezmoi Mapping

### 1. Link Directives

**Dotbot** (install.conf.yaml):
```yaml
- link:
    ~/.bashrc: base/bashrc
    ~/.config/fish: config/fish
```

**Chezmoi**:
- Files are automatically managed based on their names in the source directory
- `dot_bashrc` → `~/.bashrc`
- `dot_config/fish/` → `~/.config/fish/`
- Use `symlink_` prefix for symlinks: `symlink_dot_vim` → symlinked `~/.vim`

### 2. Create Directives

**Dotbot**:
```yaml
- create:
    ~/.ssh:
      mode: 0700
    ~/.local/bin:
```

**Chezmoi**:
- Create a `run_once_after_create-directories.sh.tmpl` script
- Or use `.chezmoitemplates` for reusable directory creation
- Chezmoi automatically creates parent directories

### 3. Shell Commands

**Dotbot**:
```yaml
- shell:
    - git submodule update --init --recursive
    - bash local/bin/dfm install all
```

**Chezmoi**:
- Use `run_once_*.sh.tmpl` for one-time setup scripts
- Use `run_*.sh.tmpl` for scripts that run every time
- Use `run_before_*.sh` for scripts that run before applying
- Use `run_after_*.sh` for scripts that run after applying

### 4. Clean Directives

**Dotbot**:
```yaml
- clean:
    ~/:
    ~/.config:
      recursive: true
```

**Chezmoi**:
- Chezmoi doesn't automatically remove files
- Use `chezmoi unmanaged` to see unmanaged files
- Manually remove or add to `.chezmoiignore`

### 5. Host-Specific Configuration

**Dotbot**:
```yaml
# hosts/air/install.conf.yaml
- link:
    ~/.config/:
      path: hosts/air/config/**
```

**Chezmoi**:
- Use templates with conditionals:
```
{{ if eq .chezmoi.hostname "air" }}
# air-specific content
{{ end }}
```
- Or use separate files: `dot_config/file.tmpl` with hostname checks

### 6. Dotbot Plugins

**dotbot-brew**:
- Replace with `run_once_after_install-packages.sh.tmpl`
- Use `brew bundle install`

**dotbot-asdf**:
- Chezmoi doesn't have built-in asdf support
- Use `run_once_after_*.sh` scripts to install asdf plugins

**dotbot-pip/pipx**:
- Use `run_once_after_*.sh` scripts
- Or use chezmoi's external management

## New File Structure

### Configuration Files

#### `.chezmoi.yaml.tmpl`
Main configuration file with template support. Defines:
- Source directory
- Data variables (hostname, OS, custom flags)
- Merge strategy
- Template options
- Git options

#### `.chezmoiignore`
Files and patterns to ignore when applying dotfiles. Includes:
- Repository management files (.git, .github, etc.)
- Documentation
- Development tools
- Old dotbot configuration

### Run Scripts

Scripts follow a naming convention:

- `run_once_before_*.sh.tmpl`: Runs once before applying (prerequisites)
- `run_once_after_*.sh.tmpl`: Runs once after applying (installation)
- `run_before_*.sh.tmpl`: Runs every time before applying
- `run_after_*.sh.tmpl`: Runs every time after applying
- `run_onchange_*.sh.tmpl`: Runs when file content changes

### File Naming

Chezmoi uses special prefixes:

- `dot_`: Becomes a dot file (`.`)
- `private_`: Sets permissions to 0600
- `executable_`: Makes file executable
- `symlink_`: Creates a symlink
- `readonly_`: Makes file read-only

Examples:
- `dot_bashrc` → `~/.bashrc`
- `private_dot_ssh/` → `~/.ssh/` (mode 0700)
- `executable_dot_local/bin/script` → `~/.local/bin/script` (executable)

## Migration Steps

### 1. Backup Current Setup

```bash
# Backup your current dotfiles
cd ~/.dotfiles
git add -A
git commit -m "Backup before chezmoi migration"
git push
```

### 2. Install Chezmoi

```bash
# The new install script will do this automatically
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply ivuorinen
```

### 3. Initialize Chezmoi with Existing Dotfiles

```bash
# If you want to test before full migration
chezmoi init --apply ivuorinen

# Or initialize without applying
chezmoi init ivuorinen
```

### 4. Restructure Files (Manual Step)

You'll need to rename files to follow chezmoi conventions:

```bash
cd ~/.local/share/chezmoi

# Rename base files
mv base/bashrc dot_bashrc
mv base/zshrc dot_zshrc
mv base/tmux.conf dot_tmux.conf

# Move config files
mkdir -p dot_config
mv config/* dot_config/

# Move local/bin files
mkdir -p dot_local/bin
for file in local/bin/*; do
  mv "$file" "executable_dot_local/bin/$(basename "$file")"
done

# Move SSH files with proper permissions
mkdir -p private_dot_ssh
mv ssh/* private_dot_ssh/
```

### 5. Convert Host-Specific Configurations

For files that differ between hosts, use templates:

```bash
# Instead of hosts/air/config/fish/config.fish
# Create: dot_config/fish/config.fish.tmpl

{{ if eq .chezmoi.hostname "air" }}
# air-specific configuration
{{ else if eq .chezmoi.hostname "lakka" }}
# lakka-specific configuration
{{ end }}
```

### 6. Test the Migration

```bash
# See what changes chezmoi would make
chezmoi diff

# Apply changes
chezmoi apply

# Verify everything works
chezmoi verify
```

### 7. Clean Up Old Files

```bash
# Remove dotbot directories (after confirming everything works)
cd ~/.local/share/chezmoi
rm -rf tools/dotbot tools/dotbot-*
rm install.conf.yaml
rm -rf hosts/  # If fully migrated to templates
```

## Usage Guide

### Basic Commands

```bash
# Initialize chezmoi with your dotfiles
chezmoi init ivuorinen

# See what changes would be made
chezmoi diff

# Apply dotfiles
chezmoi apply

# Apply with verbose output
chezmoi apply -v

# Edit a file managed by chezmoi
chezmoi edit ~/.bashrc

# Add a new file to chezmoi
chezmoi add ~/.newfile

# Update dotfiles from source
chezmoi update

# See what files are managed
chezmoi managed

# See what files are unmanaged
chezmoi unmanaged

# Re-run scripts
chezmoi apply --force

# Check for issues
chezmoi doctor
```

### Working with Templates

```bash
# Execute a template
chezmoi execute-template "{{ .chezmoi.hostname }}"

# See the data available in templates
chezmoi data

# Edit template data
chezmoi edit-config
```

### Managing Secrets

```bash
# Use with 1Password
chezmoi secret keychain

# Template with 1Password
{{ (index (onepasswordDocument "my-secret") 0).content }}

# Use with environment variables
{{ .Env.MY_SECRET }}
```

### Updating Dotfiles

```bash
# Edit source file
chezmoi edit ~/.bashrc

# Or edit directly and add
vi ~/.bashrc
chezmoi add ~/.bashrc

# Commit changes
cd $(chezmoi source-path)
git add -A
git commit -m "Update bashrc"
git push

# On another machine
chezmoi update
```

## Troubleshooting

### Common Issues

#### 1. File Permissions

**Problem**: Files have wrong permissions after applying.

**Solution**: Use prefixes:
```bash
# For 0600 permissions
chezmoi add --template private_dot_ssh/config

# For 0700 directories
mkdir -p private_dot_ssh
```

#### 2. Symlinks Not Working

**Problem**: Chezmoi copies files instead of symlinking.

**Solution**: Use `symlink_` prefix:
```bash
chezmoi add --symlink ~/.vim
# This creates symlink_dot_vim in the source directory
```

#### 3. Templates Not Rendering

**Problem**: Template syntax is showing literally in files.

**Solution**:
- Ensure file has `.tmpl` extension
- Check template syntax
- Verify data with `chezmoi data`

#### 4. Scripts Not Running

**Problem**: `run_once_` scripts not executing.

**Solution**:
- Check script permissions: `chmod +x run_once_*.sh.tmpl`
- Run with force: `chezmoi apply --force`
- Check script order (before/after)

#### 5. Host-Specific Files Not Applying

**Problem**: Wrong host configuration applied.

**Solution**:
- Check hostname: `chezmoi data | grep hostname`
- Verify template conditionals
- Use `.chezmoiignore` for host-specific exclusions

### Debugging

```bash
# Verbose output
chezmoi apply -v

# Very verbose output
chezmoi apply -vv

# Dry run to see what would happen
chezmoi apply --dry-run -v

# Check configuration
chezmoi doctor

# Verify state
chezmoi verify

# See source directory
chezmoi source-path

# See what would be applied to a specific file
chezmoi cat ~/.bashrc
```

### Migration Checklist

- [ ] Backup current dotfiles
- [ ] Install chezmoi
- [ ] Create `.chezmoi.yaml.tmpl`
- [ ] Create `.chezmoiignore`
- [ ] Rename files with proper prefixes
- [ ] Convert host-specific configs to templates
- [ ] Create `run_once_before` scripts
- [ ] Create `run_once_after` scripts
- [ ] Test with `chezmoi diff`
- [ ] Apply with `chezmoi apply`
- [ ] Verify everything works
- [ ] Update documentation
- [ ] Clean up old dotbot files
- [ ] Update README.md
- [ ] Test on another machine

## Additional Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Chezmoi User Guide](https://www.chezmoi.io/user-guide/)
- [Chezmoi Template Reference](https://www.chezmoi.io/reference/templates/)
- [Example Dotfiles Using Chezmoi](https://github.com/topics/chezmoi)

## Notes

### What Stays the Same

- Your actual dotfile contents
- Directory structure in home directory
- Git workflow for managing dotfiles
- The `dfm` script functionality (wrapped in run_once scripts)

### What Changes

- Installation method (new `install` script)
- Source directory location (`~/.local/share/chezmoi` by default)
- Configuration method (templates instead of YAML)
- File naming (special prefixes)
- No more symlinks by default (unless specified)

### Benefits of Migration

1. **Simplicity**: Single binary, no dependencies
2. **Templating**: Dynamic content based on hostname, OS, etc.
3. **Secrets**: Built-in support for password managers
4. **State Management**: Better tracking of what's managed
5. **Cross-platform**: Excellent support for different OSes
6. **Documentation**: Extensive docs and examples
7. **Community**: Active development and support

## Post-Migration

After successful migration:

1. Update your README to reflect chezmoi usage
2. Archive dotbot configuration for reference
3. Document any custom scripts or workflows
4. Test on all your machines
5. Share your experience!
