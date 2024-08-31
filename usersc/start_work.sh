#!/bin/bash

# Define workspace assignments for specific applications
# Format: "app_name workspace_number"
ASSIGNMENTS=(
    "nautilus 2"
    "telegram-desktop 4"
    "zen-browser 3"
    "spotify 5"
    "kitty 1"
    "kitty 2"

)

get_window_addresses() {
    local name="$1"
    local app_name
    split_string() {
        local input="$1"
        echo "${input%%-*}"
    }
    app_name=$(split_string "$name")
    
    local window_info
    window_info=$(hyprctl clients)
    
    if [ -z "$window_info" ]; then
        echo "No windows found."
        return 1
    fi
    
    echo "$window_info" | awk -v app_name="$app_name" '
    BEGIN { FS="\n"; RS="\n\n" }
    {
        if (tolower($0) ~ tolower(app_name)) {
            match($0, /^Window ([0-9a-fA-F]+)/, arr)
            address = arr[1]
            if (address != "") {
                gsub(/^[ \t]+|[ \t]+$/, "", address)
                print address
            }
        }
    }
    '
}

move_to_workspace() {
    local window_class="$1"
    local target_workspace="$2"
    
    readarray -t addresses < <(get_window_addresses "$window_class")
    
    for address in "${addresses[@]}"; do
        echo "Window address: $address"
        if [ -n "$address" ]; then
            echo "Moving $window_class to workspace $target_workspace"
            hyprctl dispatch movetoworkspacesilent "$target_workspace,address:0x$address"
            if [ $? -eq 0 ]; then
                echo "Successfully moved $window_class to workspace $target_workspace"
            else
                echo "Failed to move $window_class"
            fi
        else
            echo "$window_class not found"
        fi
    done
}

launch_app() {
    local app_name="$1"
    echo "Launching $app_name..."
    if command -v "$app_name" >/dev/null 2>&1; then
        $app_name &
    else
        echo "Executable for $app_name not found"
        return 1
    fi
}

wait_for_window() {
    local app_name="$1"
    local max_attempts=3000
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if get_window_addresses "$app_name" | grep -q .; then
            return 0
        fi
        sleep 0.5
        ((attempt++))
    done
    
    echo "Timeout waiting for $app_name window"
    return 1
}

for assignment in "${ASSIGNMENTS[@]}"; do
    app_name=$(echo "$assignment" | awk '{print $1}')
    workspace=$(echo "$assignment" | awk '{print $2}')
    
    launch_app "$app_name"
    
    if wait_for_window "$app_name"; then
        move_to_workspace "$app_name" "$workspace"
    else
        echo "Failed to launch or detect window for $app_name"
    fi
done
