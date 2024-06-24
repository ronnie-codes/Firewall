docker run -d \
    --name python_app \
    --cap-add=NET_ADMIN \
    --mount type=bind,source=/mnt/shared/pf.rules,target=/usr/src/app/pf.rules \
    --network ipvlan_network \
    --ip 192.168.68.87 \
    python_app