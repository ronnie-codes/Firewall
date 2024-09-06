
# Create the SVIs (layer 3)
interface Vlan1
ip address dhcp
no shutdown
exit

# Create the primary VLANs (layer 2)
vlan 1
private-vlan primary
private-vlan association 2
exit

# Create the isolated VLAN
vlan 2
private-vlan isolated
exit

# Host Port in Isolated VLAN 3
interface GigabitEthernet1/0/4
switchport mode private-vlan host
switchport private-vlan host-association 1 2
no shutdown
exit

interface GigabitEthernet1/0/10
switchport mode private-vlan host
switchport private-vlan host-association 1 2
no shutdown
exit

# Configure Trunk Port to Carry Private VLANs
#interface GigabitEthernet1/0/12
#switchport mode private-vlan trunk
#switchport private-vlan trunk allowed vlan 2,3,4,5
#switchport private-vlan mapping 2 3
#switchport private-vlan mapping 4 5
#switchport trunk native vlan 3
#no shutdown
#exit

# Promiscuous Ports (usually for router/firewall)
interface GigabitEthernet1/0/8
switchport mode private-vlan promiscuous
switchport private-vlan mapping 1 2
no shutdown
exit
