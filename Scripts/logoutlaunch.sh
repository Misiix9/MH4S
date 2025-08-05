#!/usr/bin/env bash

#|---/ /+-----------------------------+---/ /|#
#|--/ /-| MH4S Logout Menu Launcher  |--/ /-|#
#|-/ /--| For My Hyprland For Studying|-/ /--|#
#|/ /---+-----------------------------+/ /---|#

# Get script directory
scrDir="$(dirname "$(realpath "$0")")"

# Source global functions
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

# Define the menu options with MH4S theme (black/white)
menu_options="󰍁  Lock|󰍃  Logout|󰏦  Suspend|󰒲  Hibernate|󰚦  Shutdown"

# Use rofi to display the logout menu with MH4S styling
chosen=$(echo -e "${menu_options}" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/theme.rasi)

# Handle the chosen option
case "${chosen}" in
    "󰍁  Lock")
        hyprlock
        ;;
    "󰍃  Logout")
        hyprctl dispatch exit 0
        ;;
    "󰏦  Suspend")
        systemctl suspend
        ;;
    "󰒲  Hibernate")
        systemctl hibernate
        ;;
    "󰚦  Shutdown")
        systemctl poweroff
        ;;
    *)
        # No option selected or menu cancelled
        exit 0
        ;;
esac
