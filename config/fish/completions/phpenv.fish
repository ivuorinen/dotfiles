# Completions for phpenv command
# Place in ~/.config/fish/completions/phpenv.fish

# Complete main commands
complete -c phpenv -f -n "__fish_use_subcommand" -a "install" -d "Install a PHP version"
complete -c phpenv -f -n "__fish_use_subcommand" -a "uninstall" -d "Uninstall a PHP version"
complete -c phpenv -f -n "__fish_use_subcommand" -a "use" -d "Use PHP version for current shell"
complete -c phpenv -f -n "__fish_use_subcommand" -a "local" -d "Set PHP version for current project"
complete -c phpenv -f -n "__fish_use_subcommand" -a "global" -d "Set global PHP version"
complete -c phpenv -f -n "__fish_use_subcommand" -a "list" -d "List installed PHP versions"
complete -c phpenv -f -n "__fish_use_subcommand" -a "ls" -d "List installed PHP versions"
complete -c phpenv -f -n "__fish_use_subcommand" -a "current" -d "Show current PHP version"
complete -c phpenv -f -n "__fish_use_subcommand" -a "which" -d "Show path to PHP binary"
complete -c phpenv -f -n "__fish_use_subcommand" -a "versions" -d "Show all available versions"
complete -c phpenv -f -n "__fish_use_subcommand" -a "doctor" -d "Check phpenv installation"
complete -c phpenv -f -n "__fish_use_subcommand" -a "config" -d "Manage configuration"
complete -c phpenv -f -n "__fish_use_subcommand" -a "extensions" -d "Manage PHP extensions"
complete -c phpenv -f -n "__fish_use_subcommand" -a "ext" -d "Manage PHP extensions"
complete -c phpenv -f -n "__fish_use_subcommand" -a "help" -d "Show help"

# Helper functions for completions
function __phpenv_complete_installed_versions
    phpenv list 2>/dev/null | sed 's/^[* ]*//'
end

function __phpenv_complete_available_versions
    # Try to get dynamic versions first
    if command -q curl -a command -q jq; and functions -q __phpenv_parse_version_field
        echo "latest"
        echo "nightly"
        echo "5.x"
        echo "7.x"
        echo "8.x"
        __phpenv_parse_version_field "latest" "8.4"
        __phpenv_parse_version_field "nightly" "8.5"
        __phpenv_parse_version_field "5.x" "5.6"
        __phpenv_parse_version_field "7.x" "7.4"
        __phpenv_parse_version_field "8.x" "8.4"
    end

    # Fallback to common versions
    printf "5.6\n7.0\n7.1\n7.2\n7.3\n7.4\n8.0\n8.1\n8.2\n8.3\n8.4\n8.5\n"
end

function __phpenv_complete_config_keys
    printf "global-version\nauto-install\nauto-install-extensions\nauto-switch\ndefault-extensions\n"
end

function __phpenv_complete_extensions
    printf "xdebug\nredis\nimagick\nmongodb\nmemcached\npcov\nast\ngrpc\n"
    printf "protobuf\nyaml\nzip\ncurl\ngd\nintl\nmbstring\nmysql\nopcache\npdo\nsockets\nxml\n"
end

function __phpenv_complete_binaries
    printf "php\nphp-config\nphpize\ncomposer\npecl\npear\n"
end

# Complete versions for install command
complete -c phpenv -f -n "__fish_seen_subcommand_from install" \
    -a "(__phpenv_complete_available_versions)" -d "PHP version"

# Complete installed versions for uninstall, use commands
complete -c phpenv -f -n "__fish_seen_subcommand_from uninstall use local global" \
    -a "(__phpenv_complete_installed_versions)" -d "Installed PHP version"

# Add system option for use command
complete -c phpenv -f -n "__fish_seen_subcommand_from use" -a "system" -d "Use system PHP"

# Complete binaries for which command
complete -c phpenv -f -n "__fish_seen_subcommand_from which" -a "(__phpenv_complete_binaries)" -d "PHP binary"

# Complete config subcommands
complete -c phpenv -f -n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from get set list" \
    -a "get" -d "Get configuration value"
complete -c phpenv -f -n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from get set list" \
    -a "set" -d "Set configuration value"
complete -c phpenv -f -n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from get set list" \
    -a "list" -d "List all configuration"

# Complete config keys
complete -c phpenv -f -n "__fish_seen_subcommand_from config; and __fish_seen_subcommand_from get set" \
    -a "(__phpenv_complete_config_keys)" -d "Configuration key"

# Complete config values for boolean settings
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from config; and __fish_seen_subcommand_from set" \
    -n "contains -- (commandline -opc)[-1] auto-install auto-install-extensions auto-switch" \
    -a "true false" -d "Boolean value"

# Complete extensions subcommands
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from extensions ext" \
    -n "not __fish_seen_subcommand_from install uninstall remove list ls available" \
    -a "install" -d "Install PHP extension"
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from extensions ext" \
    -n "not __fish_seen_subcommand_from install uninstall remove list ls available" \
    -a "uninstall" -d "Uninstall PHP extension"
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from extensions ext" \
    -n "not __fish_seen_subcommand_from install uninstall remove list ls available" \
    -a "remove" -d "Remove PHP extension"
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from extensions ext" \
    -n "not __fish_seen_subcommand_from install uninstall remove list ls available" \
    -a "list" -d "List installed extensions"
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from extensions ext" \
    -n "not __fish_seen_subcommand_from install uninstall remove list ls available" \
    -a "ls" -d "List installed extensions"
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from extensions ext" \
    -n "not __fish_seen_subcommand_from install uninstall remove list ls available" \
    -a "available" -d "Show available extensions"

# Complete extension names
complete -c phpenv -f \
    -n "__fish_seen_subcommand_from extensions ext; and __fish_seen_subcommand_from install" \
    -a "(__phpenv_complete_extensions)" -d "PHP extension"

# Complete help options
complete -c phpenv -f -s h -l help -d "Show help"
