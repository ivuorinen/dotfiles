#!/usr/bin/env bash

# Get session list and pipe it to gum for selection
SESH_LIST=$(
  sesh list -i \
    | gum filter \
      --limit 1 \
      --no-sort \
      --fuzzy \
      --placeholder 'Pick a sesh' \
      --height 50 \
      --prompt='⚡'
)

# If a session was selected, connect to it
if [ "$SESH_LIST" != "" ]; then
  sesh connect "$SESH_LIST"
fi
