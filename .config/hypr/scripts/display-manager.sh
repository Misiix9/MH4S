#!/bin/bash

# Source common functions
source ~/.config/hypr/scripts/common.sh

# Get list of connected displays
get_displays() {
    hyprctl monitors -j | jq -r '.[].name'
}

# Get display properties
get_display_props() {
    local display=$1
    hyprctl monitors -j | jq -r ".[] | select(.name==\"$display\") | \"\(.width)x\(.height)@\(.refreshRate)\""
}

# Calculate optimal layout
calculate_layout() {
    local displays=($@)
    local count=${#displays[@]}
    local layout=""
    
    case $count in
        1)
            # Single display
            layout="monitor=${displays[0]},preferred,auto,1"
            ;;
        2)
            # Dual display - side by side
            layout="monitor=${displays[0]},preferred,0x0,1"
            layout+="\nmonitor=${displays[1]},preferred,auto,1"
            ;;
        3)
            # Triple display - main center, sides vertical
            layout="monitor=${displays[0]},preferred,0x0,1"
            layout+="\nmonitor=${displays[1]},preferred,auto,1"
            layout+="\nmonitor=${displays[2]},preferred,auto,1"
            ;;
        *)
            # Grid layout for more displays
            local col=0
            local row=0
            for display in "${displays[@]}"; do
                layout+="monitor=$display,preferred,${col}x${row},1\n"
                if [ $col -eq 1 ]; then
                    col=0
                    ((row+=1080))
                else
                    ((col+=1920))
                fi
            done
            ;;
    esac
    
    echo -e "$layout"
}

# Apply smooth transitions
apply_transitions() {
    # Fade out
    for workspace in $(hyprctl workspaces -j | jq -r '.[].id'); do
        hyprctl keyword animation "fadeOut,1,4,default"
        hyprctl dispatch workspace $workspace
        sleep 0.1
    done
    
    # Apply new layout
    echo "$1" > ~/.config/hypr/monitors.conf
    hyprctl reload
    
    # Fade in
    for workspace in $(hyprctl workspaces -j | jq -r '.[].id'); do
        hyprctl keyword animation "fadeIn,1,4,default"
        hyprctl dispatch workspace $workspace
        sleep 0.1
    done
}

# Create notification
show_notification() {
    notify-send "Display Layout" "$1" -i display -u low
}

# Handle display hotplug
handle_hotplug() {
    local displays=($(get_displays))
    local layout=$(calculate_layout "${displays[@]}")
    
    # Show connecting animation
    show_notification "Configuring displays..."
    
    # Apply new layout with transitions
    apply_transitions "$layout"
    
    # Update wallpaper
    ~/.config/hypr/scripts/wallpaper-switcher.sh &
    
    # Restart Waybar to update monitor configuration
    pkill waybar
    waybar &
    
    show_notification "Display layout updated\n${#displays[@]} displays connected"
}

# Watch for display changes
monitor_changes() {
    socat - UNIX-CONNECT:/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock | while read -r line; do
        if [[ $line == *"monitoradded"* ]] || [[ $line == *"monitorremoved"* ]]; then
            handle_hotplug
        fi
    done
}

# Main function
main() {
    # Initial setup
    handle_hotplug
    
    # Monitor for changes
    monitor_changes
}

main "$@"
