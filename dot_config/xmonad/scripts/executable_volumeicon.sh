#!/usr/bin/env bash
sleep 3s
pactl set-sink-mute @DEFAULT_SINK@ 0
pactl set-sink-volume @DEFAULT_SINK@ 60%
sleep 5s
mplayer ~/Music/blankaudio.mp3
volumeicon &
