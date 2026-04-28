# Usage KDL Specs, Completions, Docs & Manpages — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `.usage.kdl` specs for all owned scripts, then generate shell completions (fish/bash/zsh), markdown docs, and manpages from them.

**Architecture:** KDL specs live next to scripts. A generator script (`scripts/install-completions.sh`) globs all specs and runs `usage generate` for completions, markdown, and manpages. Shell configs source the new completion directories. `dfm install all` calls the generator after mise.

**Tech Stack:** usage-cli (KDL specs), fish/bash/zsh completions, Dotbot (linking)

---

## File Structure

### New directories

- `config/bash/completions.d/` — generated bash completions
- `config/zsh/completions.d/` — generated zsh completions
- `local/md/` — generated markdown docs

### New files (by task)

- `scripts/install-completions.sh` — generator script
- `local/bin/*.usage.kdl` — ~48 KDL spec files
- `scripts/*.usage.kdl` — ~17 KDL spec files
- `config/fish/completions/<name>.fish` — generated fish completions
- `config/bash/completions.d/<name>.bash` — generated bash completions
- `config/zsh/completions.d/_<name>` — generated zsh completions
- `local/md/<name>.md` — generated markdown docs
- `local/man/man1/<name>.1` — generated manpages

### Modified files

- `install.conf.yaml` — add create entries for new dirs
- `base/bashrc` — add bash completions sourcing loop
- `base/zshrc` — add completions.d to fpath
- `local/bin/dfm` — add install-completions call in `install all`

---

## Task 1: Infrastructure — directories, Dotbot, shell integration

**Files:**
- Modify: `install.conf.yaml:17-30` (create block)
- Modify: `base/bashrc:13` (after fzf source)
- Modify: `base/zshrc:16-17` (before compinit)
- Modify: `config/shared.sh:77-80` (completion path setup)

- [ ] **Step 1: Create new directories**

```bash
mkdir -p config/bash/completions.d
mkdir -p config/zsh/completions.d
mkdir -p local/md
```

- [ ] **Step 2: Add directories to install.conf.yaml create block**

In `install.conf.yaml`, add these entries to the `create:` block after `~/.local/state/zsh:`:

```yaml
    ~/.config/bash/completions.d:
    ~/.config/zsh/completions.d:
```

- [ ] **Step 3: Add bash completions sourcing to base/bashrc**

After line 13 (the fzf source block), add:

```bash
# Source usage-generated bash completions
for f in "$HOME/.config/bash/completions.d/"*.bash; do
  [[ -f "$f" ]] && source "$f"
done
unset f
```

- [ ] **Step 4: Add zsh completions.d to fpath in base/zshrc**

Before line 34 (`autoload -Uz compinit bashcompinit`), add:

```bash
# Add usage-generated completions to fpath
fpath=("$XDG_CONFIG_HOME/zsh/completions.d" $fpath)
```

- [ ] **Step 5: Verify Dotbot linking covers new dirs**

Run: `grep 'config/\*' install.conf.yaml`
Expected: The existing `~/.config/: glob: true path: config/*` link covers `config/bash/` and `config/zsh/` automatically. No new link entries needed.

---

## Task 2: Generator script — scripts/install-completions.sh

**Files:**
- Create: `scripts/install-completions.sh`

- [ ] **Step 1: Create the generator script**

```bash
#!/usr/bin/env bash
# @description Generate shell completions, markdown docs, and manpages from usage specs
#
# Requires: usage (https://usage.jdx.dev/) installed via mise
# Generates: fish/bash/zsh completions, markdown docs, manpages

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# shellcheck source=shared.sh
source "$DOTFILES/scripts/shared.sh"

# Output directories
FISH_DIR="$DOTFILES/config/fish/completions"
BASH_DIR="$DOTFILES/config/bash/completions.d"
ZSH_DIR="$DOTFILES/config/zsh/completions.d"
MD_DIR="$DOTFILES/local/md"
MAN_DIR="$DOTFILES/local/man/man1"

# Ensure output directories exist
mkdir -p "$FISH_DIR" "$BASH_DIR" "$ZSH_DIR" "$MD_DIR" "$MAN_DIR"

# Check for usage CLI
if ! command -v usage &> /dev/null; then
  echo "Error: usage CLI not found. Install with: mise use -g usage" >&2
  exit 1
fi

count=0
errors=0

# Process all .usage.kdl files
for spec in "$DOTFILES"/local/bin/*.usage.kdl "$DOTFILES"/scripts/*.usage.kdl; do
  [[ -f "$spec" ]] || continue

  # Extract bin name from filename: foo.usage.kdl -> foo, install-foo.sh.usage.kdl -> install-foo.sh
  basename_spec=$(basename "$spec")
  bin_name="${basename_spec%.usage.kdl}"

  echo "Generating for: $bin_name"

  # Completions
  if usage generate completion fish "$bin_name" -f "$spec" > "$FISH_DIR/$bin_name.fish" 2>/dev/null; then
    :
  else
    echo "  WARN: fish completion failed for $bin_name" >&2
    rm -f "$FISH_DIR/$bin_name.fish"
    ((errors++)) || true
  fi

  if usage generate completion bash "$bin_name" -f "$spec" > "$BASH_DIR/$bin_name.bash" 2>/dev/null; then
    :
  else
    echo "  WARN: bash completion failed for $bin_name" >&2
    rm -f "$BASH_DIR/$bin_name.bash"
    ((errors++)) || true
  fi

  if usage generate completion zsh "$bin_name" -f "$spec" > "$ZSH_DIR/_$bin_name" 2>/dev/null; then
    :
  else
    echo "  WARN: zsh completion failed for $bin_name" >&2
    rm -f "$ZSH_DIR/_$bin_name"
    ((errors++)) || true
  fi

  # Markdown docs
  if usage generate markdown -f "$spec" --out-file "$MD_DIR/$bin_name.md" 2>/dev/null; then
    :
  else
    echo "  WARN: markdown generation failed for $bin_name" >&2
    rm -f "$MD_DIR/$bin_name.md"
    ((errors++)) || true
  fi

  # Manpages
  if usage generate manpage -f "$spec" --out-file "$MAN_DIR/$bin_name.1" 2>/dev/null; then
    :
  else
    echo "  WARN: manpage generation failed for $bin_name" >&2
    rm -f "$MAN_DIR/$bin_name.1"
    ((errors++)) || true
  fi

  ((count++))
done

echo ""
echo "Done: processed $count specs ($errors warnings)"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/install-completions.sh
```

