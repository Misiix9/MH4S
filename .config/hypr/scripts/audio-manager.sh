#!/bin/bash

# Configuration
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
CACHE_DIR="$HOME/.cache/audio"
MAX_VOL=150
DEFAULT_STEP=5
VOLUME_ICONS=("" "" "" "")

# Create cache directory
mkdir -p "$CACHE_DIR"

# Function to get current volume
get_volume() {
    pamixer --get-volume
}

# Function to get current mute status
is_muted() {
    pamixer --get-mute
}

# Function to get volume icon
get_volume_icon() {
    local vol=$(get_volume)
    if [ $(is_muted) = "true" ]; then
        echo ""
    elif [ $vol -gt 75 ]; then
        echo "${VOLUME_ICONS[3]}"
    elif [ $vol -gt 50 ]; then
        echo "${VOLUME_ICONS[2]}"
    elif [ $vol -gt 25 ]; then
        echo "${VOLUME_ICONS[1]}"
    else
        echo "${VOLUME_ICONS[0]}"
    fi
}

# Function to adjust volume
adjust_volume() {
    local change=$1
    local current=$(get_volume)
    local new=$((current + change))
    
    if [ $new -lt 0 ]; then
        new=0
    elif [ $new -gt $MAX_VOL ]; then
        new=$MAX_VOL
    fi
    
    pamixer --set-volume $new
    notify_volume
}

# Function to toggle mute
toggle_mute() {
    pamixer --toggle-mute
    if [ $(is_muted) = "true" ]; then
        notify-send "Audio" "Muted" -i audio-volume-muted
    else
        notify_volume
    fi
}

# Function to show volume notification
notify_volume() {
    local vol=$(get_volume)
    local icon=""
    
    if [ $vol -gt 75 ]; then
        icon="audio-volume-high"
    elif [ $vol -gt 50 ]; then
        icon="audio-volume-medium"
    elif [ $vol -gt 25 ]; then
        icon="audio-volume-low"
    else
        icon="audio-volume-low-zero"
    fi
    
    notify-send -h int:value:$vol "Volume: ${vol}%" -i $icon
}

# Function to list audio sinks
list_sinks() {
    pactl list short sinks | while read -r line; do
        local id=$(echo "$line" | awk '{print $1}')
        local name=$(echo "$line" | awk '{print $2}')
        local desc=$(pactl list sinks | grep -A1 "Sink #$id" | grep Description | cut -d: -f2- | xargs)
        if pactl get-default-sink | grep -q "$name"; then
            echo "$desc [Active]"
        else
            echo "$desc"
        fi
    done
}

# Function to set default sink
set_default_sink() {
    local selected="$1"
    local sink_name=$(pactl list short sinks | grep "$(echo "$selected" | sed 's/ \[Active\]//')" | awk '{print $2}')
    if [ -n "$sink_name" ]; then
        pactl set-default-sink "$sink_name"
        notify-send "Audio" "Switched to $selected" -i audio-card
    fi
}

# Function to list audio sources
list_sources() {
    pactl list short sources | while read -r line; do
        local id=$(echo "$line" | awk '{print $1}')
        local name=$(echo "$line" | awk '{print $2}')
        local desc=$(pactl list sources | grep -A1 "Source #$id" | grep Description | cut -d: -f2- | xargs)
        if pactl get-default-source | grep -q "$name"; then
            echo "$desc [Active]"
        else
            echo "$desc"
        fi
    done
}

# Function to set default source
set_default_source() {
    local selected="$1"
    local source_name=$(pactl list short sources | grep "$(echo "$selected" | sed 's/ \[Active\]//')" | awk '{print $2}')
    if [ -n "$source_name" ]; then
        pactl set-default-source "$source_name"
        notify-send "Audio" "Switched to $selected" -i audio-input-microphone
    fi
}

# Main menu
case "$1" in
    "up")
        adjust_volume $DEFAULT_STEP
        ;;
    "down")
        adjust_volume -$DEFAULT_STEP
        ;;
    "mute")
        toggle_mute
        ;;
    "output-menu")
        selected=$(list_sinks | rofi -dmenu -theme-str '
            window {
                width: 500px;
                height: 300px;
            }
            listview {
                lines: 8;
            }
            entry {
                placeholder: "Select output device...";
            }
        ' -p "Audio Output")
        
        if [ -n "$selected" ]; then
            set_default_sink "$selected"
        fi
        ;;
    "input-menu")
        selected=$(list_sources | rofi -dmenu -theme-str '
            window {
                width: 500px;
                height: 300px;
            }
            listview {
                lines: 8;
            }
            entry {
                placeholder: "Select input device...";
            }
        ' -p "Audio Input")
        
        if [ -n "$selected" ]; then
            set_default_source "$selected"
        fi
        ;;
    "menu")
        choice=$(echo -e "Output Devices\nInput Devices\nVolume Control\nMixer Settings" | \
        rofi -dmenu -theme-str '
            window {
                width: 300px;
                height: 200px;
            }
            listview {
                lines: 4;
            }
        ' -p "Audio")
        
        case "$choice" in
            "Output Devices")
                $0 output-menu
                ;;
            "Input Devices")
                $0 input-menu
                ;;
            "Volume Control")
                pavucontrol &
                ;;
            "Mixer Settings")
                pavucontrol &
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 [up|down|mute|output-menu|input-menu|menu]"
        exit 1
        ;;
esac
