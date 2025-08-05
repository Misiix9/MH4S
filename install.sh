#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="$HOME/.config/hypr.backup.$(date +%Y%m%d_%H%M%S)"
INSTALL_DIR="$HOME/.config/hypr"
REPO_DIR="$(pwd)"

# Function to print colored messages
print_msg() {
    local color=$1
    local msg=$2
    echo -e "${color}${msg}${NC}"
}

# Function to check command existence
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_msg "$RED" "Error: $1 is not installed. Installing..."
        sudo pacman -S --noconfirm "$1"
        if [ $? -ne 0 ]; then
            print_msg "$RED" "Failed to install $1. Please install it manually."
            exit 1
        fi
    fi
}

# Function to backup existing configuration
backup_config() {
    local configs=(
        "$HOME/.config/hypr"
        "$HOME/.config/rofi"
        "$HOME/.config/waybar"
        "$HOME/.config/kitty"
        "$HOME/.config/mako"
    )

    print_msg "$YELLOW" "Backing up existing configurations..."
    mkdir -p "$BACKUP_DIR"

    for config in "${configs[@]}"; do
        if [ -d "$config" ]; then
            # Get the base directory name
            local dirname=$(basename "$config")
            
            # Create backup
            cp -r "$config" "$BACKUP_DIR/$dirname"
            if [ $? -eq 0 ]; then
                print_msg "$GREEN" "Backed up $dirname to: $BACKUP_DIR/$dirname"
                # Remove original after successful backup
                rm -rf "$config"
                print_msg "$YELLOW" "Removed original $dirname configuration"
            else
                print_msg "$RED" "Failed to backup $dirname. Aborting installation."
                exit 1
            fi
        fi
    done
    
    print_msg "$GREEN" "All configurations backed up successfully!"
}

# Function to install required packages
install_packages() {
    print_msg "$BLUE" "Installing required packages..."
    
    local packages=(
        hyprland
        waybar
        kitty
        rofi
        mako
        swaylock
        swayidle
        wl-clipboard
        grim
        slurp
        polkit-kde-agent
        brightnessctl
        pamixer
        networkmanager
        bluez
        bluez-utils
        python-pip
        python-psutil
        gammastep
        swww
        xdg-desktop-portal-hyprland
        qt5ct
        dolphin
        pavucontrol
        blueman
        cpupower
        lm_sensors
    )
    
    # Install packages
    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &> /dev/null; then
            print_msg "$YELLOW" "Installing $pkg..."
            sudo pacman -S --noconfirm "$pkg"
            if [ $? -ne 0 ]; then
                print_msg "$RED" "Failed to install $pkg. Please install it manually."
                exit 1
            fi
        fi
    done
    
    print_msg "$GREEN" "All required packages installed successfully!"
}

# Function to install AUR packages
install_aur_packages() {
    print_msg "$BLUE" "Installing AUR packages..."
    
    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        print_msg "$YELLOW" "Installing yay..."
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
    
    local aur_packages=(
        spicetify-cli
        rofi-calc
    )
    
    # Install AUR packages
    for pkg in "${aur_packages[@]}"; do
        if ! yay -Qi "$pkg" &> /dev/null; then
            print_msg "$YELLOW" "Installing $pkg..."
            yay -S --noconfirm "$pkg"
            if [ $? -ne 0 ]; then
                print_msg "$RED" "Failed to install $pkg. Please install it manually."
                exit 1
            fi
        fi
    done
    
    print_msg "$GREEN" "All AUR packages installed successfully!"
}

# Function to install configuration files
install_config() {
    print_msg "$BLUE" "Installing configuration files..."
    
    # Create required directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/scripts"
    
    # Copy configuration files
    cp -r "$REPO_DIR/.config/hypr/"* "$INSTALL_DIR/"
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/scripts/"*.sh
    
    print_msg "$GREEN" "Configuration files installed successfully!"
}

# Function to configure rofi
configure_rofi() {
    print_msg "$BLUE" "Configuring Rofi..."
    
    # Create rofi config directory
    mkdir -p "$HOME/.config/rofi"
    
    # Create rofi config
    cat > "$HOME/.config/rofi/config.rasi" << 'EOL'
configuration {
    modi: "drun,run,calc,window";
    icon-theme: "Papirus-Dark";
    show-icons: true;
    terminal: "kitty";
    drun-display-format: "{icon} {name}";
    location: 0;
    disable-history: false;
    sort: true;
    sorting-method: "normal";
}

@theme "/usr/share/rofi/themes/Arc-Dark.rasi"
EOL
    
    print_msg "$GREEN" "Rofi configured successfully!"
}

# Function to configure services
configure_services() {
    print_msg "$BLUE" "Configuring system services..."
    
    # Enable Bluetooth service
    sudo systemctl enable --now bluetooth.service
    
    # Enable NetworkManager service
    sudo systemctl enable --now NetworkManager.service
    
    print_msg "$GREEN" "Services configured successfully!"
}

# Function to apply system configurations
apply_system_config() {
    print_msg "$BLUE" "Applying system configurations..."
    
    # Configure user groups
    sudo usermod -aG input,video,audio "$USER"
    
    # Configure environment variables
    echo 'export XDG_CURRENT_DESKTOP=Hyprland' >> "$HOME/.profile"
    echo 'export XDG_SESSION_TYPE=wayland' >> "$HOME/.profile"
    echo 'export XDG_SESSION_DESKTOP=Hyprland' >> "$HOME/.profile"
    
    print_msg "$GREEN" "System configurations applied successfully!"
}

# Function to configure GTK theme
configure_theme() {
    print_msg "$BLUE" "Configuring GTK theme..."
    
    # Set GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
    gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
    
    print_msg "$GREEN" "GTK theme configured successfully!"
}

# Main installation function
main() {
    print_msg "$BLUE" "Starting MH4S installation..."
    
    # Check for root privileges
    if [ "$EUID" = 0 ]; then 
        print_msg "$RED" "Please do not run this script as root!"
        exit 1
    fi
    
    # Check for required commands
    check_command "git"
    check_command "sudo"
    
    # Backup existing configuration
    backup_config
    
    # Installation steps
    install_packages
    install_aur_packages
    install_config
    configure_rofi
    configure_services
    apply_system_config
    configure_theme
    
    print_msg "$GREEN" "Installation completed successfully!"
    print_msg "$YELLOW" "Please log out and log back in to start using Hyprland."
    print_msg "$YELLOW" "For more information, check the documentation in the repository."
}

# Confirm installation
read -p "This will install MH4S. Do you want to continue? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    main
else
    print_msg "$YELLOW" "Installation cancelled."
    exit 1
fi