- [ ] **Step 3: Test with a sample KDL spec**

Create a minimal test spec:

```bash
cat > /tmp/test.usage.kdl << 'EOF'
bin "test-tool"
about "A test tool"
flag "-h --help" help="Show help"
EOF

usage generate completion fish test-tool -f /tmp/test.usage.kdl > /dev/null
usage generate completion bash test-tool -f /tmp/test.usage.kdl > /dev/null
usage generate completion zsh test-tool -f /tmp/test.usage.kdl > /dev/null
usage generate markdown -f /tmp/test.usage.kdl --out-file /tmp/test.md
usage generate manpage -f /tmp/test.usage.kdl --out-file /tmp/test.1
echo "All generation commands work"
rm -f /tmp/test.usage.kdl /tmp/test.md /tmp/test.1
```

---

## Task 3: dfm integration

**Files:**
- Modify: `local/bin/dfm:118-126` (install all section)

- [ ] **Step 1: Add completions generation to dfm install all**

In the `section_install()` function, after Tier 4 (line 121, `$0 install z`), add a new tier before the reload:

```bash
      # Tier 5: Generate completions, docs, and manpages from usage specs
      msgr run "Generating completions and docs from usage specs..."
      bash "$DOTFILES/scripts/install-completions.sh" \
        && msgr run_done "Completions and docs generated!"
```

The modified section should read:

```bash
      # Tier 4: Independent utilities
      $0 install shellspec
      $0 install z

      # Tier 5: Generate completions, docs, and manpages from usage specs
      msgr run "Generating completions and docs from usage specs..."
      bash "$DOTFILES/scripts/install-completions.sh" \
        && msgr run_done "Completions and docs generated!"

      msgr msg "Reloading configurations again..."
```

---

## Task 4: KDL specs — complex scripts (dfm, a, msgr)

**Files:**
- Create: `local/bin/dfm.usage.kdl`
- Create: `local/bin/a.usage.kdl`
- Create: `local/bin/msgr.usage.kdl`

- [ ] **Step 1: Create dfm.usage.kdl**

```kdl
bin "dfm"
about "Dotfiles manager and install helper"
author "Ismo Vuorinen"

cmd "install" help="Install tools, packages, and configurations" {
  cmd "all" help="Install everything in the correct order"
  cmd "apt-packages" help="Install apt packages (Debian/Ubuntu)"
  cmd "cheat-databases" help="Install cheat external cheatsheet databases"
  cmd "composer" help="Install PHP Package Manager Composer"
  cmd "dnf-packages" help="Install dnf packages (Fedora/RHEL)"
  cmd "fonts" help="Install programming fonts"
  cmd "gh" help="Install GitHub CLI Extensions"
  cmd "git-crypt" help="Install git-crypt from source"
  cmd "imagick" help="Install ImageMagick CLI"
  cmd "macos" help="Setup nice macOS defaults"
  cmd "mise" help="Install tools via mise (runtimes + CLI tools)"
  cmd "mise-cleanup" help="Remove old version manager installations" {
    flag "--dry-run" help="Show what would be removed without removing"
  }
  cmd "ntfy" help="Install ntfy notification tool"
  cmd "python-libs" help="Install Python libraries (libtmux, pynvim)"
  cmd "shellspec" help="Install shellspec testing framework"
  cmd "xcode-cli-tools" help="Install Xcode CLI tools (macOS)"
  cmd "z" help="Install z directory jumper"
}

cmd "brew" help="Homebrew package management" {
  cmd "install" help="Install packages from Brewfile"
  cmd "update" help="Update Homebrew and packages"
  cmd "updatebundle" help="Update Brewfile with descriptions"
  cmd "autoupdate" help="Setup Homebrew auto-update"
  cmd "leaves" help="List installed-on-request packages"
  cmd "clean" help="Cleanup old versions"
  cmd "untracked" help="List packages not in Brewfile"
}

cmd "apt" help="APT package management (Debian/Ubuntu)" {
  cmd "upkeep" help="Full maintenance (update + upgrade + autoremove + clean)"
  cmd "install" help="Install packages from apt.txt"
  cmd "update" help="Update package lists"
  cmd "upgrade" help="Upgrade installed packages"
  cmd "autoremove" help="Remove unused packages"
  cmd "clean" help="Clean package cache"
}

cmd "check" help="System information checks" {
  cmd "arch" help="Get or check current architecture" {
    alias "a"
    arg "[arch]" help="Architecture to check against"
  }
  cmd "host" help="Get or check current hostname" {
    alias "h"
    alias "hostname"
    arg "[hostname]" help="Hostname to check against"
  }
}

cmd "dotfiles" help="Format and reset configurations" {
  cmd "fmt" help="Run all formatters"
  cmd "yamlfmt" help="Format YAML files"
  cmd "shfmt" help="Format shell scripts"
  cmd "reset_all" help="Reset everything"
  cmd "reset_nvim" help="Reset neovim state and config"
}

cmd "helpers" help="Display system information" {
  cmd "aliases" help="Show shell aliases" {
    arg "<shell>" help="Shell to show aliases for (bash, zsh, fish)"
  }
  cmd "colors" help="Show 256 terminal colors"
  cmd "env" help="Show environment variables"
  cmd "functions" help="Show shell functions"
  cmd "nvim" help="Show neovim keybindings"
  cmd "path" help="Show PATH directories"
  cmd "tmux" help="Show tmux keybindings"
  cmd "wezterm" help="Show wezterm keybindings"
}

cmd "docs" help="Generate documentation" {
  cmd "all" help="Update all keybindings docs"
  cmd "tmux" help="Update tmux keybindings"
  cmd "nvim" help="Update nvim keybindings"
  cmd "wezterm" help="Update wezterm keybindings"
}

cmd "scripts" help="Run install scripts from scripts/" {
  arg "[script]" help="Script name to run (without install- prefix)"
}

cmd "tests" help="Test visualization helpers" {
  cmd "msgr" help="Show all msgr message types"
  cmd "params" help="List all parameters"
}

cmd "help" help="Show help"
```

