#!/bin/bash

# Directory to save screenshots
SCREENSHOTS_DIR="$HOME/Pictures"

# Create the directory if it does not exist
mkdir -p "$SCREENSHOTS_DIR"

# Function to take a full screenshot
take_full_screenshot() {
    local filename="screenshot_$(date +' %Y-%m-%d_%H-%M-%S').png"
    grim "$SCREENSHOTS_DIR/$filename"
    cat "$SCREENSHOTS_DIR/$filename" | wl-copy
    notify-send "Screenshot taken" "Full screen screenshot saved as $filename and copied to clipboard"
}

# Function to take a partial screenshot
take_partial_screenshot() {
    local filename="screenshot_$(date +' %Y-%m-%d_%H-%M-%S').png"
    slurp | grim -g - "$SCREENSHOTS_DIR/$filename"
    cat "$SCREENSHOTS_DIR/$filename" | wl-copy
    notify-send "Screenshot taken" "Partial screenshot saved as $filename and copied to clipboard"
}

# Main script
case "$1" in
    "d")
        take_full_screenshot
        ;;
    "p")
        take_partial_screenshot
        ;;
    *)
        echo "Usage: $0 {d|p}"
        echo "d - Full screen screenshot"
        echo "p - Partial screenshot"
        exit 1
        ;;
esac

