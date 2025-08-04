#!/bin/bash

# Get Do Not Disturb status from Mako
dnd_status=$(makoctl mode | grep "do-not-disturb" || echo "none")

# Get notification count
notification_count=$(makoctl list | jq '.data | length')

# Prepare the output
if [ "$dnd_status" = "do-not-disturb" ]; then
    if [ "$notification_count" -gt 0 ]; then
        icon="dnd-notification"
    else
        icon="dnd-none"
    fi
else
    if [ "$notification_count" -gt 0 ]; then
        icon="notification"
    else
        icon="none"
    fi
fi

# Output JSON for Waybar
echo "{\"class\": \"$icon\", \"text\": \"\", \"tooltip\": \"Notifications: $notification_count\", \"alt\": \"$icon\"}"
