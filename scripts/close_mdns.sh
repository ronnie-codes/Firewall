while true; do
    sudo kill -9 $(sudo lsof -i -n -P | grep _mdnsresponder | awk '{print $2}')
    sleep 1
done