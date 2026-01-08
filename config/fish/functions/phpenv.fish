# phpenv - PHP Version Manager for Fish Shell
# Repository: https://github.com/ivuorinen/phpenv.fish

function phpenv -d "PHP version manager for Fish Shell"
    if not command -q jq
        echo "Error: jq is required but not installed. Install with: brew install jq" >&2
        return 1
    end

    set -l phpenv_cmd $argv[1]
    set -l phpenv_args $argv[2..]

    switch $phpenv_cmd
        case install
            __phpenv_install $phpenv_args
        case uninstall
            __phpenv_uninstall $phpenv_args
        case use
            __phpenv_use $phpenv_args
        case local
            __phpenv_local $phpenv_args
        case global
            __phpenv_global $phpenv_args
        case list ls
            __phpenv_list $phpenv_args
        case current
            __phpenv_current
        case which
            __phpenv_which $phpenv_args
        case versions
            __phpenv_versions
        case doctor
            __phpenv_doctor
        case config
            __phpenv_config $phpenv_args
        case extensions ext
            __phpenv_extensions $phpenv_args
        case help -h --help ""
            __phpenv_help
        case '*'
            echo "phpenv: unknown command '$phpenv_cmd'"
            echo "Run 'phpenv help' for available commands."
            return 1
    end
end

function __phpenv_current
    set -l phpenv_version (__phpenv_detect_version)
    if test -n "$phpenv_version"
        echo "$phpenv_version"
    else
        echo "No PHP version set"
        return 1
    end
end

function __phpenv_detect_version
    set -l phpenv_version_file (__phpenv_find_version_file .php-version)
    if test -n "$phpenv_version_file"
        set -l phpenv_version (string trim < $phpenv_version_file)
        if test -n "$phpenv_version"
            echo $phpenv_version
            return
        end
    end

    set -l phpenv_tool_version_file (__phpenv_find_version_file .tool-version)
    if test -n "$phpenv_tool_version_file"
        set -l phpenv_version (__phpenv_parse_tool_version $phpenv_tool_version_file)
        if test -n "$phpenv_version"
            echo $phpenv_version
            return
        end
    end

    if test -f composer.json
        set -l phpenv_version (__phpenv_parse_composer_version)
        if test -n "$phpenv_version"
            echo $phpenv_version
            return
        end
    end

    if test -n "$PHPENV_GLOBAL_VERSION"
        echo $PHPENV_GLOBAL_VERSION
        return
    end

    set -l phpenv_global_version (__phpenv_config_get global-version)
    if test -n "$phpenv_global_version"
        echo $phpenv_global_version
        return
    end

    if command -q php
        php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;" 2>/dev/null
    end
end

function __phpenv_find_version_file -a phpenv_filename
    set -l phpenv_dir (pwd)
    while test "$phpenv_dir" != "/"
        if test -f "$phpenv_dir/$phpenv_filename"
            echo "$phpenv_dir/$phpenv_filename"
            return
        end
        set phpenv_dir (dirname $phpenv_dir)
    end
end

function __phpenv_parse_tool_version -a phpenv_file
    if test -f $phpenv_file
        set -l phpenv_line (grep "^php " $phpenv_file)
        if test -n "$phpenv_line"
            set -l phpenv_parts (string split ' ' $phpenv_line)
            if test (count $phpenv_parts) -ge 2
                echo $phpenv_parts[2] | sed 's/^v//'
            end
        end
    end
end

function __phpenv_parse_composer_version
    if not test -f composer.json
        return
    end

    set -l phpenv_platform_php (jq -r '.config.platform.php // empty' composer.json 2>/dev/null)
    if test $status -eq 0 -a -n "$phpenv_platform_php" -a "$phpenv_platform_php" != "null"
        echo $phpenv_platform_php
        return
    end

    set -l phpenv_require_php (jq -r '.require.php // empty' composer.json 2>/dev/null)
    if test $status -eq 0 -a -n "$phpenv_require_php" -a "$phpenv_require_php" != "null"
        __phpenv_parse_semver_constraint $phpenv_require_php
        return
    end
end

