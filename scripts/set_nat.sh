#!/bin/bash

firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o wlo1 -j MASQUERADE
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p tcp --dport 0:65535 -j DNAT --to-destination $MY_IP:60400-60420
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 -p udp --dport 0:65535 -j DNAT --to-destination $MY_IP:60400-60420
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp --sport 443 -d $MY_IP --dport 60400:60420 -m state --state ESTABLISHED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -p tcp -s $MY_IP --sport 60400:60420 --dport 443 -m state --state ESTABLISHED,NEW -j ACCEPT
