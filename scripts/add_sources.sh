firewall-cmd --set-default-zone=drop
firewall-cmd --zone=drop --add-source=192.168.0.0/16 --permanent
firewall-cmd --zone=drop --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=drop --add-source=172.16.0.0/12 --permanent
firewall-cmd --zone=drop --add-source=127.0.0.0/8 --permanent
firewall-cmd --zone=drop --add-source=169.254.0.0/16 --permanent
firewall-cmd --zone=drop --add-source=100.64.0.0/10 --permanent
firewall-cmd --complete-reload
