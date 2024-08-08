podman network create -d ipvlan --subnet 172.16.1.0/30 --gateway 172.16.1.1 -o parent=wlo1.100 vlan100
