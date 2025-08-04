#!/bin/bash

show_menu() {
    options=(
        "🖼️  Wallpaper Selector"
        "📋 Clipboard History"
        "📸 Screenshot"
        "🎵 Audio Settings"
        "📱 Bluetooth Manager"
        "🌐 Network Manager"
        "🔑 Password Manager"
        "🔔 Notification Settings"
    )

    selected=$(printf '%s\n' "${options[@]}" | rofi -dmenu \
        -p "System Menu" \
        -theme-str 'window {width: 400px;}' \
        -theme-str 'listview {lines: 8;}' \
        -theme-str 'element {padding: 10px;}')

    case "$selected" in
        "🖼️  Wallpaper Selector")
            ~/.config/hypr/scripts/wallpaper-gui.sh
            ;;
        "📋 Clipboard History")
            ~/.config/hypr/scripts/clipboard-manager.sh paste
            ;;
        "📸 Screenshot")
            ~/.config/hypr/scripts/screenshot.sh area
            ;;
        "🎵 Audio Settings")
            ~/.config/hypr/scripts/audio-manager.sh menu
            ;;
        "📱 Bluetooth Manager")
            ~/.config/hypr/scripts/bluetooth-manager.sh menu
            ;;
        "🌐 Network Manager")
            ~/.config/hypr/scripts/network-manager.sh menu
            ;;
        "🔑 Password Manager")
            bitwarden-desktop
            ;;
        "🔔 Notification Settings")
            ~/.config/hypr/scripts/toggle-dnd.sh toggle
            ;;
    esac
}

show_menu
