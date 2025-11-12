# Chezmoi Migration Summary

## What Was Done

Your dotfiles repository has been prepared for migration from dotbot to chezmoi. Here's what was created:

### 1. Updated Install Script
- **File**: `install`
- **Change**: Now uses chezmoi's one-line installer
- **Command**: `sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply ivuorinen`

### 2. Chezmoi Configuration Files

#### `.chezmoi.yaml.tmpl`
Main configuration file that includes:
- Source directory configuration
- Host detection (air, lakka, tunkki, s)
- OS detection (macOS, Linux)
- Custom data variables for templates
- Merge and diff settings
- Git configuration
- Pre-read hook for submodule updates

#### `.chezmoiignore`
Specifies what files should NOT be managed by chezmoi:
- Git and GitHub files
- Documentation (*.md files)
- Development tools (.vscode, node_modules, etc.)
- Old dotbot configuration
- Host-specific files (via templates)
- Repository management files

### 3. Run Scripts (Automated Setup)

#### `run_once_before_install-prerequisites.sh.tmpl`
Runs **once before** applying dotfiles:
- Installs Homebrew (macOS)
- Installs Xcode CLI tools (macOS)
- Updates package manager (Linux)

#### `run_once_after_install-packages.sh.tmpl`
Runs **once after** applying dotfiles:
- Installs Homebrew packages (Brewfile)
- Sets macOS defaults
- Installs apt packages (Linux)
- Installs pipx packages

#### `run_once_after_setup-languages.sh.tmpl`
Runs **once after** applying dotfiles:
- Installs fonts
- Installs Cargo packages (Rust)
- Installs Go packages
- Installs Composer (PHP)
- Installs NVM and latest Node LTS
- Installs NPM packages
- Installs GitHub CLI extensions
- Installs z (directory jumper)
- Installs cheat databases

#### `run_once_after_create-directories.sh.tmpl`
Runs **once after** applying dotfiles:
- Creates required directories in `$HOME`
- Sets proper permissions (e.g., `.ssh` → 0700)

### 4. Hooks

#### `.chezmoihooks/pre-read-source-state.sh`
Runs before chezmoi reads the source state:
- Updates git submodules automatically

### 5. Documentation

#### `MIGRATION-DOTBOT-TO-CHEZMOI.md` (66KB)
Comprehensive migration guide including:
- Why migrate to chezmoi
- Key differences between dotbot and chezmoi
- Complete dotbot → chezmoi mapping
- File structure comparison
- Step-by-step migration instructions
- Usage guide with examples
- Troubleshooting section
- Migration checklist

#### `CHEZMOI-QUICK-REFERENCE.md` (11KB)
Quick reference guide for daily use:
- Common commands
- File naming conventions
- Template syntax examples
- Host-specific configuration patterns
- Troubleshooting tips
- Useful aliases

#### `HOST-SPECIFIC-MIGRATION.md` (9KB)
Detailed guide for migrating host-specific configurations:
- Three migration approaches explained
- Examples from your current hosts
- Step-by-step host config migration
- Testing strategies
- Best practices

### 6. Migration Helper Script

#### `migrate-to-chezmoi.sh`
Automated script to restructure your files:
- Creates backup branch automatically
- Creates migration branch
- Renames files to chezmoi conventions
  - `base/*` → `dot_*`
  - `config/*` → `dot_config/*`
  - `local/bin/*` → `executable_dot_local/bin/*`
  - `ssh/*` → `private_dot_ssh/*`
- Cleans up empty directories
- Generates migration notes

## What Needs To Be Done

### Immediate Next Steps

1. **Review Changes**
   ```bash
   cd ~/.dotfiles
   git status
   git diff
   ```

2. **Read Documentation**
   - Start with: `MIGRATION-DOTBOT-TO-CHEZMOI.md`
   - Quick reference: `CHEZMOI-QUICK-REFERENCE.md`
   - Host configs: `HOST-SPECIFIC-MIGRATION.md`

