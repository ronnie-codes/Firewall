#!/bin/bash

INTERFACE="wlo1"

open_dhcp() {
    dhclient "$INTERFACE"
}

# Function to close dhcp connection
close_dhcp() {
    kill -9 $(pgrep dhclient)
}

# Main script execution
open_dhcp
sleep 1
close_dhcp
