running=$(pidof spotify)
if [ "$running" != "" ]; then
    artist=$(playerctl metadata artist --player=spotify)
    song=$(playerctl metadata title --player=spotify| cut -c 1-60)
    echo -n "$artist - $song"
fi
