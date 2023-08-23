muted=$(pactl get-source-mute '@DEFAULT_SOURCE@')
if [[ "$muted" == *"yes" ]]; then
  echo -n "Muted"
fi
