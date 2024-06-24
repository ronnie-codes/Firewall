#!/bin/sh

# TODO: Explore not flushing existing boot2docker ruleset

# Flush existing rules
iptables -F -v
iptables -X -v
iptables -t nat -F -v
iptables -t nat -X -v

# nat
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination 192.168.63.169:53 # I'm not even sure that this completely makes sense
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Default policy: DROP everything
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow established connections
iptables -A INPUT -i eth0 -m conntrack --ctstate ESTABLISHED -d 192.168.63.169 -j ACCEPT

# Allow outbound DNS (UDP port 53)
iptables -A OUTPUT -p udp -o eth0 -s 192.168.63.169 --dport 53 -j ACCEPT

# Log and drop all other packets
iptables -A INPUT -j LOG --log-prefix "Dropped inbound: "
iptables -A INPUT -j DROP
iptables -A OUTPUT -j LOG --log-prefix "Dropped outbound: "
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j LOG --log-prefix "Dropped forwarded: "
iptables -A FORWARD -j DROP