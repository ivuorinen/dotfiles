# GitHub Latest Version Fetcher

`x-gh-get-latest-version` is a versatile command-line tool for fetching the
latest version information from GitHub repositories. It can retrieve release
versions, Git tags, branch tags, and commit SHAs with simple commands.

## Features

- Fetch latest or oldest stable releases
- Include prerelease versions
- Get latest Git tags from any branch
- Fetch latest commit SHA from a specific branch
- Output in plain text or JSON format
- Combined output mode to get all information at once
- Rate limit checking to avoid GitHub API throttling
- Authenticated requests with GitHub token support

## Requirements

- `curl` for making HTTP requests
- `jq` for processing JSON responses
- A GitHub personal access token
  (optional, but recommended to avoid rate limiting)

## Installation

1. Save the script to a location in your PATH
2. Make it executable: `chmod +x x-gh-get-latest-version`
3. Optionally set up a GitHub token as an environment variable:

```bash
export GITHUB_TOKEN="your_personal_access_token"
```

## Usage

```text
Usage: x-gh-get-latest-version <repo> [options]

Arguments:
  <repo>                   Repository in format 'owner/repo' (e.g. ivuorinen/dotfiles)

Options:
  -h, --help               Show this help message and exit
  -v, --verbose            Enable verbose output
  -p, --prereleases        Include prerelease versions (default: only stable releases)
  -o, --oldest             Fetch the oldest release instead of the latest
  -b, --branch <branch>    Fetch the latest tag from a specific branch (default: main)
  -c, --commit             Fetch the latest commit SHA from the specified branch
  -t, --tag                Fetch the latest Git tag (any branch)
  -j, --json               Return output as JSON (default: plain text)
  -a, --all                Fetch all information types in a combined output
```

## Examples

### Fetch the Latest Release Version

```bash
x-gh-get-latest-version ivuorinen/dotfiles
```

Output: `v1.2.3`

### Include Prereleases

```bash
x-gh-get-latest-version ivuorinen/dotfiles --prereleases
```

Output: `v1.3.0-rc.1`

### Get the Oldest Release

```bash
x-gh-get-latest-version ivuorinen/dotfiles --oldest
```

Output: `v0.1.0`

### Fetch from a Specific Branch

```bash
x-gh-get-latest-version ivuorinen/dotfiles --branch develop
```

Output: `develop-v1.3.0`

### Get Latest Commit SHA

```bash
x-gh-get-latest-version ivuorinen/dotfiles --commit
```

Output: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0`

### Fetch Latest Git Tag

```bash
x-gh-get-latest-version ivuorinen/dotfiles --tag
```

Output: `v2.0.0-beta.1`

### Output as JSON

```bash
x-gh-get-latest-version ivuorinen/dotfiles --json
```

Output: `{"repository": "ivuorinen/dotfiles", "result": "v1.2.3"}`

### Combined Information Output

```bash
x-gh-get-latest-version ivuorinen/dotfiles --all
```

Output:

```text
Repository: ivuorinen/dotfiles
Branch:     main
Git Tag:    v2.0.0-beta.1
Commit:     a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
Prerelease: v1.3.0-rc.1
Release:    v1.2.3
```

### Combined Output as JSON

```bash
x-gh-get-latest-version ivuorinen/dotfiles --all --json
```

Output:

```json
{
  "repository": "ivuorinen/dotfiles",
  "branch": "main",
  "tag": "v2.0.0-beta.1",
  "commit": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0",
  "prerelease": "v1.3.0-rc.1",
  "release": "v1.2.3"
}
```

## Environment Variables

You can use environment variables instead of command-line options:

- `INCLUDE_PRERELEASES=1` - Include prerelease versions
- `OLDEST_RELEASE=1` - Fetch the oldest release instead of the latest
- `BRANCH=branch_name` - Specify a branch to fetch tags from
- `LATEST_COMMIT=1` - Fetch latest commit SHA
- `LATEST_TAG=1` - Fetch latest Git tag
- `OUTPUT=json` - Output results as JSON
- `GITHUB_API_URL=url` - Override GitHub API URL (useful for GitHub Enterprise)
- `GITHUB_TOKEN=token` - Use GitHub API token to increase rate limits
- `VERBOSE=1` - Enable verbose output

## GitHub API Rate Limits

GitHub enforces rate limits on API requests:

- Unauthenticated requests: 60 requests per hour
- Authenticated requests: 5,000 requests per hour

For frequent use, it's strongly recommended to set up a GitHub token:

```bash
export GITHUB_TOKEN="your_personal_access_token"
```

The script will automatically warn you when you're approaching your rate limit
and suggest using a token if you haven't already.

## Error Handling

The script provides informative error messages for common issues:

- Repository not found
- Rate limit exceeded
- No releases/tags found
- Invalid arguments

## Author

Ismo Vuorinen (<https://github.com/ivuorinen>)

## License

MIT

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
