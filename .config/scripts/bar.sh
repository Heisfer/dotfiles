#!/bin/bash

CONFIG_FILES="$HOME/.config/waybar/config"

trap "killall -SIGUSR2 waybar" EXIT

while true; do
    waybar &
    inotifywait -e create,modify $CONFIG_FILES
    killall -SIGUSR2 waybar

done
