#!/bin/bash

# Function to generate a random MAC address
# Function to generate a random MAC address using openssl
generate_random_mac() {
    # Generate the first octet with an even number in the first nibble to ensure a unicast MAC address
    first_octet=$(printf '%02X' $(( ( $(openssl rand -hex 1 | head -c 1 | tr 'abcdef' 'ABCDEF') & 0xFE) | 0x02 )))
    
    # Generate the remaining 5 octets
    remaining_octets=$(openssl rand -hex 5 | sed 's/\(..\)/\1:/g; s/:$//')

    # Combine the first octet with the remaining ones
    echo "${first_octet}:${remaining_octets}"
}

# Check if the user provided an interface name
if [ -z "$1" ]; then
    echo "Usage: $0 <network_interface>"
    exit 1
fi

INTERFACE=$1

# Generate a random MAC address
NEW_MAC=$(generate_random_mac)

# Disable the network interface
ip link set $INTERFACE down

# Set the new MAC address
ip link set $INTERFACE address $NEW_MAC

# Enable the network interface
ip link set $INTERFACE up

# Print the new MAC address
echo "The new MAC address for $INTERFACE is set."

