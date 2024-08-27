#!/bin/bash

# Display clipboard history using cliphist and wofi
selected=$(cliphist list | wofi --show dmenu --prompt="Clipboard History")

# If a selection was made, decode and copy it to the clipboard
if [ -n "$selected" ]; then
    echo "$selected" | cliphist decode | wl-copy
fi

