#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Required packages
BASE_PACKAGES=(
    hyprland kitty dolphin rofi waybar mako zsh alacritty pipewire
    wireplumber pavucontrol xdg-desktop-portal-hyprland wofi networkmanager
    blueman bitwarden wl-clipboard grim slurp wlroots swaybg noto-fonts
    ttf-font-awesome unzip brightnessctl pamixer
)

AUR_PACKAGES=(
    spicetify-cli zen-browser visual-studio-code-bin ttf-lexend-gfonts
    cliphist sddm-astronaut-theme-git
)

# Install official packages
install_base() {
    log "Installing base packages..."
    sudo pacman -S --needed "${BASE_PACKAGES[@]}"
}

# Install AUR packages
install_aur() {
    log "Installing AUR packages..."
    yay -S --needed "${AUR_PACKAGES[@]}"
}

# Install GPU drivers
install_drivers() {
    source /tmp/mh4s-detected.conf
    
    case $GPU in
        "nvidia")
            log "Installing NVIDIA drivers..."
            sudo pacman -S --needed nvidia nvidia-utils nvidia-settings
            ;;
        "amd")
            log "Installing AMD drivers..."
            sudo pacman -S --needed xf86-video-amdgpu mesa
            ;;
        "intel")
            log "Installing Intel drivers..."
            sudo pacman -S --needed xf86-video-intel mesa
            ;;
    esac
}

# Configure system services
setup_services() {
    log "Setting up system services..."
    
    # Enable NetworkManager
    sudo systemctl enable NetworkManager
    
    # Enable SDDM
    sudo systemctl enable sddm
    
    # Enable Bluetooth
    sudo systemctl enable bluetooth
}

# Main installation
main() {
    log "Starting base system installation..."
    
    # Confirm installation
    if ! confirm "This will install the base system. Continue?"; then
        return 1
    fi
    
    # Install packages
    install_base
    install_aur
    install_drivers
    setup_services
    
    log "Base system installation complete!"
}

main "$@"