function __phpenv_parse_semver_constraint -a phpenv_constraint
    set phpenv_constraint (echo $phpenv_constraint | tr -d ' "')

    set -l phpenv_latest_8x (__phpenv_parse_version_field "8.x" "8.4")
    set -l phpenv_latest_7x (__phpenv_parse_version_field "7.x" "7.4")
    set -l phpenv_latest (__phpenv_parse_version_field "latest" "8.4")

    switch $phpenv_constraint
        case '^8.*'
            echo $phpenv_latest_8x
        case '^7.*'
            echo $phpenv_latest_7x
        case '~8.4*'
            echo "8.4"
        case '~8.3*'
            echo "8.3"
        case '~8.2*'
            echo "8.2"
        case '~8.1*'
            echo "8.1"
        case '~8.0*'
            echo "8.0"
        case '~7.4*'
            echo "7.4"
        case '>=8.1'
            echo $phpenv_latest_8x
        case '>=8.0'
            echo $phpenv_latest_8x
        case '>=7.4'
            echo $phpenv_latest_8x
        case '8.*' '8.x.*'
            echo $phpenv_latest_8x
        case '7.*' '7.x.*'
            echo $phpenv_latest_7x
        case '5.*' '5.x.*'
            echo "5.6"
        case '*'
            if echo $phpenv_constraint | grep -q '[0-9]\+\.[0-9]\+'
                echo $phpenv_constraint | sed 's/[^0-9\.]//g' | cut -d. -f1,2
            else
                echo $phpenv_latest
            end
    end
end

# Cache version info to avoid repeated API calls
set -g __phpenv_version_cache
set -g __phpenv_version_cache_time 0

function __phpenv_get_version_info
    set -l current_time (date +%s)
    set -l cache_duration 300  # 5 minutes

    # Return cached version if still valid
    if test -n "$__phpenv_version_cache"
        set -l cache_age (math $current_time - $__phpenv_version_cache_time)
        if test $cache_age -lt $cache_duration
            echo $__phpenv_version_cache
            return
        end
    end

    if command -q curl
        set -l url https://raw.githubusercontent.com/shivammathur/setup-php/refs/heads/main
        set -l version_data (curl -s "$url/src/configs/php-versions.json" 2>/dev/null)
        if test -n "$version_data"
            set -g __phpenv_version_cache $version_data
            set -g __phpenv_version_cache_time $current_time
            echo $version_data
        end
    end
end

# Cache cellar path as it doesn't change
set -g __phpenv_cellar_cache

function __phpenv_get_cellar_path
    if test -n "$__phpenv_cellar_cache"
        echo $__phpenv_cellar_cache
        return
    end

    if test -d /opt/homebrew/Cellar
        set -g __phpenv_cellar_cache /opt/homebrew/Cellar
    else if test -d /usr/local/Cellar
        set -g __phpenv_cellar_cache /usr/local/Cellar
    else if test -d /home/linuxbrew/.linuxbrew/Cellar
        set -g __phpenv_cellar_cache /home/linuxbrew/.linuxbrew/Cellar
    else
        set -g __phpenv_cellar_cache ""
    end

    echo $__phpenv_cellar_cache
end

function __phpenv_ensure_taps
    if not command -q brew
        return 1
    end

    # Check and add required taps only if missing
    set -l required_taps "shivammathur/php" "shivammathur/extensions"
    for tap in $required_taps
        if not brew tap | grep -q $tap 2>/dev/null
            if not brew tap $tap 2>/dev/null
                echo "Warning: Failed to add tap $tap" >&2
                return 1
            end
        end
    end
end

function __phpenv_parse_version_field -a field fallback
    set -l version_info (__phpenv_get_version_info)
    if test -n "$version_info"
        echo $version_info | jq -r ".$field // \"$fallback\"" 2>/dev/null
    else
        echo $fallback
    end
end

function __phpenv_list_installed
    set -l phpenv_versions
    set -l phpenv_cellar_path (__phpenv_get_cellar_path)

    if test -d $phpenv_cellar_path
        for phpenv_dir in $phpenv_cellar_path/php@* $phpenv_cellar_path/php
            if test -d $phpenv_dir
                set -l phpenv_basename (basename $phpenv_dir)

                if echo $phpenv_basename | grep -qE '(debug|zts)'
                    continue
                end

                if test "$phpenv_basename" = "php"
                    set -l phpenv_latest (__phpenv_parse_version_field "latest" "8.4")
                    set -a phpenv_versions $phpenv_latest
                else if echo $phpenv_basename | grep -qE '^php@[0-9]+\.[0-9]+$'
                    set -l phpenv_version (echo $phpenv_basename | sed 's/php@//')
                    set -a phpenv_versions $phpenv_version
                end
            end
        end
    end

    printf '%s\n' $phpenv_versions | sort -V | uniq
end

