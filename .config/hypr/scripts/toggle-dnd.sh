#!/bin/bash

# Toggle Do Not Disturb mode for Mako
if [ "$(makoctl mode | grep 'do-not-disturb')" ]; then
    makoctl mode -r do-not-disturb
    notify-send "Notifications Enabled" "Do Not Disturb mode disabled" -a "System" -i "notifications-active"
else
    makoctl mode -a do-not-disturb
    notify-send "Do Not Disturb Enabled" "Notifications will be hidden" -a "System" -i "notifications-disabled" -t 2000
fi
