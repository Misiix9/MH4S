#!/bin/bash

# Configuration
UPDATE_INTERVAL=2
NOTIFICATION_TIME=5000
TEMP_WARNING=70
CPU_WARNING=80
MEM_WARNING=80
DISK_WARNING=90

# Function to show notification
show_notification() {
    local title=$1
    local message=$2
    local urgency=${3:-"normal"}
    local icon="system-monitor"
    
    notify-send -t $NOTIFICATION_TIME \
        -u "$urgency" \
        -h string:x-canonical-private-synchronous:resource-monitor \
        "$title" "$message" -i "$icon"
}

# Function to get CPU usage and temperature
get_cpu_info() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}')
    local cpu_temp=$(sensors | grep "Core 0" | awk '{print int($3)}' | tr -d '+°C')
    echo "$cpu_usage $cpu_temp"
}

# Function to get memory usage
get_memory_info() {
    free -m | awk 'NR==2{printf "%.1f %.1f", $3/1024, $2/1024}'
}

# Function to get disk usage
get_disk_info() {
    df -h / | awk 'NR==2{printf "%s %s %s", $5, $3, $2}' | tr -d '%'
}

# Function to get network usage
get_network_info() {
    local interface=$(ip route | grep default | awk '{print $5}')
    local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    echo "$rx_bytes $tx_bytes"
}

# Function to format network speed
format_speed() {
    local bytes=$1
    if [ $bytes -gt 1073741824 ]; then
        echo "$(printf "%.1f" $((bytes/1073741824)))GB/s"
    elif [ $bytes -gt 1048576 ]; then
        echo "$(printf "%.1f" $((bytes/1048576)))MB/s"
    elif [ $bytes -gt 1024 ]; then
        echo "$(printf "%.1f" $((bytes/1024)))KB/s"
    else
        echo "${bytes}B/s"
    fi
}

# Function to check resource usage and show warnings
check_resources() {
    # Get CPU info
    read cpu_usage cpu_temp <<< "$(get_cpu_info)"
    
    # Get memory info
    read mem_used mem_total <<< "$(get_memory_info)"
    mem_percent=$(awk "BEGIN {printf \"%.0f\", $mem_used/$mem_total*100}")
    
    # Get disk info
    read disk_percent disk_used disk_total <<< "$(get_disk_info)"
    
    # Show warnings if thresholds are exceeded
    if [ $cpu_temp -ge $TEMP_WARNING ]; then
        show_notification "High CPU Temperature" "Temperature: ${cpu_temp}°C" "critical"
    fi
    
    if [ $cpu_usage -ge $CPU_WARNING ]; then
        show_notification "High CPU Usage" "Usage: ${cpu_usage}%" "critical"
    fi
    
    if [ $mem_percent -ge $MEM_WARNING ]; then
        show_notification "High Memory Usage" "Usage: ${mem_percent}%" "critical"
    fi
    
    if [ $disk_percent -ge $DISK_WARNING ]; then
        show_notification "Low Disk Space" "Used: ${disk_percent}%" "critical"
    fi
}

# Function to show performance menu
show_menu() {
    # Get system information
    read cpu_usage cpu_temp <<< "$(get_cpu_info)"
    read mem_used mem_total <<< "$(get_memory_info)"
    read disk_percent disk_used disk_total <<< "$(get_disk_info)"
    
    local options="System Performance\n"
    options+="┌──────────────────────┐\n"
    options+="│ 💻 CPU: ${cpu_usage}% (${cpu_temp}°C)  │\n"
    options+="│ 🧠 RAM: ${mem_used}/${mem_total}GB    │\n"
    options+="│ 💾 Disk: ${disk_used}/${disk_total}   │\n"
    options+="├──────────────────────┤\n"
    options+="│ 📊 Show Monitor      │\n"
    options+="│ ⚡ CPU Boost         │\n"
    options+="│ 🧹 Clear Memory      │\n"
    options+="│ 🔧 System Tuning     │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Performance Manager" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Show Monitor"*) show_monitor ;;
        *"CPU Boost"*) show_cpu_menu ;;
        *"Clear Memory"*) clear_memory ;;
        *"System Tuning"*) show_tuning_menu ;;
    esac
}

# Function to show live monitor
show_monitor() {
    local prev_rx=0
    local prev_tx=0
    
    while true; do
        # Get updated info
        read cpu_usage cpu_temp <<< "$(get_cpu_info)"
        read mem_used mem_total <<< "$(get_memory_info)"
        read disk_percent disk_used disk_total <<< "$(get_disk_info)"
        read rx_bytes tx_bytes <<< "$(get_network_info)"
        
        # Calculate network speed
        local rx_speed=$((($rx_bytes - $prev_rx) / $UPDATE_INTERVAL))
        local tx_speed=$((($tx_bytes - $prev_tx) / $UPDATE_INTERVAL))
        prev_rx=$rx_bytes
        prev_tx=$tx_bytes
        
        # Format output
        clear
        echo "System Resource Monitor"
        echo "───────────────────────"
        echo "CPU Usage: ${cpu_usage}%"
        echo "CPU Temperature: ${cpu_temp}°C"
        echo "Memory: ${mem_used}GB / ${mem_total}GB"
        echo "Disk: ${disk_used} / ${disk_total} (${disk_percent}%)"
        echo "Network ↓ $(format_speed $rx_speed)"
        echo "Network ↑ $(format_speed $tx_speed)"
        echo "───────────────────────"
        echo "Press Ctrl+C to exit"
        
        sleep $UPDATE_INTERVAL
    done
}