3. **Commit Current State**
   ```bash
   git add install .chezmoi.yaml.tmpl .chezmoiignore
   git add run_once_*.sh.tmpl .chezmoihooks/
   git add migrate-to-chezmoi.sh
   git add *.md
   git commit -m "Add chezmoi configuration and migration tools"
   ```

### File Restructuring

You have two options:

#### Option A: Automated (Recommended for First Pass)

```bash
# Run the migration script
./migrate-to-chezmoi.sh

# This will:
# - Create backup branch
# - Create migration branch
# - Rename all files to chezmoi conventions
# - Show you what was done
```

#### Option B: Manual (More Control)

Manually rename files following chezmoi conventions:

```bash
# Base files become dot_ files
git mv base/bashrc dot_bashrc
git mv base/zshrc dot_zshrc
git mv base/tmux.conf dot_tmux.conf

# Config files
mkdir -p dot_config
git mv config/fish dot_config/fish
git mv config/nvim dot_config/nvim
# ... etc

# Local bin (make executable)
mkdir -p executable_dot_local/bin
for file in local/bin/*; do
  git mv "$file" "executable_dot_local/bin/$(basename $file)"
done

# SSH files (private)
mkdir -p private_dot_ssh
git mv ssh/* private_dot_ssh/

# See full examples in MIGRATION-DOTBOT-TO-CHEZMOI.md
```

### Host-Specific Configurations

Your hosts need special attention:

```bash
hosts/
├── air/
├── lakka/
├── tunkki/
└── s/
```

**Read**: `HOST-SPECIFIC-MIGRATION.md` for detailed strategies.

**Quick decision guide**:
- **Few differences per file** → Use templates with `{{ if .is_air }}`
- **Complete replacement** → Use `filename__hostname` suffix
- **Host-specific directories** → Use `.chezmoiignore` with templates

### Testing Before Commit

```bash
# After restructuring files, test with chezmoi
cd ~/.dotfiles

# Initialize chezmoi with current directory as source
chezmoi init --source $(pwd)

# See what would happen (dry run)
chezmoi apply --dry-run --verbose

# See what a specific file would look like
chezmoi cat ~/.bashrc

# Check for errors
chezmoi verify
```

### Final Steps

1. **Commit Migration**
   ```bash
   git add -A
   git commit -m "Migrate from dotbot to chezmoi"
   git push
   ```

2. **Test on Current Machine**
   ```bash
   # Apply dotfiles
   chezmoi apply -v

   # Verify everything works
   # Open new terminal
   # Check configs
   ```

3. **Test on Another Machine** (if available)
   ```bash
   # On another machine
   sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply ivuorinen

   # Verify host-specific configs applied correctly
   ```

4. **Clean Up** (after confirming everything works)
   ```bash
   cd $(chezmoi source-path)

   # Remove old dotbot files
   rm -rf tools/dotbot tools/dotbot-*
   rm install.conf.yaml
   rm tools/dotbot-defaults.yaml

   # Optionally remove hosts/ if fully migrated to templates
   # rm -rf hosts/

   git add -A
   git commit -m "Clean up old dotbot files"
   git push
   ```

## Key Differences to Remember

### Installation
**Before**: `./install` (ran dotbot)
**After**: `sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply ivuorinen`

### Making Changes
**Before**:
```bash
cd ~/.dotfiles
vim base/bashrc
./install  # Re-run to create symlinks
```

**After**:
```bash
chezmoi edit ~/.bashrc
# Or: vim ~/.bashrc && chezmoi add ~/.bashrc
chezmoi apply
```

### Syncing Across Machines
**Before**:
```bash
cd ~/.dotfiles
git pull
./install
```

**After**:
```bash
chezmoi update
# Equivalent to: cd $(chezmoi source-path) && git pull && chezmoi apply
```

### Host-Specific Configs
**Before**: Separate files in `hosts/hostname/`
**After**: Templates with `{{ if eq .chezmoi.hostname "air" }}` or `filename__hostname`

