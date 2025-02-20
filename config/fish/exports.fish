#!/usr/bin/env fish

# Set XDG environment variables
test -z "$XDG_CONFIG_HOME" && set -x XDG_CONFIG_HOME "$HOME/.config"
test -z "$XDG_DATA_HOME" && set -x XDG_DATA_HOME "$HOME/.local/share"
test -z "$XDG_CACHE_HOME" && set -x XDG_CACHE_HOME "$HOME/.cache"
test -z "$XDG_STATE_HOME" && set -x XDG_STATE_HOME "$HOME/.local/state"
test -z "$XDG_BIN_HOME" && set -x XDG_BIN_HOME "$HOME/.local/bin"
test -z "$XDG_RUNTIME_DIR" && set -x XDG_RUNTIME_DIR "$HOME/.local/run"

# Set dotfiles directory
test -z "$DOTFILES" && set -x DOTFILES "$HOME/.dotfiles"

# Set other environment variables
test -z "$EDITOR" && set -x EDITOR "nvim"
test -z "$VISUAL" && set -x VISUAL "code"
test -z "$HOSTNAME" && set -x HOSTNAME (hostname -s)

# Add local bin to path
fish_add_path "$XDG_BIN_HOME"

# Set npm environment variables
test -z "$NPM_CONFIG_PREFIX" && set -x NPM_CONFIG_PREFIX "$XDG_DATA_HOME/npm"
fish_add_path "$NPM_CONFIG_PREFIX/bin"

# Set yarn environment variables
test -z "$YARN_GLOBAL_FOLDER" && set -x YARN_GLOBAL_FOLDER "$XDG_DATA_HOME/yarn"
fish_add_path "$YARN_GLOBAL_FOLDER/bin"

# Set mason environment variables
test -z "$MASON_HOME" && set -x MASON_HOME "$XDG_DATA_HOME/nvim/mason"
fish_add_path "$MASON_HOME/bin"

# Set ASDF environment variables
test -z "$ASDF_DATA_DIR" && set -x ASDF_DATA_DIR "$XDG_DATA_HOME/asdf"
test -z "$ASDF_LOG_PATH" && set -x ASDF_LOG_PATH "$XDG_STATE_HOME/asdf/log"
test -z "$ASDF_CONFIG_DIR" && set -x ASDF_CONFIG_DIR "$XDG_CONFIG_HOME/asdf"
test -z "$ASDF_CONFIG_FILE" && set -x ASDF_CONFIG_FILE "$ASDF_CONFIG_DIR/asdfrc"

## Default package files
test -z "$ASDF_CRATE_DEFAULT_PACKAGES_FILE" && set -x ASDF_CRATE_DEFAULT_PACKAGES_FILE "$ASDF_CONFIG_DIR/cargo-packages"
test -z "$ASDF_GEM_DEFAULT_PACKAGES_FILE" && set -x ASDF_GEM_DEFAULT_PACKAGES_FILE "$ASDF_CONFIG_DIR/gem-packages"
test -z "$ASDF_GOLANG_DEFAULT_PACKAGES_FILE" && set -x ASDF_GOLANG_DEFAULT_PACKAGES_FILE "$ASDF_CONFIG_DIR/golang-packages"
test -z "$ASDF_NPM_DEFAULT_PACKAGES_FILE" && set -x ASDF_NPM_DEFAULT_PACKAGES_FILE "$ASDF_CONFIG_DIR/npm-packages"
test -z "$ASDF_PYTHON_DEFAULT_PACKAGES_FILE" && set -x ASDF_PYTHON_DEFAULT_PACKAGES_FILE "$ASDF_CONFIG_DIR/python-packages"

## Plugin configuration
set -x ASDF_DIRENV_IGNORE_MISSING_PLUGINS "1"
set -x ASDF_GOLANG_MOD_VERSION_ENABLED "true"
set -x ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY "latest_available"
test -z "$ASDF_GOLANG_MOD_VERSION_ENABLED" && set -x ASDF_GOLANG_MOD_VERSION_ENABLED "true"

## Load ASDF, if it exists
test -f "$HOME/.local/asdf/asdf.fish" &&
  source "$HOME/.local/asdf/asdf.fish" &&
  asdf reshim &&
  fish_add_path "$ASDF_DIR/shims"
## If $HOME/.local/asdf/asdf.fish does not exist, show error message
test -e "$HOME/.local/asdf/asdf.fish" || echo "ASDF not found"

# Load ASDF completions
test -d "$XDG_CONFIG_HOME/fish/completions" ||
  mkdir -p "$XDG_CONFIG_HOME/fish/completions";
