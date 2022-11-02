#!/usr/bin/env bash


status=$(systemctl show -p ActiveState openvpn-client@<Your service>.service | sed 's/ActiveState=//g')

check_connection () {
  msgTag="ovpn"
	newStatus=$(systemctl show -p ActiveState openvpn-client@<Your Service>.service | sed 's/ActiveState=//g')
  if [ "$status" != "$newStatus" ]; then
    notify-send -h string:x-canonical-private-synchronous:$msgTag "Pinging google in 2sec..."
    sleep 2
    COUNTER=0
    while ! timeout 0.2 ping -c 1 -n google.com &> /dev/null
    do
      notify-send -h string:x-canonical-private-synchronous:$msgTag -A "vpn-notify" "Waiting for connection..." "Time: ${COUNTER}s" -r $NID
      let COUNTER=COUNTER+1 
      sleep 1
    done
    notify-send -h string:x-canonical-private-synchronous:$msgTag -A "vpn-notify" "Connection is up" "VPN status: ${newStatus}" -r $NID
  fi
	
}





options="Connect Work VPN
Stop VPN Connection
Restart VPN Connection"

theme=${1:-$HOME/.config/rofi/config.rasi}

selection=$(echo -e "${options}" | rofi -dmenu -config $theme -p ${status})
case "${selection}" in
  "Connect Work VPN")
    pkexec systemctl start openvpn-client@<Your Service>.service
    check_connection;;
  "Stop VPN Connection")
    pkexec systemctl stop openvpn-client@<Your Service>.service
    check_connection;;
  "Restart VPN Connection")
    pkexec systemctl restart openvpn-client@<Your Service>.service
    check_connection;;
esac
