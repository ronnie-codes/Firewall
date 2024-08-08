#!/bin/bash

MY_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# Get dhcp mac address
DNS_IP=$(cat /etc/resolv.conf | awk '{print $2}')

# Default policy: DROP everything
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Limit the number of connections
iptables -A INPUT -p tcp -m connlimit --connlimit-above 0 -j DROP
iptables -A OUTPUT -p tcp -m connlimit --connlimit-above 0 -j DROP
iptables -A FORWARD -p tcp -m connlimit --connlimit-above 0 -j DROP

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Masquerade outbound traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A PREROUTING -i eth0 -j DNAT --to-destination $MY_IP

# Allow inbound traffic to a specific service (e.g., DNS on port 53)
iptables -A FORWARD -i eth0 -o eth0 -p udp --sport 53 -d $MY_IP -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth0 -p udp -s $MY_IP -d $DNS_IP --dport 53 -m state --state ESTABLISHED,NEW -j ACCEPT

# Allow established connections
iptables -A INPUT -p udp -i eth0 -s $DNS_IP --sport 53 -d $MY_IP -m state --state ESTABLISHED -j ACCEPT

# Allow outbound DNS (UDP port 53)
iptables -A OUTPUT -p udp -o eth0 -s $MY_IP -d $DNS_IP --dport 53 -m state --state ESTABLISHED,NEW -j ACCEPT

# Log and drop all other packets
iptables -A INPUT -j LOG --log-prefix "Dropped inbound: "
iptables -A INPUT -j DROP
iptables -A OUTPUT -j LOG --log-prefix "Dropped outbound: "
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j LOG --log-prefix "Dropped forwarded: "
iptables -A FORWARD -j DROP
