# php-switcher

Switch between Homebrew-installed PHP versions or list installed versions.

## Usage

```bash
php-switcher <version>|--auto [options]
```

Options:

- `--installed` – list versions installed via Homebrew
- `--current` – print currently active PHP version
- `--auto` – read version from `.php-version` in current directory

### Example

```bash
php-switcher 8.3
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