- [ ] **Step 2: Create a.usage.kdl**

```kdl
bin "a"
about "Encrypt and decrypt files or directories with age and SSH keys"
version "1.1.0"

flag "-v --verbose" help="Print log messages to console"
flag "--delete" help="Delete original files after encryption"
flag "-f --force" help="Overwrite existing output files"

cmd "encrypt" help="Encrypt a file or directory" {
  alias "e"
  alias "enc"
  arg "<target>" help="File or directory to encrypt"
}

cmd "decrypt" help="Decrypt a file or directory" {
  alias "d"
  alias "dec"
  arg "<target>" help="File or directory to decrypt"
}

cmd "help" help="Show help"
cmd "version" help="Show version"
```

- [ ] **Step 3: Create msgr.usage.kdl**

```kdl
bin "msgr"
about "Colored message output helper for shell scripts"

cmd "msg" help="Print a message with arrow marker" {
  arg "<message>" help="Message text"
}
cmd "yay" help="Print a celebration message" {
  arg "<message>" help="Message text"
}
cmd "yay_done" help="Print a celebration with checkmark" {
  arg "<message>" help="Message text"
}
cmd "done" help="Print a completion checkmark" {
  arg "<message>" help="Message text"
}
cmd "run" help="Print a running-task message" {
  arg "<message>" help="Message text"
}
cmd "run_done" help="Print a running-task with checkmark" {
  arg "<message>" help="Message text"
}
cmd "ok" help="Print a success message" {
  arg "<message>" help="Message text"
}
cmd "warn" help="Print a warning message" {
  arg "<message>" help="Message text"
}
cmd "err" help="Print an error message" {
  arg "<message>" help="Message text"
}
cmd "prompt" help="Print a prompt-style message" {
  arg "<message>" help="Message text"
}
cmd "prompt_done" help="Print a prompt with checkmark" {
  arg "<message>" help="Message text"
}
cmd "nested" help="Print an indented message" {
  arg "<message>" help="Message text"
}
cmd "nested_done" help="Print an indented message with checkmark" {
  arg "<message>" help="Message text"
}
cmd "test" help="Show all message types"
cmd "help" help="Show help"
```

- [ ] **Step 4: Validate the three specs**

```bash
usage generate completion fish dfm -f local/bin/dfm.usage.kdl > /dev/null
usage generate completion fish a -f local/bin/a.usage.kdl > /dev/null
usage generate completion fish msgr -f local/bin/msgr.usage.kdl > /dev/null
echo "All three complex specs validate"
```

---

## Task 5: KDL specs — git utilities

**Files:**
- Create: `local/bin/git-attributes.usage.kdl`
- Create: `local/bin/git-dirty.usage.kdl`
- Create: `local/bin/git-fsck-dirs.usage.kdl`
- Create: `local/bin/git-update-dirs.usage.kdl`

- [ ] **Step 1: Create git-attributes.usage.kdl**

```kdl
bin "git-attributes"
about "Check .gitattributes coverage and suggest missing rules"

flag "-h --help" help="Show help"
flag "-v --verbose" help="Verbose output"
flag "-e --exit" help="Exit with error if uncovered files found"
flag "-p --pattern" help="Show pattern matches"
flag "-n --no-suggest" help="Skip suggestions"
flag "-w --write" help="Write suggested rules to .gitattributes"
flag "-f --format-width <width>" help="Format column width"
```

- [ ] **Step 2: Create git-dirty.usage.kdl**

```kdl
bin "git-dirty"
about "Recursively check for dirty git repositories"

flag "-v --verbose" help="Verbose output"
```

