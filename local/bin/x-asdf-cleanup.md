# x-asdf-cleanup

A tool to clean up unused asdf tool versions from your system.

## Features

- Scans for version files (`.tool-versions`, `.nvmrc`, `.python-version`)
- Detects installed versions that are no longer in use
- Supports dry-run mode for safe verification
- Parallel processing for better performance
- Built-in caching system
- Automatic backups before uninstallation
- Restore functionality for accidental removals
- Comprehensive logging
- Progress indication during operations
- Performance metrics

## Installation

### 1. Copy the script to your local bin directory

```bash
mkdir -p ~/.local/bin
curl -o ~/.local/bin/x-asdf-cleanup https://raw.githubusercontent.com/yourusername/dotfiles/main/.dotfiles/local/bin/x-asdf-cleanup
chmod +x ~/.local/bin/x-asdf-cleanup
```

### 2. Ensure you have the required dependencies

- [asdf](https://asdf-vm.com/)
- [fd](https://github.com/sharkdp/fd)
- [jq](https://stedolan.github.io/jq/)

## Directory Structure

The script uses XDG Base Directory Specification:

```text
$HOME/
├── .local/
│   ├── bin/
│   │   └── x-asdf-cleanup
│   └── state/
│       └── asdf-cleanup/
│           ├── cleanup.log
│           ├── last_operation
│           └── backups/
│               └── tool_version_timestamp.tar.gz
├── .config/
│   └── asdf-cleanup/
│       └── config
└── .cache/
    └── asdf-cleanup/
        └── version-cache
```

## Configuration

Create a configuration file at `~/.config/asdf-cleanup/config`:

```bash
# Base directory for searching version files
BASE_DIR="$HOME/projects"

# Additional directories to exclude
EXCLUDE_PATTERNS+=(
    "node_modules"
    "vendor"
    "dist"
    ".venv"
)

# Performance settings
MAX_PARALLEL_JOBS=8
USE_CACHE=true
CACHE_MAX_AGE=3600  # 1 hour in seconds

# Output settings
VERBOSE=false
```

## Usage

Basic usage:

```bash
x-asdf-cleanup
```

Available options:

```text
--base-dir=DIR     Specify the base directory to search for version files
--dry-run          Perform a dry run without uninstalling any versions
--exclude=DIR      Exclude a directory from the search path (can be used multiple times)
--debug            Show debug information and exit
--verbose          Enable verbose output
--no-cache         Disable version cache
--max-parallel=N   Set maximum number of parallel processes (default: 4)
--restore          Restore the last uninstalled version from backup
-h, --help         Show help message and exit
-v, --version      Show version information and exit
```

### Examples

Dry run to see what would be uninstalled:

```bash
x-asdf-cleanup --dry-run
```

Exclude specific directories:

```bash
x-asdf-cleanup --exclude=node_modules --exclude=vendor
```

Restore last uninstalled version:

```bash
x-asdf-cleanup --restore
```

## Logging

Logs are stored in `~/.local/state/asdf-cleanup/cleanup.log`:

```bash
tail -f ~/.local/state/asdf-cleanup/cleanup.log
```

## Contributing

1. Fork the repository
2. Create your feature branch:

  ```bash
  git checkout -b feature/amazing-feature
  ```

3. Follow the coding standards:

- Use shellcheck for bash script linting
- Add comments for complex logic
- Update documentation as needed
- Add error handling for new functions

4. Test your changes:

- Test with different tool versions
- Test error scenarios
- Verify backup/restore functionality
- Check performance impact

5. Commit your changes:

  ```bash
  git commit -m 'Add some amazing feature'
  ```

6. Push to the branch:

  ```bash
  git push origin feature/amazing-feature
  ```

7. Open a Pull Request

### Development Setup

1. Clone the repository:

  ```bash
  git clone https://github.com/ivuorinen/dotfiles.git $HOME/.dotfiles
  cd $HOME/.dotfiles/local/bin
  ```

2. Create symbolic link:

  ```bash
  ln -s "$(pwd)/x-asdf-cleanup" ~/.local/bin/x-asdf-cleanup
  ```

3. Install development tools:

  ```bash
  # Install shellcheck
  asdf plugin add shellcheck
  asdf install shellcheck latest

  # Install shfmt
  asdf plugin add shfmt
  asdf install shfmt latest
  ```

4. Run tests:

  ```bash
  shellcheck x-asdf-cleanup
  shfmt -d x-asdf-cleanup
  ```

## License

This project is licensed under the MIT License.

## Author

Ismo Vuorinen - [@ivuorinen](https://github.com/ivuorinen)

## Acknowledgments

- [asdf](https://asdf-vm.com/) - The extensible version manager
- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'
- [jq](https://stedolan.github.io/jq/) - Command-line JSON processor
