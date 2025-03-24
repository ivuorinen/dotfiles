#!/usr/bin/env fish

# XDG Base Directory Specification
set -q XDG_CONFIG_HOME; or set -x XDG_CONFIG_HOME "$HOME/.config"
set -q XDG_DATA_HOME; or set -x XDG_DATA_HOME "$HOME/.local/share"
set -q XDG_CACHE_HOME; or set -x XDG_CACHE_HOME "$HOME/.cache"
set -q XDG_STATE_HOME; or set -x XDG_STATE_HOME "$HOME/.local/state"
set -q XDG_BIN_HOME; or set -x XDG_BIN_HOME "$HOME/.local/bin"
set -q XDG_RUNTIME_DIR; or set -x XDG_RUNTIME_DIR "$HOME/.local/run"

# Dotfiles directory
set -q DOTFILES; or set -x DOTFILES "$HOME/.dotfiles"

# Editor settings
set -q EDITOR; or set -x EDITOR "nvim"
set -q VISUAL; or set -x VISUAL "code"
set -q HOSTNAME; or set -x HOSTNAME (hostname -s)

# Add local bin to path
fish_add_path "$XDG_BIN_HOME"

# Add cargo bin to path
fish_add_path "$XDG_SHARE_HOME/cargo/bin"

# Set Aqua configuration
set -q AQUA_BIN; or set -x AQUA_BIN "$XDG_DATA_HOME/aquaproj-aqua/bin"
set -q AQUA_CONFIG; or set -x AQUA_CONFIG "$XDG_CONFIG_HOME/aqua/aqua.yaml"
set -gx PATH $AQUA_BIN $PATH


# Yarn configuration
set -q YARN_GLOBAL_FOLDER; or set -x YARN_GLOBAL_FOLDER "$XDG_DATA_HOME/yarn"
fish_add_path "$YARN_GLOBAL_FOLDER/bin"

# Mason configuration
set -q MASON_HOME; or set -x MASON_HOME "$XDG_DATA_HOME/nvim/mason"
fish_add_path "$MASON_HOME/bin"

# Set Neovim environment variables
test -z "$NVIM_STATE" && set -x NVIM_STATE "$XDG_STATE_HOME/nvim"
test -z "$NVIM_CONFIG_HOME" && set -x NVIM_CONFIG_HOME "$XDG_CONFIG_HOME/nvim"
test -z "$NVIM_DATA_HOME" && set -x NVIM_DATA_HOME "$XDG_DATA_HOME/nvim"
test -z "$NVIM_CACHE_HOME" && set -x NVIM_CACHE_HOME "$XDG_CACHE_HOME/nvim"
test -z "$NVIM_LOG_PATH" && set -x NVIM_LOG_PATH "$NVIM_STATE/log"
test -z "$NVIM_SESSION_PATH" && set -x NVIM_SESSION_PATH "$NVIM_STATE/session"
test -z "$NVIM_SHADA_PATH" && set -x NVIM_SHADA_PATH "$NVIM_STATE/shada"
test -z "$NVIM_UNDO_PATH" && set -x NVIM_UNDO_PATH "$NVIM_STATE/undo"

# Ansible configuration
set -q ANSIBLE_HOME; or set -x ANSIBLE_HOME "$XDG_CONFIG_HOME/ansible"
set -q ANSIBLE_CONFIG; or set -x ANSIBLE_CONFIG "$ANSIBLE_HOME/ansible.cfg"
set -q ANSIBLE_GALAXY_CACHE_DIR; or set -x ANSIBLE_GALAXY_CACHE_DIR "$XDG_CACHE_HOME/ansible/galaxy_cache"
x-dc "$ANSIBLE_HOME"
x-dc "$ANSIBLE_GALAXY_CACHE_DIR"

