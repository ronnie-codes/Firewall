#!/bin/sh

# Default policy: DROP everything
iptables-legacy -P INPUT DROP
iptables-legacy -P OUTPUT DROP
iptables-legacy -P FORWARD DROP

# Allow established connections
iptables-legacy -A INPUT -i eth0 -m conntrack --ctstate ESTABLISHED -d 192.168.63.169 -j ACCEPT

# Allow loopback traffic
iptables-legacy -A INPUT -i lo -j ACCEPT
iptables-legacy -A OUTPUT -o lo -j ACCEPT

# Allow outbound DNS (UDP port 53)
iptables-legacy -A OUTPUT -p udp -o eth0 -s 192.168.63.169 --dport 53 -j ACCEPT
iptables-legacy -A OUTPUT -p tcp -o eth0 -s 192.168.63.169 --dport 53 -j ACCEPT

# Log and drop all other packets
iptables-legacy -A INPUT -j LOG --log-prefix "Dropped inbound: "
iptables-legacy -A INPUT -j DROP
iptables-legacy -A OUTPUT -j LOG --log-prefix "Dropped outbound: "
iptables-legacy -A OUTPUT -j DROP
iptables-legacy -A FORWARD -j LOG --log-prefix "Dropped forwarded: "
iptables-legacy -A FORWARD -j DROP