- [ ] **Step 3: Create git-fsck-dirs.usage.kdl**

```kdl
bin "git-fsck-dirs"
about "Run git fsck on all git repositories in subdirectories"
```

- [ ] **Step 4: Create git-update-dirs.usage.kdl**

```kdl
bin "git-update-dirs"
about "Pull and rebase all git repos in subdirectories"

flag "--help" help="Display help"
flag "--version" help="Display version"
flag "-v --verbose" help="Verbose output"
flag "-q --quiet" help="Quiet output"
flag "--force" help="Force operations"
```

- [ ] **Step 5: Validate**

```bash
for f in local/bin/git-*.usage.kdl; do
  bin=$(basename "$f" .usage.kdl)
  usage generate completion fish "$bin" -f "$f" > /dev/null && echo "OK: $bin"
done
```

---

## Task 6: KDL specs — encryption tools (ad, ae)

**Files:**
- Create: `local/bin/ad.usage.kdl`
- Create: `local/bin/ae.usage.kdl`

- [ ] **Step 1: Create ad.usage.kdl**

```kdl
bin "ad"
about "Decrypt a file using age with GitHub SSH keys"

arg "<file>" help="File to decrypt"
```

- [ ] **Step 2: Create ae.usage.kdl**

```kdl
bin "ae"
about "Encrypt a file using age with GitHub SSH keys"

arg "<file>" help="File to encrypt"
```

- [ ] **Step 3: Validate**

```bash
usage generate completion fish ad -f local/bin/ad.usage.kdl > /dev/null && echo "OK: ad"
usage generate completion fish ae -f local/bin/ae.usage.kdl > /dev/null && echo "OK: ae"
```

---

## Task 7: KDL specs — path manipulation and session tools

**Files:**
- Create: `local/bin/x-path.usage.kdl`
- Create: `local/bin/x-path-append.usage.kdl`
- Create: `local/bin/x-path-prepend.usage.kdl`
- Create: `local/bin/x-path-remove.usage.kdl`
- Create: `local/bin/t.usage.kdl`

- [ ] **Step 1: Create x-path.usage.kdl**

```kdl
bin "x-path"
about "Unified PATH manipulation tool"

cmd "append" help="Append directory to PATH" {
  arg "<directory>" help="Directory to append"
}
cmd "prepend" help="Prepend directory to PATH" {
  arg "<directory>" help="Directory to prepend"
}
cmd "remove" help="Remove directory from PATH" {
  arg "<directory>" help="Directory to remove"
}
cmd "check" help="Check if directory is in PATH" {
  arg "<directory>" help="Directory to check"
}
```

- [ ] **Step 2: Create x-path-append.usage.kdl**

```kdl
bin "x-path-append"
about "Append directories to PATH"

arg "<directory>" help="Directory to append" var=#true
```

- [ ] **Step 3: Create x-path-prepend.usage.kdl**

```kdl
bin "x-path-prepend"
about "Prepend directories to PATH"

arg "<directory>" help="Directory to prepend" var=#true
```

- [ ] **Step 4: Create x-path-remove.usage.kdl**

```kdl
bin "x-path-remove"
about "Remove directories from PATH"

arg "<directory>" help="Directory to remove" var=#true
```

- [ ] **Step 5: Create t.usage.kdl**

```kdl
bin "t"
about "Fuzzy tmux session manager"
```

- [ ] **Step 6: Validate**

```bash
for name in x-path x-path-append x-path-prepend x-path-remove t; do
  usage generate completion fish "$name" -f "local/bin/$name.usage.kdl" > /dev/null && echo "OK: $name"
done
```

---

## Task 8: KDL specs — GitHub and network tools

**Files:**
- Create: `local/bin/x-gh-get-latest-version.usage.kdl`
- Create: `local/bin/x-gh-get-latest-release-targz.usage.kdl`
- Create: `local/bin/x-pr-comments.usage.kdl`
- Create: `local/bin/x-sonarcloud.usage.kdl`
- Create: `local/bin/x-multi-ping.usage.kdl`
- Create: `local/bin/x-ip.usage.kdl`
- Create: `local/bin/x-localip.usage.kdl`
- Create: `local/bin/x-open-ports.usage.kdl`
- Create: `local/bin/x-ssl-expiry-date.usage.kdl`
- Create: `local/bin/x-ssh-audit.usage.kdl`
- Create: `local/bin/x-when-up.usage.kdl`
- Create: `local/bin/x-when-down.usage.kdl`

- [ ] **Step 1: Create x-gh-get-latest-version.usage.kdl**

```kdl
bin "x-gh-get-latest-version"
about "Get latest GitHub release version for a repository"

flag "--branch" help="Get latest branch name"
flag "--tag" help="Get latest tag (default)"
flag "--commit" help="Get latest commit SHA"
flag "--json" help="Output as JSON"
flag "-v --verbose" help="Verbose output"
flag "--oldest" help="Get oldest instead of latest"
flag "--prereleases" help="Include pre-releases"

arg "<repo>" help="GitHub repository (owner/repo)"
```

- [ ] **Step 2: Create x-gh-get-latest-release-targz.usage.kdl**

```kdl
bin "x-gh-get-latest-release-targz"
about "Download latest GitHub release tarball"

flag "--get" help="Download the release"

arg "<repo>" help="GitHub repository (owner/repo)"
```

- [ ] **Step 3: Create x-pr-comments.usage.kdl**

