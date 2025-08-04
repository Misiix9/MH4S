#!/bin/bash

# Configuration
CACHE_DIR="$HOME/.cache/spotify-widget"
CURRENT_COVER="$CACHE_DIR/current_cover.png"
DISPLAY_SCRIPT="$CACHE_DIR/show_cover.sh"
DESKTOP_ENTRY="$HOME/.local/share/applications/spotify-widget.desktop"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Function to extract album art
get_album_art() {
    playerctl -p spotify metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/'
}

# Function to show album art using swaybg
show_album_art() {
    local art_url="$1"
    if [ -n "$art_url" ]; then
        wget -q -O "$CURRENT_COVER" "$art_url"
        convert "$CURRENT_COVER" -resize 300x300 "$CURRENT_COVER"
        
        # Create a script to display the cover
        echo '#!/bin/bash' > "$DISPLAY_SCRIPT"
        echo "swww img \"$CURRENT_COVER\" --transition-type simple --transition-pos bottom-right --transition-duration 1" >> "$DISPLAY_SCRIPT"
        chmod +x "$DISPLAY_SCRIPT"
        
        # Show the cover
        "$DISPLAY_SCRIPT"
    fi
}

# Monitor Spotify playback
while true; do
    if pgrep -x "spotify" > /dev/null; then
        current_art=$(get_album_art)
        if [ -n "$current_art" ]; then
            show_album_art "$current_art"
        fi
    fi
    sleep 2
done
