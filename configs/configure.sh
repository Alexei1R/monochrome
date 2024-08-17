#!/bin/bash

# Define source directories
CONFIG_SRC="./config"
HOMECONFIGS_SRC="./homeconfigs"
USER_SC_SRC="./usersc"

# Define target directories
CONFIG_DST="$HOME/.config"
HOMECONFIGS_DST="$HOME"
USER_SC_DST="$HOME/.local/bin"

# Function to ensure directory exists
ensure_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        echo "Directory '$dir' does not exist. Creating..."
        mkdir -p "$dir"
    fi
}

# Function to copy contents and handle errors
copy_contents() {
    local src="$1"
    local dst="$2"
    
    ensure_directory "$dst"
    
    if [ -d "$src" ]; then
        echo "Copying contents of '$src' to '$dst'..."
        cp -r "$src/" "$dst/"
    else
        echo "Source directory '$src' does not exist."
    fi
}

# Copy contents of 'config' to '.config'
copy_contents "$CONFIG_SRC" "$CONFIG_DST"

# Copy contents of 'homeconfigs' to home directory
copy_contents "$HOMECONFIGS_SRC" "$HOMECONFIGS_DST"

# Copy contents of 'usersc' to '.local/bin'
copy_contents "$USER_SC_SRC" "$USER_SC_DST"

echo "Configuration completed."

