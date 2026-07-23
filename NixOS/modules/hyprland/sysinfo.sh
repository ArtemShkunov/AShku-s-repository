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

    cache="${XDG_RUNTIME_DIR:-/tmp}/sysinfo_cpu"

    read cpu user nice system idle iowait irq softirq steal guest guest_nice \
        < /proc/stat


    total=$((user+nice+system+idle+iowait+irq+softirq+steal))
    idle_total=$((idle+iowait))


    # Первый запуск
    if [ ! -f "$cache" ]; then
        echo "$total $idle_total" > "$cache"
        echo "0"
        return
    fi


    read old_total old_idle < "$cache"


    echo "$total $idle_total" > "$cache"


    total_diff=$((total-old_total))
    idle_diff=$((idle_total-old_idle))


    if [ "$total_diff" -eq 0 ]; then
        echo "0"
        return
    fi


    usage=$(( (total_diff-idle_diff)*100/total_diff ))


    echo "$usage"
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

    cache="/tmp/sysinfo_net"

    now=$(date +%s)


    # Первый запуск
    if [ ! -f "$cache" ]; then
        echo "$rx $tx $now" > "$cache"
        echo "↓0B/s ↑0B/s"
        return
    fi


    read old_rx old_tx old_time < "$cache"


    echo "$rx $tx $now" > "$cache"


    delta_time=$((now-old_time))


    # Защита от деления на 0
    if [ "$delta_time" -le 0 ]; then
        echo "↓0B/s ↑0B/s"
        return
    fi


    rx_speed=$(( (rx-old_rx) / delta_time ))
    tx_speed=$(( (tx-old_tx) / delta_time ))


    human_size() {
        local bytes=$1

        if [ "$bytes" -ge 1048576 ]; then
            awk "BEGIN {printf \"%.1fMB/s\", $bytes/1048576}"
        elif [ "$bytes" -ge 1024 ]; then
            awk "BEGIN {printf \"%.1fKB/s\", $bytes/1024}"
        else
            echo "${bytes}B/s"
        fi
    }


    echo "↓$(human_size "$rx_speed") ↑$(human_size "$tx_speed")"
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
