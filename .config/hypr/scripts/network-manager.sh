#!/bin/bash

# Configuration
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
CACHE_DIR="$HOME/.cache/networkmanager"
KNOWN_CONNECTIONS="$CACHE_DIR/known_connections"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Icons
WIFI_ICON=""
ETHERNET_ICON=""
VPN_ICON=""
AIRPLANE_ICON="✈"

# Colors
COLOR_CONNECTED="#FFFFFF"
COLOR_DISCONNECTED="#666666"

# Function to get current WiFi status
get_wifi_status() {
    if nmcli radio wifi | grep -q "enabled"; then
        echo "WiFi: On"
    else
        echo "WiFi: Off"
    fi
}

# Function to toggle WiFi
toggle_wifi() {
    if nmcli radio wifi | grep -q "enabled"; then
        nmcli radio wifi off
        notify-send "WiFi" "WiFi disabled" -i network-wireless-offline
    else
        nmcli radio wifi on
        notify-send "WiFi" "WiFi enabled" -i network-wireless
    fi
}

# Function to toggle airplane mode
toggle_airplane() {
    if nmcli radio all | grep -q "enabled"; then
        nmcli radio all off
        notify-send "Airplane Mode" "Enabled" -i airplane-mode
    else
        nmcli radio all on
        notify-send "Airplane Mode" "Disabled" -i network-wireless
    fi
}

# Function to format network list
format_networks() {
    nmcli -f IN-USE,SSID,BARS,SECURITY device wifi list | tail -n +2 | \
    while read -r line; do
        in_use=$(echo "$line" | awk '{print $1}')
        ssid=$(echo "$line" | awk '{print $2}')
        signal=$(echo "$line" | awk '{print $3}')
        security=$(echo "$line" | awk '{print $4}')
        
        # Format the entry
        if [ "$in_use" = "*" ]; then
            echo "$ssid [Connected] $signal"
        else
            echo "$ssid $signal"
        fi
    done
}

# Function to connect to a network
connect_to_network() {
    local ssid="$1"
    if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
        # Connect to known network
        nmcli connection up "$ssid"
        notify-send "WiFi" "Connected to $ssid" -i network-wireless
    else
        # Connect to new network
        password=$(rofi -dmenu -p "Enter password for $ssid" -password -theme-str '
            window {
                width: 400px;
                height: 100px;
            }
            listview {
                lines: 0;
            }
            entry {
                placeholder: "Password";
            }
        ')
        if [ -n "$password" ]; then
            nmcli device wifi connect "$ssid" password "$password" || \
            notify-send "WiFi" "Failed to connect to $ssid" -i network-wireless-offline
        fi
    fi
}

# Main menu
case "$1" in
    "toggle-wifi")
        toggle_wifi
        ;;
    "toggle-airplane")
        toggle_airplane
        ;;
    "connect")
        selected=$(format_networks | rofi -dmenu -theme-str '
            window {
                width: 600px;
                height: 400px;
            }
            listview {
                lines: 10;
            }
            entry {
                placeholder: "Select WiFi network...";
            }
        ' -p "WiFi Networks")
        
        if [ -n "$selected" ]; then
            ssid=$(echo "$selected" | awk '{print $1}')
            connect_to_network "$ssid"
        fi
        ;;
    "menu")
        # Show main network menu
        choice=$(echo -e "WiFi Networks\n$(get_wifi_status)\nToggle WiFi\nToggle Airplane Mode\nNetwork Settings" | \
        rofi -dmenu -theme-str '
            window {
                width: 300px;
                height: 300px;
            }
            listview {
                lines: 5;
            }
        ' -p "Network")
        
        case "$choice" in
            "WiFi Networks")
                $0 connect
                ;;
            "Toggle WiFi")
                toggle_wifi
                ;;
            "Toggle Airplane Mode")
                toggle_airplane
                ;;
            "Network Settings")
                nm-connection-editor &
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 [toggle-wifi|toggle-airplane|connect|menu]"
        exit 1
        ;;
esac
