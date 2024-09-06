#!/bin/bash

# Variables
INTERFACE="wlo1"
WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
DHCLIENT_LEASE_FILE="/var/lib/dhclient/dhclient.leases"

# Function to connect to Wi-Fi
connect_wifi() {
    echo "Connecting to Wi-Fi..."
    wpa_supplicant -B -i "$INTERFACE" -c "$WPA_CONF"
}

# Main script execution
connect_wifi
