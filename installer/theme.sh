#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Configure Hyprland theme
setup_hyprland() {
    log "Setting up Hyprland configuration..."
    
    # Create Hyprland config directory
    mkdir -p ~/.config/hypr
    
    # Copy base configuration
    cp -r ../config/hypr/* ~/.config/hypr/
}

# Configure Waybar
setup_waybar() {
    log "Setting up Waybar..."
    
    mkdir -p ~/.config/waybar
    cp -r ../config/waybar/* ~/.config/waybar/
}

# Configure Kitty
setup_kitty() {
    log "Setting up Kitty terminal..."
    
    mkdir -p ~/.config/kitty
    cp -r ../config/kitty/* ~/.config/kitty/
}

# Configure Rofi
setup_rofi() {
    log "Setting up Rofi..."
    
    mkdir -p ~/.config/rofi
    cp -r ../config/rofi/* ~/.config/rofi/
}

# Configure GTK theme
setup_gtk() {
    log "Setting up GTK theme..."
    
    mkdir -p ~/.config/gtk-3.0
    mkdir -p ~/.config/gtk-4.0
    
    cp ../config/gtk-3.0/settings.ini ~/.config/gtk-3.0/
    cp ../config/gtk-4.0/settings.ini ~/.config/gtk-4.0/
}

# Configure Qt theme
setup_qt() {
    log "Setting up Qt theme..."
    
    mkdir -p ~/.config/qt5ct
    cp ../config/qt5ct/qt5ct.conf ~/.config/qt5ct/
}

# Configure SDDM
setup_sddm() {
    log "Setting up SDDM theme..."
    
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp ../config/sddm/10-theme.conf /etc/sddm.conf.d/
}

# Configure fonts
setup_fonts() {
    log "Setting up fonts..."
    
    sudo mkdir -p /etc/fonts
    sudo cp ../config/fonts/local.conf /etc/fonts/
    
    fc-cache -f
}

# Configure Spicetify
setup_spicetify() {
    log "Setting up Spicetify..."
    
    mkdir -p ~/.config/spicetify/Themes
    cp -r ../config/spicetify/* ~/.config/spicetify/
    
    spicetify backup apply
}

# Main theme setup
main() {
    log "Starting theme setup..."
    
    # Confirm setup
    if ! confirm "This will set up the system theme. Continue?"; then
        return 1
    fi
    
    setup_hyprland
    setup_waybar
    setup_kitty
    setup_rofi
    setup_gtk
    setup_qt
    setup_sddm
    setup_fonts
    setup_spicetify
    
    log "Theme setup complete!"
}

main "$@"
