# XDG Base Directory Specification
set -q XDG_CONFIG_HOME; or set -x XDG_CONFIG_HOME "$HOME/.config"
set -q XDG_DATA_HOME; or set -x XDG_DATA_HOME "$HOME/.local/share"
set -q XDG_CACHE_HOME; or set -x XDG_CACHE_HOME "$HOME/.cache"
set -q XDG_STATE_HOME; or set -x XDG_STATE_HOME "$HOME/.local/state"
set -q XDG_BIN_HOME; or set -x XDG_BIN_HOME "$HOME/.local/bin"
set -q XDG_RUNTIME_DIR; or set -x XDG_RUNTIME_DIR "$HOME/.local/run"

# POSIX fallback; macOS launchd sets its own per-user TMPDIR.
set -q TMPDIR; or set -x TMPDIR /tmp

# Dotfiles directory
set -q DOTFILES; or set -x DOTFILES "$HOME/.dotfiles"

# Editor settings
set -q EDITOR; or set -x EDITOR nvim
set -q VISUAL; or set -x VISUAL nvim
set -q HOSTNAME; or set -x HOSTNAME (hostname -s)

# UTF-8 locale fallback — mirrors config/exports. SSH sessions can arrive
# with no locale at all; tmux's server then starts under C/POSIX and renders
# multibyte glyphs (the window pill caps) as escaped octets.
set -l _locale $LC_ALL
test -n "$_locale"; or set _locale $LC_CTYPE
test -n "$_locale"; or set _locale $LANG
if not string match -qir 'utf-?8' -- "$_locale"
    set -x LANG (locale -a 2>/dev/null | string match -ri '^C\.utf-?8$')[1]
    test -n "$LANG"; or set -x LANG en_US.UTF-8
end

# Add local bin to path
fish_add_path "$XDG_BIN_HOME"

# Add mise shims to path
fish_add_path "$XDG_DATA_HOME/mise/shims"

# Add cargo bin to path
fish_add_path "$XDG_DATA_HOME/cargo/bin"

# Yarn configuration
set -q YARN_GLOBAL_FOLDER; or set -x YARN_GLOBAL_FOLDER "$XDG_DATA_HOME/yarn"
fish_add_path "$YARN_GLOBAL_FOLDER/bin"

# Mason configuration
set -q MASON_HOME; or set -x MASON_HOME "$XDG_DATA_HOME/nvim/mason"
fish_add_path "$MASON_HOME/bin"

# Add dotnet tools to path
fish_add_path "$HOME/.dotnet/tools/"

# fish-lsp — silence 4006 (duplicate function in same scope).
# Our if/else blocks define the same function name in mutually exclusive
# branches; fish-lsp flags them lexically, which is a false positive.
set -q fish_lsp_diagnostic_disable_error_codes
or set -gx fish_lsp_diagnostic_disable_error_codes 4006

# Brew configuration
set -q HOMEBREW_NO_ANALYTICS; or set -x HOMEBREW_NO_ANALYTICS true
set -q HOMEBREW_NO_ENV_HINTS; or set -x HOMEBREW_NO_ENV_HINTS true
set -q HOMEBREW_BUNDLE_MAS_SKIP; or set -x HOMEBREW_BUNDLE_MAS_SKIP true
set -q HOMEBREW_BUNDLE_FILE; or set -x HOMEBREW_BUNDLE_FILE "$XDG_CONFIG_HOME/homebrew/Brewfile"

# Composer configuration
set -q COMPOSER_HOME; or set -x COMPOSER_HOME "$XDG_STATE_HOME/composer"
set -q COMPOSER_BIN; or set -x COMPOSER_BIN "$COMPOSER_HOME/vendor/bin"
fish_add_path "$COMPOSER_BIN"

# Docker configuration
set -q DOCKER_CONFIG; or set -x DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"
x-dc "$DOCKER_CONFIG"
set -q DOCKER_HIDE_LEGACY_COMMANDS; or set -x DOCKER_HIDE_LEGACY_COMMANDS true
set -q DOCKER_SCAN_SUGGEST; or set -x DOCKER_SCAN_SUGGEST false

# fzf configuration
set -q FZF_DEFAULT_OPTS; or set -x FZF_DEFAULT_OPTS \
    '--height 40% --tmux bottom,40% --layout reverse --border top'

