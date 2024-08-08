#!/bin/bash

while true; do
  ./change_mac.sh wlo1
  ./connect_wifi.sh
  ./open_close_dhcp.sh
  sleep 10
  ./update_firewall.sh
  sleep 30
done
