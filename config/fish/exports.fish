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

# Set Neovim environment variables
test -z "$NVIM_STATE" && set -x NVIM_STATE "$XDG_STATE_HOME/nvim"
test -z "$NVIM_CONFIG_HOME" && set -x NVIM_CONFIG_HOME "$XDG_CONFIG_HOME/nvim"
test -z "$NVIM_DATA_HOME" && set -x NVIM_DATA_HOME "$XDG_DATA_HOME/nvim"
test -z "$NVIM_CACHE_HOME" && set -x NVIM_CACHE_HOME "$XDG_CACHE_HOME/nvim"
test -z "$NVIM_LOG_PATH" && set -x NVIM_LOG_PATH "$NVIM_STATE/log"
test -z "$NVIM_SESSION_PATH" && set -x NVIM_SESSION_PATH "$NVIM_STATE/session"
test -z "$NVIM_SHADA_PATH" && set -x NVIM_SHADA_PATH "$NVIM_STATE/shada"
test -z "$NVIM_UNDO_PATH" && set -x NVIM_UNDO_PATH "$NVIM_STATE/undo"

# fish-lsp — silence 4006 (duplicate function in same scope).
# Our if/else blocks define the same function name in mutually exclusive
# branches; fish-lsp flags them lexically, which is a false positive.
set -q fish_lsp_diagnostic_disable_error_codes
or set -gx fish_lsp_diagnostic_disable_error_codes 4006

# Ansible configuration
set -q ANSIBLE_HOME; or set -x ANSIBLE_HOME "$XDG_CONFIG_HOME/ansible"
set -q ANSIBLE_CONFIG; or set -x ANSIBLE_CONFIG "$ANSIBLE_HOME/ansible.cfg"
set -q ANSIBLE_GALAXY_CACHE_DIR; or set -x ANSIBLE_GALAXY_CACHE_DIR "$XDG_CACHE_HOME/ansible/galaxy_cache"
x-dc "$ANSIBLE_HOME"
x-dc "$ANSIBLE_GALAXY_CACHE_DIR"

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
set -q FZF_BASE; or set -x FZF_BASE "$XDG_CONFIG_HOME/fzf"
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
set -x GOBIN "$XDG_BIN_HOME"
set -e GOROOT

# 1Password configuration
set -q OP_CACHE; or set -x OP_CACHE "$XDG_STATE_HOME/1password"

# Python configuration
set -q WORKON_HOME; or set -x WORKON_HOME "$XDG_DATA_HOME/virtualenvs"

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

# Poetry configuration
set -q POETRY_HOME; or set -x POETRY_HOME "$XDG_DATA_HOME/poetry"
fish_add_path "$POETRY_HOME/bin"

# Rust / cargo configuration
set -q CARGO_HOME; or set -x CARGO_HOME "$XDG_DATA_HOME/cargo"
set -q CARGO_BIN_HOME; or set -x CARGO_BIN_HOME "$XDG_BIN_HOME"
set -q RUSTUP_HOME; or set -x RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -x RUST_WITHOUT "clippy,docs,rls"
fish_add_path "$CARGO_HOME/bin"

# screen configuration
set -q SCREENRC; or set -x SCREENRC "$XDG_CONFIG_HOME/misc/screenrc"

# Sonarlint configuration
set -q SONARLINT_HOME; or set -x SONARLINT_HOME "$XDG_DATA_HOME/sonarlint"
set -q SONARLINT_BIN; or set -x SONARLINT_BIN "$XDG_BIN_HOME"
set -q SONARLINT_USER_HOME; or set -x SONARLINT_USER_HOME "$XDG_DATA_HOME/sonarlint"

# tmux configuration
set -q TMUX_TMPDIR; or set -x TMUX_TMPDIR "$XDG_STATE_HOME/tmux"
set -q TMUX_CONF_DIR; or set -x TMUX_CONF_DIR "$XDG_CONFIG_HOME/tmux"
set -q TMUX_PLUGINS; or set -x TMUX_PLUGINS "$TMUX_CONF_DIR/plugins"
set -q TMUX_CONF; or set -x TMUX_CONF "$TMUX_CONF_DIR/tmux.conf"
set -q TMUX_PLUGIN_MANAGER_PATH; or set -x TMUX_PLUGIN_MANAGER_PATH "$TMUX_PLUGINS"

# tms configuration
set -q TMS_CONFIG_FILE; or set -x TMS_CONFIG_FILE "$XDG_CONFIG_HOME/tms/config.toml"

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
