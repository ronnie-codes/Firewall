#!/bin/bash

# Function to generate a random MAC address
generate_random_mac() {
    hexchars="0123456789ABCDEF"
    echo "02:${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}"
}

# Check if the user provided an interface name
if [ -z "$1" ]; then
    echo "Usage: $0 <network_interface>"
    exit 1
fi

INTERFACE=$1

# Generate a random MAC address
#NEW_MAC=$(generate_random_mac)
NEW_MAC=02:81:30:92:6a:0c

# Disable the network interface
sudo ip link set $INTERFACE down

# Set the new MAC address
sudo ip link set $INTERFACE address $NEW_MAC

# Enable the network interface
sudo ip link set $INTERFACE up

# Print the new MAC address
echo "The new MAC address for $INTERFACE is set."

