# Fish Shell Secrets Directory

This directory contains sensitive environment variables like API tokens and credentials.

## Usage

1. Copy an example file (e.g., `github.fish.example`) to remove the `.example` suffix:

    ```bash
    cp github.fish.example github.fish
    ```

2. Edit the file and replace placeholder values with your actual secrets:

    ```bash
    $EDITOR github.fish
    ```

3. Reload your fish shell or source the exports:

    ```fish
    source ~/.config/fish/exports.fish
    ```

## Adding New Secret Files

Create a new `.fish` file in this directory with your environment variables:

```fish
# Example: openai.fish
set -x OPENAI_API_KEY "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

Common secret patterns:

- `github.fish` - GitHub Personal Access Token (`GITHUB_TOKEN`)
- `aws.fish` - AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- `openai.fish` - OpenAI API key (`OPENAI_API_KEY`)
- `anthropic.fish` - Anthropic API key (`ANTHROPIC_API_KEY`)

## Security Best Practices

- **Never commit actual secrets** - Only `.example` files are tracked by git
- **Use specific permissions** - Consider `chmod 600` for secret files
- **Rotate credentials regularly** - Update tokens when compromised
- **Use environment-specific files** - Separate dev/staging/prod credentials
- **Check before committing** - Run `git status` to verify secrets aren't staged

## How It Works

The `exports.fish` file automatically sources all `*.fish` files from this directory:

```fish
if test -d "$DOTFILES/config/fish/secrets.d"
    for secret_file in "$DOTFILES/config/fish/secrets.d"/*.fish
        if test -f "$secret_file"
            source "$secret_file"
        end
    end
end
```

Files ending in `.example` are ignored by the loader but tracked by git as templates.

## Backward Compatibility

This directory supplements the existing `exports-secret.fish` pattern. Both methods work:

- **Legacy**: `config/fish/exports-secret.fish` (single file, still supported)
- **New**: `config/fish/secrets.d/*.fish` (multiple files, recommended)

Use whichever approach fits your workflow best.