## File Mapping Reference

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `base/bashrc` | `dot_bashrc` | Becomes `~/.bashrc` |
| `config/fish/` | `dot_config/fish/` | Becomes `~/.config/fish/` |
| `local/bin/script` | `executable_dot_local/bin/script` | Executable `~/.local/bin/script` |
| `ssh/config` | `private_dot_ssh/config` | Private (0600) `~/.ssh/config` |
| `install.conf.yaml` | `run_once_*.sh.tmpl` | Setup tasks |
| `hosts/air/config/` | `dot_config/*.tmpl` or `*__air` | Host-specific |

## Troubleshooting Quick Tips

### "Entry not in source state"
```bash
# File not added to chezmoi
chezmoi add <file>
```

### "File modified since chezmoi last wrote it"
```bash
# See changes
chezmoi diff

# Re-add
chezmoi add <file>
```

### "Template undefined variable"
```bash
# Check available data
chezmoi data

# Test template
chezmoi execute-template "{{ .chezmoi.hostname }}"
```

### Scripts not running
```bash
# Check permissions
chmod +x run_once_*.sh.tmpl

# Force re-run
chezmoi apply --force
```

## Additional Resources

### Created Documentation
- `MIGRATION-DOTBOT-TO-CHEZMOI.md` - Complete migration guide
- `CHEZMOI-QUICK-REFERENCE.md` - Daily usage reference
- `HOST-SPECIFIC-MIGRATION.md` - Host configuration guide
- `MIGRATION-NOTES.md` - Generated after running migration script

### External Resources
- [Chezmoi Official Docs](https://www.chezmoi.io/)
- [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Chezmoi User Guide](https://www.chezmoi.io/user-guide/)
- [Chezmoi Templates](https://www.chezmoi.io/reference/templates/)

## Summary Checklist

- [x] Install script updated
- [x] Chezmoi configuration created (`.chezmoi.yaml.tmpl`)
- [x] Ignore file created (`.chezmoiignore`)
- [x] Run scripts created (4 scripts)
- [x] Hooks created (pre-read-source-state)
- [x] Migration script created (`migrate-to-chezmoi.sh`)
- [x] Documentation created (3 guides)
- [ ] **Review and commit configuration files**
- [ ] **Run migration script** or manually restructure
- [ ] **Migrate host-specific configs**
- [ ] **Test with chezmoi**
- [ ] **Commit migration**
- [ ] **Test on current machine**
- [ ] **Test on other machines**
- [ ] **Clean up old dotbot files**
- [ ] **Update README.md** (document chezmoi usage)

## Questions?

If you have questions during migration:

1. Check the relevant guide:
   - General questions → `MIGRATION-DOTBOT-TO-CHEZMOI.md`
   - Usage questions → `CHEZMOI-QUICK-REFERENCE.md`
   - Host configs → `HOST-SPECIFIC-MIGRATION.md`

2. Use chezmoi's help:
   ```bash
   chezmoi help
   chezmoi help <command>
   chezmoi doctor
   ```

3. Check official docs:
   - https://www.chezmoi.io/

## What Makes This Migration Special

Your dotfiles have:
- ✅ Custom `dfm` script → Wrapped in run_once scripts
- ✅ Multiple dotbot plugins → Equivalent run_once scripts
- ✅ Host-specific configs → Template support added
- ✅ Complex installation → Automated in run scripts
- ✅ Git submodules → Pre-read hook handles this
- ✅ Multiple hosts (air, lakka, tunkki, s) → Detected and flagged

Everything from your dotbot setup has been accounted for in the chezmoi migration!

## Final Notes

- **Take your time**: This is a significant migration
- **Test thoroughly**: Use `--dry-run` extensively
- **Backup everything**: The migration script creates backups
- **Iterate**: You can always refine the migration later
- **Have fun**: Chezmoi offers powerful features to explore!

Good luck with your migration! 🚀
