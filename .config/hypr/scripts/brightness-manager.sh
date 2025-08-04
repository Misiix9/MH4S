#!/bin/bash

# Initialize variables
BRIGHTNESS_STEP=5
CURRENT_BRIGHTNESS=$(brightnessctl g)
MAX_BRIGHTNESS=$(brightnessctl m)
BRIGHTNESS_PERCENT=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# Function to show notification
show_notification() {
    local brightness=$1
    local icon="display-brightness"
    
    # Create progress bar
    local progress=""
    for ((i=0; i<$brightness/5; i++)); do
        progress+="─"
    done
    for ((i=$brightness/5; i<20; i++)); do
        progress+="─"
    done
    
    notify-send -t 2000 -h string:x-canonical-private-synchronous:brightness \
        -h "int:value:$brightness" \
        "Brightness: ${brightness}%" \
        -i "$icon" \
        "[$progress]"
}

# Function to set brightness
set_brightness() {
    local target=$1
    brightnessctl s "${target}%" -q
    show_notification "$target"
}

# Function to increase brightness
increase_brightness() {
    local new_brightness=$((BRIGHTNESS_PERCENT + BRIGHTNESS_STEP))
    [[ $new_brightness -gt 100 ]] && new_brightness=100
    set_brightness $new_brightness
}

# Function to decrease brightness
decrease_brightness() {
    local new_brightness=$((BRIGHTNESS_PERCENT - BRIGHTNESS_STEP))
    [[ $new_brightness -lt 5 ]] && new_brightness=5
    set_brightness $new_brightness
}

# Function to show brightness menu
show_menu() {
    local options="Brightness: ${BRIGHTNESS_PERCENT}%\n"
    options+="┌──────────────────────┐\n"
    options+="│ 🔆 100% Maximum      │\n"
    options+="│ 🌤️  75% High         │\n"
    options+="│ 🌥️  50% Medium       │\n"
    options+="│ 🌦️  25% Low          │\n"
    options+="│ 🌑 5%  Minimum       │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Brightness" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"100%"*) set_brightness 100 ;;
        *"75%"*) set_brightness 75 ;;
        *"50%"*) set_brightness 50 ;;
        *"25%"*) set_brightness 25 ;;
        *"5%"*) set_brightness 5 ;;
    esac
}

# Main script
case "$1" in
    up) increase_brightness ;;
    down) decrease_brightness ;;
    menu) show_menu ;;
    *) echo "Usage: $0 {up|down|menu}" ;;
esac
