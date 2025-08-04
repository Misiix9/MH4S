#!/bin/bash

# Constants for bar visualization
BAR_LENGTH=10
CRITICAL_THRESHOLD=80
WARNING_THRESHOLD=60

# Bar characters
FILL_CHAR="▰"
EMPTY_CHAR="▱"

# Generate progress bar
generate_bar() {
    local percentage=$1
    local filled=$((percentage * BAR_LENGTH / 100))
    local empty=$((BAR_LENGTH - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="$FILL_CHAR"
    done
    for ((i=0; i<empty; i++)); do
        bar+="$EMPTY_CHAR"
    done
    
    echo "$bar"
}

# Get color based on percentage
get_color() {
    local percentage=$1
    if [ "$percentage" -ge "$CRITICAL_THRESHOLD" ]; then
        echo "#ff5555"
    elif [ "$percentage" -ge "$WARNING_THRESHOLD" ]; then
        echo "#ffbe6f"
    else
        echo "#ffffff"
    fi
}

# Get CPU usage
get_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
    local bar=$(generate_bar "$cpu_usage")
    local color=$(get_color "$cpu_usage")
    echo "{\"percentage\": $cpu_usage, \"bar\": \"$bar\", \"color\": \"$color\"}"
}

# Get RAM usage
get_ram_usage() {
    local total=$(free | grep Mem | awk '{print $2}')
    local used=$(free | grep Mem | awk '{print $3}')
    local ram_usage=$((used * 100 / total))
    local bar=$(generate_bar "$ram_usage")
    local color=$(get_color "$ram_usage")
    echo "{\"percentage\": $ram_usage, \"bar\": \"$bar\", \"color\": \"$color\"}"
}

# Get temperature
get_temperature() {
    local temp=$(sensors | grep "CPU" | awk '{print int($2)}' | tr -d "+°C")
    local bar=$(generate_bar "$temp")
    local color=$(get_color "$temp")
    echo "{\"percentage\": $temp, \"bar\": \"$bar\", \"color\": \"$color\"}"
}

# Get disk usage
get_disk_usage() {
    local disk_usage=$(df -h / | awk 'NR==2 {print int($5)}' | tr -d "%")
    local bar=$(generate_bar "$disk_usage")
    local color=$(get_color "$disk_usage")
    echo "{\"percentage\": $disk_usage, \"bar\": \"$bar\", \"color\": \"$color\"}"
}

# Get network usage
get_network_usage() {
    local interface=$(ip route | grep default | awk '{print $5}')
    local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    
    # Store previous values
    local prev_file="/tmp/network_usage"
    local prev_rx=0
    local prev_tx=0
    
    if [ -f "$prev_file" ]; then
        prev_rx=$(cat "$prev_file" | cut -d' ' -f1)
        prev_tx=$(cat "$prev_file" | cut -d' ' -f2)
    fi
    
    # Save current values
    echo "$rx_bytes $tx_bytes" > "$prev_file"
    
    # Calculate speed
    local rx_speed=$((($rx_bytes - $prev_rx) / 1024))  # KB/s
    local tx_speed=$((($tx_bytes - $prev_tx) / 1024))  # KB/s
    
    echo "{\"download\": $rx_speed, \"upload\": $tx_speed}"
}

# Main function
main() {
    # Get all metrics
    local cpu=$(get_cpu_usage)
    local ram=$(get_ram_usage)
    local temp=$(get_temperature)
    local disk=$(get_disk_usage)
    local net=$(get_network_usage)
    
    # Build tooltip
    local tooltip="CPU Usage: $(echo $cpu | jq -r '.percentage')%\n"
    tooltip+="RAM Usage: $(echo $ram | jq -r '.percentage')%\n"
    tooltip+="Temperature: $(echo $temp | jq -r '.percentage')°C\n"
    tooltip+="Disk Usage: $(echo $disk | jq -r '.percentage')%\n"
    tooltip+="Network: ↓$(echo $net | jq -r '.download')KB/s ↑$(echo $net | jq -r '.upload')KB/s"
    
    # Format output for Waybar
    local text="CPU: $(echo $cpu | jq -r '.bar')"
    
    # JSON output
    echo "{\"text\": \"$text\", \
          \"tooltip\": \"$tooltip\", \
          \"class\": \"custom-monitoring\", \
          \"cpu\": $(echo $cpu | jq -c), \
          \"ram\": $(echo $ram | jq -c), \
          \"temp\": $(echo $temp | jq -c), \
          \"disk\": $(echo $disk | jq -c), \
          \"net\": $(echo $net | jq -c)}"
}

main