```kdl
bin "x-pr-comments"
about "Fetch PR comments formatted for LLM analysis"

flag "--help" help="Show help"

arg "<pr>" help="PR number or full GitHub URL"
```

- [ ] **Step 4: Create x-sonarcloud.usage.kdl**

```kdl
bin "x-sonarcloud"
about "Fetch SonarCloud issues for LLM analysis"

flag "--pr <number>" help="PR-specific issues"
flag "--branch <name>" help="Branch-specific issues"
flag "--org <org>" help="Organization name"
flag "--project-key <key>" help="Project key"
flag "--severities <severities>" help="Filter by severity (BLOCKER,CRITICAL,MAJOR,MINOR,INFO)"
flag "--types <types>" help="Filter by type (BUG,VULNERABILITY,CODE_SMELL,SECURITY_HOTSPOT)"
flag "--statuses <statuses>" help="Filter by status (OPEN,CONFIRMED,REOPENED)"
flag "--resolved" help="Include resolved issues"
flag "-h --help" help="Show help"
```

- [ ] **Step 5: Create x-multi-ping.usage.kdl**

```kdl
bin "x-multi-ping"
about "Multi-protocol ping for IPv4 and IPv6"

flag "--help" help="Show help"
flag "--verbose" help="Verbose output"
flag "--loop" help="Loop indefinitely"
flag "--forever" help="Loop indefinitely (alias)"
flag "--sleep <seconds>" help="Sleep between iterations (default: 1)"

arg "<hostnames>" help="Hostnames to ping" var=#true
```

- [ ] **Step 6: Create remaining network tool specs**

`x-ip.usage.kdl`:
```kdl
bin "x-ip"
about "Show external IP address"
```

`x-localip.usage.kdl`:
```kdl
bin "x-localip"
about "Display local IP addresses"

flag "--help" help="Show help"
flag "--version" help="Show version"
flag "--ipv4" help="Show only IPv4 addresses"
flag "--ipv6" help="Show only IPv6 addresses"

arg "[interface]" help="Specific network interface"
```

`x-open-ports.usage.kdl`:
```kdl
bin "x-open-ports"
about "List open ports in Markdown or JSON format"

flag "--json" help="Output in JSON format"
flag "--help" help="Show help"
```

`x-ssl-expiry-date.usage.kdl`:
```kdl
bin "x-ssl-expiry-date"
about "Check SSL certificate expiry date"

flag "-p <port>" help="Port number (default: 443)"
flag "-d <days>" help="Days threshold for expiry warning"

arg "<hostname>" help="Domain or hostname to check"
```

`x-ssh-audit.usage.kdl`:
```kdl
bin "x-ssh-audit"
about "Run SSH security audit and generate reports"
```

`x-when-up.usage.kdl`:
```kdl
bin "x-when-up"
about "Wait for host to come online, then execute command"

arg "<host>" help="Host to monitor"
arg "<command>" help="Command to execute when host is up" var=#true
```

`x-when-down.usage.kdl`:
```kdl
bin "x-when-down"
about "Wait for host to go offline, then execute command"

arg "<host>" help="Host to monitor"
arg "<command>" help="Command to execute when host is down" var=#true
```

- [ ] **Step 7: Validate all**

```bash
for f in local/bin/x-gh-*.usage.kdl local/bin/x-pr-comments.usage.kdl \
         local/bin/x-sonarcloud.usage.kdl local/bin/x-multi-ping.usage.kdl \
         local/bin/x-ip.usage.kdl local/bin/x-localip.usage.kdl \
         local/bin/x-open-ports.usage.kdl local/bin/x-ssl-expiry-date.usage.kdl \
         local/bin/x-ssh-audit.usage.kdl local/bin/x-when-up.usage.kdl \
         local/bin/x-when-down.usage.kdl; do
  bin=$(basename "$f" .usage.kdl)
  usage generate completion fish "$bin" -f "$f" > /dev/null && echo "OK: $bin"
done
```

---

## Task 9: KDL specs — PHP tools

**Files:**
- Create: `local/bin/php-switcher.usage.kdl`
- Create: `local/bin/x-set-php-aliases.usage.kdl`
- Create: `local/bin/x-quota-usage.php.usage.kdl`

- [ ] **Step 1: Create php-switcher.usage.kdl**

```kdl
bin "php-switcher"
about "Switch between PHP versions installed via Homebrew"

flag "--help" help="Show help"
flag "--installed" help="List installed PHP versions"
flag "--current" help="Show currently active version"
flag "--auto" help="Auto-switch based on .php-version file"

arg "[version]" help="PHP version (e.g., 7.4, 8.0) or 'latest'"
```

- [ ] **Step 2: Create x-set-php-aliases.usage.kdl**

```kdl
bin "x-set-php-aliases"
about "Cache PHP installations and generate shell aliases"

flag "--prefix" help="Show Homebrew prefix"
```

- [ ] **Step 3: Create x-quota-usage.php.usage.kdl**

```kdl
bin "x-quota-usage.php"
about "Display disk quota usage information"
```

- [ ] **Step 4: Validate**

```bash
for name in php-switcher x-set-php-aliases x-quota-usage.php; do
  usage generate completion fish "$name" -f "local/bin/$name.usage.kdl" > /dev/null && echo "OK: $name"
done
```

---

## Task 10: KDL specs — file and backup tools