# gh-dash / television — read their theme-composed config from the theme
# state dir so config/gh-dash and config/television stay plain symlinks with
# no install.conf exclude. Paths are stable; the theme handlers rewrite the
# files behind them on every flip. (BAT_THEME is mode-driven and lives in
# conf.d/theme-switch.fish alongside LS_COLORS.)
set -gx GH_DASH_CONFIG "$XDG_STATE_HOME/dotfiles-theme/gh-dash-config.yml"
set -gx TELEVISION_CONFIG "$XDG_STATE_HOME/dotfiles-theme/television"

# GnuPG configuration
set -q GNUPGHOME; or set -x GNUPGHOME "$XDG_DATA_HOME/gnupg"

# Go configuration
set -x GOPATH "$XDG_DATA_HOME/go"
# Go's own default ($GOPATH/bin), NOT $XDG_BIN_HOME: `go install` binaries
# landing in ~/.local/bin shadow the mise-managed versions. fish_add_path
# appends here, so it stays behind the mise shims.
set -x GOBIN "$GOPATH/bin"
fish_add_path --append "$GOBIN"
set -e GOROOT

# 1Password configuration
set -q OP_CACHE; or set -x OP_CACHE "$XDG_STATE_HOME/1password"

# Set precompiled Python arch+OS so mise downloads the right binary
# Each output line from mise-python-arch has the format: export KEY="value"
if command -v mise-python-arch >/dev/null 2>&1
    for _line in (mise-python-arch 2>/dev/null)
        set -l _kv (string replace -r '^export ' '' -- $_line)
        set -l _key (string split -m1 '=' $_kv)[1]
        set -l _val (string replace -r '^[^=]+="|"$' '' -- $_kv | string replace -ra '"' '')
        if test -n "$_key"
            set -gx $_key $_val
        end
    end
end

# Rust / cargo configuration
set -q CARGO_HOME; or set -x CARGO_HOME "$XDG_DATA_HOME/cargo"
set -q CARGO_BIN_HOME; or set -x CARGO_BIN_HOME "$XDG_BIN_HOME"
set -q RUSTUP_HOME; or set -x RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -x RUST_WITHOUT "clippy,docs,rls"
fish_add_path "$CARGO_HOME/bin"

# tmux configuration. TMUX_PLUGIN_MANAGER_PATH is set by tmux.conf itself
# (set-environment -g), which is the value tpm reads.
set -q TMUX_TMPDIR; or set -x TMUX_TMPDIR "$XDG_STATE_HOME/tmux"

# wakatime configuration
set -q WAKATIME_HOME; or set -x WAKATIME_HOME "$XDG_STATE_HOME/wakatime"
x-dc "$WAKATIME_HOME"

# Zoxide configuration
set -q _ZO_DATA_DIR; or set -x _ZO_DATA_DIR "$XDG_DATA_HOME/zoxide"
set -q _ZO_EXCLUDE_DIRS; or set -x _ZO_EXCLUDE_DIRS "$XDG_DATA_HOME"

# bkt (shell command caching tool) configuration
set -q BKT_TTL; or set -x BKT_TTL 1m

# Manpager
set -q MANPAGER; or set -x MANPAGER "less -X"

# sonarqube-cli
fish_add_path "$XDG_DATA_HOME/sonarqube-cli/bin"

# Miscellaneous configuration
set -q CHEAT_USE_FZF; or set -x CHEAT_USE_FZF true
set -q SQLITE_HISTORY; or set -x SQLITE_HISTORY "$XDG_CACHE_HOME/sqlite/sqlite_history"

# Source additional configuration files if they exist
if test -f "$DOTFILES/config/fish/exports-secret.fish"
    source "$DOTFILES/config/fish/exports-secret.fish"
end

if test -f "$DOTFILES/hosts/$HOSTNAME/config/fish/exports.fish"
    source "$DOTFILES/hosts/$HOSTNAME/config/fish/exports.fish"
end

if test -f "$DOTFILES/hosts/$HOSTNAME/config/fish/exports-secret.fish"
    source "$DOTFILES/hosts/$HOSTNAME/config/fish/exports-secret.fish"
end

# Source secret environment variables from secrets.d directory
if test -d "$DOTFILES/config/fish/secrets.d"
    for secret_file in "$DOTFILES/config/fish/secrets.d"/*.fish
        if test -f "$secret_file"
            source "$secret_file"
        end
    end
end
