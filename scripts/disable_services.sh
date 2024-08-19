# === DISABLE SERVICES ===

# High risk and unused services/sockets
services=(
    #abrt-journal-core.service # Not found in Silverblue 38
    #abrt-oops.service # Fedora crash reporting, not in Silverblue 38
    #abrtd.service # Fedora crash reporting, not in Silverblue 38
    avahi-daemon # Recommended by CIS
    geoclue.service # Location service
    httpd # Recommended by CIS
    network-online.target # Remote file mounting, most likely unncessary
    nfs-server # Recommended by CIS
    remote-fs.target # Remote file mounting, most likely unnecessary
    rpcbind # Recommended by CIS
    rpm-ostree-countme.service # Potential to leak information about OS to someone monitoring network
    sshd # Not needed on desktop
)

# Loop through the array and stop and disable each service/socket
for service in "${services[@]}"; do
    # Check if the service exists
    if systemctl list-units --all | grep -q "^$service"; then
        # Stop the service/socket
        systemctl stop "$service"
        # Disable the service/socket
        systemctl disable "$service" > /dev/null
        # Mask service/socket
        systemctl --now mask "$service" > /dev/null
        # Reload systemd after masking
        systemctl daemon-reload
    fi
done

echo "High risk and unnecessary services disabled"

