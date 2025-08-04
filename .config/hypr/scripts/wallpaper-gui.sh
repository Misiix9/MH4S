#!/bin/bash

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CURRENT_WALLPAPER="$HOME/.config/hypr/.current_wallpaper"

# Function to apply wallpaper
apply_wallpaper() {
    local wallpaper=$1
    echo "$wallpaper" > "$CURRENT_WALLPAPER"
    swww img "$wallpaper" \
        --transition-fps 60 \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 2
}

# Create temporary directory for thumbnails
THUMB_DIR=$(mktemp -d)
trap 'rm -rf "$THUMB_DIR"' EXIT

# Generate thumbnails and list of wallpapers
declare -A wallpapers
while IFS= read -r img; do
    thumb="$THUMB_DIR/$(basename "$img").thumb.jpg"
    convert "$img" -thumbnail 100x100^ -gravity center -extent 100x100 "$thumb"
    wallpapers["$thumb"]="$img"
done < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \))

# Create list of thumbnails for rofi
thumbs=()
for thumb in "${!wallpapers[@]}"; do
    thumbs+=("$thumb")
done

# Show rofi menu with thumbnails
selected=$(printf '%s\n' "${thumbs[@]}" | rofi \
    -dmenu \
    -theme-str 'window {width: 800px;}' \
    -theme-str 'listview {columns: 4;}' \
    -theme-str 'element {orientation: vertical;}' \
    -show-icons \
    -icon-theme "Papirus" \
    -icon-size "100" \
    -kb-custom-1 "Alt+r" \
    -markup-rows)

# If a wallpaper was selected, apply it
if [ -n "$selected" ] && [ -f "${wallpapers[$selected]}" ]; then
    apply_wallpaper "${wallpapers[$selected]}"
fi