**Files:**
- Create: `local/bin/x-backup-folder.usage.kdl`
- Create: `local/bin/x-backup-mysql-with-prefix.usage.kdl`
- Create: `local/bin/x-clean-vendordirs.usage.kdl`
- Create: `local/bin/x-thumbgen.usage.kdl`
- Create: `local/bin/x-change-alacritty-theme.usage.kdl`
- Create: `local/bin/x-dc.usage.kdl`
- Create: `local/bin/x-sha256sum-matcher.usage.kdl`
- Create: `local/bin/x-record.usage.kdl`

- [ ] **Step 1: Create x-backup-folder.usage.kdl**

```kdl
bin "x-backup-folder"
about "Backup a folder with a timestamp"

arg "<folder>" help="Folder to backup"
arg "[filename]" help="Custom output filename (default: folder name)"
```

- [ ] **Step 2: Create x-backup-mysql-with-prefix.usage.kdl**

```kdl
bin "x-backup-mysql-with-prefix"
about "Backup MySQL tables matching a prefix"

arg "<table_prefix>" help="Table name prefix to match"
arg "<filename_prefix>" help="Output filename prefix"
arg "[database]" help="Database name (optional)"
```

- [ ] **Step 3: Create x-clean-vendordirs.usage.kdl**

```kdl
bin "x-clean-vendordirs"
about "Remove vendor and node_modules directories recursively"

arg "[directory]" help="Directory to clean (default: current)"
```

- [ ] **Step 4: Create x-thumbgen.usage.kdl**

```kdl
bin "x-thumbgen"
about "Generate image thumbnails using ImageMagick"

flag "-h --help" help="Show help"
flag "-o <output_dir>" help="Output directory (default: same as source)"
flag "-s <suffix>" help="Thumbnail suffix (default: _thumb)"

arg "<source_dir>" help="Directory containing images"
```

- [ ] **Step 5: Create x-change-alacritty-theme.usage.kdl**

```kdl
bin "x-change-alacritty-theme"
about "Switch Alacritty color theme"

arg "<theme>" help="Theme name to apply"
```

- [ ] **Step 6: Create x-dc.usage.kdl**

```kdl
bin "x-dc"
about "Create a directory with verbose output"

arg "<path>" help="Directory path to create"
```

- [ ] **Step 7: Create x-sha256sum-matcher.usage.kdl**

```kdl
bin "x-sha256sum-matcher"
about "Compare two files by SHA256 hash"

flag "-v --verbose" help="Verbose output"
flag "-h --help" help="Show help"

arg "<file1>" help="First file"
arg "<file2>" help="Second file"
```

- [ ] **Step 8: Create x-record.usage.kdl**

```kdl
bin "x-record"
about "Screen recording tool using ffmpeg"

arg "<type>" help="Recording type: gif or mkv"
arg "<scope>" help="Recording scope: size (window) or full (screen)"
```

- [ ] **Step 9: Validate**

```bash
for name in x-backup-folder x-backup-mysql-with-prefix x-clean-vendordirs \
            x-thumbgen x-change-alacritty-theme x-dc x-sha256sum-matcher x-record; do
  usage generate completion fish "$name" -f "local/bin/$name.usage.kdl" > /dev/null && echo "OK: $name"
done
```

---

## Task 11: KDL specs — utility and control flow tools

**Files:**
- Create: `local/bin/x-until-success.usage.kdl`
- Create: `local/bin/x-until-error.usage.kdl`
- Create: `local/bin/x-foreach.usage.kdl`
- Create: `local/bin/x-have.usage.kdl`
- Create: `local/bin/x-visit-folders.usage.kdl`
- Create: `local/bin/x-codeql.usage.kdl`
- Create: `local/bin/x-gitprofile.usage.kdl`
- Create: `local/bin/x-load-configs.usage.kdl`
- Create: `local/bin/pushover.usage.kdl`

- [ ] **Step 1: Create x-until-success.usage.kdl**

```kdl
bin "x-until-success"
about "Retry a command until it succeeds"

flag "--sleep <seconds>" help="Sleep between retries"
flag "--help" help="Show help"

arg "<command>" help="Command to run" var=#true
```

- [ ] **Step 2: Create x-until-error.usage.kdl**

```kdl
bin "x-until-error"
about "Run a command repeatedly until it fails"

flag "--sleep <seconds>" help="Sleep between iterations"
flag "--help" help="Show help"

arg "<command>" help="Command to run" var=#true
```

- [ ] **Step 3: Create x-foreach.usage.kdl**

```kdl
bin "x-foreach"
about "Run a command in each directory from a listing"

arg "<listing_cmd>" help="Command that lists directories"
arg "<command>" help="Command to run in each directory" var=#true
```

- [ ] **Step 4: Create x-have.usage.kdl**

```kdl
bin "x-have"
about "Check if a command exists on the system"

arg "<command>" help="Command to check for"
```

- [ ] **Step 5: Create x-visit-folders.usage.kdl**

```kdl
bin "x-visit-folders"
about "Register subdirectories with zoxide"

flag "--dry-run" help="Show what would be registered"
flag "--verbose" help="Verbose output"
flag "--help" help="Show help"

arg "[directory]" help="Target directory (default: current)"
```

- [ ] **Step 6: Create x-codeql.usage.kdl**

```kdl
bin "x-codeql"
about "CodeQL security scanning wrapper"

flag "--path <path>" help="Source path to analyze (default: current directory)"
flag "--parallel" help="Run language analyses in parallel"
flag "-h --help" help="Show help"
flag "-v --version" help="Show version"
```

