#!/bin/bash

while true; do
  ./change_mac.sh wlo1
  ./connect_wifi.sh
  ./update_firewall.sh
  sleep 120
done