# AWS configuration
set -q AWS_CONFIG_FILE; or set -x AWS_CONFIG_FILE "$XDG_STATE_HOME/aws/config"
set -q AWS_SHARED_CREDENTIALS_FILE; or set -x AWS_SHARED_CREDENTIALS_FILE "$XDG_STATE_HOME/aws/credentials"
set -q AWS_SESSION_TOKEN; or set -x AWS_SESSION_TOKEN "$XDG_STATE_HOME/aws/session_token"
set -q AWS_DATA_PATH; or set -x AWS_DATA_PATH "$XDG_DATA_HOME/aws"
set -q AWS_DEFAULT_OUTPUT; or set -x AWS_DEFAULT_OUTPUT "table"
set -q AWS_CONFIGURE_KEYS; or set -x AWS_CONFIGURE_KEYS "true"
set -q AWS_CONFIGURE_SESSION; or set -x AWS_CONFIGURE_SESSION "true"
set -q AWS_CONFIGURE_SESSION_DURATION; or set -x AWS_CONFIGURE_SESSION_DURATION "7200"
set -q AWS_CONFIGURE_SESSION_MFA; or set -x AWS_CONFIGURE_SESSION_MFA "true"
set -q AWS_CONFIGURE_PROFILE; or set -x AWS_CONFIGURE_PROFILE "true"
set -q AWS_CONFIGURE_PROMPT; or set -x AWS_CONFIGURE_PROMPT "true"
set -q AWS_CONFIGURE_PROMPT_DEFAULT; or set -x AWS_CONFIGURE_PROMPT_DEFAULT "true"

# Brew configuration
set -q HOMEBREW_NO_ANALYTICS; or set -x HOMEBREW_NO_ANALYTICS "true"
set -q HOMEBREW_NO_ENV_HINTS; or set -x HOMEBREW_NO_ENV_HINTS "true"
set -q HOMEBREW_BUNDLE_MAS_SKIP; or set -x HOMEBREW_BUNDLE_MAS_SKIP "true"
set -q HOMEBREW_BUNDLE_FILE; or set -x HOMEBREW_BUNDLE_FILE "$XDG_CONFIG_HOME/homebrew/Brewfile"

# Composer configuration
set -q COMPOSER_HOME; or set -x COMPOSER_HOME "$XDG_STATE_HOME/composer"
set -q COMPOSER_BIN; or set -x COMPOSER_BIN "$COMPOSER_HOME/vendor/bin"
fish_add_path "$COMPOSER_BIN"

# direnv configuration
set -q DIRENV_LOG_FORMAT; or set -x DIRENV_LOG_FORMAT ''

# Docker configuration
set -q DOCKER_CONFIG; or set -x DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"
x-dc "$DOCKER_CONFIG"
set -q DOCKER_HIDE_LEGACY_COMMANDS; or set -x DOCKER_HIDE_LEGACY_COMMANDS "true"
set -q DOCKER_SCAN_SUGGEST; or set -x DOCKER_SCAN_SUGGEST "false"

# fzf configuration
set -q FZF_BASE; or set -x FZF_BASE "$XDG_CONFIG_HOME/fzf"
set -q FZF_DEFAULT_OPTS; or set -x FZF_DEFAULT_OPTS '--height 40% --tmux bottom,40% --layout reverse --border top'

# GnuPG configuration
set -q GNUPGHOME; or set -x GNUPGHOME "$XDG_DATA_HOME/gnupg"

# Go configuration
set -q GOPATH; or set -x GOPATH "$XDG_DATA_HOME/go"
set -q GOBIN; or set -x GOBIN "$XDG_BIN_HOME"
fish_add_path "$GOBIN"

# NPM: Add npm packages to path
if x-have node;
  set -x NVM_NODE_BIN_DIR (dirname (which node))
  fish_add_path "$NVM_NODE_BIN_DIR"
end

# 1Password configuration
set -q OP_CACHE; or set -x OP_CACHE "$XDG_STATE_HOME/1password"