test -e "$XDG_CONFIG_HOME/fish/completions/asdf.fish" ||
  and ln -s "$ASDF_DIR/completions/asdf.fish" "$XDG_CONFIG_HOME/fish/completions/asdf.fish"

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
# https://docs.ansible.com/ansible/latest/reference_appendices/config.html
test -z "$ANSIBLE_HOME" && set -x ANSIBLE_HOME "$XDG_CONFIG_HOME/ansible"
test -z "$ANSIBLE_CONFIG" && set -x ANSIBLE_CONFIG "$ANSIBLE_HOME/ansible.cfg"
test -z "$ANSIBLE_GALAXY_CACHE_DIR" && set -x ANSIBLE_GALAXY_CACHE_DIR "$XDG_CACHE_HOME/ansible/galaxy_cache"
x-dc "$ANSIBLE_HOME"
x-dc "$ANSIBLE_GALAXY_CACHE_DIR"

# AWS configuration
test -z "$AWS_CONFIG_FILE" && set -x AWS_CONFIG_FILE "$XDG_STATE_HOME/aws/config"
test -z "$AWS_SHARED_CREDENTIALS_FILE" && set -x AWS_SHARED_CREDENTIALS_FILE "$XDG_STATE_HOME/aws/credentials"
test -z "$AWS_SESSION_TOKEN" && set -x AWS_SESSION_TOKEN "$XDG_STATE_HOME/aws/session_token"
test -z "$AWS_DATA_PATH" && set -x AWS_DATA_PATH "$XDG_DATA_HOME/aws"
test -z "$AWS_DEFAULT_OUTPUT" && set -x AWS_DEFAULT_OUTPUT "table"
test -z "$AWS_CONFIGURE_KEYS" && set -x AWS_CONFIGURE_KEYS "true"
test -z "$AWS_CONFIGURE_SESSION" && set -x AWS_CONFIGURE_SESSION "true"
test -z "$AWS_CONFIGURE_SESSION_DURATION" && set -x AWS_CONFIGURE_SESSION_DURATION "7200"
test -z "$AWS_CONFIGURE_SESSION_MFA" && set -x AWS_CONFIGURE_SESSION_MFA "true"
test -z "$AWS_CONFIGURE_PROFILE" && set -x AWS_CONFIGURE_PROFILE "true"
test -z "$AWS_CONFIGURE_PROMPT" && set -x AWS_CONFIGURE_PROMPT "true"
test -z "$AWS_CONFIGURE_PROMPT_DEFAULT" && set -x AWS_CONFIGURE_PROMPT_DEFAULT "true"

# Brew configuration
test -z "$HOMEBREW_NO_ANALYTICS" && set -x HOMEBREW_NO_ANALYTICS "true"
test -z "$HOMEBREW_NO_ENV_HINTS" && set -x HOMEBREW_NO_ENV_HINTS "true"
test -z "$HOMEBREW_BUNDLE_MAS_SKIP" && set -x HOMEBREW_BUNDLE_MAS_SKIP "true"
test -z "$HOMEBREW_BUNDLE_FILE" && set -x HOMEBREW_BUNDLE_FILE "$XDG_CONFIG_HOME/homebrew/Brewfile"

# Set composer environment variables
test -z "$COMPOSER_HOME" && set -x COMPOSER_HOME "$XDG_STATE_HOME/composer"
test -z "$COMPOSER_BIN" && set -x COMPOSER_BIN "$COMPOSER_HOME/vendor/bin"
fish_add_path "$COMPOSER_BIN"

# direnv, https://direnv.net/
# https://direnv.net/docs/hook.html
# Set the hook to show the direnv message in a different color
# export DIRENV_LOG_FORMAT=$'\033[2mdirenv: %s\033[0m'
test -z "$DIRENV_LOG_FORMAT" && set -x DIRENV_LOG_FORMAT ''

# docker, https://docs.docker.com/engine/reference/commandline/cli/
test -z "$DOCKER_CONFIG" && set -x DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"
x-dc "$DOCKER_CONFIG"
test -z "$DOCKER_HIDE_LEGACY_COMMANDS" && set -x DOCKER_HIDE_LEGACY_COMMANDS "true"
# Docke: Disable snyk ad
test -z "$DOCKER_SCAN_SUGGEST" && set -x DOCKER_SCAN_SUGGEST "false"

# fzf
test -z "$FZF_BASE" && set -x FZF_BASE "$XDG_CONFIG_HOME/fzf"
test -z "$FZF_DEFAULT_OPTS" && set -x FZF_DEFAULT_OPTS '--height 40% --tmux bottom,40% --layout reverse --border top'

# GnuPG
# https://gnupg.org/documentation/manuals/gnupg/Invoking-GPG.html
test -z "$GNUPGHOME" && set -x GNUPGHOME "$XDG_DATA_HOME/gnupg"

