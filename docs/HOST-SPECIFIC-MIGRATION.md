# Host-Specific Configuration Migration

Guide for migrating host-specific configurations from dotbot to chezmoi.

## Current Dotbot Structure

You currently have host-specific configurations in:

```
hosts/
├── air/
│   ├── base/
│   ├── config/
│   └── install.conf.yaml
├── lakka/
│   ├── base/
│   ├── config/
│   └── install.conf.yaml
├── tunkki/
│   └── install.conf.yaml
└── s/
    └── install.conf.yaml
```

## Chezmoi Approaches

There are three main approaches to handle host-specific configurations in chezmoi:

### 1. Template Conditionals (Recommended)

Use if/else conditions in template files.

**Pros:**
- Single source file for all hosts
- Easy to see all variations
- Less file duplication

**Cons:**
- Files can get complex with many hosts
- Need `.tmpl` extension

**Example:**

Create `dot_bashrc.tmpl`:
```bash
# Common configuration for all hosts
export PATH="$HOME/.local/bin:$PATH"

{{ if eq .chezmoi.hostname "air" }}
# air-specific
export WORK_DIR="$HOME/Work"
alias air-specific="echo air"
{{ end }}

{{ if eq .chezmoi.hostname "lakka" }}
# lakka-specific
export WORK_DIR="$HOME/Projects"
alias lakka-specific="echo lakka"
{{ end }}

# More common configuration
```

### 2. Separate Files with .chezmoiignore (Simple)

Keep separate files per host and ignore the ones that don't apply.

**Pros:**
- Clean separation
- No template syntax needed
- Easy to maintain

**Cons:**
- More files to manage
- Some duplication

**Example:**

Create multiple version files:
```
dot_bashrc__air
dot_bashrc__lakka
dot_bashrc__tunkki
```

These automatically apply based on hostname. No `.chezmoiignore` needed!

Or use directories:
```
dot_config/
├── app/
│   ├── config.yaml__air
│   ├── config.yaml__lakka
│   └── config.yaml__default
```

### 3. Hybrid Approach (Most Flexible)

Combine both methods:
- Use templates for files with minor differences
- Use separate files for completely different configs

## Migration Steps for Your Hosts

### Step 1: Analyze Each Host

Review what's different per host:

```bash
# See what's in each host directory
ls -la hosts/air/
ls -la hosts/lakka/
ls -la hosts/tunkki/
ls -la hosts/s/

# Compare configs
diff hosts/air/config/some-app/config hosts/lakka/config/some-app/config
```

### Step 2: Choose Strategy Per File

For each file that differs:

**Small differences** (few lines):
→ Use templates with conditionals

**Complete replacement**:
→ Use `filename__hostname` suffix

**Shared base + host additions**:
→ Use templates with includes or blocks

### Step 3: Migrate Host Configurations

#### Example: Fish Configuration

Your `hosts/air/config/fish/config.fish` differences:

**Current dotbot way:**
```yaml
# hosts/air/install.conf.yaml
- link:
    ~/.config/:
      path: hosts/air/config/**
```

**New chezmoi way - Option A (Templates):**

Create `dot_config/fish/config.fish.tmpl`:
```fish
# Common fish configuration
set -gx EDITOR nvim

{{ if eq .chezmoi.hostname "air" }}
# air-specific config
set -gx WORK_DIR ~/Work
{{ else if eq .chezmoi.hostname "lakka" }}
# lakka-specific config
set -gx WORK_DIR ~/Projects
{{ end }}

# More common configuration
```

**New chezmoi way - Option B (Separate files):**

Create multiple files:
```
dot_config/fish/config.fish__air
dot_config/fish/config.fish__lakka
```

Chezmoi will automatically use the correct file based on hostname.

### Step 4: Update .chezmoi.yaml.tmpl

Add host flags for easier conditionals:

```yaml
{{- $hostname := .chezmoi.hostname -}}

data:
  hostname: {{ $hostname | quote }}

  # Host-specific flags
  is_air: {{ eq $hostname "air" }}
  is_lakka: {{ eq $hostname "lakka" }}
  is_tunkki: {{ eq $hostname "tunkki" }}
  is_s: {{ eq $hostname "s" }}

  # Group flags
  is_work: {{ or (eq $hostname "air") (eq $hostname "tunkki") }}
  is_personal: {{ or (eq $hostname "lakka") (eq $hostname "s") }}
```

Then use simpler conditionals:

```go
{{ if .is_air }}
# air config
{{ end }}

{{ if .is_work }}
# All work machines
{{ end }}
```

## Specific Migration Examples

### Example 1: Simple Host-Specific Line

**Before (dotbot):**
```yaml
# hosts/air/config/app/config
setting=value_for_air

# hosts/lakka/config/app/config
setting=value_for_lakka
```

**After (chezmoi) - Option A:**
```
# dot_config/app/config.tmpl
{{ if .is_air -}}
setting=value_for_air
{{- else if .is_lakka -}}
setting=value_for_lakka
{{- end }}
```

**After (chezmoi) - Option B:**
```
# dot_config/app/config__air
setting=value_for_air

# dot_config/app/config__lakka
setting=value_for_lakka
```

### Example 2: Mostly Shared with Few Differences

**Before:**
100 lines shared, 5 lines different per host

