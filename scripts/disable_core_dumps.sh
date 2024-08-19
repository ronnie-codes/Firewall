#!/bin/bash

# === DISABLE CORE DUMPS ===

# Temporarily disable core dumps until next reboot
ulimit -c 0

# Purge old core dumps
systemd-tmpfiles --clean 2> /dev/null

# Add a line to disable core dumps in limits.conf
echo "* hard core 0" | tee -a /etc/security/limits.conf > /dev/null

# Update the coredump.conf file
echo "[Coredump]" | tee /etc/systemd/coredump.conf > /dev/null
echo "Storage=none" | tee -a /etc/systemd/coredump.conf > /dev/null
echo "ProcessSizeMax=0" | tee -a /etc/systemd/coredump.conf > /dev/null
echo "ExternalSizeMax=0" | tee -a /etc/systemd/coredump.conf > /dev/null

# Reload systemctl configs
systemctl daemon-reload

echo "Core dumps disabled"
