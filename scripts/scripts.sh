#!/bin/bash


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
)

# Set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
INSTLOG="install.log"


# Function to test for a package and if not found, attempts to install it
install_software() {
    if yay -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        echo -en "$CNT - Now installing $1 "
        yay -S  $1
        if yay -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K$COK - $1 was installed."
        else
            echo -e "\e[1A\e[K$CER - $1 install failed, please check the install.log"
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
    echo -e "${CER}This is not an Arch-based distribution. This will not work on other distros !!!!!!"
    exit 1  
fi

# Display the installation message
echo -e "${CNT} MONOCHROME Installation Script"
if prompt "Do you want to begin configuring the MONOCHROME setup?"; then
    echo "Starting the configuration..."
else
    echo "Exiting script."
    exit 0
fi

# Check for package manager
if ! command -v yay &> /dev/null; then  
    echo -en "$CNT - Configuring yay."
    git clone https://aur.archlinux.org/yay.git 
    cd yay || exit 1
    makepkg -si 
    cd ..
    if command -v yay &> /dev/null; then
        echo -en "$CNT - yay configured."
        echo -en "$CNT - Updating yay."
        yay -Suy 
        echo -e "\e[1A\e[K$COK - yay updated."
    else
        echo -e "\e[1A\e[K$CER - yay install failed, please check the install.log"
        exit 1
    fi
fi

# Install main packages
for pkg in "${main_pkg[@]}"; do
    install_software "$pkg"
done

# Check for Nvidia GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo -e "$CNT - Nvidia GPU support setup stage, this may take a while..."
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
    sudo echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$MODPROBE_CONF" > /dev/null

    # Rebuild the initramfs
    echo "Rebuilding initramfs..."
    sudo mkinitcpio -P
else
    echo "$CER - No Nvidia GPU detected. Skipping Nvidia configuration."
fi

# Prompt to reboot
if prompt "Configuration complete. Do you want to reboot now?"; then
    sudo reboot
fi

