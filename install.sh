#!/bin/bash

# Source the colors script
source "$(dirname "$0")/scripts/colors.sh"

# Define paths
CONFIG_DIR="$(dirname "$0")/configs"
USERSC_DIR="$(dirname "$0")/usersc"
LOCAL_BIN_DIR="$HOME/.local/bin"
CONFIG_TARGET="$HOME/.config"
SETUP_SCRIPT="$(dirname "$0")/scripts/setup.sh"

# Function to copy files
copy_files() {
    local src_dir="$1"
    local dest_dir="$2"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Copy files from source to destination
    cp -r "$src_dir/"* "$dest_dir/"
}

# Check if setup script exists and is executable
if [ -x "$SETUP_SCRIPT" ]; then
    echo -e "${NOTE} Running setup script..."
    "$SETUP_SCRIPT"
else
    echo -e "${ERROR} Setup script '$SETUP_SCRIPT' does not exist or is not executable."
    exit 1
fi

# Copy configuration files
echo -e "${NOTE} Copying configuration files..."
copy_files "$CONFIG_DIR" "$CONFIG_TARGET"

# Copy user scripts
echo -e "${NOTE} Copying user scripts..."
copy_files "$USERSC_DIR" "$LOCAL_BIN_DIR"

echo -e "${NOTE} Installation and configuration completed."


# Prompt to reboot
if prompt "Configuration complete. Do you want to reboot now?"; then
    sudo reboot
fi
