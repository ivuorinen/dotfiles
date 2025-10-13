# Task Completion Checklist

When completing any development task in this dotfiles repository, follow this
checklist to ensure compliance with project standards.

## Required Steps (BLOCKING)

### 1. Code Quality Checks

```bash
# Run all linting tools - MUST PASS with zero errors
yarn lint

# Individual checks if needed:
yarn lint:markdown    # Markdownlint validation
yarn lint:prettier    # Prettier formatting check
yarn lint:ec          # EditorConfig compliance verification
```

### 2. Shell Script Validation (if applicable)

```bash
# All shell scripts must pass shellcheck without warnings
find . -path ./node_modules -prune -o -name '*.sh' -print0 | xargs -0 shellcheck

# For individual scripts:
shellcheck path/to/script.sh
```

### 3. Testing Infrastructure

```bash
# Run all tests - MUST PASS completely
yarn test
# OR alternative runner
bash test-all.sh

# For specific test categories:
# Bats tests in tests/ directory
# Individual script functionality tests
```

### 4. EditorConfig Compliance (CRITICAL)

- **BLOCKING REQUIREMENT**: EditorConfig violations prevent completion
- All code must follow `.editorconfig` rules exactly:
  - UTF-8 charset
  - LF line endings
  - Final newline required
  - Trailing whitespace removal
  - Language-specific indentation (2-space default, 4-space for Fish)
- Use autofixers before attempting manual fixes
- Never modify linting configuration to bypass errors

## Auto-fixing Protocol

```bash
# ALWAYS run auto-fixers first, in this order:
yarn fix              # Fix all auto-fixable issues
yarn fix:markdown     # Fix markdown formatting violations
yarn fix:prettier     # Fix code formatting issues

# Verify fixes applied correctly:
yarn lint             # Should show reduced error count
```

## Pre-commit Hook Integration

Current pre-commit configuration enforces:

- Security checks (credentials, private keys)
- Shell script validation (shellcheck, shfmt)
- Markdown formatting (markdownlint with auto-fix)
- YAML/JSON validation and formatting
- Lua formatting (stylua for Neovim configs)
- Fish shell syntax validation
- GitHub Actions validation (actionlint)
- Renovate configuration validation

## Memory File Maintenance

When updating memory files:

1. Follow markdown best practices (blank lines around headings/lists)
2. Specify language for fenced code blocks
3. Ensure final newline exists
4. Respect line length limits (120 chars for markdown)
5. Use proper heading hierarchy

## Critical Success Criteria

✅ **REQUIRED FOR TASK COMPLETION:**

- `yarn lint` exits with code 0 (no errors)
- `yarn test` passes all test suites
- EditorConfig compliance verified
- No trailing whitespace or missing final newlines
- Shell scripts have proper shebangs and pass shellcheck
- All temporary/cache files cleaned up

❌ **BLOCKING ISSUES:**

- Any linting errors or warnings
- EditorConfig violations of any kind
- Test failures or incomplete test coverage
- Use of `--no-verify` flag with git operations
- Modified linting configurations to bypass errors

## Quality Assurance Notes

- **Use `which command`** to get full paths in scripts
- **Prefer modern tools**: `rg` over `grep`, `fd` over `find`, `bat` over `cat`
- **Test cross-shell compatibility**: bash, zsh, fish
- **Validate host-specific configurations** don't break general setup
- **Document any new utilities** in `local/bin/README.md`
