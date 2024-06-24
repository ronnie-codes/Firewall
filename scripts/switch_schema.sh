
# Create the SVIs (layer 3)
interface Vlan2
ip address dhcp
no shutdown
exit

interface Vlan4
ip address dhcp
no shutdown
exit

# Create the primary VLANs (layer 2)
vlan 2
private-vlan primary
private-vlan association 3
exit

# Create the isolated VLAN
vlan 3
private-vlan isolated
exit

vlan 4
private-vlan primary
private-vlan association 5
exit

# Create the isolated VLAN
vlan 5
private-vlan isolated
exit

# Host Port in Isolated VLAN 3
interface GigabitEthernet1/0/1
switchport mode private-vlan host
switchport private-vlan host-association 2 3
no shutdown
exit

# Host Port in Isolated VLAN 5
interface GigabitEthernet1/0/10
switchport mode private-vlan host
switchport private-vlan host-association 4 5
no shutdown
exit

# Configure Trunk Port to Carry Private VLANs
interface GigabitEthernet1/0/12
switchport mode private-vlan trunk
switchport private-vlan trunk allowed vlan 2,3,4,5
switchport private-vlan mapping 2 3
switchport private-vlan mapping 4 5
switchport trunk native vlan 3
no shutdown
exit

# Promiscuous Ports (usually for router/firewall)
interface GigabitEthernet1/0/23
switchport mode private-vlan promiscuous
switchport private-vlan mapping 2 3
no shutdown
exit

interface GigabitEthernet1/0/24
switchport mode private-vlan promiscuous
switchport private-vlan mapping 4 5
no shutdown
exit
