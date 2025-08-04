#!/bin/bash

# Screenshot save directory
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with timestamp
FILENAME="$(date +'%Y-%m-%d-%H%M%S')-screenshot.png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# Function to copy to clipboard
copy_to_clipboard() {
    wl-copy < "$1"
    notify-send "Screenshot" "Copied to clipboard" -i "$1"
}

# Function to save file
save_screenshot() {
    local path="$1"
    mv "$path" "$FILEPATH"
    notify-send "Screenshot" "Saved to $FILEPATH" -i "$FILEPATH"
    
    # Copy to clipboard as well
    copy_to_clipboard "$FILEPATH"
}

# Take different types of screenshots based on the argument
case "$1" in
    # Full screen screenshot
    "full")
        grim "$FILEPATH"
        notify-send "Screenshot" "Full screen captured" -i "$FILEPATH"
        copy_to_clipboard "$FILEPATH"
        ;;
        
    # Active window screenshot
    "active")
        ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [ "$ACTIVE_WINDOW" != "null" ]; then
            grim -g "$ACTIVE_WINDOW" "$FILEPATH"
            notify-send "Screenshot" "Active window captured" -i "$FILEPATH"
            copy_to_clipboard "$FILEPATH"
        else
            notify-send "Screenshot" "No active window found" -u critical
        fi
        ;;
        
    # Selection screenshot
    "area")
        SELECTION=$(slurp -d -b "#00000000" -c "#FFFFFF" -w 2)
        if [ -n "$SELECTION" ]; then
            grim -g "$SELECTION" "$FILEPATH"
            notify-send "Screenshot" "Selection captured" -i "$FILEPATH"
            copy_to_clipboard "$FILEPATH"
        else
            notify-send "Screenshot" "Selection cancelled" -u low
        fi
        ;;
        
    # Screen recording (requires wf-recorder)
    "record")
        RECORDING_DIR="$HOME/Videos/Recordings"
        mkdir -p "$RECORDING_DIR"
        RECORDING_FILE="$RECORDING_DIR/recording-$(date +'%Y-%m-%d-%H%M%S').mp4"
        
        if pgrep -x "wf-recorder" > /dev/null; then
            # Stop recording
            pkill -x "wf-recorder"
            notify-send "Recording" "Saved to $RECORDING_FILE"
        else
            # Start recording
            notify-send "Recording" "Started screen recording..."
            wf-recorder -f "$RECORDING_FILE" &
        fi
        ;;
        
    # Display help
    *)
        echo "Usage: $0 [full|active|area|record]"
        echo "  full    - Take a screenshot of the entire screen"
        echo "  active  - Take a screenshot of the active window"
        echo "  area    - Take a screenshot of a selected area"
        echo "  record  - Toggle screen recording"
        exit 1
        ;;
esac
