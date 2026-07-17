# lakka fish exports — host-specific, sourced by config/fish/exports.fish.

# Mirror MISE_DISABLE_TOOLS from hosts/lakka/config/exports-lakka (bash/zsh) so
# `mise install` from an interactive fish shell also skips the two dotnet tools
# that cannot build on lakka. disable_tools layers over the shared mise config.
set -gx MISE_DISABLE_TOOLS "dotnet:csharpier,dotnet:coverlet.console"
