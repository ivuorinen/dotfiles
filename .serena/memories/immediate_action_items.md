# Immediate Action Items - Priority Order

## HIGH PRIORITY (Must Fix Before Any Development)

### 1. Fix Memory File Formatting (BLOCKING)

```bash
# These files prevent any linting from passing:
- .serena/memories/code_style_conventions.md
- .serena/memories/darwin_system_utilities.md
- .serena/memories/project_overview.md
- .serena/memories/project_structure.md
- .serena/memories/suggested_commands.md
- .serena/memories/task_completion_checklist.md

# Issues: Missing final newlines, markdown formatting, line length
# Impact: Blocks all linting commands
```

### 2. Fix Fish Shell Line Length Violations (BLOCKING)

```bash
# Files exceeding 80-char limit:
config/fish/alias.fish (4 violations)
config/fish/exports.fish (15 violations)

# These are CRITICAL - Fish config has strict limits
# Must be fixed before any fish-related changes
```

### 3. Fix Git Configuration Indentation (BLOCKING)

```bash
# Files with tab/space mixing:
config/git/shared (40+ violations)
hosts/s/config/git/overrides/config
hosts/s/config/git/local.d/work-git

# Impact: Git configuration may not work correctly
```

## MEDIUM PRIORITY (Fix During Next Development Cycle)

### 4. Prettier Formatting Issues

```bash
# 17 files need prettier formatting:
yarn fix:prettier
# Most are JSON/YAML configuration files
```

### 5. WezTerm Color Scheme Indentation

```bash
# All files in config/wezterm/colors/ using tabs instead of spaces
# Affects terminal appearance configuration
```

### 6. Update Linting Configuration

```bash
# Add shellcheck exclusions for submodules:
# - tools/antidote/
# - config/tmux/plugins/
# - config/vim/extra/fzf/
# - config/cheat/cheatsheets/tldr/
```

## LOW PRIORITY (Future Improvements)

### 7. Test Infrastructure

```bash
# Fix bats test PATH issues
# Tests pass but show rm command not found errors
```

### 8. Documentation Updates

```bash
# Add troubleshooting section to AGENTS.md
# Create shellcheck exclusion documentation
```

## Immediate Commands to Run

### Step 1: Auto-fix What's Possible

```bash
yarn fix:prettier    # Fix 17 files
yarn fix:markdown    # Attempt markdown fixes
```

### Step 2: Manual Fixes Required

- Add final newlines to all memory files
- Wrap long lines in Fish configuration files
- Convert tabs to spaces in Git configuration files

### Step 3: Verify Progress

```bash
yarn lint:ec         # Check EditorConfig compliance
yarn lint:markdown   # Check markdown issues
yarn lint:prettier   # Check remaining prettier issues
```

## Success Criteria

✅ `yarn lint` passes without errors
✅ All EditorConfig violations resolved
✅ Memory files properly formatted
✅ Fish configuration under line limits
✅ Git configuration uses consistent indentation
