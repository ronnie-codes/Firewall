#!/bin/bash

# Network Offloading:
# Some network cards have hardware offloading features that bypass iptables. Disable these features if necessary.

sudo ethtool -K wlo1 gro off
sudo ethtool -K wlo1 gso off
sudo ethtool -K wlo1 tso off
