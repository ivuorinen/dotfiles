# ShellCheck Issues Analysis

## Critical Shell Script Problems

### Missing Shebangs (SC2148)

Multiple shell scripts missing proper shebang lines:

- `tools/antidote/tests/` - Test scripts
- `config/vim/*/test/lib/common.sh` - FZF test libraries
- `config/tmux/plugins/*/scripts/helpers.sh` - Plugin helper scripts
- Various submodule scripts

### Syntax Errors (SC1036, SC1088, SC1073)

- `config/vim/fzf/test/lib/common.sh` - Invalid ERB template syntax
- `config/cheat/cheatsheets/tldr/` - Markdown files incorrectly parsed as shell
- `tmux-sessionist/scripts/list_sessions.sh` - Brace parsing errors

### Variable Assignment Issues (SC1007, SC2155)

- `config/vim/extra/fzf/test/lib/common.sh` - Incorrect empty variable assignments
- Multiple tmux plugin scripts - Declare and assign should be separate

### Quoting Problems (SC2086, SC2006)

- Unquoted variable expansions in tmux plugin scripts
- Legacy backtick usage instead of $(...) syntax
- Missing quotes around variable expansions

## Third-Party Code Issues

### Submodule Problems

Most shellcheck errors are in **third-party submodules**:

- `tools/antidote/` - Zsh plugin manager
- `config/tmux/plugins/` - Tmux plugins
- `config/vim/extra/fzf/` - FZF integration
- `config/cheat/cheatsheets/tldr/` - Cheat sheet collection

### Recommendation

- These should be **excluded from shellcheck** via configuration
- Focus linting only on **project-owned scripts**
- Add shellcheck ignore patterns for submodule directories

## Project-Owned Script Issues

### Main Scripts Status

- `install` - ✅ Clean (no shellcheck errors)
- `test-all.sh` - ✅ Clean
- `add-submodules.sh` - ✅ Clean
- `config/shared.sh` - ✅ Clean
- Scripts in `local/bin/` - ✅ Mostly clean

### Minor Issues Found

- Some scripts could benefit from stricter quoting
- Consistent shebang usage across all scripts
- Consider adding `set -euo pipefail` to more scripts
