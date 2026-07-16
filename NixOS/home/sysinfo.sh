#!/usr/bin/env bash

# Waybar system information module
# Outputs JSON

set -o pipefail

# -------------------------
# Helpers
# -------------------------

json_escape() {
    printf '%s' "$1" | sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e ':a;N;$!ba;s/\n/\\n/g'
}


# -------------------------
# CPU
# -------------------------

get_cpu() {
    read cpu user nice system idle iowait irq softirq steal guest guest_nice \
        < /proc/stat

    total=$((user+nice+system+idle+iowait+irq+softirq+steal))
    used=$((total-idle-iowait))

    if [ "$total" -gt 0 ]; then
        echo $((used*100/total))
    else
        echo 0
    fi
}

# -------------------------
# RAM (fraction: used/total in GB)
# -------------------------

get_ram() {
    awk '
    /MemTotal/ {total=$2}
    /MemAvailable/ {avail=$2}
    END {
        used = (total - avail) / 1024 / 1024
        total_gb = total / 1024 / 1024
        printf "%.1f/%.1f", used, total_gb
    }' /proc/meminfo
}

# -------------------------
# Temperature
# -------------------------

get_temp() {

    temp=""

    for f in /sys/class/thermal/thermal_zone*/temp; do

        [ -f "$f" ] || continue

        value=$(cat "$f" 2>/dev/null)

        if [ "$value" -gt 1000 ]; then
            temp=$((value/1000))
            break
        fi
    done


    if [ -n "$temp" ]; then
        echo "${temp}°C"
    else
        echo "N/A"
    fi
}


# -------------------------
# Network
# -------------------------

get_network() {

    interface=$(ip route | awk '/default/ {print $5; exit}')

    if [ -z "$interface" ]; then
        echo "offline"
        return
    fi


    rx=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    tx=$(cat /sys/class/net/$interface/statistics/tx_bytes)


    rx=$((rx/1024))
    tx=$((tx/1024))


    echo "↓${rx}KiB ↑${tx}KiB"
}

# -------------------------
# Collect
# -------------------------

cpu=$(get_cpu)
ram=$(get_ram)
temp=$(get_temp)
net=$(get_network)


text=" ${cpu}%   ${ram}GB  ${net}"

[ -n "$temp" ] && \
    text+="  ${temp}"


tooltip=$(cat <<EOF
CPU: ${cpu}%
RAM: ${ram} GB
Temperature: ${temp}
Network: ${net}
EOF
)


# -------------------------
# JSON output
# -------------------------

jq -n -c \
    --arg text "$text" \
    --arg tooltip "$tooltip" \
    '{
        text:$text,
        tooltip:$tooltip,
        class:"normal"
    }'
