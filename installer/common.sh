#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${GREEN}[MH4S]${NC} $1"
}

# Error logging function
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Warning logging function
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Confirmation prompt
confirm() {
    read -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if running as root
check_root() {
    if [ "$(id -u)" = 0 ]; then
        error "This script should not be run as root!"
        exit 1
    fi
}

# Check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "Required command '$1' not found!"
        return 1
    fi
}

# Check system requirements
check_requirements() {
    # Check for yay
    if ! check_command yay; then
        error "yay is required for AUR packages"
        return 1
    fi
    
    # Check for systemd
    if ! check_command systemctl; then
        error "systemd is required"
        return 1
    fi
    
    return 0
}

# Detect GPU
detect_gpu() {
    if lspci | grep -i nvidia > /dev/null; then
        echo "nvidia"
    elif lspci | grep -i amd > /dev/null; then
        echo "amd"
    elif lspci | grep -i intel > /dev/null; then
        echo "intel"
    else
        echo "unknown"
    fi
}

# Save system detection results
save_detection() {
    # Create temporary config file
    cat > /tmp/mh4s-detected.conf << EOF
# MH4S detected system configuration
GPU="$(detect_gpu)"
EOF
}

# Initialize script
init_script() {
    # Check if running as root
    check_root
    
    # Check requirements
    check_requirements || exit 1
    
    # Save detection results
    save_detection
}

# Export functions
export -f log error warn confirm check_root check_command check_requirements detect_gpu save_detection init_script
