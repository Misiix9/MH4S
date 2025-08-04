#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Optional applications
OPTIONAL_PACKAGES=(
    "firefox"
    "thunderbird"
    "vlc"
    "gimp"
    "libreoffice-fresh"
    "discord"
    "obs-studio"
    "spotify"
)

# Install selected optional packages
install_optional() {
    log "Installing optional packages..."
    
    # Create a temporary file to store selections
    TMPFILE=$(mktemp)
    
    # Display menu
    echo "Select additional applications to install:"
    for i in "${!OPTIONAL_PACKAGES[@]}"; do
        echo "$i) ${OPTIONAL_PACKAGES[$i]}"
    done
    
    # Get user selection
    read -p "Enter numbers (space-separated) or 'all': " selection
    
    # Handle selection
    if [ "$selection" = "all" ]; then
        selected_apps=("${OPTIONAL_PACKAGES[@]}")
    else
        selected_apps=()
        for num in $selection; do
            if [ "$num" -lt "${#OPTIONAL_PACKAGES[@]}" ]; then
                selected_apps+=("${OPTIONAL_PACKAGES[$num]}")
            fi
        done
    fi
    
    # Install selected packages
    if [ ${#selected_apps[@]} -gt 0 ]; then
        log "Installing selected applications..."
        sudo pacman -S --needed "${selected_apps[@]}"
    else
        log "No applications selected."
    fi
}

# Configure Spotify
setup_spotify() {
    if command -v spotify &> /dev/null; then
        log "Setting up Spotify..."
        
        # Wait for Spotify installation to complete
        sleep 2
        
        # Apply Spicetify theme
        spicetify config current_theme Mono
        spicetify backup apply
    fi
}

# Configure Firefox
setup_firefox() {
    if command -v firefox &> /dev/null; then
        log "Setting up Firefox..."
        
        # Create Firefox config directory
        mkdir -p ~/.mozilla/firefox/default
        
        # Copy Firefox config if available
        if [ -d "../config/firefox" ]; then
            cp -r ../config/firefox/* ~/.mozilla/firefox/default/
        fi
    fi
}

# Configure OBS Studio
setup_obs() {
    if command -v obs &> /dev/null; then
        log "Setting up OBS Studio..."
        
        # Create OBS config directory
        mkdir -p ~/.config/obs-studio
        
        # Copy OBS config if available
        if [ -d "../config/obs-studio" ]; then
            cp -r ../config/obs-studio/* ~/.config/obs-studio/
        fi
    fi
}

# Main application setup
main() {
    log "Starting application setup..."
    
    # Confirm installation
    if ! confirm "This will install additional applications. Continue?"; then
        return 1
    fi
    
    # Install optional packages
    install_optional
    
    # Configure applications
    setup_spotify
    setup_firefox
    setup_obs
    
    log "Application setup complete!"
}

main "$@"
