#!/bin/bash

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CURRENT_WALLPAPER="$HOME/.config/hypr/.current_wallpaper"
ANIMATION_SHADER="$HOME/.config/hypr/scripts/bubbles.frag"

# Function to get a random time between 3 and 8 minutes (in seconds)
get_random_time() {
    echo $(( (RANDOM % 300) + 180 ))
}

# Function to get a random wallpaper
get_random_wallpaper() {
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1
}

# Function to apply wallpaper with animation
apply_wallpaper() {
    local wallpaper=$1
    
    # Store current wallpaper path
    echo "$wallpaper" > "$CURRENT_WALLPAPER"
    
    # Apply wallpaper with swww (with bubble animation)
    swww img "$wallpaper" \
        --transition-fps 60 \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 2
}

# Main loop
while true; do
    # Get random wallpaper
    WALL=$(get_random_wallpaper)
    
    # Apply the wallpaper
    apply_wallpaper "$WALL"
    
    # Wait for random time between 3-8 minutes
    sleep $(get_random_time)
done
