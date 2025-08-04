#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Create backup of original configs
create_backup() {
    log "Creating backup of original configurations..."
    
    BACKUP_DIR="$HOME/.config/mh4s-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing configs
    [ -d ~/.config/hypr ] && cp -r ~/.config/hypr "$BACKUP_DIR/"
    [ -d ~/.config/waybar ] && cp -r ~/.config/waybar "$BACKUP_DIR/"
    [ -d ~/.config/kitty ] && cp -r ~/.config/kitty "$BACKUP_DIR/"
    [ -d ~/.config/rofi ] && cp -r ~/.config/rofi "$BACKUP_DIR/"
    [ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/"
    
    log "Backup created at: $BACKUP_DIR"
}

# Show post-installation tips
show_tips() {
    cat << EOF
╭───────────────────────────────────────╮
│        Post-Installation Tips         │
├───────────────────────────────────────┤
│ 1. Logout and choose Hyprland in     │
│    SDDM to start your new desktop    │
│                                       │
│ 2. Super + S opens the system menu   │
│                                       │
│ 3. Super + Enter opens terminal      │
│                                       │
│ 4. Super + R opens app launcher      │
│                                       │
│ 5. Super + Q closes active window    │
│                                       │
│ Check ~/.config/hypr/hyprland.conf   │
│ for more keybindings and settings    │
╰───────────────────────────────────────╯
EOF
}

# Clean up temporary files
cleanup() {
    log "Cleaning up..."
    rm -f /tmp/mh4s-detected.conf
}

# Main post-installation
main() {
    log "Starting post-installation tasks..."
    
    # Create backup
    create_backup
    
    # Show tips
    show_tips
    
    # Cleanup
    cleanup
    
    log "Post-installation tasks complete!"
    log "Please logout and choose Hyprland in SDDM to start your new desktop."
}

main "$@"
