#! /usr/local/bin/python3

with open('hosts') as input:
    with open('hosts.txt', 'w') as output:
        for line in input:
            words = line.split()
            output.write(f"{words[1]}\n")
