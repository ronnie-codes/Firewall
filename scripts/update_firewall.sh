#!/bin/bash

# Get the private IP address
MY_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# Get dhcp mac address
DHCP_MAC=$(ip neigh | awk '{print $5}')

declare -a myipset

# Read from ./config/hosts.txt
while read -r line; do
    # Use awk to skip comments and empty lines, and extract the first field
    ip=$(echo "$line" | awk '/^[^#]/ {print $1}')
    # Check if the line was not empty or a comment (ip is not empty)
    if [[ -n "$ip" ]]; then
        # Append the IP address to the array
        myipset+=("$ip")
    fi
done < ../config/hosts.txt

# Remove duplicates by sorting and using awk to keep unique entries
myipset=($(printf "%s\n" "${myipset[@]}" | sort -u))

# clear direct rules
./clear_direct_rules.sh

# clear ipset
./clear_ipset.sh

firewall-cmd --lockdown-off
firewall-cmd --reload

# IPv6 Drop Rules
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv6 filter OUTPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv6 filter FORWARD 0 -j DROP

# NAT Rules
firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o wlo1 -j MASQUERADE
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p tcp --dport 0:65535 -j DNAT --to-destination $MY_IP:60400-60420
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p udp --dport 0:65535 -j DNAT --to-destination 192.168.1.100:65535

# Fragment Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -m state --state INVALID -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -m state --state INVALID -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -m state --state INVALID -j DROP

# Connection Limits
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m connlimit --connlimit-above 20 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -m connlimit --connlimit-above 20 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp -m connlimit --connlimit-above 20 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp -m connlimit --connlimit-above 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p udp -m connlimit --connlimit-above 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p udp -m connlimit --connlimit-above 0 -j DROP

# ipset entries
cmd="firewall-cmd --permanent --ipset=white-list"

# Append each IP address as an --add-entry option
for ip in "${myipset[@]}"; do
    cmd+=" --add-entry=$ip"
done

eval $cmd

# IP Filter Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i wlo1 -o wlo1 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp -m mac --mac-source $DHCP_MAC -m set --match-set white-list src --sport 443 -d $MY_IP --dport 60400:60420 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp -m set --match-set white-list dst -s $MY_IP --sport 60400:60420 --dport 443 -m state --state ESTABLISHED,NEW -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m mac --mac-source $DHCP_MAC -m set --match-set white-list src --sport 443 -d $MY_IP --dport 60400:60420 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -s $MY_IP --sport 60400:60420 -m set --match-set white-list dst --dport 443 -m state --state ESTABLISHED,NEW -j ACCEPT

# Default Drop Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -j DROP

firewall-cmd --lockdown-on

# Reload Firewalld to apply changes
firewall-cmd --complete-reload
