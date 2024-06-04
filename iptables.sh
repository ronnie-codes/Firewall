#!/bin/sh

# Flush existing rules
iptables -F
iptables -X

# Default policy: DROP everything
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow established connections
iptables -A INPUT -i eth0 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow outbound DNS (UDP port 53)
iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT

# Enable NAT (Masquerade) on the external interface
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Log and drop all other packets
iptables -A INPUT -j LOG --log-prefix "Dropped inbound: "
iptables -A INPUT -j DROP
iptables -A OUTPUT -j LOG --log-prefix "Dropped outbound: "
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j LOG --log-prefix "Dropped forwarded: "
iptables -A FORWARD -j DROP