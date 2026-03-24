#!/bin/bash

# Detect compositor
if [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
    LOG=~/swayidle.log
elif [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    LOG=~/hypridle.log
else
    echo "{\"text\": \"⚫\", \"class\": \"unknown\", \"tooltip\": \"Unknown compositor\"}"
    exit 0
fi

last_value=$(grep "Inhibit locks:" "$LOG" | tail -n 1 | awk '{print $NF}')

if [ -z "$last_value" ]; then
    echo "{\"text\": \"⚫\", \"class\": \"unknown\", \"tooltip\": \"No data\"}"
    exit 0
fi

if [ "$last_value" -eq 0 ]; then
    echo "{\"text\": \"⚫\", \"class\": \"sleep\", \"tooltip\": \"Screen can sleep\"}"
else
    echo "{\"text\": \"🔴\", \"class\": \"awake\", \"tooltip\": \"Screen prevented from sleeping\"}"
fi
