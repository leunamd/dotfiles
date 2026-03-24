#!/bin/bash

declare -A sender_inhibits
current_sender=""

dbus-monitor --session \
  "type='method_call',interface='org.freedesktop.ScreenSaver'" \
  "type='signal',interface='org.freedesktop.DBus',member='NameOwnerChanged'" \
  2>/dev/null | \
while read -r line; do
  # Capture sender from header lines
  if echo "$line" | grep -q "member="; then
    current_sender=$(echo "$line" | grep -oP 'sender=\K\S+')
  fi

  get_total() {
    local total=0
    for v in "${sender_inhibits[@]}"; do total=$((total + v)); done
    echo $total
  }

  if echo "$line" | grep -q "member=Inhibit$"; then
    sender_inhibits[$current_sender]=$(( ${sender_inhibits[$current_sender]:-0} + 1 ))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Idle inhibitor registered | Inhibit locks: $(get_total)" >> ~/swayidle.log

  elif echo "$line" | grep -q "member=UnInhibit"; then
    if [ -n "${sender_inhibits[$current_sender]}" ]; then
      sender_inhibits[$current_sender]=$(( sender_inhibits[$current_sender] > 0 ? sender_inhibits[$current_sender] - 1 : 0 ))
      [ "${sender_inhibits[$current_sender]}" -eq 0 ] && unset sender_inhibits[$current_sender]
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Idle inhibitor released | Inhibit locks: $(get_total)" >> ~/swayidle.log

  elif echo "$line" | grep -q "member=NameOwnerChanged"; then
    read -r next_line
    old_owner=$(echo "$next_line" | grep -oP 'string "\K[^"]+')
    if [ -n "${sender_inhibits[$old_owner]}" ]; then
      unset sender_inhibits[$old_owner]
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Idle inhibitor auto-released (app closed) | Inhibit locks: $(get_total)" >> ~/swayidle.log
    fi
  fi
done
