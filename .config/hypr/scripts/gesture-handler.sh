#!/bin/bash

# Source common functions
source ~/.config/hypr/scripts/common.sh

# Configuration
GESTURES_CONF="/tmp/hyprland_gestures.conf"
SWIPE_THRESHOLD=100
PINCH_THRESHOLD=0.1

# Store last coordinates
declare -A LAST_COORDS
declare -A GESTURE_STATE

# Initialize libinput-gestures config
init_gestures() {
    cat > "$GESTURES_CONF" << EOL
# Swipe gestures
gesture swipe up 3 ~/.config/hypr/scripts/gesture-handler.sh swipe up 3
gesture swipe down 3 ~/.config/hypr/scripts/gesture-handler.sh swipe down 3
gesture swipe left 3 ~/.config/hypr/scripts/gesture-handler.sh swipe left 3
gesture swipe right 3 ~/.config/hypr/scripts/gesture-handler.sh swipe right 3

# Four finger swipes
gesture swipe up 4 ~/.config/hypr/scripts/gesture-handler.sh swipe up 4
gesture swipe down 4 ~/.config/hypr/scripts/gesture-handler.sh swipe down 4
gesture swipe left 4 ~/.config/hypr/scripts/gesture-handler.sh swipe left 4
gesture swipe right 4 ~/.config/hypr/scripts/gesture-handler.sh swipe right 4

# Pinch gestures
gesture pinch in ~/.config/hypr/scripts/gesture-handler.sh pinch in
gesture pinch out ~/.config/hypr/scripts/gesture-handler.sh pinch out

# Pinch and rotate
gesture pinch clockwise ~/.config/hypr/scripts/gesture-handler.sh rotate clockwise
gesture pinch anticlockwise ~/.config/hypr/scripts/gesture-handler.sh rotate anticlockwise
EOL

    # Apply configuration
    libinput-gestures-setup restart
}

# Handle swipe gestures
handle_swipe() {
    local direction=$1
    local fingers=$2
    
    case "$fingers" in
        3)
            case "$direction" in
                "up")
                    # Overview mode
                    hyprctl dispatch toggleoverview
                    ;;
                "down")
                    # Show desktop
                    minimize_all_windows
                    ;;
                "left")
                    # Next workspace
                    hyprctl dispatch workspace e+1
                    ;;
                "right")
                    # Previous workspace
                    hyprctl dispatch workspace e-1
                    ;;
            esac
            ;;
        4)
            case "$direction" in
                "up")
                    # Maximize window
                    hyprctl dispatch togglefloating
                    hyprctl dispatch fullscreen 1
                    ;;
                "down")
                    # Restore window
                    hyprctl dispatch fullscreen 0
                    hyprctl dispatch togglefloating
                    ;;
                "left")
                    # Move window to next workspace
                    hyprctl dispatch movetoworkspace e+1
                    ;;
                "right")
                    # Move window to previous workspace
                    hyprctl dispatch movetoworkspace e-1
                    ;;
            esac
            ;;
    esac
}

# Handle pinch gestures
handle_pinch() {
    local direction=$1
    
    case "$direction" in
        "in")
            # Zoom out effect
            adjust_active_window_scale 0.9
            ;;
        "out")
            # Zoom in effect
            adjust_active_window_scale 1.1
            ;;
    esac
}

# Handle rotation gestures
handle_rotate() {
    local direction=$1
    
    case "$direction" in
        "clockwise")
            rotate_active_window 90
            ;;
        "anticlockwise")
            rotate_active_window -90
            ;;
    esac
}

# Minimize all windows
minimize_all_windows() {
    for window in $(hyprctl clients -j | jq -r '.[].address'); do
        hyprctl dispatch minimize address:$window
    done
}

# Adjust window scale
adjust_active_window_scale() {
    local scale=$1
    local window=$(hyprctl activewindow -j)
    
    if [ -n "$window" ]; then
        local current_scale=$(echo "$window" | jq -r '.size[0] / .scale')
        local new_scale=$(echo "$current_scale * $scale" | bc)
        hyprctl dispatch resizeactive exact "$new_scale" "$new_scale"
    fi
}

# Rotate window
rotate_active_window() {
    local angle=$1
    hyprctl dispatch togglefloating
    hyprctl dispatch rotateactive "$angle"
}

# Visual feedback
show_feedback() {
    local gesture=$1
    local direction=$2
    local icon
    
    case "$gesture" in
        "swipe")
            case "$direction" in
                "up") icon="" ;;
                "down") icon="" ;;
                "left") icon="" ;;
                "right") icon="" ;;
            esac
            ;;
        "pinch")
            case "$direction" in
                "in") icon="" ;;
                "out") icon="" ;;
            esac
            ;;
        "rotate")
            case "$direction" in
                "clockwise") icon="󰑐" ;;
                "anticlockwise") icon="󰑏" ;;
            esac
            ;;
    esac
    
    notify-send -t 1000 -h string:x-canonical-private-synchronous:gesture "$icon" -h int:value:$(($RANDOM % 100))
}

# Main function
main() {
    local gesture=$1
    local direction=$2
    local fingers=${3:-3}
    
    case "$gesture" in
        "init")
            init_gestures
            ;;
        "swipe")
            handle_swipe "$direction" "$fingers"
            show_feedback "swipe" "$direction"
            ;;
        "pinch")
            handle_pinch "$direction"
            show_feedback "pinch" "$direction"
            ;;
        "rotate")
            handle_rotate "$direction"
            show_feedback "rotate" "$direction"
            ;;
        *)
            echo "Usage: $0 {init|swipe|pinch|rotate} {direction} [fingers]"
            exit 1
            ;;
    esac
}

main "$@"
