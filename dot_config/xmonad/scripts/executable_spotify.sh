running=$(pidof spotify)
if [ "$running" != "" ]; then
    status=$(playerctl status --player=spotify)
    if [ "$status" == "Playing" ]; then
      artist=$(playerctl metadata artist --player=spotify)
      song=$(playerctl metadata title --player=spotify| cut -c 1-60)
      echo -n "$artist - $song"
    fi
fi
