#!/bin/bash

# Configuration
MAX_ENTRIES=100
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
CLIP_STORE="$HOME/.cache/cliphist/store"

# Ensure cache directory exists
mkdir -p "$(dirname "$CLIP_STORE")"

case $1 in
    "store")
        # Store clipboard content
        wl-paste --watch cliphist store -max-items $MAX_ENTRIES
        ;;
        
    "paste")
        # Show clipboard history and paste selected item
        cliphist list | rofi -dmenu -theme-str '
            window {
                width: 800px;
                height: 600px;
            }
            listview {
                columns: 1;
                lines: 15;
            }
            entry {
                placeholder: "Search clipboard history...";
            }
        ' -p "Clipboard" | cliphist decode | wl-copy
        ;;
        
    "delete")
        # Show clipboard history and delete selected item
        cliphist list | rofi -dmenu -theme-str '
            window {
                width: 800px;
                height: 600px;
            }
            listview {
                columns: 1;
                lines: 15;
            }
            entry {
                placeholder: "Select item to delete...";
            }
        ' -p "Delete from Clipboard" | cliphist delete
        ;;
        
    "clear")
        # Clear clipboard history
        cliphist wipe
        notify-send "Clipboard" "History cleared" -i edit-clear
        ;;
        
    *)
        echo "Usage: $0 [store|paste|delete|clear]"
        echo "  store  - Start clipboard monitoring"
        echo "  paste  - Show history and paste selected"
        echo "  delete - Show history and delete selected"
        echo "  clear  - Clear clipboard history"
        exit 1
        ;;
esac
