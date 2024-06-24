docker network rm ipvlan_network

docker network create -d ipvlan \
    --subnet=192.168.63.0/24 \
    --gateway=192.168.63.1 \
    -o ipvlan_flag=private \
    -o parent=eth0 \
    ipvlan_network