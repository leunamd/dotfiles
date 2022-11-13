#! /bin/sh

sleep 2 && killall trayer
trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 000000 --height 22
