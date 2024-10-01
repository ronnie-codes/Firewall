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
MY_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
DHCP_MAC=$(ip neigh | awk '{print $5}')
DHCP_IP=$(ip neigh | awk '{print $1}')

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
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p tcp -j DNAT --to-destination $MY_IP:60400-60420
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p udp -j DNAT --to-destination $MY_IP:60400-60420

# Fragment Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -m state --state INVALID -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -m state --state INVALID -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -m state --state INVALID -j DROP

# Connection Limits
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp -m connlimit --connlimit-above 40 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p udp -m connlimit --connlimit-above 40 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p udp -m connlimit --connlimit-above 40 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m connlimit --connlimit-above 20 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp -m connlimit --connlimit-above 20 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -m connlimit --connlimit-above 20 -j DROP

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
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp -m mac --mac-source $DHCP_MAC -s $DHCP_IP --sport 53 -d $MY_IP --dport 60400:60420 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p udp -s $MY_IP --sport 60400:60420 --dport 53 -d $DHCP_IP -m state --state ESTABLISHED,NEW -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -m mac --mac-source $DHCP_MAC --sport 443 -d $MY_IP --dport 60400:60420 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -s $MY_IP --sport 60400:60420 --dport 443 -m state --state ESTABLISHED,NEW -j ACCEPT

# Default Drop Rules
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -j DROP

# Reload Firewalld to apply changes
firewall-cmd --complete-reload
