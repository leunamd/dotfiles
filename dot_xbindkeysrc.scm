;; mute microphone
(xbindkey '(Mod4 Insert) "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
;; mute audio
(xbindkey '(Mod4 Shift Insert) "pactl set-sink-mute @DEFAULT_SINK@ toggle")
