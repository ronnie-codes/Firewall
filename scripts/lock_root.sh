#!/bin/bash

# === LOCK ROOT ===

# Uncomment the PermitRootLogin line in sshd_config, should someone ever enable it on their desktop
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config

# Lock root account
if [ "$test_mode" == true ]; then
    passwd -l root
else
    passwd -l root > /dev/null
fi
echo "Root account locked"
