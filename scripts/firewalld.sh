#!/bin/sh

# Get all zones and apply configurations to each
for zone in $(firewall-cmd --get-zones)
do
    # Enable masquerade on each zone
    firewall-cmd --permanent --zone=$zone --add-masquerade

    # Allow all outbound IPv4 traffic on port 443
    firewall-cmd --permanent --zone=$zone --add-rich-rule='rule family="ipv4" direction=out destination port port=443 protocol=tcp accept'

    # Set default policy for each zone to drop all incoming and outgoing traffic
    firewall-cmd --permanent --zone=$zone --set-target=DROP
    firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" direction=out drop'
done

# Reload Firewalld to apply changes
firewall-cmd --reload


# Allow DNS traffic
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.231.168" destination address="192.168.231.69" port port=53 protocol=udp accept'

# # Allow outgoing HTTPs to specific sites (example for VMware)
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.231.168" destination address="vmware.com" port port=443 protocol=tcp accept'

# Block all outgoing traffic in the public zone
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" direction=out drop'