function __phpenv_resolve_version_alias -a phpenv_version
    switch $phpenv_version
        case latest
            __phpenv_parse_version_field "latest" "8.4"
        case nightly
            __phpenv_parse_version_field "nightly" "8.5"
        case '8.x'
            __phpenv_parse_version_field "8.x" "8.4"
        case '7.x'
            __phpenv_parse_version_field "7.x" "7.4"
        case '5.x'
            __phpenv_parse_version_field "5.x" "5.6"
        case '*'
            echo $phpenv_version
    end
end

function __phpenv_get_formula_name -a phpenv_version
    set -l phpenv_latest_version (__phpenv_parse_version_field "latest" "8.4")

    if test "$phpenv_version" = "$phpenv_latest_version"
        echo "shivammathur/php/php"
    else
        echo "shivammathur/php/php@$phpenv_version"
    end
end

function __phpenv_is_version_installed -a phpenv_version
    set -l phpenv_cellar_path (__phpenv_get_cellar_path)
    set -l phpenv_latest_version (__phpenv_parse_version_field "latest" "8.4")

    if test "$phpenv_version" = "$phpenv_latest_version"
        test -d "$phpenv_cellar_path/php" -o -d "$phpenv_cellar_path/php@$phpenv_version"
    else
        test -d "$phpenv_cellar_path/php@$phpenv_version"
    end
end

