#!/bin/bash

# Source common functions
source ~/.config/hypr/scripts/common.sh

# Configuration menu options
declare -A MENU_OPTIONS=(
    ["⚡ Quick Layout"]="quick_layout"
    ["🔄 Rotate Display"]="rotate_display"
    ["📏 Scale Display"]="scale_display"
    ["🎯 Mirror Displays"]="mirror_displays"
    ["🔌 Manage Outputs"]="manage_outputs"
    ["💾 Save Layout"]="save_layout"
    ["📥 Load Layout"]="load_layout"
)

# Quick layout menu
quick_layout() {
    local displays=($(hyprctl monitors -j | jq -r '.[].name'))
    local options=()
    
    # Build layout options based on display count
    case ${#displays[@]} in
        1)
            options=("Optimize Single" "Center" "Scale to Fit")
            ;;
        2)
            options=("Side by Side" "Stack Vertical" "Mirror" "Extended")
            ;;
        *)
            options=("Grid Layout" "Row Layout" "Column Layout" "Focus Main")
            ;;
    esac
    
    # Show menu
    local choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Select Layout" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$choice" ]; then
        case $choice in
            "Side by Side")
                hyprctl keyword monitor "${displays[0]},preferred,0x0,1"
                hyprctl keyword monitor "${displays[1]},preferred,auto,1"
                ;;
            "Stack Vertical")
                hyprctl keyword monitor "${displays[0]},preferred,0x0,1"
                hyprctl keyword monitor "${displays[1]},preferred,0x1080,1"
                ;;
            *)
                notify-send "Display Layout" "Applying $choice layout..." -i display
                ;;
        esac
    fi
}

# Rotate display menu
rotate_display() {
    local displays=($(hyprctl monitors -j | jq -r '.[].name'))
    local display=$(printf '%s\n' "${displays[@]}" | rofi -dmenu -p "Select Display" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$display" ]; then
        local rotations=("normal" "90" "180" "270")
        local rotation=$(printf '%s\n' "${rotations[@]}" | rofi -dmenu -p "Select Rotation" -theme ~/.config/rofi/config.rasi)
        
        if [ -n "$rotation" ]; then
            hyprctl keyword monitor "$display,transform,$rotation"
            notify-send "Display Rotation" "Rotated $display to $rotation°" -i display
        fi
    fi
}

# Scale display menu
scale_display() {
    local displays=($(hyprctl monitors -j | jq -r '.[].name'))
    local display=$(printf '%s\n' "${displays[@]}" | rofi -dmenu -p "Select Display" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$display" ]; then
        local scales=("0.5" "0.75" "1.0" "1.25" "1.5" "2.0")
        local scale=$(printf '%s\n' "${scales[@]}" | rofi -dmenu -p "Select Scale" -theme ~/.config/rofi/config.rasi)
        
        if [ -n "$scale" ]; then
            hyprctl keyword monitor "$display,preferred,auto,$scale"
            notify-send "Display Scale" "Set $display scale to $scale" -i display
        fi
    fi
}

# Mirror displays menu
mirror_displays() {
    local displays=($(hyprctl monitors -j | jq -r '.[].name'))
    
    if [ ${#displays[@]} -lt 2 ]; then
        notify-send "Display Mirror" "Need at least 2 displays to mirror" -i display -u critical
        return 1
    fi
    
    local source=$(printf '%s\n' "${displays[@]}" | rofi -dmenu -p "Select Source Display" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$source" ]; then
        local target=$(printf '%s\n' "${displays[@]}" | grep -v "^$source$" | rofi -dmenu -p "Select Target Display" -theme ~/.config/rofi/config.rasi)
        
        if [ -n "$target" ]; then
            hyprctl keyword monitor "$target,preferred,auto,1,mirror,$source"
            notify-send "Display Mirror" "Mirroring $source to $target" -i display
        fi
    fi
}

# Manage outputs menu
manage_outputs() {
    local displays=($(hyprctl monitors -j | jq -r '.[].name'))
    local actions=("Enable" "Disable" "Primary")
    
    local display=$(printf '%s\n' "${displays[@]}" | rofi -dmenu -p "Select Display" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$display" ]; then
        local action=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "Select Action" -theme ~/.config/rofi/config.rasi)
        
        case $action in
            "Enable")
                hyprctl keyword monitor "$display,preferred,auto,1"
                ;;
            "Disable")
                hyprctl keyword monitor "$display,disable"
                ;;
            "Primary")
                hyprctl keyword monitor "$display,preferred,0x0,1"
                ;;
        esac
        
        notify-send "Display Output" "$action $display" -i display
    fi
}

# Save layout menu
save_layout() {
    local name=$(rofi -dmenu -p "Layout Name" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$name" ]; then
        mkdir -p ~/.config/hypr/layouts
        hyprctl monitors -j > ~/.config/hypr/layouts/"$name".json
        notify-send "Display Layout" "Saved layout as $name" -i display
    fi
}

# Load layout menu
load_layout() {
    local layouts=(~/.config/hypr/layouts/*.json)
    local names=()
    
    for layout in "${layouts[@]}"; do
        names+=($(basename "$layout" .json))
    done
    
    local choice=$(printf '%s\n' "${names[@]}" | rofi -dmenu -p "Select Layout" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$choice" ] && [ -f ~/.config/hypr/layouts/"$choice".json ]; then
        # Apply layout with transition
        ~/.config/hypr/scripts/display-manager.sh apply ~/.config/hypr/layouts/"$choice".json
        notify-send "Display Layout" "Loaded layout $choice" -i display
    fi
}

# Main menu
main() {
    local choice=$(printf '%s\n' "${!MENU_OPTIONS[@]}" | rofi -dmenu -p "Display Settings" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$choice" ] && [ -n "${MENU_OPTIONS[$choice]}" ]; then
        ${MENU_OPTIONS[$choice]}
    fi
}

main "$@"
