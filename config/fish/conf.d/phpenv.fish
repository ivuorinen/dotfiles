# phpenv configuration file
# Place in ~/.config/fish/conf.d/phpenv.fish

# Set default configuration using session variables for most settings
# Only PHPENV_GLOBAL_VERSION needs to persist across shells
if not set -q PHPENV_AUTO_INSTALL
    set -g PHPENV_AUTO_INSTALL false
end

if not set -q PHPENV_AUTO_INSTALL_EXTENSIONS
    set -g PHPENV_AUTO_INSTALL_EXTENSIONS false
end

if not set -q PHPENV_AUTO_SWITCH
    set -g PHPENV_AUTO_SWITCH true
end

if not set -q PHPENV_DEFAULT_EXTENSIONS
    set -g PHPENV_DEFAULT_EXTENSIONS "opcache"
end

# Initialize PATH on shell startup if global version is set (less aggressive)
if test -n "$PHPENV_GLOBAL_VERSION"; and not set -q PHPENV_INITIALIZED
    if functions -q __phpenv_is_version_installed __phpenv_set_php_path
        if __phpenv_is_version_installed "$PHPENV_GLOBAL_VERSION" 2>/dev/null
            # Only set PATH if no project-specific version is detected
            if not __phpenv_find_version_file .php-version >/dev/null 2>&1
                if not __phpenv_find_version_file .tool-version >/dev/null 2>&1
                    if not test -f composer.json
                        __phpenv_set_php_path "$PHPENV_GLOBAL_VERSION" 2>/dev/null
                    end
                end
            end
        end
    end
    set -g PHPENV_INITIALIZED true
end

