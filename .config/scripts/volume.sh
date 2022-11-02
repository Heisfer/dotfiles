#!/bin/bash

# You can call this script like this:
# $./volume.sh up
# $./volume.sh down
# $./volume.sh mute
command=$1
msgTag="SysVolCng"
value=5
maxVol=100
function get_volume () {
    volume="$(amixer -D pulse get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1)"
}

function is_mute () {
    mute="$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d ":" -f 2 | sed -e 's/^[[:space:]]*//')"
}
function send_notification () {
    NID=0
    is_mute
    get_volume
    if [[ $volume == 0 || "$mute" == "yes" ]]; then
        # Show the sound muted notification
        # dunstify -a "changeVolume" -u normal -h string:x-dunst-stack-tag:$msgTag "Volume muted" 
        notify-send -a "changeVolume" -u normal -h string:x-canonical-private-synchronous:$msgTag "Volume muted"
    else
        # Show the volume notification
        get_volume
        # dunstify -a "changeVolume" -u normal -h string:x-dunst-stack-tag:$msgTag -h int:value:"$volume" "Volume: ${volume}%"
        notify-send -a "changeVolume" -u normal -h string:x-canonical-private-synchronous:$msgTag -h int:value:"$volume" "Volume: ${volume}%"
    fi
}

get_volume
is_mute
if [ $mute == "yes" ] && [ $command != "mute" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    send_notification
    exit;
fi

if [ $volume -ge 100 ] && [ $command == up ]; then
    send_notification
    exit;
fi

case $1 in
    up)
        echo $volume
        if [[ $volume -gt 95 ]]; then
	    echo "aaa"
            value=`expr $maxVol - $volume`
	    echo "werks"
            echo $value
        fi
	pactl set-sink-volume @DEFAULT_SINK@ +"$value"%
    send_notification
	;;
    down)
	pactl set-sink-volume @DEFAULT_SINK@ -"$value"%
    send_notification
	;;
    mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    send_notification
	;;
esac


