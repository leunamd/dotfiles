#!/bin/bash
fifo=$(mktemp -u)
mkfifo "$fifo"
niri msg -j event-stream > "$fifo" &
stream_pid=$!

jq --unbuffered -r '.WindowOpenedOrChanged | select(. != null) | select(.window.app_id == "ffplay") | .window.id' < "$fifo" \
  | while read -r id; do
      prev=$(niri msg -j focused-window | jq -r ".id")
      active_ws_dp3=$(niri msg -j workspaces | jq -r ".[] | select(.output == \"DP-3\" and .is_active) | .active_window_id")
      niri msg action focus-window --id "$id"
      niri msg action move-column-left
      [ -n "$active_ws_dp3" ] && niri msg action focus-window --id "$active_ws_dp3"
      [ -n "$prev" ] && niri msg action focus-window --id "$prev"
      kill "$stream_pid"
      rm "$fifo"
      break
  done

