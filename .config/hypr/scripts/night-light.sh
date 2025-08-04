#!/bin/bash

# Initialize variables
TEMP_STEP=500
MIN_TEMP=2500
MAX_TEMP=6500
GAMMA_CONF="$HOME/.config/hypr/.gamma"

# Function to show notification
show_notification() {
    local temp=$1
    local icon="night-light"
    local mode=$2
    
    # Calculate warmth percentage
    local warmth=$(( ((MAX_TEMP - temp) * 100) / (MAX_TEMP - MIN_TEMP) ))
    
    # Create progress bar
    local progress=""
    for ((i=0; i<$warmth/5; i++)); do
        progress+="─"
    done
    for ((i=$warmth/5; i<20; i++)); do
        progress+="─"
    done
    
    notify-send -t 2000 -h string:x-canonical-private-synchronous:gamma \
        -h "int:value:$warmth" \
        "${mode:-"Color Temperature"}: ${temp}K" \
        -i "$icon" \
        "[$progress]"
}

# Function to set color temperature
set_temperature() {
    local temp=$1
    local mode=$2
    
    # Save current temperature
    echo "$temp" > "$GAMMA_CONF"
    
    # Apply using gammastep
    pkill gammastep
    gammastep -O "$temp" -P &
    
    show_notification "$temp" "$mode"
}

# Function to increase temperature (make cooler)
increase_temperature() {
    local current_temp
    if [[ -f "$GAMMA_CONF" ]]; then
        current_temp=$(cat "$GAMMA_CONF")
    else
        current_temp=$MAX_TEMP
    fi
    
    local new_temp=$((current_temp + TEMP_STEP))
    [[ $new_temp -gt $MAX_TEMP ]] && new_temp=$MAX_TEMP
    set_temperature $new_temp
}

# Function to decrease temperature (make warmer)
decrease_temperature() {
    local current_temp
    if [[ -f "$GAMMA_CONF" ]]; then
        current_temp=$(cat "$GAMMA_CONF")
    else
        current_temp=$MAX_TEMP
    fi
    
    local new_temp=$((current_temp - TEMP_STEP))
    [[ $new_temp -lt $MIN_TEMP ]] && new_temp=$MIN_TEMP
    set_temperature $new_temp
}

# Function to toggle night light
toggle_night_light() {
    if pgrep -x "gammastep" > /dev/null; then
        pkill gammastep
        rm -f "$GAMMA_CONF"
        notify-send -t 2000 "Night Light" "Disabled" -i "night-light"
    else
        set_temperature 4000 "Night Light"
    fi
}

# Function to show temperature menu
show_menu() {
    local current_temp
    if [[ -f "$GAMMA_CONF" ]]; then
        current_temp=$(cat "$GAMMA_CONF")
    else
        current_temp=$MAX_TEMP
    fi
    
    local options="Current: ${current_temp}K\n"
    options+="┌──────────────────────┐\n"
    options+="│ 🌞 6500K Daylight    │\n"
    options+="│ 🌥️  5500K Cool        │\n"
    options+="│ 🌤️  4500K Neutral     │\n"
    options+="│ 🌅 3500K Warm        │\n"
    options+="│ 🌙 2500K Night       │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Color Temperature" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"6500K"*) set_temperature 6500 "Daylight" ;;
        *"5500K"*) set_temperature 5500 "Cool" ;;
        *"4500K"*) set_temperature 4500 "Neutral" ;;
        *"3500K"*) set_temperature 3500 "Warm" ;;
        *"2500K"*) set_temperature 2500 "Night" ;;
    esac
}

# Initialize night light service
init() {
    if [[ -f "$GAMMA_CONF" ]]; then
        temp=$(cat "$GAMMA_CONF")
        set_temperature "$temp" "Restored"
    fi
}

# Main script
case "$1" in
    up) increase_temperature ;;
    down) decrease_temperature ;;
    toggle) toggle_night_light ;;
    menu) show_menu ;;
    init) init ;;
    *) echo "Usage: $0 {up|down|toggle|menu|init}" ;;
esac
