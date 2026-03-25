#!/bin/bash
niri msg -j event-stream \
  | jq --unbuffered -r '.WindowUrgencyChanged | select(. != null) | .id' \
  | xargs -I{} sh -c '
      app=$(niri msg -j windows | jq -r ".[] | select(.id == {}) | .app_id")
      [ "$app" != "spotify" ] && niri msg action focus-window --id {}
      niri msg action unset-window-urgent --id {}
    '