# Python configuration
set -q WORKON_HOME; or set -x WORKON_HOME "$XDG_DATA_HOME/virtualenvs"
set -q PYENV_ROOT; or set -x PYENV_ROOT "$XDG_DATA_HOME/pyenv"
fish_add_path "$PYENV_ROOT/bin"
if x-have pyenv; and not functions -q pyenv
  status --is-interactive; and source (pyenv init - | psub)
end

# Poetry configuration
set -q POETRY_HOME; or set -x POETRY_HOME "$XDG_DATA_HOME/poetry"
fish_add_path "$POETRY_HOME/bin"

# Rust / cargo configuration
set -q CARGO_HOME; or set -x CARGO_HOME "$XDG_DATA_HOME/cargo"
set -q CARGO_BIN_HOME; or set -x CARGO_BIN_HOME "$XDG_BIN_HOME"
set -q RUSTUP_HOME; or set -x RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -x RUST_WITHOUT "clippy,docs,rls"
fish_add_path "$CARGO_BIN_HOME"
fish_add_path "$CARGO_HOME/bin"
fish_add_path "$XDG_SHARE_HOME/bob/nvim-bin"

# screen configuration
set -q SCREENRC; or set -x SCREENRC "$XDG_CONFIG_HOME/misc/screenrc"

# Sonarlint configuration
set -q SONARLINT_HOME; or set -x SONARLINT_HOME "$XDG_DATA_HOME/sonarlint"
set -q SONARLINT_BIN; or set -x SONARLINT_BIN "$XDG_BIN_HOME"
set -q SONARLINT_USER_HOME; or set -x SONARLINT_USER_HOME "$XDG_DATA_HOME/sonarlint"

# Terraform configuration
set -q TF_DATA_DIR; or set -x TF_DATA_DIR "$XDG_STATE_HOME/terraform"
set -q TF_CLI_CONFIG_FILE; or set -x TF_CLI_CONFIG_FILE "$XDG_CONFIG_HOME/terraform/terraformrc"
set -q TF_PLUGIN_CACHE_DIR; or set -x TF_PLUGIN_CACHE_DIR "$XDG_CACHE_HOME/terraform/plugin-cache"

# tmux configuration
set -q TMUX_TMPDIR; or set -x TMUX_TMPDIR "$XDG_STATE_HOME/tmux"
set -q TMUX_CONF_DIR; or set -x TMUX_CONF_DIR "$XDG_CONFIG_HOME/tmux"
set -q TMUX_PLUGINS; or set -x TMUX_PLUGINS "$TMUX_CONF_DIR/plugins"
set -q TMUX_CONF; or set -x TMUX_CONF "$TMUX_CONF_DIR/tmux.conf"
set -q TMUX_PLUGIN_MANAGER_PATH; or set -x TMUX_PLUGIN_MANAGER_PATH "$TMUX_PLUGINS"

# Source tmux theme activation script for Fish shell
if test -f "$DOTFILES/config/tmux/theme-activate.fish"
  source "$DOTFILES/config/tmux/theme-activate.fish"
end

# tms configuration
set -q TMS_CONFIG_FILE; or set -x TMS_CONFIG_FILE "$XDG_CONFIG_HOME/tms/config.toml"

# wakatime configuration
set -q WAKATIME_HOME; or set -x WAKATIME_HOME "$XDG_STATE_HOME/wakatime"
x-dc "$WAKATIME_HOME"

# Miscellaneous configuration
set -q CHEAT_USE_FZF; or set -x CHEAT_USE_FZF "true"
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

# Configure tide prompt
set -gx tide_prompt_transient_enabled true
set -gx tide_prompt_add_newline_before true
set -gx tide_prompt_min_cols 34
set -gx tide_prompt_pad_items false
set -gx tide_left_prompt_items context pwd git node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig newline character
set -gx tide_right_prompt_items status jobs direnv
set -gx tide_context_hostname_parts 1