- [ ] **Step 7: Create x-gitprofile.usage.kdl**

```kdl
bin "x-gitprofile"
about "Set git profile configuration hooks"

arg "[profile]" help="Profile name"
arg "[directory]" help="Directory to configure"
```

- [ ] **Step 8: Create x-load-configs.usage.kdl**

```kdl
bin "x-load-configs"
about "Load host-specific configuration files"
```

- [ ] **Step 9: Create pushover.usage.kdl**

```kdl
bin "pushover"
about "Send Pushover notifications from the command line"

flag "-c <callback>" help="Callback URL"
flag "-d <device>" help="Target device"
flag "-D <timestamp>" help="Delivery timestamp"
flag "-e <expire>" help="Expiration time in seconds"
flag "-p <priority>" help="Priority level (-2 to 2)"
flag "-r <retry>" help="Retry interval in seconds"
flag "-t <title>" help="Message title"
flag "-T <token>" help="Pushover API token"
flag "-s <sound>" help="Notification sound"
flag "-u <url>" help="URL to include"
flag "-U <user>" help="Pushover user key"
flag "-a <url_title>" help="URL title"

arg "<message>" help="Message content"
```

- [ ] **Step 10: Validate**

```bash
for name in x-until-success x-until-error x-foreach x-have x-visit-folders \
            x-codeql x-gitprofile x-load-configs pushover; do
  usage generate completion fish "$name" -f "local/bin/$name.usage.kdl" > /dev/null && echo "OK: $name"
done
```

---

## Task 12: KDL specs — display and info tools

**Files:**
- Create: `local/bin/x-help.usage.kdl`
- Create: `local/bin/x-env-list.usage.kdl`
- Create: `local/bin/x-hr.usage.kdl`
- Create: `local/bin/x-term-colors.usage.kdl`
- Create: `local/bin/x-welcome-banner.usage.kdl`
- Create: `local/bin/x-dfm-docs-xterm-keybindings.usage.kdl`

- [ ] **Step 1: Create x-help.usage.kdl**

```kdl
bin "x-help"
about "Browse and display dotfiles documentation"

flag "--source-only" help="Show raw source instead of rendered output"

arg "[name]" help="Script name to look up (interactive fzf if omitted)"
```

- [ ] **Step 2: Create x-env-list.usage.kdl**

```kdl
bin "x-env-list"
about "List environment variables grouped by prefix"
```

- [ ] **Step 3: Create x-hr.usage.kdl**

```kdl
bin "x-hr"
about "Print a solid separator line in the terminal"
```

- [ ] **Step 4: Create x-term-colors.usage.kdl**

```kdl
bin "x-term-colors"
about "Display 24-bit terminal color test"
```

- [ ] **Step 5: Create x-welcome-banner.usage.kdl**

```kdl
bin "x-welcome-banner"
about "Print system welcome banner with host info"
```

- [ ] **Step 6: Create x-dfm-docs-xterm-keybindings.usage.kdl**

```kdl
bin "x-dfm-docs-xterm-keybindings"
about "Update tmux keybindings documentation"
```

- [ ] **Step 7: Validate**

```bash
for name in x-help x-env-list x-hr x-term-colors x-welcome-banner \
            x-dfm-docs-xterm-keybindings; do
  usage generate completion fish "$name" -f "local/bin/$name.usage.kdl" > /dev/null && echo "OK: $name"
done
```

---

## Task 13: KDL specs — Python, Perl, PHP scripts

**Files:**
- Create: `local/bin/x-compare-versions.py.usage.kdl`
- Create: `local/bin/x-git-largest-files.py.usage.kdl`
- Create: `local/bin/x-multi-ping.pl.usage.kdl`

- [ ] **Step 1: Create x-compare-versions.py.usage.kdl**

```kdl
bin "x-compare-versions.py"
about "Compare semantic version strings"
```

- [ ] **Step 2: Create x-git-largest-files.py.usage.kdl**

```kdl
bin "x-git-largest-files.py"
about "Find largest files in git repository history"
```

- [ ] **Step 3: Create x-multi-ping.pl.usage.kdl**

```kdl
bin "x-multi-ping.pl"
about "Multi-protocol ping utility (Perl version)"
```

- [ ] **Step 4: Validate**

```bash
for name in x-compare-versions.py x-git-largest-files.py x-multi-ping.pl; do
  usage generate completion fish "$name" -f "local/bin/$name.usage.kdl" > /dev/null && echo "OK: $name"
done
```

---

## Task 14: KDL specs — scripts/*.sh

**Files:**
- Create: `scripts/install-apt-packages.sh.usage.kdl`
- Create: `scripts/install-cheat-purebashbible.sh.usage.kdl`
- Create: `scripts/install-composer.sh.usage.kdl`
- Create: `scripts/install-dnf-packages.sh.usage.kdl`
- Create: `scripts/install-fonts.sh.usage.kdl`
- Create: `scripts/install-gh-extensions.sh.usage.kdl`
- Create: `scripts/install-macos-defaults.sh.usage.kdl`
- Create: `scripts/install-ntfy.sh.usage.kdl`
- Create: `scripts/install-python-packages.sh.usage.kdl`
- Create: `scripts/install-shellspec.sh.usage.kdl`
- Create: `scripts/install-xcode-cli-tools.sh.usage.kdl`
- Create: `scripts/install-z.sh.usage.kdl`
- Create: `scripts/create-nvim-keymaps.sh.usage.kdl`
- Create: `scripts/create-wezterm-keymaps.sh.usage.kdl`
- Create: `scripts/cleanup-old-version-managers.sh.usage.kdl`
- Create: `scripts/update-readme-aliases.sh.usage.kdl`
- Create: `scripts/shared.sh.usage.kdl`

