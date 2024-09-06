#!/bin/bash

while true; do
  bash ./change_mac.sh wlo1
  bash ./open_close_dhcp.sh
  sleep 2
  bash ./update_firewall.sh
  sleep 120
done
