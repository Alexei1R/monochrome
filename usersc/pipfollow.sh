#!/bin/bash

WINDOW_TITLE="Picture-in-Picture"
LAST_WORKSPACE=""
LAST_WINDOW_ADDRESS=""
IS_RUNNING=true

get_window_address() {
    hyprctl clients -j | jq -r --arg title "$WINDOW_TITLE" '.[] | select(.title == $title) | .address'
}

move_to_active_workspace() {
    WINDOW_ADDRESS=$(get_window_address)
    ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')

    # Only proceed if the workspace has changed or the window address has changed
    if [ "$ACTIVE_WORKSPACE" != "$LAST_WORKSPACE" ] || [ "$WINDOW_ADDRESS" != "$LAST_WINDOW_ADDRESS" ]; then
        echo "Detected window address: $WINDOW_ADDRESS"
        echo "Detected active workspace: $ACTIVE_WORKSPACE"

        if [ -n "$WINDOW_ADDRESS" ] && [ -n "$ACTIVE_WORKSPACE" ]; then
            echo "Moving window $WINDOW_ADDRESS to workspace $ACTIVE_WORKSPACE"
            hyprctl dispatch movetoworkspacesilent "$ACTIVE_WORKSPACE,address:$WINDOW_ADDRESS"

            if [ $? -eq 0 ]; then
                echo "Move command succeeded."
                LAST_WORKSPACE="$ACTIVE_WORKSPACE"
                LAST_WINDOW_ADDRESS="$WINDOW_ADDRESS"
            else
                echo "Move command failed."
            fi
        else
            echo "Popup window not found or no active workspace detected."
            IS_RUNNING=false
        fi
    fi
}

check_if_running() {
    if [ "$IS_RUNNING" = true ]; then
        return 0
    else
        return 1
    fi
}

notify_and_exit() {
    notify-send "Script Terminated" "The 'Picture-in-Picture' window is no longer running. The script has been closed."
    exit 0
}

# Monitor the file for changes
MONITOR_FILE="/tmp/hyprland_monitor"
touch "$MONITOR_FILE"

while true; do
    if ! check_if_running; then
        notify_and_exit
    fi

    inotifywait -e modify "$MONITOR_FILE" >/dev/null 2>&1
    move_to_active_workspace
done