**After (recommended - templates):**
```bash
# dot_config/app/config.tmpl
# ... 50 lines of shared config ...

{{ if .is_air }}
air_specific_setting=true
{{ else if .is_lakka }}
lakka_specific_setting=true
{{ end }}

# ... 50 more lines of shared config ...
```

### Example 3: Completely Different Configs

**Before:**
Two totally different config files

**After (recommended - separate files):**
```
dot_config/app/config__air
dot_config/app/config__lakka
```

### Example 4: Host-Specific Directories

**Before:**
```
hosts/air/config/air-only-app/
hosts/lakka/config/lakka-only-app/
```

**After - Use .chezmoiignore:**
```
# .chezmoiignore
{{ if ne .chezmoi.hostname "air" }}
dot_config/air-only-app/
{{ end }}

{{ if ne .chezmoi.hostname "lakka" }}
dot_config/lakka-only-app/
{{ end }}
```

Then create:
```
dot_config/air-only-app/     # Only applied on air
dot_config/lakka-only-app/   # Only applied on lakka
```

## Testing Host-Specific Configs

### Before Applying

```bash
# See what would be applied on this host
chezmoi diff

# See what a specific file would look like
chezmoi cat ~/.config/fish/config.fish

# Check template data
chezmoi data | grep hostname
```

### Simulating Other Hosts

```bash
# Test what would be applied on another host
chezmoi execute-template --init --promptString hostname=air "{{ .chezmoi.hostname }}"

# See what a file would look like on another host
# (This requires manual variable setting in templates)
```

### On Another Machine

```bash
# Initialize and test without applying
chezmoi init --dry-run --verbose ivuorinen

# Apply with dry-run
chezmoi apply --dry-run -v
```

## Migration Script Adjustments

Add to `migrate-to-chezmoi.sh`:

```bash
# Migrate host-specific configs
log_info "Processing host-specific configurations..."

CURRENT_HOST=$(hostname -s)
log_info "Current hostname: $CURRENT_HOST"

# Prompt for migration strategy
echo ""
log_warning "How do you want to handle host-specific configs?"
echo "  1) Merge into templates (recommended for small differences)"
echo "  2) Keep separate files per host (recommended for large differences)"
echo "  3) Manual (skip automatic migration)"
read -p "Choose (1/2/3): " -r STRATEGY

if [ "$STRATEGY" = "1" ]; then
  log_info "Will merge into templates (requires manual editing after)"
  # Create template files
  # ... migration logic ...

elif [ "$STRATEGY" = "2" ]; then
  log_info "Creating separate host-specific files..."

  for host in air lakka tunkki s; do
    if [ -d "hosts/$host" ]; then
      log_info "Processing host: $host"

      # Process host-specific base files
      if [ -d "hosts/$host/base" ]; then
        for file in hosts/$host/base/*; do
          if [ -f "$file" ]; then
            filename=$(basename "$file")
            move_dotfiles "$file" "dot_${filename}__${host}" ""
          fi
        done
      fi

      # Process host-specific config files
      if [ -d "hosts/$host/config" ]; then
        for file in hosts/$host/config/*; do
          if [ -f "$file" ]; then
            filename=$(basename "$file")
            dest="dot_config/$(dirname $file)__${host}"
            move_dotfiles "$file" "$dest/$(basename $file)" ""
          fi
        done
      fi
    fi
  done

else
  log_info "Skipping automatic host-specific migration"
  log_info "You'll need to manually migrate hosts/ directory"
fi
```

## Best Practices

1. **Start Simple**: Use separate files first, move to templates as you see patterns

2. **Don't Over-Template**: If a file is completely different per host, use separate files

3. **Document Hosts**: Add comments in `.chezmoi.yaml.tmpl` explaining each host

4. **Test Thoroughly**: Test on each host before committing

5. **Use Host Groups**: Group hosts (work/personal, laptop/desktop) for easier conditionals

## Checklist

- [ ] Identify all host-specific files
- [ ] Choose strategy per file (templates vs separate)
- [ ] Update `.chezmoi.yaml.tmpl` with host flags
- [ ] Migrate host-specific base files
- [ ] Migrate host-specific config files
- [ ] Update `.chezmoiignore` for host-specific directories
- [ ] Test on current host
- [ ] Test on other hosts
- [ ] Document which approach was used where
- [ ] Clean up old hosts/ directory

## Examples from Your Hosts

Based on your current structure:

### hosts/air/install.conf.yaml

```yaml
- link:
    ~/.config/:
      path: hosts/air/config/**
```

**Migration approach:**
- Check what's in `hosts/air/config/`
- If it's app configs, use separate files: `dot_config/app/config__air`
- If it's just a few lines different, merge into templates

### Common Pattern

For configurations that need host-specific values but share structure:

```yaml
# dot_config/app/config.tmpl
# Common settings
port=8080

# Host-specific
{{ if .is_air -}}
workspace=/Users/yourname/Work
{{- else if .is_lakka -}}
workspace=/Users/yourname/Projects
{{- end }}

# More common settings
debug=false
```

## Need Help?

If you're unsure about a specific file:

1. Check the diff: `diff hosts/air/file hosts/lakka/file`
2. Count different lines
3. If < 20% different → use templates
4. If > 20% different → use separate files

Remember: You can always refactor later!
