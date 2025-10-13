# x-pr-comments

---

## Usage

```bash
x-pr-comments <pr-number>                    # When run inside a git repository
x-pr-comments <github-pr-url>                # Direct GitHub PR URL
x-pr-comments -h|--help                      # Show help
```

Fetches GitHub Pull Request comments and review suggestions, formats them
for LLM analysis with processing instructions and API endpoints for detailed
examination.

## Examples

```bash
x-pr-comments 1                              # PR #1 in current repo
x-pr-comments https://github.com/user/repo/pull/1
```

## Requirements

- GitHub CLI (`gh`) installed and authenticated
- Internet connection for GitHub API access
- Git repository context for PR number usage

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