function __phpenv_get_php_path -a phpenv_version
    set -l phpenv_cellar_path (__phpenv_get_cellar_path)
    set -l phpenv_latest_version (__phpenv_parse_version_field "latest" "8.4")

    set -l phpenv_target_dir
    if test "$phpenv_version" = "$phpenv_latest_version"
        if test -d "$phpenv_cellar_path/php"
            set phpenv_target_dir "$phpenv_cellar_path/php"
        else if test -d "$phpenv_cellar_path/php@$phpenv_version"
            set phpenv_target_dir "$phpenv_cellar_path/php@$phpenv_version"
        end
    else
        if test -d "$phpenv_cellar_path/php@$phpenv_version"
            set phpenv_target_dir "$phpenv_cellar_path/php@$phpenv_version"
        end
    end

    if test -n "$phpenv_target_dir"
        # Find the latest version directory by sorting
        set -l phpenv_versions
        for phpenv_dir in $phpenv_target_dir/*
            if test -d "$phpenv_dir"
                set -a phpenv_versions (basename "$phpenv_dir")
            end
        end

        if test (count $phpenv_versions) -gt 0
            set -l phpenv_latest_dir (printf '%s\n' $phpenv_versions | sort -V | tail -1)
            if test -n "$phpenv_latest_dir"
                echo "$phpenv_target_dir/$phpenv_latest_dir"
            end
        end
    end
end

function __phpenv_set_php_path -a phpenv_version
    set -l phpenv_php_path (__phpenv_get_php_path $phpenv_version)
    if test -z "$phpenv_php_path"
        echo "Failed to locate PHP $phpenv_version installation path" >&2
        return 1
    end

    if not test -x "$phpenv_php_path/bin/php"
        echo "PHP binary not found at $phpenv_php_path/bin/php" >&2
        return 1
    end

    # Store original PATH if not already stored
    if not set -q PHPENV_ORIGINAL_PATH
        set -g PHPENV_ORIGINAL_PATH $PATH
    end

    # Check if we're already using this version
    if set -q PHPENV_CURRENT_VERSION; and test "$PHPENV_CURRENT_VERSION" = "$phpenv_version"
        return 0
    end

    # Build clean PATH without any PHP paths
    set -l phpenv_clean_path
    for phpenv_path_entry in $PHPENV_ORIGINAL_PATH
        if not echo $phpenv_path_entry | grep -qE "/(Cellar|opt/homebrew)/(php|php@)"
            set -a phpenv_clean_path $phpenv_path_entry
        end
    end

    # Set new PATH with PHP version at front
    set -gx PATH "$phpenv_php_path/bin" $phpenv_clean_path
    set -g PHPENV_CURRENT_VERSION $phpenv_version
    set -g PHPENV_CURRENT_PATH "$phpenv_php_path/bin"

    # Verify the change worked
    if command -q php
        set -l phpenv_active_version (php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;" 2>/dev/null)
        if test "$phpenv_active_version" != "$phpenv_version"
            echo "Warning: PHP $phpenv_version set in PATH but php command shows $phpenv_active_version" >&2
            echo "PATH may have conflicting PHP installations" >&2
        end
    end
end

function __phpenv_restore_system_path
    if set -q PHPENV_ORIGINAL_PATH
        set -gx PATH $PHPENV_ORIGINAL_PATH
        set -e PHPENV_CURRENT_VERSION
        set -e PHPENV_CURRENT_PATH
        set -e PHPENV_ORIGINAL_PATH
        return 0
    else
        echo "No original PATH stored to restore"
        return 1
    end
end

function __phpenv_install -a phpenv_version
    if test -z "$phpenv_version"
        echo "Usage: phpenv install <version>"
        return 1
    end

    set phpenv_version (__phpenv_resolve_version_alias $phpenv_version)

    if __phpenv_is_version_installed $phpenv_version
        echo "PHP $phpenv_version is already installed"
        return 0
    end

    echo "Installing PHP $phpenv_version..."

    if not __phpenv_ensure_taps
        echo "Error: Homebrew is required but not available"
        return 1
    end

    set -l phpenv_formula (__phpenv_get_formula_name $phpenv_version)
    if test -z "$phpenv_formula"
        echo "Unknown PHP version: $phpenv_version"
        echo "Run 'phpenv versions' to see available versions"
        return 1
    end

    if brew install $phpenv_formula
        echo "PHP $phpenv_version installed successfully"

        if __phpenv_config_get auto-install-extensions | grep -q true
            __phpenv_install_default_extensions $phpenv_version
        end
    else
        echo "Failed to install PHP $phpenv_version"
        return 1
    end
end

function __phpenv_uninstall -a phpenv_version
    if test -z "$phpenv_version"
        echo "Usage: phpenv uninstall <version>"
        return 1
    end

    if not __phpenv_is_version_installed $phpenv_version
        echo "PHP $phpenv_version is not installed"
        return 1
    end

    set -l phpenv_formula (__phpenv_get_formula_name $phpenv_version)
    if brew uninstall $phpenv_formula
        echo "PHP $phpenv_version uninstalled successfully"
    else
        echo "Failed to uninstall PHP $phpenv_version"
        return 1
    end
end

function __phpenv_use
    set -l phpenv_version $argv[1]

    # Handle special case: restore system PHP
    if test "$phpenv_version" = "system"
        __phpenv_restore_system_path
        echo "Restored system PHP"
        return 0
    end

    if test -z "$phpenv_version"
        set phpenv_version (__phpenv_detect_version)
        if test -z "$phpenv_version"
            echo "No PHP version found for this project"
            echo "Usage: phpenv use <version|system>"
            return 1
        end
        echo "Detected PHP $phpenv_version for this project"
    end

    if not __phpenv_is_version_installed $phpenv_version
        if test "$(__phpenv_config_get auto-install)" = "true"
            __phpenv_install $phpenv_version
        else
            echo "PHP $phpenv_version is not installed. Install with: phpenv install $phpenv_version"
            return 1
        end
    end

    if __phpenv_set_php_path $phpenv_version
        echo "Using PHP $phpenv_version"
    else
        echo "Failed to switch to PHP $phpenv_version"
        return 1
    end
end

function __phpenv_local -a phpenv_version
    if test -z "$phpenv_version"
        echo "Usage: phpenv local <version>"
        return 1
    end

    echo $phpenv_version > .php-version
    echo "Set local PHP version to $phpenv_version"
end

function __phpenv_global -a phpenv_version
    if test -z "$phpenv_version"
        echo "Usage: phpenv global <version>"
        return 1
    end

    set -U PHPENV_GLOBAL_VERSION $phpenv_version
    echo "Set global PHP version to $phpenv_version"
end

function __phpenv_list
    set -l phpenv_versions (__phpenv_list_installed)
    set -l phpenv_current (__phpenv_detect_version)

    for phpenv_version in $phpenv_versions
        if test "$phpenv_version" = "$phpenv_current"
            echo "* $phpenv_version"
        else
            echo "  $phpenv_version"
        end
    end
end

function __phpenv_versions
    echo "Available versions from shivammathur/homebrew-php:"

    set -l phpenv_tap_versions (__phpenv_get_tap_versions)
    if test -n "$phpenv_tap_versions"
        echo $phpenv_tap_versions
        return
    end

    # Use cached version info
    set -l phpenv_latest (__phpenv_parse_version_field "latest" "8.4")
    set -l phpenv_nightly (__phpenv_parse_version_field "nightly" "8.5")
    set -l phpenv_version_8x (__phpenv_parse_version_field "8.x" "8.4")
    set -l phpenv_version_7x (__phpenv_parse_version_field "7.x" "7.4")
    set -l phpenv_version_5x (__phpenv_parse_version_field "5.x" "5.6")

    echo "Stable versions:"
    echo "  $phpenv_version_5x (5.x latest)  $phpenv_version_7x (7.x latest)  $phpenv_latest (latest stable)"
    echo "  $phpenv_nightly (nightly)"
    echo "  5.6  7.0  7.1  7.2  7.3  7.4"
    echo "  8.0  8.1  8.2  8.3  8.4  8.5"
end

function __phpenv_get_tap_versions
    if not command -q brew
        return
    end

    set -l phpenv_formulas (__phpenv_get_tap_formulas "shivammathur/php")

    if test -z "$phpenv_formulas"
        return
    end

    set -l phpenv_versions
    set -l phpenv_version_info (__phpenv_get_version_info)
    set -l phpenv_latest_version (echo $phpenv_version_info | jq -r '.latest // "8.4"' 2>/dev/null)

    for phpenv_formula in $phpenv_formulas
        set -l phpenv_clean_name (echo $phpenv_formula | sed 's|shivammathur/php/||')

        if echo $phpenv_clean_name | grep -qE '(debug|zts|autoconf|bison)'
            continue
        end

        if test "$phpenv_clean_name" = "php"
            set -a phpenv_versions "$phpenv_latest_version (latest)"
        else if echo $phpenv_clean_name | grep -qE '^php@[0-9]+\.[0-9]+$'
            set -l phpenv_version (echo $phpenv_clean_name | sed 's/php@//')
            set -a phpenv_versions $phpenv_version
        end
    end

    if test (count $phpenv_versions) -gt 0
        printf '%s\n' $phpenv_versions | sort -V | tr '\n' ' ' | sed 's/ $//'
        echo ""
    end
end

function __phpenv_which -a phpenv_binary
    set -l phpenv_binary (test -n "$phpenv_binary"; and echo $phpenv_binary; or echo "php")
    set -l phpenv_version (__phpenv_detect_version)

    if test -n "$phpenv_version"
        set -l phpenv_php_path (__phpenv_get_php_path $phpenv_version)
        if test -x "$phpenv_php_path/bin/$phpenv_binary"
            echo "$phpenv_php_path/bin/$phpenv_binary"
        else
            echo "$phpenv_binary not found for PHP $phpenv_version"
            return 1
        end
    else
        which $phpenv_binary
    end
end

function __phpenv_doctor
    echo "phpenv doctor"
    echo "============="

    if command -q jq
        echo "✓ jq is installed"
    else
        echo "✗ jq is not installed (required)"
    end

    if command -q brew
        echo "✓ Homebrew is installed"
    else
        echo "✗ Homebrew is not installed"
        return 1
    end

    # Check taps using unified function
    set -l tap_status (__phpenv_ensure_taps 2>/dev/null; echo $status)
    if test $tap_status -eq 0
        echo "✓ Required Homebrew taps are available"
    else
        echo "! Some Homebrew taps may need to be added automatically"
    end

    set -l phpenv_versions (__phpenv_list_installed)
    if test (count $phpenv_versions) -gt 0
        echo "✓ PHP versions installed: "(string join ", " $phpenv_versions)
    else
        echo "! No PHP versions installed"
    end

    set -l phpenv_current (__phpenv_detect_version)
    if test -n "$phpenv_current"
        echo "✓ Current PHP version: $phpenv_current"
    else
        echo "! No PHP version detected"
    end
end

function __phpenv_config -a phpenv_action phpenv_key phpenv_value
    switch $phpenv_action
        case get
            __phpenv_config_get $phpenv_key
        case set
            __phpenv_config_set $phpenv_key $phpenv_value
        case list
            __phpenv_config_list
        case '*'
            echo "Usage: phpenv config {get|set|list} [key] [value]"
            return 1
    end
end

# Helper function to get environment variable value
function __phpenv_get_env_var -a key
    switch $key
        case global-version
            echo $PHPENV_GLOBAL_VERSION
        case auto-install
            echo $PHPENV_AUTO_INSTALL
        case auto-install-extensions
            echo $PHPENV_AUTO_INSTALL_EXTENSIONS
        case auto-switch
            echo $PHPENV_AUTO_SWITCH
        case default-extensions
            echo $PHPENV_DEFAULT_EXTENSIONS
    end
end

# Helper function to map config key to env var name
function __phpenv_env_var_name -a key
    switch $key
        case global-version
            echo PHPENV_GLOBAL_VERSION
        case auto-install
            echo PHPENV_AUTO_INSTALL
        case auto-install-extensions
            echo PHPENV_AUTO_INSTALL_EXTENSIONS
        case auto-switch
            echo PHPENV_AUTO_SWITCH
        case default-extensions
            echo PHPENV_DEFAULT_EXTENSIONS
        case '*'
            echo ""
    end
end

function __phpenv_config_get -a phpenv_key
    set -l phpenv_env_var (__phpenv_env_var_name $phpenv_key)
    set -l phpenv_value
    set -l phpenv_source

    # Check if environment variable is set
    if test -n "$phpenv_env_var"; and set -q $phpenv_env_var
        set phpenv_value (eval echo \$$phpenv_env_var)
        set phpenv_source "fish universal variable"
    else
        # Check config files if environment variable is unset
        for phpenv_config_file in ~/.config/fish/conf.d/phpenv.fish ~/.config/phpenv/config ~/.phpenv.fish
            if test -f $phpenv_config_file
                set -l phpenv_file_value (grep "^$phpenv_key=" $phpenv_config_file | cut -d= -f2- | head -1)
                if test -n "$phpenv_file_value"
                    set phpenv_value $phpenv_file_value
                    set phpenv_source $phpenv_config_file
                    break
                end
            end
        end
    end

    if test "$argv[2]" = "--verbose"
        if test -n "$phpenv_value"
            echo "$phpenv_key = $phpenv_value (from $phpenv_source)"
        else
            echo "$phpenv_key = (not set)"
        end
    else
        echo $phpenv_value
    end
end

function __phpenv_config_set -a phpenv_key phpenv_value
    if test -z "$phpenv_value"
        echo "Usage: phpenv config set <key> <value>"
        return 1
    end

    switch $phpenv_key
        case global-version
            if __phpenv_validate_version $phpenv_value
                set -U PHPENV_GLOBAL_VERSION $phpenv_value
            else
                echo "Invalid PHP version: $phpenv_value"
                echo "Run 'phpenv versions' to see available versions"
                return 1
            end
        case auto-install
            if __phpenv_validate_boolean $phpenv_value
                set -g PHPENV_AUTO_INSTALL $phpenv_value
            else
                echo "Invalid value for auto-install. Use 'true' or 'false'"
                return 1
            end
        case auto-install-extensions
            if __phpenv_validate_boolean $phpenv_value
                set -g PHPENV_AUTO_INSTALL_EXTENSIONS $phpenv_value
            else
                echo "Invalid value for auto-install-extensions. Use 'true' or 'false'"
                return 1
            end
        case auto-switch
            if __phpenv_validate_boolean $phpenv_value
                set -g PHPENV_AUTO_SWITCH $phpenv_value
            else
                echo "Invalid value for auto-switch. Use 'true' or 'false'"
                return 1
            end
        case default-extensions
            if __phpenv_validate_extensions $phpenv_value
                set -g PHPENV_DEFAULT_EXTENSIONS $phpenv_value
            else
                echo "Warning: Some extensions may not be available for all PHP versions"
                set -g PHPENV_DEFAULT_EXTENSIONS $phpenv_value
            end
        case '*'
            echo "Unknown config key: $phpenv_key"
            echo "Available keys: global-version, auto-install, auto-install-extensions, auto-switch,"
            echo "                default-extensions"
            return 1
    end
    echo "Set $phpenv_key = $phpenv_value"
end

function __phpenv_config_list
    echo "Configuration (showing sources):"
    __phpenv_config_get global-version --verbose
    __phpenv_config_get auto-install --verbose
    __phpenv_config_get auto-install-extensions --verbose
    __phpenv_config_get auto-switch --verbose
    __phpenv_config_get default-extensions --verbose
end

function __phpenv_extensions -a phpenv_action phpenv_extension
    switch $phpenv_action
        case install
            __phpenv_extensions_install $phpenv_extension
        case uninstall remove
            __phpenv_extensions_uninstall $phpenv_extension
        case list ls
            __phpenv_extensions_list
        case available
            __phpenv_extensions_available
        case '*'
            echo "Usage: phpenv extensions {install|uninstall|list|available} [extension]"
            return 1
    end
end

function __phpenv_extensions_install -a phpenv_extension
    if test -z "$phpenv_extension"
        echo "Usage: phpenv extensions install <extension>"
        return 1
    end

    # Check for version override first (from environment, not global variable)
    set -l phpenv_version
    if test -n "$PHPENV_VERSION_OVERRIDE"
        set phpenv_version $PHPENV_VERSION_OVERRIDE
    else
        set phpenv_version (__phpenv_detect_version)
    end
    if test -z "$phpenv_version"
        echo "No PHP version detected"
        return 1
    end

    if not __phpenv_extension_available $phpenv_extension $phpenv_version
        echo "Extension $phpenv_extension may not be available for PHP $phpenv_version"
        echo "Attempting installation anyway..."
    end

    echo "Installing $phpenv_extension for PHP $phpenv_version..."

    if not __phpenv_ensure_taps
        echo "Error: Homebrew is required but not available"
        return 1
    end

    set -l phpenv_formula "shivammathur/extensions/$phpenv_extension@$phpenv_version"
    if brew install $phpenv_formula
        echo "$phpenv_extension@$phpenv_version installed successfully"
    else
        echo "Failed to install $phpenv_extension@$phpenv_version"
        echo "Extension may not be available for PHP $phpenv_version"
        echo "Run 'phpenv extensions available' to see available extensions"
        return 1
    end
end

function __phpenv_extensions_uninstall -a phpenv_extension
    if test -z "$phpenv_extension"
        echo "Usage: phpenv extensions uninstall <extension>"
        return 1
    end

    set -l phpenv_version (__phpenv_detect_version)
    if test -z "$phpenv_version"
        echo "No PHP version detected"
        return 1
    end

    set -l phpenv_formula "shivammathur/extensions/$phpenv_extension@$phpenv_version"
    if brew uninstall $phpenv_formula
        echo "$phpenv_extension@$phpenv_version uninstalled successfully"
    else
        echo "Failed to uninstall $phpenv_extension@$phpenv_version"
        return 1
    end
end

# Unified helper for getting tap formulas
function __phpenv_get_tap_formulas -a tap_name
    if not command -q brew
        return 1
    end

    brew tap-info $tap_name --json 2>/dev/null | \
        jq -r '.[]|(.formula_names[]?)' 2>/dev/null
end

function __phpenv_get_available_extensions
    __phpenv_get_tap_formulas "shivammathur/extensions"
end

function __phpenv_extension_available -a phpenv_extension phpenv_version
    set -l phpenv_available_extensions (__phpenv_get_available_extensions)

    if test -z "$phpenv_available_extensions"
        return 0  # Assume available if can't check
    end

    for phpenv_ext_formula in $phpenv_available_extensions
        if test "$phpenv_ext_formula" = "shivammathur/extensions/$phpenv_extension@$phpenv_version"
            return 0
        end
    end

    return 1
end

function __phpenv_extensions_available
    set -l phpenv_version (__phpenv_detect_version)
    if test -z "$phpenv_version"
        set phpenv_version "8.3"
    end

    echo "Available extensions for PHP $phpenv_version:"

    set -l phpenv_available_extensions (__phpenv_get_available_extensions)

    if test -n "$phpenv_available_extensions"
        set -l phpenv_version_extensions
        for phpenv_ext_formula in $phpenv_available_extensions
            if echo $phpenv_ext_formula | grep -q "@$phpenv_version\$"
                set -l phpenv_ext_name (echo $phpenv_ext_formula | \
                    sed "s|shivammathur/extensions/||" | sed "s|@$phpenv_version||")
                set -a phpenv_version_extensions $phpenv_ext_name
            end
        end

        if test (count $phpenv_version_extensions) -gt 0
            printf '  %s\n' $phpenv_version_extensions | sort
        else
            echo "  No extensions found for PHP $phpenv_version"
        end
    else
        echo "  Unable to fetch extension list or Homebrew not available"
    end
end

function __phpenv_extensions_list
    set -l phpenv_version (__phpenv_detect_version)
    if test -z "$phpenv_version"
        echo "No PHP version detected"
        return 1
    end

    set -l phpenv_cellar_path (__phpenv_get_cellar_path)
    echo "Extensions for PHP $phpenv_version:"

    if test -d $phpenv_cellar_path
        for phpenv_ext_dir in $phpenv_cellar_path/*@$phpenv_version
            if test -d $phpenv_ext_dir
                set -l phpenv_ext_name (basename $phpenv_ext_dir | sed "s/@$phpenv_version//")
                if test "$phpenv_ext_name" != "php"
                    echo "  $phpenv_ext_name"
                end
            end
        end
    end
end

function __phpenv_install_default_extensions -a phpenv_version
    set -l phpenv_extensions (__phpenv_config_get default-extensions)
    if test -n "$phpenv_extensions"
        echo "Installing default extensions for PHP $phpenv_version..."
        set -l phpenv_failed_extensions

        for phpenv_ext in (echo $phpenv_extensions | tr ' ' '\n')
            if test -n "$phpenv_ext"
                echo "Installing $phpenv_ext..."
                # Temporarily switch context using local variable
                set -l phpenv_saved_version (__phpenv_detect_version)
                set -l PHPENV_VERSION_OVERRIDE $phpenv_version
                if not env PHPENV_VERSION_OVERRIDE=$phpenv_version __phpenv_extensions_install $phpenv_ext
                    set -a phpenv_failed_extensions $phpenv_ext
                    echo "Warning: Failed to install $phpenv_ext for PHP $phpenv_version"
                end
            end
        end

        if test (count $phpenv_failed_extensions) -gt 0
            echo "Some extensions failed to install: "(string join ", " $phpenv_failed_extensions)
            echo "You can install them manually later with: phpenv extensions install <extension>"
        else
            echo "All default extensions installed successfully"
        end
    end
end

function __phpenv_auto_switch --on-variable PWD
    # Debouncing: skip if we just switched directories recently
    set -l phpenv_current_time (date +%s)
    if set -q PHPENV_LAST_SWITCH_TIME
        set -l phpenv_time_diff (math $phpenv_current_time - $PHPENV_LAST_SWITCH_TIME)
        if test $phpenv_time_diff -lt 1
            return 0
        end
    end

    set -l phpenv_auto_switch (__phpenv_config_get auto-switch)
    if test "$phpenv_auto_switch" = "false"
        return 0
    end

    if not functions -q __phpenv_detect_version __phpenv_set_php_path
        return 0
    end

    set -l phpenv_new_version (__phpenv_detect_version 2>/dev/null)
    if test -z "$phpenv_new_version"
        return 0
    end

    # Check if we're already using the correct version
    if set -q PHPENV_CURRENT_VERSION; and test "$PHPENV_CURRENT_VERSION" = "$phpenv_new_version"
        return 0
    end

    if __phpenv_is_version_installed "$phpenv_new_version" 2>/dev/null
        __phpenv_set_php_path "$phpenv_new_version" 2>/dev/null
        set -g PHPENV_LAST_SWITCH_TIME $phpenv_current_time
    else
        set -l phpenv_auto_install (__phpenv_config_get auto-install)
        if test "$phpenv_auto_install" = "true"
            echo "Auto-installing PHP $phpenv_new_version..."
            if phpenv install "$phpenv_new_version"
                set -g PHPENV_LAST_SWITCH_TIME $phpenv_current_time
            end
        end
    end
end

function __phpenv_help
    echo "phpenv - PHP Version Manager for Fish Shell"
    echo ""
    echo "Usage: phpenv <command> [args]"
    echo ""
    echo "Commands:"
    echo "  install <version>        Install a PHP version"
    echo "  uninstall <version>      Uninstall a PHP version"
    echo "  use [version|system]    Use PHP version for current shell (auto-detects if no version)"
    echo "                          'system' restores original PATH"
    echo "  local <version>         Set PHP version for current project"
    echo "  global <version>        Set global PHP version"
    echo "  list                    List installed PHP versions"
    echo "  current                 Show current PHP version"
    echo "  which [binary]          Show path to PHP binary"
    echo "  versions                Show all available versions"
    echo "  doctor                  Check phpenv installation"
    echo "  config <action>         Manage configuration"
    echo "  extensions <action>     Manage PHP extensions"
    echo "  help                    Show this help"
    echo ""
    echo "Version sources (in order of priority):"
    echo "  1. .php-version file"
    echo "  2. .tool-version file"
    echo "  3. composer.json"
    echo "  4. Global version"
    echo "  5. System PHP"
    echo ""
    echo "Configuration:"
    echo "  auto-switch: Enable automatic PHP version switching (default: true)"
    echo "  auto-install: Auto-install missing versions (default: false)"
    echo ""
    echo "For more information, visit:"
    echo "  https://github.com/ivuorinen/phpenv.fish"
end

function __phpenv_validate_boolean -a phpenv_value
    test "$phpenv_value" = "true" -o "$phpenv_value" = "false"
end

function __phpenv_validate_version -a phpenv_version
    if echo $phpenv_version | grep -qE '^[0-9]+\.[0-9]+$'
        return 0
    end

    switch $phpenv_version
        case latest nightly '5.x' '7.x' '8.x'
            return 0
        case '*'
            return 1
    end
end

function __phpenv_validate_extensions -a phpenv_extensions_string
    if echo $phpenv_extensions_string | grep -qE '^[a-zA-Z0-9_-]+( +[a-zA-Z0-9_-]+)*$'
        return 0
    else
        return 1
    end
end
