podman run -d \
	       --privileged \
	       --env IPTABLES_BACKEND=legacy \
	       --mount type=bind,source=/var/home/rvega/Developer/Firewall/config/hosts.txt,target=/usr/src/app/hosts.txt \
	       --dns 192.168.152.216 \
	       --name python_app \
	       python_app
