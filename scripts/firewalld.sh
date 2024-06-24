#!/bin/bash

myip="192.168.1.70"

declare -a myipset

# Read from ./config/hosts
while read -r line; do
    # Use awk to skip comments and empty lines, and extract the first field
    ip=$(echo "$line" | awk '/^[^#]/ {print $1}')
    # Check if the line was not empty or a comment (ip is not empty)
    if [[ -n "$ip" ]]; then
        # Append the IP address to the array
        myipset+=("$ip")
    fi
done < ./config/hosts

# Get all zones and apply configurations to each
for zone in $(firewall-cmd --get-zones)
do
    # Enable masquerade on each zone
    firewall-cmd --permanent --zone=$zone --add-masquerade

    # Allow DNS traffic
    firewall-cmd --permanent --zone=$zone --add-rich-rule="rule family='ipv4' source address=$myip destination address='192.168.231.69' port port=53 protocol=udp accept"

    # Allow ipset outbound IPv4 traffic on port 443
    for ip in "${myipset[@]}"
    do
        firewall-cmd --permanent --zone=$zone --add-rich-rule="rule family='ipv4' direction=out destination address=$ip destination port port=443 protocol=tcp accept"
    done

    # # Allow all outbound IPv4 traffic on port 443
    # firewall-cmd --permanent --zone=$zone --add-rich-rule='rule family="ipv4" direction=out destination port port=443 protocol=tcp accept'

    # Set default policy for each zone to drop all incoming and outgoing traffic
    firewall-cmd --permanent --zone=$zone --set-target=DROP
    firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" direction=out drop'
done

# Reload Firewalld to apply changes
firewall-cmd --reload