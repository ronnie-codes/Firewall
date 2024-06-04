#!/bin/bash

while true; do
    dscacheutil -flushcache; killall -HUP mDNSResponder

    # Start Docker Compose services in detached mode
    docker compose up -d

    # Wait for Python script to finish 
    container_name=$(docker ps -aqf "name=python_app")  # Get container ID

    docker logs -f "$container_name"  # Optionally, stream logs for visibility
    docker wait "$container_name"     # Wait for container to exit
    exit_code=$?                      # Get container exit code

    if [[ $exit_code -eq 0 ]]; then
        echo "Python script in Docker container completed successfully."
    else
        echo "Python script in Docker container exited with error code $exit_code."
    fi

    # Load PF rules (after container finishes)
    pfctl -f pf.rules

    sleep 1
done
