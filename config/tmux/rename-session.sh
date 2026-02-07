#!/usr/bin/env bash

# Default session name
DEFAULT_NAME="main"

# Current session
CURRENT_SESSION=$(tmux display-message -p "#{session_name}")

# Check that the session has a name
if [[ "$CURRENT_SESSION" = "#{session_name}" ]] || [[ "$CURRENT_SESSION" = "0" ]]; then
  # Check if the default name is already in use
  if tmux has-session -t "$DEFAULT_NAME" 2> /dev/null; then
    # Query the user for a new name
    echo "Session name '$DEFAULT_NAME' is already in use. Enter a new name:"
    read -r NEW_NAME
    while tmux has-session -t "$NEW_NAME" 2> /dev/null || [[ -z "$NEW_NAME" ]]; do
      echo "Name '$NEW_NAME' is invalid or already in use. Enter a new name:"
      read -r NEW_NAME
    done
    # Rename the session with the new name
    tmux rename-session -t "$(tmux display-message -p "#{session_id}")" "$NEW_NAME"
    exit 0
  else
    # Rename the session with the default name
    tmux rename-session -t "$(tmux display-message -p "#{session_id}")" "$DEFAULT_NAME"
    exit 0
  fi
fi
