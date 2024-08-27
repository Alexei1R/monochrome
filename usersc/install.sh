#!/bin/bash

sanitize_name() {
    echo "$1" | sed 's/[^a-zA-Z_]//g'
}

# Function to create a desktop entry
create_desktop_entry() {
    local exec_path="$1"
    local exec_name="$2"
    local desktop_entry_file="$HOME/.local/share/applications/${exec_name}.desktop"
    local icon_path="${exec_path}/icons/mozicon128.png"  # Adjust if the icon path is different
    local symlink_path="/usr/local/bin/${exec_name}"

    echo "Creating desktop entry..."
    cat <<EOF > "${desktop_entry_file}"
[Desktop Entry]
Name=${exec_name}
Comment=Application
Exec=${exec_path}/${exec_name}
Icon=${icon_path}
Terminal=false
Type=Application
Categories=Network;Email;
EOF

    chmod +x "${desktop_entry_file}"

    # Add to PATH (Optional)
    read -p "Do you want to add ${exec_name} to your PATH? (y/n) " choice
    if [[ "$choice" == [Yy] ]]; then
        echo "Creating symbolic link..."
        sudo ln -s "${exec_path}/${exec_name}" "${symlink_path}"
    fi
}

# Function to select and extract the folder or archive
select_and_extract() {
    LOCAL_PATH=$(yad --file --title="Install" --width=800 --height=500 --file-filter="*.zip *.tar *.tar.gz *.tar.bz2 *.tar.xz")

    if [ -z "$LOCAL_PATH" ]; then
        notify-send -a "Monochrome Install" "No file or folder selected. Exiting."
        exit 1
    fi

    if [ -d "$LOCAL_PATH" ]; then
        FOLDER_PATH="$LOCAL_PATH"
    else
        EXT="${LOCAL_PATH##*.}"
        EXTRACT_DIR="${LOCAL_PATH%.*}"

        notify-send -a "Monochrome Install" "Extracting archive..."

        case "$EXT" in
            zip)
                mkdir -p "$EXTRACT_DIR"
                unzip "$LOCAL_PATH" -d "$EXTRACT_DIR"
                ;;
            tar)
                mkdir -p "$EXTRACT_DIR"
                tar -xf "$LOCAL_PATH" -C "$EXTRACT_DIR"
                ;;
            gz)
                mkdir -p "$EXTRACT_DIR"
                tar -xzf "$LOCAL_PATH" -C "$EXTRACT_DIR"
                ;;
            bz2)
                mkdir -p "$EXTRACT_DIR"
                tar -xjf "$LOCAL_PATH" -C "$EXTRACT_DIR"
                ;;
            xz)
                mkdir -p "$EXTRACT_DIR"
                tar -xJf "$LOCAL_PATH" -C "$EXTRACT_DIR"
            ;;
            *)
                yad --error --text="Selected file is not a supported archive type."
                exit 1
                ;;
        esac
        FOLDER_PATH="$EXTRACT_DIR"
    fi

    # Search for executables recursively
    EXECUTABLES=$(find "$FOLDER_PATH" -type f -executable)

    if [ -z "$EXECUTABLES" ]; then
        notify-send -a "Monochrome Install" "No executables found in the selected directory."
        exit 0
    fi

    # Display the list of executables using yad
    SELECTED_EXECUTABLE=$(yad --list --title="Install" \
        --column="Executable" \
        --width=800 \
        --height=500 \
        $EXECUTABLES \
        --button="Cancel:1" \
        --button="Install:0")

    if [ $? -eq 1 ]; then
        notify-send -a "Monochrome Install" "Installation canceled."
        exit 0
    fi

    # Extract the directory and application name
    EXECUTABLE_DIR=$(dirname "$SELECTED_EXECUTABLE")
    EXECUTABLE_NAME=$(basename "$SELECTED_EXECUTABLE")

    # Sanitize the application name
    EXECUTABLE_NAME=$(sanitize_name "$EXECUTABLE_NAME")

    # Create a destination directory in /opt
    DEST_DIR="/opt/$EXECUTABLE_NAME"

    # Function to prompt for sudo password
    get_sudo_password() {
        PASSWORD=$(yad --entry --title="Install" \
            --text="Enter your sudo password to install the executable:" \
            --hide-text)
        echo $PASSWORD
    }

    # Get sudo password
    SUDO_PASS=$(get_sudo_password)

    # Use sudo with password to copy
    if echo "$SUDO_PASS" | sudo -S cp -r "$EXECUTABLE_DIR" "$DEST_DIR" > /dev/null 2>&1; then
        notify-send -a "Monochrome Install" "Copy completed"
    else
        yad --error --title="Install" \
            --text="Failed to copy the executable to /opt. Please check your password and try again." \
            --width=400 \
            --height=200
    fi

    # Clear the password variable for security
    unset SUDO_PASS

    # Create desktop entry and add to PATH
    create_desktop_entry "$DEST_DIR" "$EXECUTABLE_NAME"

    notify-send -a "Monochrome Install" "Application installed and set up."
}

# Display popup window with two buttons
CHOICE=$(yad --title="Install" \
             --text="Select folder or archive to install" \
             --button="Exit:1" \
             --button="Browse:0")

# Check the user's choice
if [ $? -eq 1 ]; then
    exit 0
fi

notify-send -a "Monochrome Install" "Browsing for files"
select_and_extract

notify-send -a "Monochrome Install" "Installation completed."


