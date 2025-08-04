#!/bin/bash

# Source common functions
source ~/.config/hypr/scripts/common.sh

# Workspace configurations
declare -A WORKSPACE_CONFIGS=(
    [1]="Development:master:0.6"      # Name:Layout:Split-ratio
    [2]="Web:dwindle:0.5"
    [3]="Communication:master:0.7"
    [4]="Media:dwindle:0.5"
    [5]="Design:master:0.65"
)

# Window rules for workspaces
declare -A WORKSPACE_RULES=(
    [1]="class:^(code)$,workspace 1
class:^(kitty)$,workspace 1"
    [2]="class:^(firefox)$,workspace 2
class:^(chromium)$,workspace 2"
    [3]="class:^(discord)$,workspace 3
class:^(telegram-desktop)$,workspace 3"
    [4]="class:^(vlc)$,workspace 4
class:^(spotify)$,workspace 4"
    [5]="class:^(gimp)$,workspace 5
class:^(inkscape)$,workspace 5"
)

# Apply workspace layout
apply_workspace_layout() {
    local workspace=$1
    local config=${WORKSPACE_CONFIGS[$workspace]}
    
    if [ -n "$config" ]; then
        IFS=':' read -r name layout ratio <<< "$config"
        
        # Set workspace name
        hyprctl keyword workspace "$workspace,name:$name"
        
        # Apply layout
        hyprctl keyword workspace "$workspace,layoutopt:layout $layout"
        hyprctl keyword workspace "$workspace,layoutopt:splitratio $ratio"
        
        # Apply window rules
        local rules=${WORKSPACE_RULES[$workspace]}
        if [ -n "$rules" ]; then
            echo "$rules" | while IFS= read -r rule; do
                hyprctl keyword windowrule "$rule"
            done
        fi
        
        notify-send "Workspace $workspace" "Applied $name layout" -i window-new
    fi
}

# Initialize workspace
init_workspace() {
    local workspace=$1
    local config=${WORKSPACE_CONFIGS[$workspace]}
    
    if [ -n "$config" ]; then
        IFS=':' read -r name layout ratio <<< "$config"
        
        # Create workspace if it doesn't exist
        if ! hyprctl workspaces | grep -q "^$workspace:"; then
            hyprctl dispatch workspace "$workspace"
        fi
        
        # Apply layout
        apply_workspace_layout "$workspace"
        
        # Auto-start applications
        case $workspace in
            1)
                if ! pgrep code > /dev/null; then
                    code &
                fi
                ;;
            3)
                if ! pgrep discord > /dev/null; then
                    discord &
                fi
                ;;
            4)
                if ! pgrep spotify > /dev/null; then
                    spotify &
                fi
                ;;
        esac
    fi
}

# Show workspace menu
workspace_menu() {
    local options=()
    for workspace in "${!WORKSPACE_CONFIGS[@]}"; do
        IFS=':' read -r name layout ratio <<< "${WORKSPACE_CONFIGS[$workspace]}"
        options+=("$workspace: $name ($layout)")
    done
    
    local choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Workspace" -theme ~/.config/rofi/config.rasi)
    
    if [ -n "$choice" ]; then
        local workspace=${choice%%:*}
        hyprctl dispatch workspace "$workspace"
    fi
}

# Reset workspace layout
reset_workspace() {
    local workspace=$(hyprctl activeworkspace | grep -oP 'workspace ID \K\d+')
    apply_workspace_layout "$workspace"
}

# Workspace actions menu
workspace_actions() {
    local workspace=$(hyprctl activeworkspace | grep -oP 'workspace ID \K\d+')
    local actions=(
        "Reset Layout"
        "Toggle Master/Dwindle"
        "Adjust Split Ratio"
        "Save Layout"
        "Load Layout"
    )
    
    local choice=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "Workspace Actions" -theme ~/.config/rofi/config.rasi)
    
    case "$choice" in
        "Reset Layout")
            reset_workspace
            ;;
        "Toggle Master/Dwindle")
            local current=$(hyprctl workspaces -j | jq -r ".[] | select(.id==$workspace) | .layout")
            if [ "$current" = "master" ]; then
                hyprctl keyword workspace "$workspace,layoutopt:layout dwindle"
            else
                hyprctl keyword workspace "$workspace,layoutopt:layout master"
            fi
            ;;
        "Adjust Split Ratio")
            local ratio=$(seq 0.1 0.1 0.9 | rofi -dmenu -p "Split Ratio" -theme ~/.config/rofi/config.rasi)
            if [ -n "$ratio" ]; then
                hyprctl keyword workspace "$workspace,layoutopt:splitratio $ratio"
            fi
            ;;
        "Save Layout")
            local name=$(rofi -dmenu -p "Layout Name" -theme ~/.config/rofi/config.rasi)
            if [ -n "$name" ]; then
                mkdir -p ~/.config/hypr/workspace-layouts
                hyprctl workspaces -j > ~/.config/hypr/workspace-layouts/"$name".json
            fi
            ;;
        "Load Layout")
            local layouts=(~/.config/hypr/workspace-layouts/*.json)
            local names=()
            for layout in "${layouts[@]}"; do
                names+=($(basename "$layout" .json))
            done
            local choice=$(printf '%s\n' "${names[@]}" | rofi -dmenu -p "Select Layout" -theme ~/.config/rofi/config.rasi)
            if [ -n "$choice" ] && [ -f ~/.config/hypr/workspace-layouts/"$choice".json ]; then
                hyprctl reload ~/.config/hypr/workspace-layouts/"$choice".json
            fi
            ;;
    esac
}

# Main function
main() {
    case "$1" in
        "init")
            for workspace in "${!WORKSPACE_CONFIGS[@]}"; do
                init_workspace "$workspace"
            done
            ;;
        "menu")
            workspace_menu
            ;;
        "actions")
            workspace_actions
            ;;
        "reset")
            reset_workspace
            ;;
        *)
            echo "Usage: $0 {init|menu|actions|reset}"
            exit 1
            ;;
    esac
}

main "$@"