# Function to show CPU performance menu
show_cpu_menu() {
    local options="CPU Performance\n"
    options+="┌──────────────────────┐\n"
    options+="│ ⚡ Performance Mode   │\n"
    options+="│ 🔋 Power Save        │\n"
    options+="│ ⚖️  Balanced         │\n"
    options+="│ 🎮 Gaming Mode       │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "CPU Performance" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Performance"*)
            cpupower frequency-set -g performance
            show_notification "CPU Mode" "Set to Performance Mode" ;;
        *"Power Save"*)
            cpupower frequency-set -g powersave
            show_notification "CPU Mode" "Set to Power Save Mode" ;;
        *"Balanced"*)
            cpupower frequency-set -g ondemand
            show_notification "CPU Mode" "Set to Balanced Mode" ;;
        *"Gaming"*)
            cpupower frequency-set -g performance
            echo 0 | sudo tee /proc/sys/kernel/nmi_watchdog >/dev/null
            show_notification "CPU Mode" "Set to Gaming Mode" ;;
    esac
}

# Function to clear memory
clear_memory() {
    local options="Memory Cleanup\n"
    options+="┌──────────────────────┐\n"
    options+="│ 🧹 Clear Cache       │\n"
    options+="│ 🗑️  Clear Swap        │\n"
    options+="│ 💫 Clear All         │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Memory Cleanup" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Clear Cache"*)
            sudo sh -c 'sync; echo 1 > /proc/sys/vm/drop_caches'
            show_notification "Memory" "Cache Cleared" ;;
        *"Clear Swap"*)
            sudo sh -c 'swapoff -a && swapon -a'
            show_notification "Memory" "Swap Cleared" ;;
        *"Clear All"*)
            sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
            sudo sh -c 'swapoff -a && swapon -a'
            show_notification "Memory" "All Caches Cleared" ;;
    esac
}

# Function to show system tuning menu
show_tuning_menu() {
    local options="System Tuning\n"
    options+="┌──────────────────────┐\n"
    options+="│ 🎯 IO Priority       │\n"
    options+="│ 🔄 Process Nice      │\n"
    options+="│ 💻 CPU Governor      │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "System Tuning" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"IO Priority"*)
            show_io_menu ;;
        *"Process Nice"*)
            show_nice_menu ;;
        *"CPU Governor"*)
            show_governor_menu ;;
    esac
}

# Function to show IO priority menu
show_io_menu() {
    local options="IO Priority\n"
    options+="┌──────────────────────┐\n"
    options+="│ ⚡ Real-time         │\n"
    options+="│ 🎮 Best-effort       │\n"
    options+="│ 🔋 Idle              │\n"
    options+="└──────────────────────┘"
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "IO Priority" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Real-time"*)
            ionice -c 1 -n 0 -p $$
            show_notification "IO Priority" "Set to Real-time" ;;
        *"Best-effort"*)
            ionice -c 2 -n 0 -p $$
            show_notification "IO Priority" "Set to Best-effort" ;;
        *"Idle"*)
            ionice -c 3 -p $$
            show_notification "IO Priority" "Set to Idle" ;;
    esac
}

# Function to output Waybar format
output_waybar() {
    # Get system information
    read cpu_usage cpu_temp <<< "$(get_cpu_info)"
    read mem_used mem_total <<< "$(get_memory_info)"
    mem_percent=$(awk "BEGIN {printf \"%.0f\", $mem_used/$mem_total*100}")
    
    # Determine class based on resource usage
    local class="normal"
    if [ $cpu_usage -ge $CPU_WARNING ] || [ $cpu_temp -ge $TEMP_WARNING ] || [ $mem_percent -ge $MEM_WARNING ]; then
        class="warning"
    fi
    
    # Create JSON output
    echo "{\"text\": \"💻 ${cpu_usage}% 🌡️ ${cpu_temp}°C 🧠 ${mem_percent}%\", \"tooltip\": \"CPU Usage: ${cpu_usage}%\nCPU Temp: ${cpu_temp}°C\nRAM Usage: ${mem_percent}%\", \"class\": \"$class\"}"
}

# Initialize monitoring
init() {
    # Start background monitoring
    while true; do
        check_resources
        sleep $UPDATE_INTERVAL
    done &
}

# Main script
case "$1" in
    "menu") show_menu ;;
    "monitor") show_monitor ;;
    "cpu") show_cpu_menu ;;
    "memory") clear_memory ;;
    "tune") show_tuning_menu ;;
    "check") check_resources ;;
    "waybar") output_waybar ;;
    "init") init ;;
    *) echo "Usage: $0 {menu|monitor|cpu|memory|tune|check|waybar|init}" ;;
esac
