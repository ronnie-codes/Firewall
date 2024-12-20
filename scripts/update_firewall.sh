#!/bin/bash

# Loop until the result of 'ip neigh' is non-empty
while true; do
    # Capture the output of 'ip neigh'
    ip_neigh_output=$(ip neigh | awk '{print $5}')
    mac_neigh_output=$(ip neigh | awk '{print $1}')
    ip_output=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

    # Check if the output is non-empty
    if [[ -n "$ip_neigh_output" ]]; then
      if [[ -n "$mac_neigh_output" ]]; then
        if [[ -n "$ip_output" ]]; then
          echo "ARP table is populated"
          break
        fi
      fi
    fi

    # Wait for a short period before checking again
    sleep 1
done

# Get variables
#MY_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
#DHCP_MAC=$(ip neigh | awk '{print $5}')
#DHCP_IP=$(ip neigh | awk '{print $1}')

#declare -a myipset

# Read from ./config/hosts.txt
#while read -r line; do
    # Use awk to skip comments and empty lines, and extract the first field
#    ip=$(echo "$line" | awk '/^[^#]/ {print $1}')
    # Check if the line was not empty or a comment (ip is not empty)
#    if [[ -n "$ip" ]]; then
        # Append the IP address to the array
#        myipset+=("$ip")
#    fi
#done < ../config/hosts.txt

# Remove duplicates by sorting and using awk to keep unique entries
#myipset=($(printf "%s\n" "${myipset[@]}" | sort -u))

# clear direct rules
firewall-cmd --permanent --direct --remove-rules ipv4 nat POSTROUTING
firewall-cmd --permanent --direct --remove-rules ipv4 nat PREROUTING
firewall-cmd --permanent --direct --remove-rules ipv4 filter INPUT
firewall-cmd --permanent --direct --remove-rules ipv4 filter OUTPUT
firewall-cmd --permanent --direct --remove-rules ipv4 filter FORWARD
firewall-cmd --permanent --direct --remove-rules ipv6 filter INPUT
firewall-cmd --permanent --direct --remove-rules ipv6 filter OUTPUT
firewall-cmd --permanent --direct --remove-rules ipv6 filter FORWARD

# clear ipset
#firewall-cmd --permanent --delete-ipset=white-list
#firewall-cmd --permanent --new-ipset=white-list --type=hash:ip

# IPv6 Drop Rules
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv6 filter OUTPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv6 filter FORWARD 0 -j DROP

# NAT Rules
firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o wlo1 -j MASQUERADE
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p tcp -j DNAT --to-destination 192.168.1.14:60400-60480
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p udp -j DNAT --to-destination 192.168.1.14:60400-60480

# Fragment Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -m state --state INVALID -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -m state --state INVALID -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -m state --state INVALID -j DROP

# Connection Limits
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp -m connlimit --connlimit-above 80 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p udp -m connlimit --connlimit-above 80 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p udp -m connlimit --connlimit-above 80 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m connlimit --connlimit-above 80 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp -m connlimit --connlimit-above 80 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -m connlimit --connlimit-above 80 -j DROP

# ipset entries
#cmd="firewall-cmd --permanent --ipset=white-list"

# Append each IP address as an --add-entry option
#for ip in "${myipset[@]}"; do
#    cmd+=" --add-entry=$ip"
#done

#eval $cmd

# IP Filter Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p udp -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp -m mac --mac-source bc:24:11:1c:08:99 -s 192.168.1.9 --sport 53 -d 192.168.1.14 --dport 60400:60480 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p udp -s 192.168.1.14 --sport 60400:60480 --dport 53 -d 192.168.1.9 -m state --state ESTABLISHED,NEW -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m mac --mac-source bc:24:11:1c:08:99 --sport 443 -d 192.168.1.14 --dport 60400:60480 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -s 192.168.1.14 --sport 60400:60480 --dport 443 -m state --state ESTABLISHED,NEW -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m mac --mac-source a0:ce:c8:b7:2a:17 -s 192.168.1.10 --sport 443 -d 192.168.1.14 --dport 60400:60480 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m mac --mac-source 64:62:66:22:a3:33 -s 192.168.1.12 --sport 8006 -d 192.168.1.14 --dport 60400:60480 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -s 192.168.1.14 --sport 60400:60480 -d 192.168.1.12 --dport 8006 -m state --state ESTABLISHED,NEW -j ACCEPT

# Default Drop Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -j DROP

# Reload Firewalld to apply changes
firewall-cmd --complete-reload
