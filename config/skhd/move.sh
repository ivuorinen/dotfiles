#!/bin/bash

direction="$1" # east | west

# Active window and display
window=$(yabai -m query --windows --window)
display=$(yabai -m query --displays --display)

win_x=$(echo "$window" | jq '.frame.x')
win_w=$(echo "$window" | jq '.frame.w')
disp_x=$(echo "$display" | jq '.frame.x')
disp_w=$(echo "$display" | jq '.frame.w')

# Edge detection buffer
padding=20
move_to_display=false

if [[ "$direction" == "east" ]]; then
    [[ $((win_x + win_w)) -ge $((disp_x + disp_w - padding)) ]] && move_to_display=true
elif [[ "$direction" == "west" ]]; then
    [[ $win_x -le $((disp_x + padding)) ]] && move_to_display=true
fi

if $move_to_display; then
    # Find the target display based on the direction
    if [[ "$direction" == "east" ]]; then
        target_display=$(yabai -m query --displays | jq ".[] | select(.frame.x > $disp_x)" | jq -s '.[0].index')
    else
        target_display=$(yabai -m query --displays | jq ".[] | select(.frame.x < $disp_x)" | jq -s '.[-1].index')
    fi

    if [[ -n "$target_display" && "$target_display" != "null" ]]; then
        # Find current space on the target display
        target_space=$(yabai -m query --spaces | jq ".[] | select(.display == $target_display) | .index" | head -n1)

        # If no space found, create a new one
        if [[ -z "$target_space" || "$target_space" == "null" ]]; then
            yabai -m space --create
            sleep 0.3
            # Asign the new space to the target display
            target_space=$(yabai -m query --spaces | jq ".[] | select(.display == $target_display) | .index" | head -n1)
        fi

        # Move the window to the new space and focus it
        yabai -m window --space "$target_space"
        yabai -m space --focus "$target_space"
        yabai -m display --focus "$target_display"
    fi
else
    yabai -m window --warp "$direction"
fi

