#!/bin/bash

# Variables
INTERFACE="wlo1"
WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
DHCLIENT_LEASE_FILE="/var/lib/dhclient/dhclient.leases"

# Function to connect to Wi-Fi
connect_wifi() {
    echo "Connecting to Wi-Fi..."
    wpa_supplicant -B -i "$INTERFACE" -c "$WPA_CONF"
    dhclient "$INTERFACE"
}

# Function to close dhcp connection
close_dhcp() {
    kill -9 $(pgrep dhclient)
}

# Main script execution
connect_wifi
close_dhcp

