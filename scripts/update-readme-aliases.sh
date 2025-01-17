#!/usr/bin/env bash
# update-readme-aliases.sh
# @description Update alias documentation in $DOTFILES/docs/alias.md
#
# Author: Ismo Vuorinen <https://github.com/ivuorinen> 2025
# License: MIT

set -euo pipefail

# Paths
ALIAS_FILE="$DOTFILES/config/alias"
OUTPUT_FILE="$DOTFILES/docs/alias.md"

# Check if alias file exists
if [[ ! -f $ALIAS_FILE ]]; then
  echo "Alias file not found: $ALIAS_FILE"
  exit 1
fi

# Declare associative array
declare -a alias_table

echo "Parsing aliases..."
while IFS= read -r line; do
  # Skip all lines that do not start with 'alias'
  if [[ ! $line =~ ^alias\  ]]; then
    continue
  fi

  # Split alias and command and handle both ' and "
  if [[ $line =~ ^alias\ ([^=]+)=[\'\"](.*)[\'\"]$ ]]; then
    alias_name="${BASH_REMATCH[1]}"
    alias_command="${BASH_REMATCH[2]//|/\\|}" # fix markdown table separator

    # Save alias to table
    alias_table+=("\`$alias_name\`␟\`$alias_command\`")
  else
    echo "Warning: Could not parse line: $line"
  fi

done < "$ALIAS_FILE"

# Sort array by alias name
# shellcheck disable=SC2207
IFS=$'\n' sorted_aliases=($(sort <<< "${alias_table[*]}"))
unset IFS

# Calculate cell max lengths
max_alias_length=5   # "Alias" min length
max_command_length=7 # "Command" min length

for entry in "${sorted_aliases[@]}"; do
  IFS=$'␟' read -r alias_name alias_command <<< "$entry"
  max_alias_length=$((${#alias_name} > max_alias_length ? ${#alias_name} : max_alias_length))
  max_command_length=$((${#alias_command} > max_command_length ? ${#alias_command} : max_command_length))
done

# Empty the markdown file and add header
printf "# Alias Commands\n\nThis file lists all aliases defined in \`config/alias\`.\n\n" > "$OUTPUT_FILE"

# Add table header
printf "| %-*s | %-*s |\n" \
  "$max_alias_length" "Alias" \
  "$max_command_length" "Command" >> "$OUTPUT_FILE"

# Add table header separator
printf "| %-*s | %-*s |\n" \
  "$max_alias_length" "$(printf '%0.s-' $(seq 1 $max_alias_length))" \
  "$max_command_length" "$(printf '%0.s-' $(seq 1 $max_command_length))" >> "$OUTPUT_FILE"

# Create table with max cell lengths
for entry in "${sorted_aliases[@]}"; do
  IFS=$'␟' read -r alias_name alias_command <<< "$entry"
  printf "| %-*s | %-*s |\n" \
    "$max_alias_length" "$alias_name" \
    "$max_command_length" "$alias_command" >> "$OUTPUT_FILE"
done

{
  printf "\n"
  printf "Total aliases: %d\n" "${#sorted_aliases[@]}"
  printf "Last updated: %s\n" "$(date)"
} >> "$OUTPUT_FILE"

# Announce process completion
echo "Alias documentation updated: $OUTPUT_FILE"
