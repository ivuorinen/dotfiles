#!/usr/bin/env bash
# Migration helper script: Dotbot to Chezmoi
# This script helps restructure files from dotbot format to chezmoi format
#
# IMPORTANT: Review changes carefully before running!
# It's recommended to run this in a new git branch

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}→${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

# Check if we're in a git repository
if [ ! -d .git ]; then
  log_error "Not a git repository. Please run from your dotfiles directory."
  exit 1
fi

# Confirm with user
log_warning "This script will restructure your dotfiles for chezmoi."
log_warning "It's STRONGLY recommended to:"
log_warning "  1. Commit all current changes"
log_warning "  2. Create a new branch for migration"
log_warning "  3. Review all changes before merging"
echo ""
read -p "Do you want to continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  log_info "Migration cancelled."
  exit 0
fi

# Create backup branch
log_info "Creating backup branch..."
BACKUP_BRANCH="backup-before-chezmoi-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH"
log_success "Created backup branch: $BACKUP_BRANCH"

# Create migration branch
log_info "Creating migration branch..."
MIGRATION_BRANCH="migrate-to-chezmoi"
git checkout -b "$MIGRATION_BRANCH" 2>/dev/null || git checkout "$MIGRATION_BRANCH"
log_success "Switched to migration branch: $MIGRATION_BRANCH"

# Function to move and rename files
move_dotfiles() {
  local src=$1
  local dest=$2
  local prefix=$3

  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    log_info "Moving: $src → $dest"
    git mv "$src" "$dest" 2>/dev/null || mv "$src" "$dest"
  fi
}

# Migrate base files (these become dot_ files)
log_info "Migrating base files..."
if [ -d base ]; then
  for file in base/*; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      # Skip certain files
      if [[ "$filename" =~ \.(md|MD)$ ]]; then
        continue
      fi
      move_dotfiles "$file" "dot_${filename}" ""
    fi
  done
  log_success "Base files migrated"
fi

# Migrate config directory
log_info "Migrating config directory..."
if [ -d config ]; then
  # Create dot_config if it doesn't exist
  mkdir -p dot_config

  for item in config/*; do
    if [ -e "$item" ]; then
      basename_item=$(basename "$item")
      # Skip certain directories
      if [[ "$basename_item" == "homebrew" ]] || [[ "$basename_item" == "shared.sh" ]]; then
        log_info "Keeping $item in place (referenced by scripts)"
        continue
      fi

      log_info "Moving: $item → dot_config/$basename_item"
      git mv "$item" "dot_config/$basename_item" 2>/dev/null || mv "$item" "dot_config/$basename_item"
    fi
  done
  log_success "Config files migrated"
fi

# Migrate local/bin with executable prefix
log_info "Migrating local/bin scripts..."
if [ -d local/bin ]; then
  mkdir -p executable_dot_local/bin

  for script in local/bin/*; do
    if [ -f "$script" ]; then
      basename_script=$(basename "$script")
      log_info "Moving: $script → executable_dot_local/bin/$basename_script"
      git mv "$script" "executable_dot_local/bin/$basename_script" 2>/dev/null || \
        mv "$script" "executable_dot_local/bin/$basename_script"
    fi
  done
  log_success "Local bin scripts migrated"
fi

# Migrate local/share
log_info "Migrating local/share..."
if [ -d local/share ]; then
  mkdir -p dot_local/share

  for item in local/share/*; do
    if [ -e "$item" ]; then
      basename_item=$(basename "$item")
      log_info "Moving: $item → dot_local/share/$basename_item"
      git mv "$item" "dot_local/share/$basename_item" 2>/dev/null || \
        mv "$item" "dot_local/share/$basename_item"
    fi
  done
  log_success "Local share migrated"
fi

# Migrate local/man
log_info "Migrating local/man..."
if [ -d local/man ]; then
  mkdir -p dot_local/man

  for item in local/man/*; do
    if [ -e "$item" ]; then
      basename_item=$(basename "$item")
      log_info "Moving: $item → dot_local/man/$basename_item"
      git mv "$item" "dot_local/man/$basename_item" 2>/dev/null || \
        mv "$item" "dot_local/man/$basename_item"
    fi
  done
  log_success "Local man pages migrated"
fi

# Migrate SSH files with private prefix
log_info "Migrating SSH files..."
if [ -d ssh ]; then
  mkdir -p private_dot_ssh

  for item in ssh/*; do
    if [ -f "$item" ]; then
      basename_item=$(basename "$item")
      log_info "Moving: $item → private_dot_ssh/$basename_item"
      git mv "$item" "private_dot_ssh/$basename_item" 2>/dev/null || \
        mv "$item" "private_dot_ssh/$basename_item"
    fi
  done
  log_success "SSH files migrated"
fi

# Clean up empty directories
log_info "Cleaning up empty directories..."
find . -type d -empty -delete 2>/dev/null || true
log_success "Empty directories removed"

# Create README for old structure
log_info "Creating migration notes..."
cat > MIGRATION-NOTES.md << 'EOF'
# Migration Notes

This repository has been migrated from dotbot to chezmoi.

## Old Structure (Dotbot)
```
~/.dotfiles/
├── base/          # Files symlinked to ~/.*
├── config/        # Files symlinked to ~/.config/
├── local/         # Scripts and local files
├── ssh/           # SSH configuration
├── install        # Dotbot installation script
└── install.conf.yaml  # Dotbot configuration
```

## New Structure (Chezmoi)
```
~/.dotfiles/ (or ~/.local/share/chezmoi)
├── dot_*          # Files that become ~/.*
├── dot_config/    # Files that become ~/.config/
├── executable_dot_local/  # Executable scripts
├── private_dot_ssh/       # SSH files with 0700 permissions
├── run_once_*.sh.tmpl     # One-time setup scripts
├── .chezmoi.yaml.tmpl     # Chezmoi configuration
└── .chezmoiignore         # Files to ignore
```

## File Naming Conventions

- `dot_bashrc` → `~/.bashrc`
- `dot_config/fish/` → `~/.config/fish/`
- `private_dot_ssh/` → `~/.ssh/` (mode 0700)
- `executable_dot_local/bin/script` → `~/.local/bin/script` (executable)
- `symlink_dot_vim` → `~/.vim` (symlink)

## Next Steps

1. Review the migration with: `git diff`
2. Test with chezmoi: `chezmoi init --dry-run --verbose $(pwd)`
3. Apply if everything looks good: `chezmoi init --apply $(pwd)`
4. Read the full migration guide: `MIGRATION-DOTBOT-TO-CHEZMOI.md`

## Backup

A backup branch was created: `$BACKUP_BRANCH`

You can switch back with: `git checkout $BACKUP_BRANCH`
EOF

log_success "Migration notes created: MIGRATION-NOTES.md"

# Show summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "Migration complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "Summary:"
echo "  • Backup branch: $BACKUP_BRANCH"
echo "  • Migration branch: $MIGRATION_BRANCH"
echo ""
log_info "Next steps:"
echo "  1. Review changes:        git status && git diff"
echo "  2. Test with chezmoi:     chezmoi init --dry-run --verbose \$(pwd)"
echo "  3. Read migration guide:  cat MIGRATION-DOTBOT-TO-CHEZMOI.md"
echo "  4. Commit changes:        git add -A && git commit -m 'Migrate to chezmoi'"
echo ""
log_warning "IMPORTANT: Review all changes before committing!"
log_warning "Test thoroughly before applying to your home directory!"
echo ""
