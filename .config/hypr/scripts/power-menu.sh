#!/bin/bash

# Source common functions
source ~/.config/hypr/scripts/common.sh

# Configuration
STYLE_FILE="/tmp/power_menu_style.css"
MENU_FILE="/tmp/power_menu.html"
TIMEOUT=60

# Create menu style
create_style() {
    cat > "$STYLE_FILE" << EOL
    * {
        font-family: "Lexend";
        color: #ffffff;
        background: transparent;
    }
    
    #menu {
        padding: 20px;
        background: rgba(0, 0, 0, 0.8);
        border-radius: 15px;
        border: 2px solid rgba(255, 255, 255, 0.1);
    }
    
    .item {
        padding: 10px 20px;
        margin: 5px 0;
        border-radius: 10px;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .item:hover {
        background: rgba(255, 255, 255, 0.1);
    }
    
    .icon {
        margin-right: 10px;
        font-size: 20px;
    }
    
    .label {
        font-size: 16px;
    }
    
    .shortcut {
        float: right;
        opacity: 0.7;
        font-size: 14px;
    }
    
    #lock { color: #98c379; }
    #sleep { color: #61afef; }
    #reboot { color: #e5c07b; }
    #shutdown { color: #e06c75; }
    #logout { color: #c678dd; }
EOL
}

# Create menu items
create_menu() {
    cat > "$MENU_FILE" << EOL
    <span class="item" id="lock">
        <span class="icon"></span>
        <span class="label">Lock</span>
        <span class="shortcut">Super + L</span>
    </span>
    <span class="item" id="sleep">
        <span class="icon">⏾</span>
        <span class="label">Sleep</span>
        <span class="shortcut">Super + Alt + S</span>
    </span>
    <span class="item" id="logout">
        <span class="icon">󰍃</span>
        <span class="label">Logout</span>
        <span class="shortcut">Super + Alt + L</span>
    </span>
    <span class="item" id="reboot">
        <span class="icon"></span>
        <span class="label">Reboot</span>
        <span class="shortcut">Super + Alt + R</span>
    </span>
    <span class="item" id="shutdown">
        <span class="icon">⏻</span>
        <span class="label">Shutdown</span>
        <span class="shortcut">Super + Alt + P</span>
    </span>
EOL
}

# Show confirmation dialog
confirm_action() {
    local action=$1
    local message=$2
    
    rofi -theme ~/.config/rofi/config.rasi \
         -dmenu \
         -mesg "$message" \
         -i \
         -no-custom \
         -p "Confirm" \
         -theme-str 'window {width: 400px;}' \
         <<< $'Yes\nNo' | grep -q "^Yes$"
}

# Fade screen
fade_screen() {
    local opacity=$1
    hyprctl keyword animation "fadeOut,1,4,default"
    sleep 0.5
    hyprctl keyword "decoration:dim_inactive $opacity"
}

# Execute action
execute_action() {
    local choice=$1
    local confirmed=false
    
    # Fade screen during confirmation
    fade_screen 0.5
    
    case $choice in
        "lock")
            swaylock -f
            ;;
        "sleep")
            if confirm_action "sleep" "Do you want to put the system to sleep?"; then
                systemctl suspend
            fi
            ;;
        "logout")
            if confirm_action "logout" "Do you want to logout?"; then
                hyprctl dispatch exit
            fi
            ;;
        "reboot")
            if confirm_action "reboot" "Do you want to reboot the system?"; then
                systemctl reboot
            fi
            ;;
        "shutdown")
            if confirm_action "shutdown" "Do you want to shutdown the system?"; then
                systemctl poweroff
            fi
            ;;
    esac
    
    # Restore screen
    fade_screen 0
}

# Show power menu
show_menu() {
    # Create style and menu files
    create_style
    create_menu
    
    # Show menu with rofi
    local choice=$(cat "$MENU_FILE" | rofi \
        -dmenu \
        -markup-rows \
        -theme-str "configuration { show-icons: false; } window { width: 400px; } listview { spacing: 0; }" \
        -theme-str "@import '$STYLE_FILE'" \
        -theme ~/.config/rofi/config.rasi \
        -i \
        -p "Power Menu" | sed -n 's/.*id="\([^"]*\)".*/\1/p')
    
    # Execute selected action
    if [ -n "$choice" ]; then
        execute_action "$choice"
    fi
    
    # Cleanup
    rm -f "$STYLE_FILE" "$MENU_FILE"
}

# Add keybindings to Hyprland
add_keybindings() {
    local config_file="$HOME/.config/hypr/hyprland.conf"
    
    # Check if bindings already exist
    if ! grep -q "# Power Menu Bindings" "$config_file"; then
        cat >> "$config_file" << EOL

# Power Menu Bindings
bind = SUPER ALT, S, exec, ~/.config/hypr/scripts/power-menu.sh sleep
bind = SUPER ALT, L, exec, ~/.config/hypr/scripts/power-menu.sh logout
bind = SUPER ALT, R, exec, ~/.config/hypr/scripts/power-menu.sh reboot
bind = SUPER ALT, P, exec, ~/.config/hypr/scripts/power-menu.sh shutdown
EOL
    fi
}

# Main function
main() {
    case "$1" in
        "sleep"|"logout"|"reboot"|"shutdown")
            execute_action "$1"
            ;;
        *)
            show_menu
            ;;
    esac
}

main "$@"
