#!/bin/bash

# Tighten access to console
echo "-:ALL EXCEPT (wheel):LOCAL" | tee -a /etc/security/access.conf > /dev/null

echo "Only non-remote 'wheel' group members can access the console"

