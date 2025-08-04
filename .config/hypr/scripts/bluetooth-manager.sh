#!/bin/bash

# Configuration
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
CACHE_DIR="$HOME/.cache/bluetooth"
KNOWN_DEVICES="$CACHE_DIR/known_devices"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Icons
BT_ICON=""
AUDIO_ICON=""
KEYBOARD_ICON="⌨"
PHONE_ICON=""

# Function to get Bluetooth status
get_bluetooth_status() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        echo "Bluetooth: On"
    else
        echo "Bluetooth: Off"
    fi
}

# Function to toggle Bluetooth
toggle_bluetooth() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
        notify-send "Bluetooth" "Bluetooth disabled" -i bluetooth-disabled
    else
        bluetoothctl power on
        notify-send "Bluetooth" "Bluetooth enabled" -i bluetooth-active
    fi
}

# Function to format device list
format_devices() {
    bluetoothctl devices | while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            echo "$name [Connected]"
        else
            echo "$name"
        fi
    done
}

# Function to connect to a device
connect_to_device() {
    local name="$1"
    local mac=$(bluetoothctl devices | grep "$name" | awk '{print $2}')
    
    if [ -n "$mac" ]; then
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            bluetoothctl disconnect "$mac"
            notify-send "Bluetooth" "Disconnected from $name" -i bluetooth
        else
            bluetoothctl connect "$mac"
            notify-send "Bluetooth" "Connected to $name" -i bluetooth
        fi
    fi
}

# Function to pair new device
pair_new_device() {
    notify-send "Bluetooth" "Scanning for devices..." -i bluetooth
    bluetoothctl scan on &
    sleep 5
    kill $!
    
    devices=$(bluetoothctl devices | cut -d' ' -f3-)
    selected=$(echo "$devices" | rofi -dmenu -theme-str '
        window {
            width: 400px;
            height: 300px;
        }
        listview {
            lines: 8;
        }
        entry {
            placeholder: "Select device to pair...";
        }
    ' -p "Available Devices")
    
    if [ -n "$selected" ]; then
        mac=$(bluetoothctl devices | grep "$selected" | awk '{print $2}')
        if [ -n "$mac" ]; then
            bluetoothctl pair "$mac"
            bluetoothctl trust "$mac"
            bluetoothctl connect "$mac"
        fi
    fi
}

# Main menu
case "$1" in
    "toggle")
        toggle_bluetooth
        ;;
    "connect")
        selected=$(format_devices | rofi -dmenu -theme-str '
            window {
                width: 400px;
                height: 300px;
            }
            listview {
                lines: 8;
            }
            entry {
                placeholder: "Select device...";
            }
        ' -p "Bluetooth Devices")
        
        if [ -n "$selected" ]; then
            name=$(echo "$selected" | sed 's/ \[Connected\]//')
            connect_to_device "$name"
        fi
        ;;
    "pair")
        pair_new_device
        ;;
    "menu")
        choice=$(echo -e "Devices\n$(get_bluetooth_status)\nToggle Bluetooth\nPair New Device\nBluetooth Settings" | \
        rofi -dmenu -theme-str '
            window {
                width: 300px;
                height: 300px;
            }
            listview {
                lines: 5;
            }
        ' -p "Bluetooth")
        
        case "$choice" in
            "Devices")
                $0 connect
                ;;
            "Toggle Bluetooth")
                toggle_bluetooth
                ;;
            "Pair New Device")
                $0 pair
                ;;
            "Bluetooth Settings")
                blueman-manager &
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 [toggle|connect|pair|menu]"
        exit 1
        ;;
esac
