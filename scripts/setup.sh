#!/bin/bash

# Source the colors script
source "./scripts/colors.sh"

# Define package lists
nvidia_pkg=(
    linux-headers 
    nvidia-dkms 
    nvidia-utils
    egl-wayland
    nvidia-settings 
    libva 
    libva-nvidia-driver-git
)

main_pkg=(
    hyprland
    hyprpaper
    kitty
    jq
    swww
    swaylock-effects
    wofi
    wlogout
    xdg-desktop-portal-hyprland
    swappy
    grim
    slurp
    python-requests
    pamixer
    pipewire
    pavucontrol
    brightnessctl
    bluez
    bluez-utils
    blueman
    network-manager-applet
    gvfs
    btop
    pacman-contrib
    starship
    ttf-jetbrains-mono-nerd
    noto-fonts-emoji
    ly
    nautilus
    neovim
    fastfetch
    curl
    wget
    dunst
    libnotify
    gnome-disk-utility
    waybar
    cava
    nwg-look
    graphite-gtk-theme
    sassc
    zsh
    fzf
    zoxide
    yazi
    tree
    github-cli
    starship
    wl-clipboard
    cliphist
    zenity
)

optional_pkg=(
    cmake
    gcc
    wget
    unzip
    clang
    ninja
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
    ffmpeg
    gtk2
    gtk3
    libpng
    libjpeg-turbo
    openexr
    libtiff
    libwebp
)

INSTLOG="install.log"

# Function to test for a package and if not found, attempts to install it
install_software() {
    if yay -Q "$1" &> /dev/null; then
        echo -e "${OK} - $1 is already installed."
    else
        echo -en "${NOTE} - Now installing $1 "
        yay -S --noconfirm "$1"
        if yay -Q "$1" &> /dev/null; then
            echo -e "\e[1A\e[K${OK} - $1 was installed."
        else
            echo -e "\e[1A\e[K${ERROR} - $1 install failed, please check the $INSTLOG"
            exit 1
        fi
    fi
}

prompt() {
    local prompt_message="$1"
    local choice

    read -p "$prompt_message (y/n): " choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$choice" == "y" || "$choice" == "yes" ]]; then
        return 0  
    else
        return 1 
    fi
}

if ! grep -qi "Arch" /etc/os-release; then
    echo -e "${ERROR} This is not an Arch-based distribution. This will not work on other distros."
    exit 1  
fi

# Display the installation message
echo -e "${NOTE} MONOCHROME Installation Script"
if prompt "Do you want to begin configuring the MONOCHROME setup?"; then
    echo "Starting the configuration..."
else
    echo "Exiting script."
    exit 0
fi

YAY_DIR="${HOME}/yay"

# Check for package manager
if ! command -v yay &> /dev/null; then
    echo -e "${CNT} - Configuring yay."

    # Clone yay repository if it doesn't exist
    if [ ! -d "$YAY_DIR" ]; then
        git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
    fi

    # Navigate to yay directory and build package
    cd "$YAY_DIR" || { echo -e "${CER} - Failed to navigate to '$YAY_DIR'"; exit 1; }
    if ! makepkg -si ; then
        echo -e "${CER} - Failed to build and install yay. Check '$INSTLOG' for details."
        exit 1
    fi

    # Navigate back to the original directory
    cd - || exit 1

    # Verify if yay is now available
    if command -v yay &> /dev/null; then
        echo -e "${CNT} - yay configured successfully."
        echo -e "${CNT} - Updating yay."
        yay -Suy &>> "$INSTLOG"
        echo -e "\e[1A\e[K${COK} - yay updated."
    else
        echo -e "\e[1A\e[K${CER} - yay installation failed. Check '$INSTLOG' for details."
        exit 1
    fi
else
    echo -e "${COK} - yay is already installed."
fi


# Install main packages
for pkg in "${main_pkg[@]}"; do
    install_software "$pkg"
done

echo -e "${NOTE} DEV TOOLS"
if prompt "Do you want to install all dev packages"; then
    for pkg in "${optional_pkg[@]}"; do
        install_software "$pkg"
    done
fi

# Check for Nvidia GPU
if sudo lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo -e "${NOTE} - Nvidia GPU support setup stage, this may take a while..."
    for SOFTWR in "${nvidia_pkg[@]}"; do
        install_software "$SOFTWR"
    done

    # Configure NVIDIA modules
    CONFIG_FILE="/etc/mkinitcpio.conf"
    MODPROBE_CONF="/etc/modprobe.d/nvidia.conf"
    NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

    # Check if NVIDIA modules are already in the MODULES array
    if sudo grep -q "$NVIDIA_MODULES" "$CONFIG_FILE"; then
        echo "NVIDIA modules are already added to the MODULES array."
    else
        # Append NVIDIA modules after existing ones in the MODULES array
        sudo sed -i "/^MODULES=/ s/)/ $NVIDIA_MODULES)/" "$CONFIG_FILE"
        echo "NVIDIA modules have been added to the MODULES array."
    fi

    sudo grep "^MODULES=" "$CONFIG_FILE"

    # Create or edit /etc/modprobe.d/nvidia.conf
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$MODPROBE_CONF" > /dev/null

    # Rebuild the initramfs
    echo "Rebuilding initramfs..."
    sudo mkinitcpio -P
else
    echo -e "${ERROR} - No Nvidia GPU detected. Skipping Nvidia configuration."
fi




# Define the path to the postinstall script
POSTINSTALL_SCRIPT="$(dirname "$0")/postinstall.sh"

# Check if postinstall script exists and is executable
if [ -x "$POSTINSTALL_SCRIPT" ]; then
    echo -e "${CNT} - Running Post install script"
    "$POSTINSTALL_SCRIPT"
else
    echo -e "${CER} - Post install script '$POSTINSTALL_SCRIPT' does not exist or is not executable."
    exit 1
fi


