#!/usr/bin/env bash

# Dependency: requires the 1password cli: https://developer.1password.com/docs/cli/

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Login password to clipboard
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔐
# @raycast.packageName Password to clipboard
# @raycast.description Returns password from 1Password

# Documentation:
# @raycast.author Ismo Vuorinen
# @raycast.authorURL https://github.com/ivuorinen

set -euo pipefail

op read "op://Svea/3hzhctmvovbwlgulv7mgy25rf4/login-input" | pbcopy