# Go
test -z "$GOPATH" && set -x GOPATH "$XDG_DATA_HOME/go"
test -z "$GOBIN" && set -x GOBIN "$XDG_BIN_HOME"
fish_add_path "$GOBIN"

# NPM: Add npm packages to path
if x-have node;
  set -x NVM_NODE_BIN_DIR $(dirname $(which node))
  fish_add_path "$NVM_NODE_BIN_DIR"
end

# 1Password
test -z "$OP_CACHE" && set -x OP_CACHE "$XDG_STATE_HOME/1password"

# Python
test -z "$WORKON_HOME" && set -x WORKON_HOME "$XDG_DATA_HOME/virtualenvs"
test -z "$PYENV_ROOT" && set -x PYENV_ROOT "$XDG_DATA_HOME/pyenv"
fish_add_path "$PYENV_ROOT/bin"

## Set poetry environment variables
test -z "$POETRY_HOME" && set -x POETRY_HOME "$XDG_DATA_HOME/poetry"
fish_add_path "$POETRY_HOME/bin"

# Rust / cargo
test -z "$CARGO_HOME" && set -x CARGO_HOME "$XDG_DATA_HOME/cargo"
test -z "$CARGO_BIN_HOME" && set -x CARGO_BIN_HOME "$XDG_BIN_HOME"
test -z "$RUSTUP_HOME" && set -x RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -x RUST_WITHOUT "clippy,docs,rls"
fish_add_path "$CARGO_BIN_HOME"
fish_add_path "$XDG_SHARE_HOME/bob/nvim-bin"

# screen
# https://www.gnu.org/software/screen/manual/screen.html
test -z "$SCREENRC" && set -x SCREENRC "$XDG_CONFIG_HOME/misc/screenrc"

# Sonarlint
test -z "$SONARLINT_HOME" && set -x SONARLINT_HOME "$XDG_DATA_HOME/sonarlint"
test -z "$SONARLINT_BIN" && set -x SONARLINT_BIN "$XDG_BIN_HOME"
test -z "$SONARLINT_USER_HOME" && set -x SONARLINT_USER_HOME "$XDG_DATA_HOME/sonarlint"

# Terraform
test -z "$TF_DATA_DIR" && set -x TF_DATA_DIR "$XDG_STATE_HOME/terraform"
test -z "$TF_CLI_CONFIG_FILE" && set -x TF_CLI_CONFIG_FILE "$XDG_CONFIG_HOME/terraform/terraformrc"
test -z "$TF_PLUGIN_CACHE_DIR" && set -x TF_PLUGIN_CACHE_DIR "$XDG_CACHE_HOME/terraform/plugin-cache"

# tmux
# https://tmux.github.io/
test -z "$TMUX_TMPDIR" && set -x TMUX_TMPDIR "$XDG_STATE_HOME/tmux"
test -z "$TMUX_CONF_DIR" && set -x TMUX_CONF_DIR "$XDG_CONFIG_HOME/tmux"
test -z "$TMUX_PLUGINS" && set -x TMUX_PLUGINS "$TMUX_CONF_DIR/plugins"
test -z "$TMUX_CONF" && set -x TMUX_CONF "$TMUX_CONF_DIR/tmux.conf"
test -z "$TMUX_PLUGIN_MANAGER_PATH" && set -x TMUX_PLUGIN_MANAGER_PATH "$TMUX_PLUGINS"

# tms
# https://github.com/jrmoulton/tmux-sessionizer
test -z "$TMS_CONFIG_FILE" && set -x TMS_CONFIG_FILE "$XDG_CONFIG_HOME/tms/config.toml"

# wakatime
# https://github.com/wakatime/wakatime-cli
test -z "$WAKATIME_HOME" && set -x WAKATIME_HOME "$XDG_STATE_HOME/wakatime"
x-dc "$WAKATIME_HOME"

# misc
test -z "$CHEAT_USE_FZF" && set -x CHEAT_USE_FZF "true"
test -z "$SQLITE_HISTORY" && set -x SQLITE_HISTORY "$XDG_CACHE_HOME/sqlite/sqlite_history"

# Source exports-secret.fish if it exists
if test -f "$DOTFILES/config/fish/exports-secret.fish"
  source "$DOTFILES/config/fish/exports-secret.fish"
end

# Source $DOTFILES/hosts/$HOSTNAME/config/fish/exports.fish if it exists
if test -f "$DOTFILES/hosts/$HOSTNAME/config/fish/exports.fish"
  source "$DOTFILES/hosts/$HOSTNAME/config/fish/exports.fish"
end

# Source $DOTFILES/hosts/$HOSTNAME/config/fish/exports-secret.fish if it exists
if test -f "$DOTFILES/hosts/$HOSTNAME/config/fish/exports-secret.fish"
  source "$DOTFILES/hosts/$HOSTNAME/config/fish/exports-secret.fish"
end
