#!/bin/bash

# Get the private IP address
MY_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# Get dhcp mac address
DHCP_MAC=$(ip neigh | awk '{print $5}')

firewall-cmd --permanent --direct --remove-rule ipv4 nat PREROUTING 0 -p udp --dport 60400:60420 -j DNAT --to-destination $MY_IP:60400-60420
firewall-cmd --permanent --direct --remove-rule ipv4 filter FORWARD 0 -p udp -m mac --mac-source $DHCP_MAC -m set --match-set white-list src --sport 53 -d $MY_IP --dport 60400:60420 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --remove-rule ipv4 filter FORWARD 0 -p udp -m set --match-set white-list dst -s $MY_IP --sport 60400:60420 --dport 53 -m state --state ESTABLISHED,NEW -j ACCEPT
firewall-cmd --permanent --direct --remove-rule ipv4 filter INPUT 0 -p udp -m mac --mac-source $DHCP_MAC -m set --match-set white-list src --sport 53 -d $MY_IP --dport 60400:60420 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --remove-rule ipv4 filter OUTPUT 0 -p udp -s $MY_IP --sport 60400:60420 -m set --match-set white-list dst --dport 53 -m state --state ESTABLISHED,NEW -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p udp --dport 0:65535 -j DNAT --to-destination 172.16.1.1:65535

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp -m connlimit --connlimit-above 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p udp -m connlimit --connlimit-above 0 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p udp -m connlimit --connlimit-above 0 -j DROP

firewall-cmd --reload
