#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Configure zsh
setup_zsh() {
    log "Setting up zsh..."
    
    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Copy zsh configuration
    cp ../config/zsh/.zshrc ~/.zshrc
    
    # Set zsh as default shell
    chsh -s $(which zsh)
}

# Configure scripts
setup_scripts() {
    log "Setting up utility scripts..."
    
    # Create scripts directory
    mkdir -p ~/.config/hypr/scripts
    
    # Copy and make executable
    cp -r ../scripts/* ~/.config/hypr/scripts/
    chmod +x ~/.config/hypr/scripts/*
}

# Configure wallpapers
setup_wallpapers() {
    log "Setting up wallpapers..."
    
    # Create wallpapers directory
    mkdir -p ~/Pictures/wallpapers
    
    # Copy wallpapers
    cp -r ../wallpapers/* ~/Pictures/wallpapers/
}

# Configure notifications
setup_notifications() {
    log "Setting up notifications..."
    
    mkdir -p ~/.config/mako
    cp ../config/mako/config ~/.config/mako/
}

# Configure Dolphin
setup_dolphin() {
    log "Setting up Dolphin..."
    
    mkdir -p ~/.config/dolphin
    cp ../config/dolphin/dolphinrc ~/.config/
}

# Configure keybindings
setup_keybindings() {
    log "Setting up keybindings..."
    
    # Already done in Hyprland config, but can be customized here
    if [ -f ~/.config/hypr/keybinds.conf ]; then
        cp ../config/hypr/keybinds.conf ~/.config/hypr/
    fi
}

# Main configuration
main() {
    log "Starting user configuration..."
    
    # Confirm setup
    if ! confirm "This will set up user configurations. Continue?"; then
        return 1
    fi
    
    setup_zsh
    setup_scripts
    setup_wallpapers
    setup_notifications
    setup_dolphin
    setup_keybindings
    
    log "User configuration complete!"
}

main "$@"
