#!/bin/bash

# Configuration
STEP=5
NOTIFICATION_TIME=2000

# Function to show notification
show_notification() {
    local title=$1
    local message=$2
    local icon="window"
    
    notify-send -t $NOTIFICATION_TIME \
        -h string:x-canonical-private-synchronous:window-manager \
        "$title" "$message" -i "$icon"
}

# Function to get active window position and size
get_window_info() {
    hyprctl activewindow -j | jq -r '.at[0], .at[1], .size[0], .size[1]'
}

# Function to move window to a specific position and size
set_window_geometry() {
    local x=$1
    local y=$2
    local width=$3
    local height=$4
    
    hyprctl dispatch movewindowpixel exact $x $y
    hyprctl dispatch resizewindowpixel exact $width $height
}

# Function to snap window to different positions
snap_window() {
    local position=$1
    local monitor_info=$(hyprctl monitors -j | jq -r '.[0] | .width, .height')
    read -r screen_width screen_height <<< "$monitor_info"
    
    case "$position" in
        "left")
            set_window_geometry 0 0 $((screen_width/2)) $screen_height
            show_notification "Window Snapped" "Left Half"
            ;;
        "right")
            set_window_geometry $((screen_width/2)) 0 $((screen_width/2)) $screen_height
            show_notification "Window Snapped" "Right Half"
            ;;
        "top")
            set_window_geometry 0 0 $screen_width $((screen_height/2))
            show_notification "Window Snapped" "Top Half"
            ;;
        "bottom")
            set_window_geometry 0 $((screen_height/2)) $screen_width $((screen_height/2))
            show_notification "Window Snapped" "Bottom Half"
            ;;
        "topleft")
            set_window_geometry 0 0 $((screen_width/2)) $((screen_height/2))
            show_notification "Window Snapped" "Top Left Quarter"
            ;;
        "topright")
            set_window_geometry $((screen_width/2)) 0 $((screen_width/2)) $((screen_height/2))
            show_notification "Window Snapped" "Top Right Quarter"
            ;;
        "bottomleft")
            set_window_geometry 0 $((screen_height/2)) $((screen_width/2)) $((screen_height/2))
            show_notification "Window Snapped" "Bottom Left Quarter"
            ;;
        "bottomright")
            set_window_geometry $((screen_width/2)) $((screen_height/2)) $((screen_width/2)) $((screen_height/2))
            show_notification "Window Snapped" "Bottom Right Quarter"
            ;;
        "center")
            set_window_geometry $((screen_width/4)) $((screen_height/4)) $((screen_width/2)) $((screen_height/2))
            show_notification "Window Snapped" "Center"
            ;;
        "maximize")
            hyprctl dispatch fullscreen
            show_notification "Window Maximized" "Full Screen"
            ;;
    esac
}

# Function to resize window
resize_window() {
    local direction=$1
    read -r x y width height <<< "$(get_window_info)"
    
    case "$direction" in
        "grow")
            width=$((width + STEP))
            height=$((height + STEP))
            ;;
        "shrink")
            width=$((width - STEP))
            height=$((height - STEP))
            ;;
        "grow-h")
            width=$((width + STEP))
            ;;
        "shrink-h")
            width=$((width - STEP))
            ;;
        "grow-v")
            height=$((height + STEP))
            ;;
        "shrink-v")
            height=$((height - STEP))
            ;;
    esac
    
    hyprctl dispatch resizewindowpixel exact $width $height
    show_notification "Window Resized" "${direction^}"
}

# Function to show the window management menu
show_menu() {
    local options="Window Management\n"
    options+="┌──────────────────────┐\n"
    options+="│ 📍 Snap Positions    │\n"
    options+="│ 📏 Resize Window     │\n"
    options+="│ 🔄 Quick Actions     │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Window Manager" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Snap Positions"*)
            show_snap_menu
            ;;
        *"Resize Window"*)
            show_resize_menu
            ;;
        *"Quick Actions"*)
            show_actions_menu
            ;;
    esac
}

# Function to show snap positions menu
show_snap_menu() {
    local options="Current Window Position\n"
    options+="┌──────────────────────┐\n"
    options+="│ ⬅️  Snap Left        │\n"
    options+="│ ➡️  Snap Right       │\n"
    options+="│ ⬆️  Snap Top         │\n"
    options+="│ ⬇️  Snap Bottom      │\n"
    options+="│ ↖️  Top Left         │\n"
    options+="│ ↗️  Top Right        │\n"
    options+="│ ↙️  Bottom Left      │\n"
    options+="│ ↘️  Bottom Right     │\n"
    options+="│ ⭐ Center           │\n"
    options+="│ 🔲 Maximize         │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Snap Position" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Snap Left"*) snap_window "left" ;;
        *"Snap Right"*) snap_window "right" ;;
        *"Snap Top"*) snap_window "top" ;;
        *"Snap Bottom"*) snap_window "bottom" ;;
        *"Top Left"*) snap_window "topleft" ;;
        *"Top Right"*) snap_window "topright" ;;
        *"Bottom Left"*) snap_window "bottomleft" ;;
        *"Bottom Right"*) snap_window "bottomright" ;;
        *"Center"*) snap_window "center" ;;
        *"Maximize"*) snap_window "maximize" ;;
    esac
}

# Function to show resize menu
show_resize_menu() {
    local options="Resize Options\n"
    options+="┌──────────────────────┐\n"
    options+="│ ⬆️  Grow            │\n"
    options+="│ ⬇️  Shrink          │\n"
    options+="│ ➡️  Grow Width       │\n"
    options+="│ ⬅️  Shrink Width     │\n"
    options+="│ ⬆️  Grow Height      │\n"
    options+="│ ⬇️  Shrink Height    │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Resize Window" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Grow"*) resize_window "grow" ;;
        *"Shrink"*) resize_window "shrink" ;;
        *"Grow Width"*) resize_window "grow-h" ;;
        *"Shrink Width"*) resize_window "shrink-h" ;;
        *"Grow Height"*) resize_window "grow-v" ;;
        *"Shrink Height"*) resize_window "shrink-v" ;;
    esac
}

# Function to show quick actions menu
show_actions_menu() {
    local options="Quick Actions\n"
    options+="┌──────────────────────┐\n"
    options+="│ 🔄 Rotate Layout     │\n"
    options+="│ 📌 Toggle Floating   │\n"
    options+="│ 📍 Toggle Sticky     │\n"
    options+="│ 🎯 Center Window     │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Quick Actions" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Rotate Layout"*)
            hyprctl dispatch togglesplit
            show_notification "Layout" "Rotated"
            ;;
        *"Toggle Floating"*)
            hyprctl dispatch togglefloating
            show_notification "Window State" "Floating Toggled"
            ;;
        *"Toggle Sticky"*)
            hyprctl dispatch pin
            show_notification "Window State" "Sticky Toggled"
            ;;
        *"Center Window"*)
            snap_window "center"
            ;;
    esac
}

# Main script
case "$1" in
    "snap") show_snap_menu ;;
    "resize") show_resize_menu ;;
    "actions") show_actions_menu ;;
    "menu") show_menu ;;
    *) echo "Usage: $0 {snap|resize|actions|menu}" ;;
esac
