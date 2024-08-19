#!/usr/bin/python3

cloak = []

with open('../config/hosts.txt', 'r') as hosts:
    for host in hosts:
        parts = host.split()
        cloak.append(parts[1] + ' ' + parts[0])
	
for host in cloak:
  print(host)
