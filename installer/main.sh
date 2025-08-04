#!/bin/bash

# Configuration
LOG_FILE="/tmp/mh4s-install.log"
INSTALL_DIR="$HOME/.config"
REPO_URL="https://github.com/Misiix9/MH4S.git"
BACKUP_DIR="$HOME/.config.bak.$(date +%Y%m%d_%H%M%S)"

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "$timestamp - $1" | tee -a "$LOG_FILE"
}

# Error handling
set -e
trap 'catch $? $LINENO' ERR

catch() {
    log "${RED}Error $1 occurred on line $2${NC}"
    if [ "$1" != "0" ]; then
        log "${YELLOW}Installation failed. See $LOG_FILE for details${NC}"
        log "${YELLOW}Your original config has been backed up to $BACKUP_DIR${NC}"
        exit 1
    fi
}

# Check if running on Arch Linux
check_arch() {
    if [ ! -f "/etc/arch-release" ]; then
        log "${RED}This installer only works on Arch Linux${NC}"
        exit 1
    fi
}

# Check for yay
check_yay() {
    if ! command -v yay &> /dev/null; then
        log "${YELLOW}Installing yay...${NC}"
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    fi
}

# Detect system configuration
detect_system() {
    log "Detecting system configuration..."
    
    # GPU Detection
    if lspci | grep -i "NVIDIA" > /dev/null; then
        GPU="nvidia"
    elif lspci | grep -i "AMD" > /dev/null; then
        GPU="amd"
    elif lspci | grep -i "Intel" > /dev/null; then
        GPU="intel"
    fi
    
    # Display Detection
    RESOLUTION=$(xrandr 2>/dev/null | grep ' connected' | grep -o '[0-9]*x[0-9]*' | head -n1)
    
    # Keyboard Layout
    KEYBOARD=$(localectl status | grep "X11 Layout" | awk '{print $3}')
    
    # Audio
    if command -v pulseaudio &> /dev/null; then
        AUDIO="pulseaudio"
    elif command -v pipewire &> /dev/null; then
        AUDIO="pipewire"
    fi
    
    # Save detected configuration
    cat > /tmp/mh4s-detected.conf << EOF
GPU=$GPU
RESOLUTION=$RESOLUTION
KEYBOARD=$KEYBOARD
AUDIO=$AUDIO
EOF
}

# Main menu
show_menu() {
    while true; do
        clear
        echo -e "${BLUE}${BOLD}MH4S Installer${NC}"
        echo -e "${BOLD}1.${NC} Install base system"
        echo -e "${BOLD}2.${NC} Install applications"
        echo -e "${BOLD}3.${NC} Configure theme"
        echo -e "${BOLD}4.${NC} Install dotfiles"
        echo -e "${BOLD}5.${NC} Post-install setup"
        echo -e "${BOLD}q.${NC} Quit"
        
        read -p "Select an option: " choice
        case $choice in
            1) ./install.sh ;;
            2) ./apps.sh ;;
            3) ./theme.sh ;;
            4) ./config.sh ;;
            5) ./post.sh ;;
            q) exit 0 ;;
            *) echo "Invalid option" ;;
        esac
    done
}

# Main
main() {
    # Create log file
    touch "$LOG_FILE"
    log "Starting MH4S installation..."
    
    # System checks
    check_arch
    check_yay
    detect_system
    
    # Backup existing config
    if [ -d "$INSTALL_DIR" ]; then
        log "Backing up existing configuration..."
        cp -r "$INSTALL_DIR" "$BACKUP_DIR"
    fi
    
    # Show menu
    show_menu
}

main "$@"
