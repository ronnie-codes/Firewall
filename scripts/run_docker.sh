#!/bin/bash

container_name="python_app"

DNS_IP=$(ip route | awk '/default/ {print $3}')

# Remove the previous container if it exists
existing_container=$(podman ps -aqf "name=${container_name}")
if [ -n "$existing_container" ]; then
	podman rm -f "$existing_container"
fi

podman run -d \
    --privileged \
    --read-only \
    --mount type=bind,source=/var/home/rvega/Developer/Firewall/config/hosts.txt,target=/usr/src/app/hosts.txt \
    --dns $DNS_IP  \
    --name $container_name \
    $container_name

# Start Docker service
podman logs -f $container_name  # Stream logs for visibility
podman wait $container_name     # Wait for container to exit
exit_code=$?                    # Get container exit code

if [[ $exit_code -eq 0 ]]; then
	echo "Python script in Docker container completed successfully."
	bash sync_hosts.sh
else
	echo "Python script in Docker container exited with error code $exit_code."
fi

podman rm -f $container_name
