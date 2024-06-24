#!/bin/bash

container_name="python_app"

while true; do
    # Remove the previous container if it exists
    existing_container=$(docker ps -aqf "name=${container_name}")
    if [ -n "$existing_container" ]; then
        docker rm -f "$existing_container"
    fi

    docker run -d \
            --name $container_name \
            --cap-add=NET_ADMIN \
            --mount type=bind,source=/mnt/shared/config/pf.rules,target=/usr/src/app/pf.rules \
            --ip 192.168.63.169 \
            --network ipvlan_network \
        $container_name

    # Start Docker service
    docker logs -f $container_name  # Stream logs for visibility
    docker wait $container_name     # Wait for container to exit
    exit_code=$?                    # Get container exit code

    if [[ $exit_code -eq 0 ]]; then
        echo "Python script in Docker container completed successfully."
    else
        echo "Python script in Docker container exited with error code $exit_code."
    fi
done