- [ ] **Step 1: Create install script specs**

`scripts/install-apt-packages.sh.usage.kdl`:
```kdl
bin "install-apt-packages.sh"
about "Install essential apt packages for development"
```

`scripts/install-cheat-purebashbible.sh.usage.kdl`:
```kdl
bin "install-cheat-purebashbible.sh"
about "Update pure-bash-bible cheatsheet database"
```

`scripts/install-composer.sh.usage.kdl`:
```kdl
bin "install-composer.sh"
about "Install PHP Package Manager Composer"
```

`scripts/install-dnf-packages.sh.usage.kdl`:
```kdl
bin "install-dnf-packages.sh"
about "Install essential dnf packages for development"
```

`scripts/install-fonts.sh.usage.kdl`:
```kdl
bin "install-fonts.sh"
about "Install programming fonts from GitHub releases"

flag "--force" help="Re-download and reinstall all fonts"
flag "--help" help="Show help"
```

`scripts/install-gh-extensions.sh.usage.kdl`:
```kdl
bin "install-gh-extensions.sh"
about "Install GitHub CLI extensions"
```

`scripts/install-macos-defaults.sh.usage.kdl`:
```kdl
bin "install-macos-defaults.sh"
about "Configure macOS system defaults"
```

`scripts/install-ntfy.sh.usage.kdl`:
```kdl
bin "install-ntfy.sh"
about "Install ntfy notification tool"
```

`scripts/install-python-packages.sh.usage.kdl`:
```kdl
bin "install-python-packages.sh"
about "Install Python libraries via uv pip"
```

`scripts/install-shellspec.sh.usage.kdl`:
```kdl
bin "install-shellspec.sh"
about "Install shellspec testing framework"
```

`scripts/install-xcode-cli-tools.sh.usage.kdl`:
```kdl
bin "install-xcode-cli-tools.sh"
about "Install Xcode Command Line Tools (macOS)"
```

`scripts/install-z.sh.usage.kdl`:
```kdl
bin "install-z.sh"
about "Install z directory jumper"
```

- [ ] **Step 2: Create utility script specs**

`scripts/create-nvim-keymaps.sh.usage.kdl`:
```kdl
bin "create-nvim-keymaps.sh"
about "Generate Neovim keybindings documentation"
```

`scripts/create-wezterm-keymaps.sh.usage.kdl`:
```kdl
bin "create-wezterm-keymaps.sh"
about "Generate WezTerm keybindings documentation"
```

`scripts/cleanup-old-version-managers.sh.usage.kdl`:
```kdl
bin "cleanup-old-version-managers.sh"
about "Remove old version manager installations (nvm, fnm, pyenv, goenv)"
```

`scripts/update-readme-aliases.sh.usage.kdl`:
```kdl
bin "update-readme-aliases.sh"
about "Update alias documentation in docs/alias.md"
```

`scripts/shared.sh.usage.kdl`:
```kdl
bin "shared.sh"
about "Shared bash functions and helpers for install scripts"
```

- [ ] **Step 3: Validate**

```bash
for f in scripts/*.usage.kdl; do
  bin=$(basename "$f" .usage.kdl)
  usage generate completion fish "$bin" -f "$f" > /dev/null && echo "OK: $bin"
done
```

---

## Task 15: Generate all completions, docs, and manpages

- [ ] **Step 1: Run the generator**

```bash
bash scripts/install-completions.sh
```

Expected: "Done: processed N specs (0 warnings)"

- [ ] **Step 2: Verify outputs exist**

```bash
echo "Fish completions:" && ls config/fish/completions/*.fish | wc -l
echo "Bash completions:" && ls config/bash/completions.d/*.bash | wc -l
echo "Zsh completions:" && ls config/zsh/completions.d/_* | wc -l
echo "Markdown docs:" && ls local/md/*.md | wc -l
echo "Manpages:" && ls local/man/man1/*.1 | wc -l
```

- [ ] **Step 3: Spot-check a complex completion**

```bash
head -20 config/fish/completions/dfm.fish
head -20 config/bash/completions.d/dfm.bash
head -5 config/zsh/completions.d/_dfm
head -10 local/md/dfm.md
head -10 local/man/man1/dfm.1
```

---

## Task 16: Final validation

- [ ] **Step 1: Run yarn lint**

```bash
yarn lint
```

Fix any issues that arise.

- [ ] **Step 2: Verify Dotbot config is valid**

```bash
python3 -c "import yaml; yaml.safe_load(open('install.conf.yaml'))" && echo "YAML OK"
```

- [ ] **Step 3: Verify all specs parse cleanly**

```bash
errors=0
for f in local/bin/*.usage.kdl scripts/*.usage.kdl; do
  bin=$(basename "$f" .usage.kdl)
  if ! usage generate completion fish "$bin" -f "$f" > /dev/null 2>&1; then
    echo "FAIL: $f"
    ((errors++))
  fi
done
echo "Errors: $errors"
```
