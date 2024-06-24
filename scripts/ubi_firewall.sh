# Set default zone to drop
firewall-cmd --set-default-zone=drop

# Ensure loopback is allowed
firewall-cmd --zone=trusted --change-interface=lo

# Allow established connections
firewall-cmd --zone=drop --add-rich-rule='rule family="ipv4" source address="192.168.63.169" protocol value="all" accept ctstate ESTABLISHED'

# Allow UDP DNS
firewall-cmd --zone=drop --add-rich-rule='rule family="ipv4" source address="192.168.63.169" protocol value="udp" destination-port port=53 accept'

# Allow TCP DNS
firewall-cmd --zone=drop --add-rich-rule='rule family="ipv4" source address="192.168.63.169" protocol value="tcp" destination-port port=53 accept'

# Drop all other outbound IPv4 traffic
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" direction=out drop'

firewall-cmd --reload
firewall-cmd --runtime-to-permanent